// حالة التطبيق
let currentState = 'main';
let currentHero = null;
let playerBalance = 0;
let heroesData = [];
let playerHeroes = [];
let audioElement = null;

// تهيئة التطبيق
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
});

// تهيئة التطبيق
function initializeApp() {
    loadHeroesData();
    loadPlayerData();
    setupAudio();
}

// تحميل بيانات الأبطال
function loadHeroesData() {
    fetch('https://superheroes/getHeroesData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        heroesData = data.heroes;
        playerBalance = data.balance;
        playerHeroes = data.playerHeroes;
        renderMainMenu();
    })
    .catch(error => {
        console.error('Error loading heroes data:', error);
        showError('فشل في تحميل البيانات');
    });
}

// تحميل بيانات اللاعب
function loadPlayerData() {
    fetch('https://superheroes/getPlayerData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        playerBalance = data.balance;
        currentHero = data.currentHero;
        updateBalanceDisplay();
        updateCurrentHeroDisplay();
    })
    .catch(error => {
        console.error('Error loading player data:', error);
    });
}

// إعداد نظام الصوت
function setupAudio() {
    audioElement = new Audio();
    audioElement.volume = 0.7;
    audioElement.loop = true;
}

// إعداد مستمعي الأحداث
function setupEventListeners() {
    // أزرار القائمة الرئيسية
    document.getElementById('btn-heroes').addEventListener('click', showHeroSelection);
    document.getElementById('btn-inventory').addEventListener('click', showInventory);
    document.getElementById('btn-upgrades').addEventListener('click', showUpgrades);
    document.getElementById('btn-settings').addEventListener('click', showSettings);
    
    // أزرار التنقل
    document.querySelectorAll('.back-btn').forEach(btn => {
        btn.addEventListener('click', showMainMenu);
    });
}

// عرض القائمة الرئيسية
function renderMainMenu() {
    document.getElementById('main-menu').style.display = 'block';
    document.getElementById('hero-selection').style.display = 'none';
    document.getElementById('inventory').style.display = 'none';
    document.getElementById('upgrades').style.display = 'none';
    document.getElementById('settings').style.display = 'none';
    
    currentState = 'main';
    updateBalanceDisplay();
    updateCurrentHeroDisplay();
}

// عرض اختيار الأبطال
function showHeroSelection() {
    document.getElementById('main-menu').style.display = 'none';
    document.getElementById('hero-selection').style.display = 'block';
    
    renderHeroesList();
}

// عرض المخزون
function showInventory() {
    document.getElementById('main-menu').style.display = 'none';
    document.getElementById('inventory').style.display = 'block';
    
    renderInventory();
}

// عرض الترقيات
function showUpgrades() {
    document.getElementById('main-menu').style.display = 'none';
    document.getElementById('upgrades').style.display = 'block';
    
    renderUpgrades();
}

// عرض الإعدادات
function showSettings() {
    document.getElementById('main-menu').style.display = 'none';
    document.getElementById('settings').style.display = 'block';
}

// عرض قائمة الأبطال
function renderHeroesList() {
    const container = document.getElementById('heroes-list');
    container.innerHTML = '';
    
    heroesData.forEach(hero => {
        const isOwned = playerHeroes.includes(hero.hero_id);
        const isEquipped = currentHero === hero.hero_id;
        
        const heroCard = `
            <div class="hero-card ${isEquipped ? 'equipped' : ''} ${isOwned ? 'owned' : 'not-owned'}" 
                 data-hero-id="${hero.hero_id}">
                <div class="hero-image">
                    <img src="assets/images/${hero.image}" alt="${hero.name}">
                    ${isEquipped ? '<div class="equipped-badge">مجهز</div>' : ''}
                </div>
                <div class="hero-info">
                    <h3>${hero.name}</h3>
                    <p class="hero-description">${hero.description}</p>
                    <div class="hero-stats">
                        <span>الطاقة: ${hero.default_energy}</span>
                        <span>التبريد: ${hero.cooldown_default/1000}ثانية</span>
                    </div>
                    <div class="hero-actions">
                        ${isOwned ? 
                            `<button class="equip-btn" onclick="equipHero('${hero.hero_id}')" ${isEquipped ? 'disabled' : ''}>
                                ${isEquipped ? 'مجهز' : 'تجهيز'}
                            </button>` :
                            `<button class="buy-btn" onclick="buyHero('${hero.hero_id}', ${hero.cost})">
                                شراء - $${formatNumber(hero.cost)}
                            </button>`
                        }
                        <button class="preview-btn" onclick="previewHero('${hero.hero_id}')">
                            معاينة
                        </button>
                    </div>
                </div>
            </div>
        `;
        container.innerHTML += heroCard;
    });
}

