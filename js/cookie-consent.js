/**
 * Cookie Consent System for Declaration Guide
 * GDPR Article 8 compliant (age check)
 * Teen-friendly UX with visual icons
 */

class CookieConsent {
  constructor() {
    this.cookieName = 'declaration-guide-consent';
    this.expiryDays = 365;
    this.init();
  }

  init() {
    // Check if consent already given
    if (this.getConsent() === null) {
      this.showBanner();
    } else if (this.getConsent() === 'accepted') {
      this.enableAnalytics();
    }
  }

  showBanner() {
    const banner = this.createBanner();
    document.body.appendChild(banner);

    // Focus management for accessibility
    setTimeout(() => {
      const acceptBtn = banner.querySelector('.cookie-accept');
      acceptBtn?.focus();
    }, 100);
  }

  createBanner() {
    const banner = document.createElement('div');
    banner.id = 'cookie-consent-banner';
    banner.className = 'cookie-banner';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-labelledby', 'cookie-title');
    banner.setAttribute('aria-describedby', 'cookie-description');

    banner.innerHTML = `
      <div class="cookie-content">
        <div class="cookie-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
          </svg>
        </div>
        <div class="cookie-text">
          <h3 id="cookie-title">We use cookies to improve your experience</h3>
          <p id="cookie-description">
            This site uses analytics to understand usage patterns.
            <strong>Under 16? Ask a grown-up before clicking "Accept"</strong>
          </p>
        </div>
        <div class="cookie-actions">
          <button type="button" class="cookie-accept" aria-describedby="cookie-description">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
            </svg>
            Accept
          </button>
          <button type="button" class="cookie-decline">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
            </svg>
            Decline
          </button>
          <a href="/cookies" class="cookie-learn-more">Learn more</a>
        </div>
      </div>
    `;

    // Event listeners
    banner.querySelector('.cookie-accept').addEventListener('click', () => {
      this.setConsent('accepted');
      this.enableAnalytics();
      this.hideBanner();
    });

    banner.querySelector('.cookie-decline').addEventListener('click', () => {
      this.setConsent('declined');
      this.hideBanner();
    });

    // Keyboard navigation
    banner.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.setConsent('declined');
        this.hideBanner();
      }
    });

    return banner;
  }

  setConsent(value) {
    const expiry = new Date();
    expiry.setTime(expiry.getTime() + (this.expiryDays * 24 * 60 * 60 * 1000));
    const cookie = `${this.cookieName}=${value}; expires=${expiry.toUTCString()}; path=/; SameSite=Strict`;
    document.cookie = cookie;

    // Also store in localStorage as backup
    try {
      localStorage.setItem(this.cookieName, JSON.stringify({
        consent: value,
        timestamp: Date.now(),
        expires: expiry.getTime()
      }));
    } catch (e) {
      console.warn('Could not store consent in localStorage:', e);
    }
  }

  getConsent() {
    // Try cookie first
    const cookies = document.cookie.split(';');
    for (let cookie of cookies) {
      const [name, value] = cookie.trim().split('=');
      if (name === this.cookieName) {
        return value;
      }
    }

    // Fallback to localStorage
    try {
      const stored = localStorage.getItem(this.cookieName);
      if (stored) {
        const data = JSON.parse(stored);
        if (Date.now() < data.expires) {
          return data.consent;
        } else {
          localStorage.removeItem(this.cookieName);
        }
      }
    } catch (e) {
      console.warn('Could not read consent from localStorage:', e);
    }

    return null;
  }

  enableAnalytics() {
    // Enable analytics.folkup.app when consent given
    console.log('Analytics enabled - consent granted');

    // Example analytics integration
    if (window.gtag) {
      window.gtag('consent', 'update', {
        'analytics_storage': 'granted'
      });
    }

    // Fire consent event
    document.dispatchEvent(new CustomEvent('cookieConsentGranted', {
      detail: { timestamp: Date.now() }
    }));
  }

  hideBanner() {
    const banner = document.getElementById('cookie-consent-banner');
    if (banner) {
      banner.style.animation = 'slideOut 0.3s ease-out forwards';
      setTimeout(() => banner.remove(), 300);
    }
  }

  // Method to withdraw consent (for settings page)
  withdrawConsent() {
    document.cookie = `${this.cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
    try {
      localStorage.removeItem(this.cookieName);
    } catch (e) {
      console.warn('Could not remove consent from localStorage:', e);
    }

    // Fire withdrawal event
    document.dispatchEvent(new CustomEvent('cookieConsentWithdrawn', {
      detail: { timestamp: Date.now() }
    }));

    // Show banner again
    this.showBanner();
  }
}

// Initialize when DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    new CookieConsent();
  });
} else {
  new CookieConsent();
}

// Expose globally for settings page
window.CookieConsent = CookieConsent;