import { createButton, ButtonPresets } from './Button.js';
import './Button.css';

export default {
  title: 'Components/Button',
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['primary', 'secondary'],
      description: 'Button style variant'
    },
    size: {
      control: { type: 'select' },
      options: ['small', 'medium', 'large'],
      description: 'Button size'
    },
    label: {
      control: { type: 'text' },
      description: 'Button text content'
    },
    disabled: {
      control: { type: 'boolean' },
      description: 'Disabled state'
    },
    loading: {
      control: { type: 'boolean' },
      description: 'Loading state with spinner'
    },
    href: {
      control: { type: 'text' },
      description: 'URL for link buttons (creates <a> tag)'
    }
  },
  parameters: {
    docs: {
      description: {
        component: `
# FolkUp Button Component

Constitutional UI/UX Framework compliant button system with banking-level accessibility standards.

## Features
- WCAG 2.1 AA compliant (44px minimum touch targets)
- FolkUp brand colors and typography
- Keyboard navigation support
- Screen reader accessible
- Loading states
- Disabled states

## Brand Compliance
- Uses FolkUp color tokens (--bordo, --amber)
- Inter font family
- Consistent spacing and border radius
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
            id: 'interactive-supports-focus',
            enabled: true,
          }
        ]
      }
    }
  }
};

// Default story
export const Default = {
  args: {
    variant: 'primary',
    label: 'Default Button',
  },
  render: (args) => createButton(args),
};

// Primary variants
export const Primary = {
  args: {
    variant: 'primary',
    label: 'Primary Button',
  },
  render: (args) => createButton(args),
};

export const PrimaryLarge = {
  args: {
    variant: 'primary',
    size: 'large',
    label: 'Large Primary',
  },
  render: (args) => createButton(args),
};

// Secondary variants
export const Secondary = {
  args: {
    variant: 'secondary',
    label: 'Secondary Button',
  },
  render: (args) => createButton(args),
};

export const SecondarySmall = {
  args: {
    variant: 'secondary',
    size: 'small',
    label: 'Small Secondary',
  },
  render: (args) => createButton(args),
};

// States
export const Disabled = {
  args: {
    variant: 'primary',
    label: 'Disabled Button',
    disabled: true,
  },
  render: (args) => createButton(args),
};

export const Loading = {
  args: {
    variant: 'primary',
    label: 'Loading Button',
    loading: true,
  },
  render: (args) => createButton(args),
};

// Link variants
export const LinkButton = {
  args: {
    variant: 'primary',
    label: 'Link Button',
    href: '/example',
  },
  render: (args) => createButton(args),
};

// DECL Presets - Constitutional Compliance
export const SignDeclaration = {
  args: ButtonPresets.signDeclaration,
  render: (args) => createButton(args),
  parameters: {
    docs: {
      description: {
        story: 'Primary CTA for Declaration signing - P0 constitutional requirement'
      }
    }
  }
};

export const PrintDeclaration = {
  args: ButtonPresets.printDeclaration,
  render: (args) => createButton(args),
  parameters: {
    docs: {
      description: {
        story: 'Print functionality button - Secondary variant for utility actions'
      }
    }
  }
};

// All variants showcase
export const AllVariants = {
  render: () => `
    <div style="display: flex; flex-direction: column; gap: 1rem; max-width: 600px;">
      <h3 style="margin: 0; color: var(--bordo);">Primary Buttons</h3>
      <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
        ${createButton({ variant: 'primary', size: 'small', label: 'Small' })}
        ${createButton({ variant: 'primary', size: 'medium', label: 'Medium' })}
        ${createButton({ variant: 'primary', size: 'large', label: 'Large' })}
      </div>

      <h3 style="margin: 0; color: var(--bordo);">Secondary Buttons</h3>
      <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
        ${createButton({ variant: 'secondary', size: 'small', label: 'Small' })}
        ${createButton({ variant: 'secondary', size: 'medium', label: 'Medium' })}
        ${createButton({ variant: 'secondary', size: 'large', label: 'Large' })}
      </div>

      <h3 style="margin: 0; color: var(--bordo);">States</h3>
      <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
        ${createButton({ variant: 'primary', label: 'Disabled', disabled: true })}
        ${createButton({ variant: 'primary', label: 'Loading', loading: true })}
        ${createButton({ variant: 'primary', label: 'Link', href: '#' })}
      </div>
    </div>
  `,
  parameters: {
    docs: {
      description: {
        story: 'Complete button system overview - Constitutional UI/UX Framework compliance'
      }
    }
  }
};