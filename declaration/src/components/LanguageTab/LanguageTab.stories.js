import { createLanguageTab, createLanguageTabs, LanguageTabPresets } from './LanguageTab.js';
import './LanguageTab.css';

export default {
  title: 'Components/LanguageTab',
  tags: ['autodocs'],
  argTypes: {
    language: {
      control: { type: 'select' },
      options: ['en', 'ru', 'pt', 'es', 'fr', 'de'],
      description: 'Language code'
    },
    label: {
      control: { type: 'text' },
      description: 'Tab label text'
    },
    active: {
      control: { type: 'boolean' },
      description: 'Active state'
    },
    disabled: {
      control: { type: 'boolean' },
      description: 'Disabled state'
    }
  },
  parameters: {
    docs: {
      description: {
        component: `
# FolkUp Language Tab Component

Multilingual navigation system for educational platforms serving EU demographic 13-15.

## Features
- WCAG 2.1 AA compliant keyboard navigation
- ARIA attributes for screen readers
- 44px minimum touch targets
- High contrast mode support
- Responsive design
- Print-friendly (hidden in print)

## Constitutional Compliance
- Supports DECL trilingual requirement (EN/RU/PT)
- EU demographic accessibility standards
- FolkUp brand color system
- Banking-level accessibility standards
        `
      }
    },
    a11y: {
      config: {
        rules: [
          {
            id: 'color-contrast',
            enabled: true,
          },
          {
            id: 'keyboard-navigation',
            enabled: true,
          }
        ]
      }
    }
  }
};

// Single tab stories
export const Default = {
  args: {
    language: 'en',
    label: 'EN',
    active: false,
  },
  render: (args) => createLanguageTab(args),
};

export const Active = {
  args: {
    language: 'en',
    label: 'EN',
    active: true,
  },
  render: (args) => createLanguageTab(args),
};

export const Disabled = {
  args: {
    language: 'en',
    label: 'EN',
    disabled: true,
  },
  render: (args) => createLanguageTab(args),
};

// Language variants
export const Russian = {
  args: {
    language: 'ru',
    label: 'РУ',
    active: false,
  },
  render: (args) => createLanguageTab(args),
};

export const Portuguese = {
  args: {
    language: 'pt',
    label: 'PT',
    active: false,
  },
  render: (args) => createLanguageTab(args),
};

// Full tab group stories
export const DECLLanguageTabs = {
  render: () => createLanguageTabs(LanguageTabPresets.declaration),
  parameters: {
    docs: {
      description: {
        story: 'DECL trilingual configuration (EN/RU/PT) - Constitutional requirement for EU demographic 13-15'
      }
    }
  }
};

export const BilingualTabs = {
  render: () => createLanguageTabs(LanguageTabPresets.bilingual),
  parameters: {
    docs: {
      description: {
        story: 'Minimal bilingual setup for smaller projects'
      }
    }
  }
};

export const WithActiveRussian = {
  render: () => createLanguageTabs({
    ...LanguageTabPresets.declaration,
    activeLanguage: 'ru'
  }),
  parameters: {
    docs: {
      description: {
        story: 'Russian active state - demonstrates Cyrillic typography'
      }
    }
  }
};

export const WithActivePortuguese = {
  render: () => createLanguageTabs({
    ...LanguageTabPresets.declaration,
    activeLanguage: 'pt'
  }),
  parameters: {
    docs: {
      description: {
        story: 'Portuguese active state - LATAM demographic support'
      }
    }
  }
};

// Interactive demo
export const InteractiveDemo = {
  render: () => `
    <div>
      <style>
        .lang-content {
          margin-top: 2rem;
          padding: 2rem;
          border: 2px solid var(--bordo);
          border-radius: var(--radius-md);
          background: var(--bg);
        }

        .lang-content:not(.active) {
          display: none;
        }

        .lang-content h3 {
          margin: 0 0 1rem 0;
          color: var(--bordo);
          font-family: var(--font-serif);
        }
      </style>

      ${createLanguageTabs({
        ...LanguageTabPresets.declaration,
        onLanguageChange: 'demoSwitchLanguage'
      })}

      <div class="lang-content active" data-lang="en" id="content-en">
        <h3>English Content</h3>
        <p>This is the English version of the Declaration Guide, designed for European teenage audience aged 13-15.</p>
      </div>

      <div class="lang-content" data-lang="ru" id="content-ru">
        <h3>Русский контент</h3>
        <p>Это русская версия Справочника по Декларации, предназначенного для европейской подростковой аудитории 13-15 лет.</p>
      </div>

      <div class="lang-content" data-lang="pt" id="content-pt">
        <h3>Conteúdo Português</h3>
        <p>Esta é a versão portuguesa do Guia de Declaração, projetada para adolescentes europeus de 13-15 anos.</p>
      </div>

      <script>
        function demoSwitchLanguage(lang) {
          // Update active tab
          document.querySelectorAll('.lang-tab').forEach(tab => {
            tab.classList.remove('active');
            tab.removeAttribute('aria-current');
            tab.setAttribute('aria-selected', 'false');
          });

          const activeTab = document.querySelector(\`[data-lang="\${lang}"]\`);
          if (activeTab) {
            activeTab.classList.add('active');
            activeTab.setAttribute('aria-current', 'true');
            activeTab.setAttribute('aria-selected', 'true');
          }

          // Update active content
          document.querySelectorAll('.lang-content').forEach(content => {
            content.classList.remove('active');
          });

          const activeContent = document.getElementById(\`content-\${lang}\`);
          if (activeContent) {
            activeContent.classList.add('active');
          }
        }
      </script>
    </div>
  `,
  parameters: {
    docs: {
      description: {
        story: 'Interactive demonstration showing language switching functionality - mirrors DECL implementation'
      }
    }
  }
};

// Accessibility showcase
export const AccessibilityFeatures = {
  render: () => `
    <div style="max-width: 600px; margin: 0 auto;">
      <h3 style="margin: 0 0 1rem 0; color: var(--bordo);">Accessibility Features</h3>

      ${createLanguageTabs(LanguageTabPresets.declaration)}

      <div style="margin-top: 2rem; padding: 1.5rem; background: var(--light); border-radius: var(--radius-md);">
        <h4 style="margin: 0 0 1rem 0; color: var(--text);">Features Demonstrated:</h4>
        <ul style="margin: 0; padding-left: 1.5rem; color: var(--text);">
          <li><strong>WCAG 2.1 AA:</strong> 44px minimum touch targets</li>
          <li><strong>Keyboard Navigation:</strong> Tab and Enter/Space support</li>
          <li><strong>Screen Readers:</strong> ARIA labels and role attributes</li>
          <li><strong>High Contrast:</strong> Enhanced borders in high contrast mode</li>
          <li><strong>Reduced Motion:</strong> Respects prefers-reduced-motion</li>
          <li><strong>Focus Management:</strong> Visible focus indicators</li>
        </ul>
      </div>

      <div style="margin-top: 1rem; padding: 1.5rem; background: #fff3cd; border-radius: var(--radius-md); border-left: 4px solid var(--amber);">
        <h4 style="margin: 0 0 1rem 0; color: #664d03;">Constitutional Compliance</h4>
        <p style="margin: 0; color: #664d03;">
          This component meets banking-level accessibility standards required by the DECL constitutional framework for educational platforms serving EU minors.
        </p>
      </div>
    </div>
  `,
  parameters: {
    docs: {
      description: {
        story: 'Accessibility features overview - Constitutional UI/UX Framework compliance'
      }
    }
  }
};