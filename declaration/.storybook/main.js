

/** @type { import('@storybook/html-vite').StorybookConfig } */
const config = {
  "stories": [
    "../src/**/*.stories.@(js|jsx|mjs|ts|tsx)",
    "../src/**/*.mdx"
  ],
  "addons": [
    "@storybook/addon-essentials",
    "@storybook/addon-interactions",
    "@storybook/addon-a11y"
  ],
  "framework": {
    "name": "@storybook/html-vite",
    "options": {}
  },
  "staticDirs": ["../images"],
  "docs": {
    "autodocs": "tag"
  }
};
export default config;