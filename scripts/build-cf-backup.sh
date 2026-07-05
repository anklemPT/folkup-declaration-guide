#!/usr/bin/env bash
# Build CF Pages dist/ from declaration-guide root.
# Explicit-copy strategy (Кочегар verdict 2026-06-03): defensible against
# config-drift vs .cloudflareignore. Excludes _meta/, .claude/, nginx*,
# README, i18n-integration.md, index-old.html.
#
# Clean URLs: cookies.html → cookies/index.html (matches nginx
# nginx-clean-urls.conf production behavior).

set -euo pipefail

rm -rf dist
mkdir -p dist

# Root index
cp index.html dist/

# SEO: robots.txt (Q11+F8 canon; follow-up к PR #5 build-copy fix)
cp robots.txt dist/

# Clean-URL conversions (matches production nginx clean-urls)
for page in cookies privacy terms; do
  mkdir -p "dist/${page}"
  cp "${page}.html" "dist/${page}/index.html"
done

# Direct-access .html versions (per production nginx pattern, both /cookies/ AND /cookies.html work)
cp cookies.html dist/
cp privacy.html dist/
cp terms.html dist/
cp trilingual-verification.html dist/

# Static asset directories
cp -r css js fonts images dist/

# Multilingual + guide content
cp -r declaration guide dist/

# i18n helper script (root-level reference из index.html)
cp declaration-i18n.js dist/

# CF Pages headers + redirects
cat > dist/_headers <<'HEADERS'
/*
  Strict-Transport-Security: max-age=31536000; includeSubDomains
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin

/css/*
  Cache-Control: public, max-age=31536000, immutable

/js/*
  Cache-Control: public, max-age=31536000, immutable

/fonts/*
  Cache-Control: public, max-age=31536000, immutable

/images/*
  Cache-Control: public, max-age=31536000, immutable
HEADERS

cat > dist/_redirects <<'REDIRECTS'
# 404 fallback to index.html (SPA-like for multilingual routes)
/ru/*    /index.html    200
/pt/*    /index.html    200
REDIRECTS

echo "Build complete: $(find dist -type f | wc -l) files, $(du -sh dist | awk '{print $1}')"
