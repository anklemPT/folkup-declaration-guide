# FolkUp Declaration Guide

An educational guide explaining the Unenclosed Knowledge Declaration for students aged 13-15. Seven principles about open knowledge presented in plain language.

## About

This is a standalone educational resource that complements the [FolkUp](https://folkup.app) ecosystem. The guide makes complex knowledge principles accessible to teenage students across Europe.

## Background

The declaration addresses modern "knowledge enclosures" - publicly funded research locked behind paywalls and algorithmic content delivery systems. Inspired by historical land enclosure movements, it presents seven principles for keeping knowledge open and accessible.

## Status

**Production Ready** - Deployed and stable at https://declaration.folkup.app
- 51,350 bytes optimized for performance
- Full trilingual content implementation complete
- WCAG 2.1 AA accessibility compliance verified
- Business functionality active (user sign-ups working)

## Features

- **Multi-language support**: English, Russian, and Portuguese with localStorage persistence
- **Accessibility compliant**: WCAG 2.1 AA standards with ARIA attributes and focus management
- **Mobile-responsive**: Optimized for all devices
- **Print-friendly**: Clean print layouts for offline use
- **Ko-fi integration**: Support widget system with FolkUp amber branding

## Development

This is a static site built with vanilla HTML/CSS/JavaScript:
- Single-page application with client-side language switching
- Embedded fonts and optimized performance
- No build process required - direct deployment

### Local Development
Serve the files with any static server:
```bash
python -m http.server 8000
# or
npx serve .
```

### Technical Architecture
- **Single file deployment**: Primary content in `index.html` (51,350 bytes)
- **Progressive enhancement**: Graceful fallback without JavaScript
- **VPS deployment**: File sync via SSH + Docker volume auto-pickup
- **Zero dependencies**: Uses only browser-native APIs

## Deployment

Deploys independently to `declaration.folkup.app` via VPS infrastructure:
- Server: 46.225.107.2 (nginx + Docker)
- Method: SSH file sync with auto-pickup
- SSL: HTTPS-only with HSTS headers

## Educational Standards

Content follows European educational standards with emphasis on:
- Teen engagement optimization (bright colors, 2-second comprehension)
- Diverse representation
- Clear visual hierarchy
- ROSTA-inspired simplified composition

## Contributing

This project welcomes contributions:
- Content improvements and translations
- Accessibility enhancements
- Bug reports and feature suggestions

Please open an issue to discuss changes before submitting pull requests.

## License

Content: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
Code: MIT

## Project Family

Part of the [FolkUp project ecosystem](https://folkup.app) dedicated to organizing and sharing knowledge.