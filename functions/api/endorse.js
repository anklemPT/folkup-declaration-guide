// CF Pages Function — declaration.folkup.app/api/endorse
// Receives Manifesto endorsement POST, forwards notification email via Brevo API.
// Env binding required: BREVO_API_KEY (set via `wrangler pages secret put`)
// Sender: declaration@folkup.app (DKIM/SPF verified per Posthorn config)
// Recipient: anklemqq@gmail.com (Andrey — Manifesto endorsement notification)
//
// History: original form POST'd to /api/endorse expecting VPS Postgres backend.
// INC-006 killed CX33 VPS 2026-06-02. Backend never migrated. Form silent-failed
// 2 months. Cont+48 rebuild per Andrey verdict (a) 2026-08-04: CF Pages Function
// + Brevo Transactional API replaces Postgres. No DB — email notification only.

const ALLOWED_LANGS = ['ru', 'en', 'pt'];
const MAX_NAME_LEN = 200;
const MAX_STATEMENT_LEN = 2000;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json',
      'access-control-allow-origin': 'https://declaration.folkup.app',
      'access-control-allow-methods': 'POST, OPTIONS',
      'access-control-allow-headers': 'content-type',
    },
  });
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export async function onRequestOptions() {
  return jsonResponse({}, 204);
}

export async function onRequestPost({ request, env }) {
  let data;
  try {
    data = await request.json();
  } catch {
    return jsonResponse({ success: false, error: 'invalid_json' }, 400);
  }

  const name = (data.name || '').trim();
  const email = (data.email || '').trim();
  const statement = (data.statement || '').trim();
  const lang = ALLOWED_LANGS.includes(data.lang) ? data.lang : 'en';

  if (!name || name.length < 2 || name.length > MAX_NAME_LEN) {
    return jsonResponse({ success: false, error: 'invalid_name' }, 400);
  }
  if (!email || !EMAIL_RE.test(email) || email.length > 200) {
    return jsonResponse({ success: false, error: 'invalid_email' }, 400);
  }
  if (statement.length > MAX_STATEMENT_LEN) {
    return jsonResponse({ success: false, error: 'statement_too_long' }, 400);
  }

  if (!env.BREVO_API_KEY) {
    return jsonResponse({ success: false, error: 'backend_not_configured' }, 500);
  }

  const ip = request.headers.get('cf-connecting-ip') || 'unknown';
  const country = request.headers.get('cf-ipcountry') || 'unknown';
  const userAgent = request.headers.get('user-agent') || 'unknown';
  const timestamp = new Date().toISOString();

  const subject = `FolkUp Declaration endorsement — ${name}`;
  const htmlBody = `<!DOCTYPE html><html><body style="font-family:system-ui,sans-serif;max-width:640px;margin:0 auto;padding:20px;">
<h2>New Manifesto endorsement</h2>
<table cellpadding="6" style="border-collapse:collapse;width:100%;">
<tr><td><strong>Name:</strong></td><td>${escapeHtml(name)}</td></tr>
<tr><td><strong>Email:</strong></td><td>${escapeHtml(email)}</td></tr>
<tr><td><strong>Language:</strong></td><td>${escapeHtml(lang)}</td></tr>
<tr><td><strong>IP / Country:</strong></td><td>${escapeHtml(ip)} / ${escapeHtml(country)}</td></tr>
<tr><td><strong>Timestamp:</strong></td><td>${escapeHtml(timestamp)}</td></tr>
<tr><td><strong>User agent:</strong></td><td style="font-size:11px;color:#666;">${escapeHtml(userAgent)}</td></tr>
</table>
${statement ? `<h3>Statement</h3><p style="white-space:pre-wrap;background:#f5f5f5;padding:12px;border-left:3px solid #666;">${escapeHtml(statement)}</p>` : '<p style="color:#888;"><em>No statement provided.</em></p>'}
<hr style="margin-top:24px;border:none;border-top:1px solid #ddd;"/>
<p style="font-size:12px;color:#888;">Sent from declaration.folkup.app/api/endorse (CF Pages Function → Brevo). Reply-to endorser: ${escapeHtml(email)}</p>
</body></html>`;

  const brevoPayload = {
    sender: { email: 'declaration@folkup.app', name: 'FolkUp Declaration' },
    to: [{ email: 'anklemqq@gmail.com', name: 'Andrey' }],
    replyTo: { email, name },
    subject,
    htmlContent: htmlBody,
  };

  let brevoResponse;
  try {
    brevoResponse = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        accept: 'application/json',
        'api-key': env.BREVO_API_KEY,
        'content-type': 'application/json',
      },
      body: JSON.stringify(brevoPayload),
    });
  } catch (err) {
    return jsonResponse({ success: false, error: 'transport_failed' }, 502);
  }

  if (!brevoResponse.ok) {
    const errText = await brevoResponse.text().catch(() => '');
    return jsonResponse(
      { success: false, error: 'delivery_failed', status: brevoResponse.status, detail: errText.slice(0, 200) },
      502
    );
  }

  const brevoResult = await brevoResponse.json().catch(() => ({}));
  return jsonResponse({ success: true, messageId: brevoResult.messageId || null });
}

export async function onRequest({ request }) {
  return jsonResponse({ success: false, error: 'method_not_allowed', allowed: ['POST', 'OPTIONS'] }, 405);
}