// شراء بطل
function buyHero(heroId, cost) {
    if (playerBalance < cost) {
        showError('رصيدك غير كافي');
        return;
    }
    
    fetch('https://superheroes/buyHero', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ heroId: heroId, cost: cost })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showSuccess('تم الشراء بنجاح!');
            playerBalance -= cost;
            playerHeroes.push(heroId);
            updateBalanceDisplay();
            renderHeroesList();
        } else {
            showError(data.message || 'فشل في الشراء');
        }
    })
    .catch(error => {
        showError('خطأ في الاتصال');
    });
}

// تجهيز بطل
function equipHero(heroId) {
    fetch('https://superheroes/equipHero', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ heroId: heroId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showSuccess('تم التجهيز بنجاح!');
            currentHero = heroId;
            playHeroMusic(heroId);
            updateCurrentHeroDisplay();
            renderHeroesList();
            updateDiscordPresence(heroId);
        } else {
            showError(data.message || 'فشل في التجهيز');
        }
    })
    .catch(error => {
        showError('خطأ في الاتصال');
    });
}

// إلغاء تجهيز البطل
function unequipHero() {
    fetch('https://superheroes/unequipHero', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showSuccess('تم إلغاء التجهيز');
            currentHero = null;
            stopHeroMusic();
            updateCurrentHeroDisplay();
            renderHeroesList();
            resetDiscordPresence();
        } else {
            showError(data.message || 'فشل في الإلغاء');
        }
    });
}

// تشغيل موسيقى البطل
function playHeroMusic(heroId) {
    const hero = heroesData.find(h => h.hero_id === heroId);
    if (hero && hero.music) {
        audioElement.src = `assets/music/${hero.music}`;
        audioElement.play().catch(error => {
            console.log('لم يتمكن من تشغيل الموسيقى تلقائياً');
        });
    }
}

// إيقاف موسيقى البطل
function stopHeroMusic() {
    if (audioElement) {
        audioElement.pause();
        audioElement.src = '';
    }
}

// تحديث حالة Discord
function updateDiscordPresence(heroId) {
    const hero = heroesData.find(h => h.hero_id === heroId);
    if (hero) {
        fetch('https://superheroes/updateDiscord', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                heroId: heroId,
                heroName: hero.name,
                image: hero.image 
            })
        });
    }
}

// إعادة تعيين حالة Discord
function resetDiscordPresence() {
    fetch('https://superheroes/resetDiscord', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    });
}

// معاينة البطل
function previewHero(heroId) {
    const hero = heroesData.find(h => h.hero_id === heroId);
    if (hero) {
        // تشغيل صوت المعاينة
        const previewAudio = new Audio(`assets/previews/${hero.hero_id}.mp3`);
        previewAudio.volume = 0.5;
        previewAudio.play();
        
        // عرض معلومات البطل
        showModal(`
            <h2>${hero.name}</h2>
            <img src="assets/images/${hero.image}" style="width: 200px; height: 200px; border-radius: 10px;">
            <p>${hero.description}</p>
            <div class="hero-abilities">
                <h3>القدرات:</h3>
                ${hero.abilities.map(ability => `
                    <div class="ability">
                        <strong>${ability.name}</strong>
                        <span>الطاقة: ${ability.energy_cost}</span>
                        <span>التبريد: ${ability.cooldown/1000}ثانية</span>
                    </div>
                `).join('')}
            </div>
        `);
    }
}

