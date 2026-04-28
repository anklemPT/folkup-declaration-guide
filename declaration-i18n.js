// Declaration Guide i18n URL Router
(function() {
    // URL Detection & Tab Activation
    function detectLanguageFromURL() {
        const path = window.location.pathname;
        if (path.includes('/ru/')) return 'ru';
        if (path.includes('/pt/')) return 'pt';
        if (path.includes('/en/')) return 'en';
        return 'en'; // default
    }

    // Content & Tab Switching
    function switchLanguage(lang) {
        // Hide all content
        document.querySelectorAll('.lang-content').forEach(el => {
            el.style.display = 'none';
        });

        // Show target language content
        const targetContent = document.querySelector(`.lang-content[data-lang="${lang}"]`);
        if (targetContent) targetContent.style.display = 'block';

        // Update active tab
        document.querySelectorAll('.language-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        const activeTab = document.querySelector(`.language-tab[data-lang="${lang}"]`);
        if (activeTab) activeTab.classList.add('active');
    }

    // Initialize on page load
    function init() {
        const currentLang = detectLanguageFromURL();
        switchLanguage(currentLang);

        // Language tab click handlers
        document.querySelectorAll('.language-tab').forEach(tab => {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                const lang = this.dataset.lang;

                // Update URL with pushState
                const newPath = lang === 'en' ? '/' : `/${lang}/`;
                const fullPath = window.location.pathname.includes('/guide/')
                    ? `/guide${newPath}`
                    : newPath;

                history.pushState({lang}, '', fullPath);
                switchLanguage(lang);
            });
        });
    }

    // Browser back/forward support
    window.addEventListener('popstate', function(e) {
        const lang = e.state?.lang || detectLanguageFromURL();
        switchLanguage(lang);
    });

    // DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();