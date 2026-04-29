# Declaration Guide i18n Integration

## HTML Integration

### 1. Include Script
Add to both `index.html` and `guide/index.html` before closing `</body>`:

```html
<script src="declaration-i18n.js"></script>
```

### 2. Required HTML Structure

**Language Tabs:**
```html
<div class="language-tabs">
    <button class="language-tab" data-lang="en">EN</button>
    <button class="language-tab" data-lang="ru">РУ</button>
    <button class="language-tab" data-lang="pt">PT</button>
</div>
```

**Content Blocks:**
```html
<div class="lang-content" data-lang="en">English content</div>
<div class="lang-content" data-lang="ru">Russian content</div>
<div class="lang-content" data-lang="pt">Portuguese content</div>
```

### 3. CSS Requirements
```css
.lang-content { display: none; }
.language-tab.active { /* active tab styles */ }
```

## URL Structure

- **Default (EN):** `/` or `/guide/`
- **Russian:** `/ru/` or `/guide/ru/`
- **Portuguese:** `/pt/` or `/guide/pt/`

## Features

✅ **URL Detection:** Auto-activates tabs based on current path
✅ **pushState Navigation:** SEO-friendly URL updates without page reload
✅ **Browser History:** Back/forward button support
✅ **Backward Compatibility:** Works with existing tab switching
✅ **Default Fallback:** EN language for unknown paths
✅ **Guide Support:** Works for both main page and student guide

## Testing

1. Load page → correct language tab activated
2. Click language tab → URL updates, content switches
3. Use browser back/forward → language switches correctly
4. Direct URL access (e.g., `/ru/`) → correct content shown