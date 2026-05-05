/**
 * FolkUp Button Component
 * Constitutional UI/UX Framework - Banking Level Standards
 */

export const createButton = ({
  variant = 'primary',
  size = 'medium',
  label = 'Button',
  disabled = false,
  loading = false,
  href = null,
  onClick = null,
  ...props
}) => {
  // Build CSS classes
  const classes = [
    'btn',
    `btn--${variant}`,
    size !== 'medium' ? `btn--${size}` : '',
    disabled ? 'btn--disabled' : '',
    loading ? 'btn--loading' : ''
  ].filter(Boolean).join(' ');

  // Create attributes
  const attributes = {
    class: classes,
    ...props
  };

  if (disabled) {
    attributes.disabled = true;
    attributes['aria-disabled'] = 'true';
  }

  if (loading) {
    attributes['aria-busy'] = 'true';
    attributes['aria-describedby'] = 'loading-text';
  }

  // Create element based on type
  if (href && !disabled && !loading) {
    // Link button
    return `
      <a href="${href}" ${Object.entries(attributes)
        .map(([key, value]) => `${key}="${value}"`)
        .join(' ')}>
        ${label}
      </a>
    `;
  } else {
    // Button element
    const eventHandler = onClick ? `onclick="${onClick}"` : '';

    return `
      <button ${Object.entries(attributes)
        .map(([key, value]) => `${key}="${value}"`)
        .join(' ')} ${eventHandler}>
        ${loading ? '<span class="sr-only" id="loading-text">Loading</span>' : ''}
        ${label}
      </button>
    `;
  }
};

// Preset configurations
export const ButtonPresets = {
  // Declaration signing CTA
  signDeclaration: {
    variant: 'primary',
    size: 'large',
    label: 'Sign the Declaration',
    href: '/sign'
  },

  // Print functionality
  printDeclaration: {
    variant: 'secondary',
    size: 'medium',
    label: 'Print Declaration',
    onClick: 'window.print()'
  },

  // Navigation links
  navLink: {
    variant: 'secondary',
    size: 'small',
    href: '#'
  }
};