// عرض المخزون
function renderInventory() {
    const container = document.getElementById('inventory-items');
    container.innerHTML = '';
    
    playerHeroes.forEach(heroId => {
        const hero = heroesData.find(h => h.hero_id === heroId);
        if (hero) {
            const item = `
                <div class="inventory-item">
                    <img src="assets/images/${hero.image}" alt="${hero.name}">
                    <h4>${hero.name}</h4>
                    <button onclick="equipHero('${hero.hero_id}')">تجهيز</button>
                </div>
            `;
            container.innerHTML += item;
        }
    });
}

// عرض الترقيات
function renderUpgrades() {
    const container = document.getElementById('upgrades-list');
    container.innerHTML = '';
    
    if (currentHero) {
        const hero = heroesData.find(h => h.hero_id === currentHero);
        hero.abilities.forEach(ability => {
            const upgrade = `
                <div class="upgrade-item">
                    <h4>${ability.name}</h4>
                    <p>التكلفة: $${formatNumber(ability.upgradeCost || 1000)}</p>
                    <button onclick="upgradeAbility('${hero.hero_id}', '${ability.key}')">
                        ترقية
                    </button>
                </div>
            `;
            container.innerHTML += upgrade;
        });
    } else {
        container.innerHTML = '<p>ليس لديك بطل مجهز</p>';
    }
}

// ترقية القدرة
function upgradeAbility(heroId, abilityKey) {
    fetch('https://superheroes/upgradeAbility', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 
            heroId: heroId, 
            abilityKey: abilityKey 
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showSuccess('تم الترقية بنجاح!');
            playerBalance -= data.cost;
            updateBalanceDisplay();
        } else {
            showError(data.message || 'فشل في الترقية');
        }
    });
}

// تحديث عرض الرصيد
function updateBalanceDisplay() {
    document.getElementById('player-balance').textContent = formatNumber(playerBalance);
}

// تحديث عرض البطل الحالي
function updateCurrentHeroDisplay() {
    const element = document.getElementById('current-hero');
    if (currentHero) {
        const hero = heroesData.find(h => h.hero_id === currentHero);
        element.innerHTML = `
            <img src="assets/images/${hero.image}" alt="${hero.name}">
            <span>${hero.name}</span>
            <button onclick="unequipHero()">إلغاء التجهيز</button>
        `;
    } else {
        element.innerHTML = '<span>لا يوجد بطل مجهز</span>';
    }
}

// تنسيق الأرقام
function formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// عرض النجاح
function showSuccess(message) {
    const notification = document.createElement('div');
    notification.className = 'notification success';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// عرض الخطأ
function showError(message) {
    const notification = document.createElement('div');
    notification.className = 'notification error';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// عرض Modal
function showModal(content) {
    const modal = document.getElementById('modal');
    const modalContent = document.getElementById('modal-content');
    
    modalContent.innerHTML = content;
    modal.style.display = 'block';
    
    document.getElementById('close-modal').onclick = function() {
        modal.style.display = 'none';
    };
}

// إغلاق Modal
window.onclick = function(event) {
    const modal = document.getElementById('modal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
};

// التواصل مع NUI
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'updateEnergy':
            updateEnergyDisplay(data.value);
            break;
        case 'updateCooldown':
            updateCooldownDisplay(data.ability, data.remaining);
            break;
        case 'showNotification':
            if (data.type === 'success') {
                showSuccess(data.message);
            } else {
                showError(data.message);
            }
            break;
    }
});

// تحديث عرض الطاقة
function updateEnergyDisplay(energy) {
    const energyBar = document.getElementById('energy-bar');
    if (energyBar) {
        energyBar.style.width = energy + '%';
        energyBar.setAttribute('data-value', energy);
    }
}

// تحديث عرض التبريد
function updateCooldownDisplay(ability, remaining) {
    const cooldownElement = document.getElementById(`cooldown-${ability}`);
    if (cooldownElement) {
        cooldownElement.textContent = (remaining / 1000).toFixed(1) + 's';
    }
}

// إغلاق الواجهة
function closeUI() {
    fetch('https://superheroes/closeUI', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    });
}

// إعداد أزرار الإغلاق
document.getElementById('close-btn').addEventListener('click', closeUI);
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});
