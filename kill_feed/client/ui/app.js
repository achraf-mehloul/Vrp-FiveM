class KillFeedPro {
    constructor() {
        this.messages = [];
        this.maxMessages = 5;
        this.settings = this.loadSettings();
        this.init();
    }

    init() {
        this.applyTheme(this.settings.theme);
        this.setDirection(this.settings.language);
        this.setupCanvas();
    }

    loadSettings() {
        return JSON.parse(localStorage.getItem('killfeed_settings')) || {
            theme: 'dark',
            language: 'ar',
            position: 'top-right',
            sounds: true,
            avatars: true
        };
    }

    saveSettings() {
        localStorage.setItem('killfeed_settings', JSON.stringify(this.settings));
    }

    applyTheme(theme) {
        const container = document.getElementById('killFeedContainer');
        container.className = `${this.settings.position} theme-${theme}`;
        document.documentElement.setAttribute('data-theme', theme);
    }

    setDirection(lang) {
        document.getElementById('mainHtml').setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
        document.getElementById('mainHtml').setAttribute('lang', lang);
    }

    setupCanvas() {
        this.canvas = document.getElementById('effectsCanvas');
        this.ctx = this.canvas.getContext('2d');
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    playSound(soundPath, highlightSound) {
        if (!this.settings.sounds) return;
        
        const soundToPlay = highlightSound || soundPath;
        if (!soundToPlay) return;
        
        try {
            const fullSoundPath = `http://localhost:30120/${soundToPlay}`;
            
            const audio = new Audio(fullSoundPath);
            audio.volume = 0.3;
            audio.play().catch(e => {
                console.log('Sound play error:', e);
                this.playFallbackSound(soundToPlay);
            });
        } catch (error) {
            console.log('Sound loading error:', error);
        }
    }

    playFallbackSound(soundPath) {
        try {
            const fileName = soundPath.split('/').pop();
            const relativePath = `./sounds/${fileName}`;
            
            const audio = new Audio(relativePath);
            audio.volume = 0.3;
            audio.play().catch(e => console.log('Fallback sound error:', e));
        } catch (error) {
            console.log('Fallback sound loading error:', error);
        }
    }

    addKillMessage(data) {
        const message = this.createMessageElement(data);
        const container = document.getElementById('killMessages');
        
        container.insertBefore(message, container.firstChild);
        this.messages.unshift(message);

        if (this.messages.length > this.maxMessages) {
            const oldMessage = this.messages.pop();
            oldMessage.remove();
        }

        this.playSound(data.weaponData?.sound, data.highlight?.sound);
        this.createParticles(data.highlight);
        
        setTimeout(() => {
            if (message.parentElement) {
                message.style.animation = 'fadeOut 0.5s ease forwards';
                setTimeout(() => message.remove(), 500);
            }
        }, 4500);
    }

    createMessageElement(data) {
        const message = document.createElement('div');
        message.className = `kill-message ${data.highlight ? 'highlight-' + data.highlight.type : ''}`;
        
        let content = '';
        if (this.settings.language === 'ar') {
            content = `
                ${this.settings.avatars ? `<img src="${data.killerAvatar || ''}" class="avatar" onerror="this.style.display='none'">` : ''}
                <strong>${data.killer || 'Unknown'}</strong> 
                <span>${data.textKilled || 'قتل'}</span> 
                <strong>${data.victim || 'Unknown'}</strong>
                <span class="weapon-icon">${data.weaponIcon || '💀'}</span>
                ${data.highlight ? `<span class="highlight-badge">${data.highlight.text || ''}</span>` : ''}
            `;
        } else {
            content = `
                ${this.settings.avatars ? `<img src="${data.killerAvatar || ''}" class="avatar" onerror="this.style.display='none'">` : ''}
                <strong>${data.killer || 'Unknown'}</strong> 
                <span>${data.textKilled || 'killed'}</span> 
                <strong>${data.victim || 'Unknown'}</strong>
                <span class="weapon-icon">${data.weaponIcon || '💀'}</span>
                ${data.highlight ? `<span class="highlight-badge">${data.highlight.text || ''}</span>` : ''}
            `;
        }
        
        message.innerHTML = content;
        return message;
    }

    createParticles(highlight) {
        if (!highlight || !this.settings.animations) return;
        
        for (let i = 0; i < 5; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.cssText = `
                left: 50%;
                top: 50%;
                width: 4px;
                height: 4px;
                background: ${highlight.color || '#ff0000'};
                --tx: ${Math.random() * 100 - 50}px;
                --ty: ${Math.random() * 100 - 50}px;
            `;
            document.body.appendChild(particle);
            
            setTimeout(() => particle.remove(), 1000);
        }
    }
}

const killFeed = new KillFeedPro();

window.addEventListener('message', (event) => {
    if (event.data.action === "showKill") {
        killFeed.addKillMessage(event.data);
    }
    
    if (event.data.action === "updateSettings") {
        killFeed.settings = { ...killFeed.settings, ...event.data.settings };
        killFeed.saveSettings();
        killFeed.applyTheme(killFeed.settings.theme);
        killFeed.setDirection(killFeed.settings.language);
    }
});

window.testKillFeed = () => {
    const testData = {
        killer: "اللاعب الأول",
        victim: "اللاعب الثاني", 
        weaponIcon: "🔫",
        textKilled: "قتل",
        weaponData: { sound: "client/ui/sounds/pistol_shot.ogg" },
        highlight: { 
            type: "headshot", 
            text: "HEADSHOT",
            sound: "client/ui/sounds/headshot.ogg",
            color: "#ff0000"
        }
    };
    killFeed.addKillMessage(testData);
};
