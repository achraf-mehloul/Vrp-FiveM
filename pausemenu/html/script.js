let playerData = {
    playerId: 0,
    playerName: "",
    serverName: "Melix Files V1",
    serverLogo: "assets/logo.png",
    wantedLevel: 0,
    playTime: "0:00:00",
    onlinePlayers: 0
};

// استقبال الأحداث من Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showMenu':
            document.getElementById('pausemenu').classList.remove('hidden');
            updatePlayerData(data.data);
            break;
            
        case 'hideMenu':
            document.getElementById('pausemenu').classList.add('hidden');
            break;
            
        case 'updateData':
            updatePlayerData(data.data);
            break;
            
        case 'updateServerSettings':
            updateServerSettings(data.data);
            break;
            
        case 'showShortcuts':
            showShortcutsMenu();
            break;
            
        case 'showFrameworks':
            showFrameworksMenu();
            break;
    }
});

// تحديث بيانات اللاعب
function updatePlayerData(data) {
    playerData = {...playerData, ...data};
    
    document.getElementById('player-id').textContent = playerData.playerId;
    document.getElementById('player-count').textContent = playerData.onlinePlayers;
    document.getElementById('play-time').textContent = playerData.playTime;
    document.getElementById('player-name').textContent = playerData.playerName;
    
    // تحديث اسم السيرفر وصورته
    document.getElementById('server-name').textContent = playerData.serverName;
    document.getElementById('server-logo').src = playerData.serverLogo;
}

// تحديث إعدادات السيرفر
function updateServerSettings(settings) {
    if (settings.serverName) {
        playerData.serverName = settings.serverName;
        document.getElementById('server-name').textContent = settings.serverName;
    }
    if (settings.serverLogo) {
        playerData.serverLogo = settings.serverLogo;
        document.getElementById('server-logo').src = settings.serverLogo;
    }
}

// معالجة الضغط على الأزرار
function handleButton(buttonType) {
    fetch(`https://${GetParentResourceName()}/buttonAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            button: buttonType
        })
    }).catch(error => {
        console.log('NUI fetch error:', error);
    });
}

// دالة لعرض قائمة الاختصارات
function showShortcutsMenu() {
    const shortcutsHTML = `
        <div id="shortcuts-menu" class="sub-menu">
            <div class="sub-menu-content">
                <h2><i class="fas fa-keyboard"></i> Keyboard Shortcuts</h2>
                <div class="shortcuts-list">
                    <div class="shortcut-item">
                        <span class="shortcut-key">F1</span>
                        <span class="shortcut-action">Open/Close Pause Menu</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F2</span>
                        <span class="shortcut-action">Open Phone</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F3</span>
                        <span class="shortcut-action">Open Inventory</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F5</span>
                        <span class="shortcut-action">Player List</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F6</span>
                        <span class="shortcut-action">Jobs Menu</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F7</span>
                        <span class="shortcut-action">Vehicles Menu</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F8</span>
                        <span class="shortcut-action">Open Chat</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F9</span>
                        <span class="shortcut-action">Take Screenshot</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">F10</span>
                        <span class="shortcut-action">Toggle Hood</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">T</span>
                        <span class="shortcut-action">Open Chat Input</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">M</span>
                        <span class="shortcut-action">Player Map</span>
                    </div>
                    <div class="shortcut-item">
                        <span class="shortcut-key">ESC</span>
                        <span class="shortcut-action">Close Menu/Go Back</span>
                    </div>
                </div>
                <button class="back-btn" onclick="closeSubMenu()">
                    <i class="fas fa-arrow-left"></i> Back to Menu
                </button>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', shortcutsHTML);
}

// دالة لعرض قائمة الفريمات
function showFrameworksMenu() {
    const frameworksHTML = `
        <div id="frameworks-menu" class="sub-menu">
            <div class="sub-menu-content">
                <h2><i class="fas fa-layer-group"></i> Frameworks Settings</h2>
                <div class="frameworks-list">
                    <button class="framework-btn" onclick="changeFramerate('high')">
                        <i class="fas fa-bolt"></i>
                        High Framerate
                    </button>
                    <button class="framework-btn" onclick="changeFramerate('medium')">
                        <i class="fas fa-tachometer-alt"></i>
                        Medium Framerate
                    </button>
                    <button class="framework-btn" onclick="changeFramerate('low')">
                        <i class="fas fa-sliders-h"></i>
                        Low Framerate
                    </button>
                    <button class="framework-btn" onclick="changeFramerate('normal')">
                        <i class="fas fa-cog"></i>
                        Normal (Default)
                    </button>
                </div>
                <button class="back-btn" onclick="closeSubMenu()">
                    <i class="fas fa-arrow-left"></i> Back to Menu
                </button>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', frameworksHTML);
}

// تغيير الإطارات
function changeFramerate(level) {
    fetch(`https://${GetParentResourceName()}/changeFramerate`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            level: level
        })
    }).catch(error => {
        console.log('NUI fetch error:', error);
    });
}

// دالة لإغلاق القوائم الفرعية
function closeSubMenu() {
    const shortcutsMenu = document.getElementById('shortcuts-menu');
    const frameworksMenu = document.getElementById('frameworks-menu');
    
    if (shortcutsMenu) shortcutsMenu.remove();
    if (frameworksMenu) frameworksMenu.remove();
}

// إخفاء القائمة عند الضغط على ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        handleButton('resume');
    }
});

// تهيئة القائمة عند التحميل
document.addEventListener('DOMContentLoaded', function() {
    console.log('Pause Menu loaded successfully');
});
