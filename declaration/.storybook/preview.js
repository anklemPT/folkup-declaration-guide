/** @type { import('@storybook/html').Preview } */
import '../src/styles/tokens.css';

const preview = {
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
    },
    backgrounds: {
      default: 'FolkUp',
      values: [
        {
          name: 'FolkUp',
          value: '#FEFCF6',
        },
        {
          name: 'White',
          value: '#ffffff',
        },
        {
          name: 'Dark',
          value: '#1a1a1a',
        },
      ],
    },
    docs: {
      toc: true,
    },
    a11y: {
      config: {
        rules: [
          // WCAG 2.1 AA compliance rules
          { id: 'color-contrast', enabled: true },
          { id: 'keyboard-navigation', enabled: true },
          { id: 'interactive-supports-focus', enabled: true },
          { id: 'touch-target-size', enabled: true },
        ],
      },
    },
  },

  globalTypes: {
    locale: {
      name: 'Language',
      description: 'DECL multilingual support',
      defaultValue: 'en',
      toolbar: {
        icon: 'globe',
        items: [
          { value: 'en', title: 'English' },
          { value: 'ru', title: 'Русский' },
          { value: 'pt', title: 'Português' },
        ],
      },
    },
  },
};

export default preview;