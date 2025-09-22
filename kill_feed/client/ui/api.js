const KillFeedAPI = {
    setTheme: (theme) => {
        killFeed.settings.theme = theme;
        killFeed.applyTheme(theme);
        killFeed.saveSettings();
    },
    
    setLanguage: (lang) => {
        killFeed.settings.language = lang;
        killFeed.setDirection(lang);
        killFeed.saveSettings();
    },
    
    toggle: (enable) => {
        document.getElementById('killFeedContainer').style.display = enable ? 'block' : 'none';
        killFeed.settings.enabled = enable;
        killFeed.saveSettings();
    },
    
    openSettings: () => {
        const settings = killFeed.settings;
        SendNUIMessage({
            action: "openSettings",
            settings: settings
        });
    }
};

window.KillFeedAPI = KillFeedAPI;
