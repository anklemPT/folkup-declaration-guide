/**
 * FolkUp Language Tab Component
 * Constitutional UI/UX Framework - Multilingual Navigation
 */

export const createLanguageTab = ({
  language = 'en',
  label = 'EN',
  active = false,
  disabled = false,
  onClick = null,
  ...props
}) => {
  const classes = [
    'lang-tab',
    'language-tab',
    active ? 'active' : ''
  ].filter(Boolean).join(' ');

  const attributes = {
    class: classes,
    'data-lang': language,
    'aria-label': `Switch to ${getLanguageName(language)}`,
    type: 'button',
    role: 'tab',
    ...props
  };

  if (active) {
    attributes['aria-current'] = 'true';
    attributes['aria-selected'] = 'true';
  } else {
    attributes['aria-selected'] = 'false';
  }

  if (disabled) {
    attributes.disabled = true;
    attributes['aria-disabled'] = 'true';
  }

  const eventHandler = onClick ? `onclick="${onClick}"` : '';

  return `
    <button ${Object.entries(attributes)
      .map(([key, value]) => `${key}="${value}"`)
      .join(' ')} ${eventHandler}>
      ${label}
    </button>
  `;
};

export const createLanguageTabs = ({
  languages = [
    { code: 'en', label: 'EN' },
    { code: 'ru', label: 'РУ' },
    { code: 'pt', label: 'PT' }
  ],
  activeLanguage = 'en',
  onLanguageChange = 'switchLanguage',
  ...props
}) => {
  const tabsHtml = languages
    .map(lang => createLanguageTab({
      language: lang.code,
      label: lang.label,
      active: lang.code === activeLanguage,
      onClick: `${onLanguageChange}('${lang.code}')`
    }))
    .join('');

  return `
    <div class="lang-tabs" role="tablist" aria-label="Language selection" ${Object.entries(props)
      .map(([key, value]) => `${key}="${value}"`)
      .join(' ')}>
      ${tabsHtml}
    </div>
  `;
};

// Helper function for accessibility
function getLanguageName(code) {
  const names = {
    'en': 'English',
    'ru': 'Russian',
    'pt': 'Portuguese',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German'
  };
  return names[code] || code.toUpperCase();
}

// Preset configurations for DECL
export const LanguageTabPresets = {
  // DECL default configuration
  declaration: {
    languages: [
      { code: 'en', label: 'EN' },
      { code: 'ru', label: 'РУ' },
      { code: 'pt', label: 'PT' }
    ],
    activeLanguage: 'en',
    onLanguageChange: 'switchLanguage'
  },

  // Minimal two-language setup
  bilingual: {
    languages: [
      { code: 'en', label: 'EN' },
      { code: 'ru', label: 'РУ' }
    ],
    activeLanguage: 'en'
  }
};