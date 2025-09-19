/**
 * نظام عرض المعلومات (HUD) - للعبة FiveM
 * نظام متقدم مع دعم كامل للتخصيص، إمكانية الوصول، وأداء عالي.
 * 
 * @version 2.2.2
 * @license MIT
 * @author Expert Development Team
 */

/* ==========================================================================
   إعدادات التهيئة - CONFIGURATION CONSTANTS
   ========================================================================== */

   const INACTIVITY_TIMEOUT = 30000;
   const THROTTLE_DELAY = 200;
   const DATA_UPDATE_DELAY = 1000;
   const NOTIFICATION_DURATION = 3000;
   const WARNING_THRESHOLD = 20;
   const DEBUG_MODE = false;
   
   /* ==========================================================================
      إدارة الحالة - STATE MANAGEMENT
      ========================================================================== */
   
   const state = {
       health: 100,
       armor: 50,
       hunger: 80,
       thirst: 70,
       cash: 5000,
       bank: 15000,
       job: "شرطي",
       rank: "رقيب",
       wantedLevel: 0,
       inCombat: false,
       
       isDragging: false,
       dragOffset: { x: 0, y: 0 },
       hudVisible: true,
       
       warningPlayed: false,
       
       lastUpdateTimestamps: {
           health: 0, armor: 0, cash: 0, bank: 0,
           job: 0, rank: 0, hunger: 0, thirst: 0
       },
       
       animationFrameId: null,
       inactivityTimer: null,
       fpsCounter: 0,
       lastFpsUpdate: 0,
       currentFps: 0,
       
       settings: {
           theme: 'dark',
           fontSize: 'medium',
           opacity: '0.8',
           layout: 'normal',
           accessibility: 'normal'
       },
       
       sounds: {
           click: new Audio('sounds/click.mp3'),
           notification: new Audio('sounds/notification.mp3'),
           open: new Audio('sounds/open.mp3')
       }
   };
   
   /* ==========================================================================
      عناصر الواجهة - DOM REFERENCES
      ========================================================================== */
   
   // سيتم تهيئة هذه العناصر بعد تحميل الصفحة
   let elements = {};
   
   /**
    * تهيئة جميع عناصر DOM بعد تحميل الصفحة
    */
   const initializeDOMElements = () => {
       elements = {
           hudContainer: document.getElementById('hud-container'),
           hudLoader: document.getElementById('hud-loader'),
           settingsToggle: document.getElementById('settings-toggle'),
           settingsPanel: document.getElementById('settings-panel'),
           
           themeSelect: document.getElementById('theme-select'),
           fontSizeSelect: document.getElementById('font-size-select'),
           opacitySlider: document.getElementById('opacity-slider'),
           opacityValue: document.getElementById('opacity-value'),
           layoutSelect: document.getElementById('layout-select'),
           accessibilitySelect: document.getElementById('accessibility-select'),
           resetPositionBtn: document.getElementById('reset-position'),
           closeSettingsBtn: document.getElementById('close-settings'),
           
           warningSound: document.getElementById('hud-warning-sound'),
           notificationsContainer: document.getElementById('notifications-container'),
           
           healthValue: document.getElementById('health-value'),
           armorValue: document.getElementById('armor-value'),
           hungerValue: document.getElementById('hunger-value'),
           thirstValue: document.getElementById('thirst-value'),
           cashValue: document.getElementById('cash-value'),
           bankValue: document.getElementById('bank-value'),
           jobValue: document.getElementById('job-value'),
           rankValue: document.getElementById('rank-value'),
           wantedValue: document.getElementById('wanted-value'),
           
           wantedElement: document.getElementById('wanted-level'),
           combatElement: document.getElementById('combat-state'),
           hungerElement: document.querySelector('.hunger-bar'),
           thirstElement: document.querySelector('.thirst-bar'),
           healthBar: document.querySelector('.health-bar')
       };
       
       console.log('✅ تم تهيئة عناصر DOM');
   };
   
   /* ==========================================================================
      دوال مساعدة - UTILITY FUNCTIONS
      ========================================================================== */
   
   const utils = {
       validateValue: (value, max) => Math.min(Math.max(0, value), max),
       
       debounce: (func, delay) => {
           let timeoutId;
           return (...args) => {
               clearTimeout(timeoutId);
               timeoutId = setTimeout(() => func.apply(this, args), delay);
           };
       },
       
       throttle: (func, delay) => {
           let lastCall = 0;
           return (...args) => {
               const now = Date.now();
               if (now - lastCall < delay) return;
               lastCall = now;
               return func.apply(this, args);
           };
       },
       
       playSound: (soundElement) => {
           try {
               soundElement.currentTime = 0;
               soundElement.play().catch(e => {
                   console.warn('تعذر تشغيل الصوت:', e);
               });
           } catch (error) {
               console.error('خطأ في تشغيل الصوت:', error);
           }
       },
       
       debugWarn: (message, data = null) => {
           if (DEBUG_MODE) {
               console.warn(`[HUD Debug] ${message}`, data);
           }
       }
   };
   
   /* ==========================================================================
      نظام إدارة الواجهة - HUD MANAGEMENT SYSTEM
      ========================================================================== */
   
   const hudManager = {
       loadSettings: () => {
           try {
               const savedTheme = localStorage.getItem('hudTheme') || 'dark';
               const savedFontSize = localStorage.getItem('hudFontSize') || 'medium';
               const savedOpacity = localStorage.getItem('hudOpacity') || '0.8';
               const savedLayout = localStorage.getItem('hudLayout') || 'normal';
               const savedPosition = localStorage.getItem('hudPosition');
               const savedVisibility = localStorage.getItem('hudVisibility') === 'true';
               const savedAccessibility = localStorage.getItem('hudAccessibility') || 'normal';
               
               if (elements.themeSelect) elements.themeSelect.value = savedTheme;
               if (elements.fontSizeSelect) elements.fontSizeSelect.value = savedFontSize;
               if (elements.opacitySlider) elements.opacitySlider.value = savedOpacity;
               if (elements.layoutSelect) elements.layoutSelect.value = savedLayout;
               if (elements.accessibilitySelect) elements.accessibilitySelect.value = savedAccessibility;
               
               if (elements.opacityValue) {
                   elements.opacityValue.textContent = Math.round(savedOpacity * 100) + '%';
               }
               
               state.settings = {
                   theme: savedTheme,
                   fontSize: savedFontSize,
                   opacity: savedOpacity,
                   layout: savedLayout,
                   accessibility: savedAccessibility
               };
               
               hudManager.applyTheme();
               if (elements.hudContainer) {
                   elements.hudContainer.style.opacity = savedOpacity;
               }
               
               const fontSizeMap = { 
                   small: '12px', medium: '14px', 
                   large: '16px', 'x-large': '18px'
               };
               document.documentElement.style.setProperty('--hud-font-size', fontSizeMap[savedFontSize]);
               
               if (savedPosition && elements.hudContainer) {
                   try {
                       const position = JSON.parse(savedPosition);
                       elements.hudContainer.style.left = position.left;
                       elements.hudContainer.style.top = position.top;
                   } catch (e) {
                       console.error('خطأ في تحميل موضع HUD:', e);
                       hudManager.resetPosition();
                   }
               }
               
               state.hudVisible = savedVisibility;
               
           } catch (error) {
               console.error('فشل في تحميل إعدادات HUD:', error);
               hudManager.resetToDefaults();
           }
       },
       
       saveSettings: () => {
           try {
               localStorage.setItem('hudTheme', elements.themeSelect.value);
               localStorage.setItem('hudFontSize', elements.fontSizeSelect.value);
               localStorage.setItem('hudOpacity', elements.opacitySlider.value);
               localStorage.setItem('hudLayout', elements.layoutSelect.value);
               localStorage.setItem('hudVisibility', state.hudVisible.toString());
               localStorage.setItem('hudAccessibility', elements.accessibilitySelect.value);
               
               state.settings = {
                   theme: elements.themeSelect.value,
                   fontSize: elements.fontSizeSelect.value,
                   opacity: elements.opacitySlider.value,
                   layout: elements.layoutSelect.value,
                   accessibility: elements.accessibilitySelect.value
               };
               
           } catch (error) {
               console.error('فشل في حفظ إعدادات HUD:', error);
           }
       },
       
       applyTheme: () => {
           if (elements.hudContainer) {
               elements.hudContainer.className = `${state.settings.theme}-theme ${state.settings.layout} ${state.settings.accessibility}`;
           }
       },
       
       updateHUD: () => {
           state.health = utils.validateValue(state.health, 100);
           state.armor = utils.validateValue(state.armor, 100);
           state.hunger = utils.validateValue(state.hunger, 100);
           state.thirst = utils.validateValue(state.thirst, 100);
           
           if (elements.healthValue) elements.healthValue.textContent = state.health;
           if (elements.armorValue) elements.armorValue.textContent = state.armor;
           if (elements.hungerValue) elements.hungerValue.textContent = state.hunger;
           if (elements.thirstValue) elements.thirstValue.textContent = state.thirst;
           if (elements.cashValue) elements.cashValue.textContent = state.cash.toLocaleString();
           if (elements.bankValue) elements.bankValue.textContent = state.bank.toLocaleString();
           if (elements.jobValue) elements.jobValue.textContent = state.job;
           if (elements.rankValue) elements.rankValue.textContent = state.rank;
           if (elements.wantedValue) elements.wantedValue.textContent = state.wantedLevel;
           
           if (elements.wantedElement) {
               elements.wantedElement.classList.toggle('hidden', state.wantedLevel === 0);
           }
           if (elements.combatElement) {
               elements.combatElement.classList.toggle('hidden', !state.inCombat);
               elements.combatElement.classList.toggle('combat-active', state.inCombat);
           }
           if (elements.hungerElement) {
               elements.hungerElement.classList.toggle('low', state.hunger < WARNING_THRESHOLD);
           }
           if (elements.thirstElement) {
               elements.thirstElement.classList.toggle('low', state.thirst < WARNING_THRESHOLD);
           }
           
           if (state.health < WARNING_THRESHOLD && elements.healthBar && elements.warningSound) {
               elements.healthBar.classList.add('low');
               if (!state.warningPlayed) {
                   utils.playSound(elements.warningSound);
                   state.warningPlayed = true;
                   notificationManager.showNotification('تحذير: مستوى الصحة منخفض', 3000, 'warning', true);
               }
           } else if (elements.healthBar) {
               elements.healthBar.classList.remove('low');
               state.warningPlayed = false;
           }
           
           if (state.wantedLevel > 0 && elements.wantedElement) {
               elements.wantedElement.classList.add('wanted-updated');
               setTimeout(() => {
                   if (elements.wantedElement) {
                       elements.wantedElement.classList.remove('wanted-updated');
                   }
               }, 2000);
           }
       },
       
       toggleHUD: (show) => {
           if (!elements.hudContainer) {
               console.warn("⚠️ عنصر hudContainer غير موجود في الصفحة.");
               return;
           }
           
           state.hudVisible = typeof show === 'undefined' ? !state.hudVisible : show;
           
           if (state.hudVisible) {
               elements.hudContainer.classList.remove('hidden');
               elements.hudContainer.classList.add('visible');
               activityManager.resetInactivityTimer();
               soundManager.playSound('open');
           } else {
               elements.hudContainer.classList.remove('visible');
               elements.hudContainer.classList.add('hidden');
               soundManager.playSound('click');
           }
           
           try {
               localStorage.setItem('hudVisibility', state.hudVisible.toString());
           } catch (e) {
               console.warn("⚠️ لم يتم حفظ حالة الإظهار في localStorage:", e);
           }
       },
       
       resetPosition: () => {
           if (elements.hudContainer) {
               elements.hudContainer.style.left = '20px';
               elements.hudContainer.style.top = '20px';
               localStorage.removeItem('hudPosition');
               notificationManager.showNotification('تم إعادة تعيين موضع HUD', 2000, 'success');
               soundManager.playSound('click');
           }
       },
       
       hideLoader: () => {
           if (elements.hudLoader) {
               elements.hudLoader.style.display = 'none';
           }
       },
       
       resetToDefaults: () => {
           localStorage.clear();
           hudManager.loadSettings();
           notificationManager.showNotification('تم إعادة التعيين إلى الإعدادات الافتراضية', 3000, 'info');
           soundManager.playSound('click');
       }
   };
   
   /* ==========================================================================
      نظام الإشعارات - NOTIFICATION SYSTEM
      ========================================================================== */
   
   const notificationManager = {
       showNotification: (text, duration = NOTIFICATION_DURATION, type = 'info', important = false) => {
           if (!elements.notificationsContainer) return null;
           
           const notification = document.createElement('div');
           notification.className = `notification ${type}`;
           notification.textContent = text;
           notification.setAttribute('role', important ? 'alert' : 'status');
           notification.setAttribute('aria-live', important ? 'assertive' : 'polite');
           
           elements.notificationsContainer.appendChild(notification);
           
           // تشغيل صوت الإشعار إذا كان مهماً
           if (important) {
               soundManager.playSound('notification');
           }
           
           setTimeout(() => {
               notification.classList.add('fade-out');
               setTimeout(() => {
                   if (notification.parentNode) {
                       elements.notificationsContainer.removeChild(notification);
                   }
               }, 300);
           }, duration);
           
           return notification;
       },
       
       clearAll: () => {
           if (elements.notificationsContainer) {
               while (elements.notificationsContainer.firstChild) {
                   elements.notificationsContainer.removeChild(elements.notificationsContainer.firstChild);
               }
           }
       }
   };
   
   /* ==========================================================================
      نظام إدارة الأصوات - SOUND MANAGEMENT SYSTEM
      ========================================================================== */
   
   const soundManager = {
       /**
        * تهيئة الأصوات وتحضيرها للاستخدام
        */
       initializeSounds: () => {
           try {
               // تحميل جميع الأصوات مسبقاً
               Object.values(state.sounds).forEach(sound => {
                   sound.volume = 0.7;
                   sound.load();
               });
               console.log('✅ تم تهيئة الأصوات بنجاح');
           } catch (error) {
               console.error('❌ فشل في تهيئة الأصوات:', error);
           }
       },
   
       /**
        * تشغيل صوت محدد
        * @param {String} soundName - اسم الصوت
        * @param {Number} volume - مستوى الصوت (0 إلى 1)
        */
       playSound: (soundName, volume = 0.7) => {
           try {
               if (state.sounds[soundName]) {
                   state.sounds[soundName].volume = Math.min(Math.max(volume, 0), 1);
                   state.sounds[soundName].currentTime = 0;
                   
                   const playPromise = state.sounds[soundName].play();
                   
                   if (playPromise !== undefined) {
                       playPromise.catch(error => {
                           console.warn(`تعذر تشغيل الصوت ${soundName}:`, error);
                       });
                   }
                   
                   return true;
               } else {
                   console.warn(`⚠️ الصوت ${soundName} غير موجود`);
                   return false;
               }
           } catch (error) {
               console.error(`❌ خطأ في تشغيل الصوت ${soundName}:`, error);
               return false;
           }
       },
   
       /**
        * إيقاف صوت محدد
        * @param {String} soundName - اسم الصوت
        */
       stopSound: (soundName) => {
           if (state.sounds[soundName]) {
               state.sounds[soundName].pause();
               state.sounds[soundName].currentTime = 0;
           }
       },
   
       /**
        * ضبط مستوى الصوت العام
        * @param {Number} volume - مستوى الصوت (0 إلى 1)
        */
       setMasterVolume: (volume) => {
           const normalizedVolume = Math.min(Math.max(volume, 0), 1);
           Object.values(state.sounds).forEach(sound => {
               sound.volume = normalizedVolume;
           });
       }
   };
   
   /* ==========================================================================
      تتبع النشاط - ACTIVITY TRACKING
      ========================================================================== */
   
   const activityManager = {
       resetInactivityTimer: () => {
           clearTimeout(state.inactivityTimer);
           if (state.hudVisible) {
               state.inactivityTimer = setTimeout(() => {
                   hudManager.toggleHUD(false);
                   notificationManager.showNotification('تم إخفاء HUD تلقائياً بسبب عدم النشاط', 2000, 'info');
               }, INACTIVITY_TIMEOUT);
           }
       },
       
       setupActivityListeners: () => {
           const debouncedReset = utils.debounce(activityManager.resetInactivityTimer, 250);
           document.addEventListener('mousemove', debouncedReset);
           document.addEventListener('keydown', debouncedReset);
           document.addEventListener('click', debouncedReset);
           document.addEventListener('touchstart', debouncedReset);
       }
   };
   
   /* ==========================================================================
      مراقبة الأداء - PERFORMANCE MONITORING
      ========================================================================== */
   
   const performanceMonitor = {
       updateFPS: () => {
           state.fpsCounter++;
           const now = Date.now();
           if (now - state.lastFpsUpdate > 1000) {
               state.currentFps = state.fpsCounter;
               state.fpsCounter = 0;
               state.lastFpsUpdate = now;
               
               const fpsElement = document.getElementById('fps-counter');
               if (fpsElement) {
                   fpsElement.textContent = `FPS: ${state.currentFps}`;
                   
                   if (state.currentFps < 30 && DEBUG_MODE) {
                       utils.debugWarn('أداء منخفض - معدل FPS أقل من 30');
                   }
               }
           }
           requestAnimationFrame(performanceMonitor.updateFPS);
       },
       
       updateClock: () => {
           const clockElement = document.getElementById('hud-clock');
           if (clockElement) {
               const now = new Date();
               clockElement.textContent = now.toLocaleTimeString('ar-SA', { 
                   hour: '2-digit', 
                   minute: '2-digit', 
                   hour12: true 
               });
           }
       },
       
       getStats: () => ({
           fps: state.currentFps,
           memory: performance.memory ? performance.memory.usedJSHeapSize : 0,
           loadTime: performance.timing ? performance.timing.loadEventEnd - performance.timing.navigationStart : 0
       })
   };
   
   /* ==========================================================================
      محاكاة البيانات - DATA SIMULATION
      ========================================================================== */
   
   const dataSimulator = {
       _simulationInterval: null,
       
       simulateData: () => {
           if (!DEBUG_MODE) {
               utils.debugWarn('وضع المحاكاة متاح فقط في وضع التصحيح');
               return null;
           }
           
           if (dataSimulator._simulationInterval) {
               clearInterval(dataSimulator._simulationInterval);
           }
           
           dataSimulator._simulationInterval = setInterval(() => {
               const mockData = {
                   type: 'updateHUD',
                   health: Math.floor(Math.random() * 100),
                   armor: Math.floor(Math.random() * 100),
                   hunger: Math.floor(Math.random() * 100),
                   thirst: Math.floor(Math.random() * 100),
                   cash: Math.floor(Math.random() * 10000),
                   bank: Math.floor(Math.random() * 50000),
                   job: ["شرطي", "طبيب", "سائق", "تاجر"][Math.floor(Math.random() * 4)],
                   rank: ["جندي", "رقيب", "ملازم", "نقيب"][Math.floor(Math.random() * 4)],
                   wantedLevel: Math.floor(Math.random() * 5),
                   inCombat: Math.random() > 0.5
               };
               
               window.dispatchEvent(new MessageEvent('message', { data: mockData }));
           }, 2000);
           
           utils.debugWarn('تم تفعيل وضع محاكاة البيانات للاختبار');
           return dataSimulator._simulationInterval;
       },
       
       stopSimulation: () => {
           if (dataSimulator._simulationInterval) {
               clearInterval(dataSimulator._simulationInterval);
               dataSimulator._simulationInterval = null;
               utils.debugWarn('تم إيقاف وضع محاكاة البيانات');
           }
       }
   };
   
   /* ==========================================================================
      معالجة الأحداث - EVENT HANDLING
      ========================================================================== */
   
   const eventHandlers = {
       handleDragStart: (e) => {
           state.isDragging = true;
           const clientX = e.clientX || e.touches[0].clientX;
           const clientY = e.clientY || e.touches[0].clientY;
           
           state.dragOffset.x = clientX - elements.hudContainer.getBoundingClientRect().left;
           state.dragOffset.y = clientY - elements.hudContainer.getBoundingClientRect().top;
           elements.hudContainer.classList.add('draggable');
           
           if (e.type === 'touchstart') e.preventDefault();
       },
       
       handleDragMove: (e) => {
           if (!state.isDragging) return;
           
           const clientX = e.clientX || e.touches[0].clientX;
           const clientY = e.clientY || e.touches[0].clientY;
           
           elements.hudContainer.style.left = (clientX - state.dragOffset.x) + 'px';
           elements.hudContainer.style.top = (clientY - state.dragOffset.y) + 'px';
           
           if (e.type === 'touchmove') e.preventDefault();
       },
       
       handleDragEnd: () => {
           state.isDragging = false;
           elements.hudContainer.classList.remove('draggable');
           
           localStorage.setItem('hudPosition', JSON.stringify({
               left: elements.hudContainer.style.left,
               top: elements.hudContainer.style.top
           }));
           
           soundManager.playSound('click');
       },
       
       /**
        * معالج حدث تشغيل الصوت
        */
       handleSoundPlay: (event) => {
           const { soundName, volume } = event.detail;
           soundManager.playSound(soundName, volume);
       },
       
       handleKeyDown: (e) => {
           if (e.key.toLowerCase() === 'h') {
               hudManager.toggleHUD();
               notificationManager.showNotification(
                   state.hudVisible ? 'تم إظهار HUD' : 'تم إخفاء HUD', 
                   2000, 
                   'info'
               );
           }
           
           if (e.key === 'F10') {
            elements.settingsPanel.classList.toggle('hidden');
            const isHidden = elements.settingsPanel.classList.contains('hidden');
            elements.settingsPanel.setAttribute('aria-hidden', isHidden ? 'true' : 'false');
            soundManager.playSound('open');
        
            notificationManager.showNotification(
                isHidden ? 'تم إغلاق الإعدادات' : 'تم فتح الإعدادات', 
                2000, 
                'info'
            );
        }
           
           if (e.ctrlKey && e.key === 'f') {
               const fpsElement = document.getElementById('fps-counter');
               if (fpsElement) {
                   fpsElement.style.display = fpsElement.style.display === 'none' ? 'block' : 'none';
                   soundManager.playSound('click');
               }
           }
           
           if (e.ctrlKey && e.key === 't' && DEBUG_MODE) {
               dataSimulator.simulateData();
               notificationManager.showNotification('تم تفعيل وضع الاختبار', 3000, 'success');
               soundManager.playSound('notification');
           }
           
           if (e.altKey && e.key === '1') {
               document.body.classList.toggle('accessibility-high-contrast');
               notificationManager.showNotification(
                   document.body.classList.contains('accessibility-high-contrast') ? 
                   'تم تفعيل وضع التباين العالي' : 'تم إيقاف وضع التباين العالي', 
                   2000, 
                   'info'
               );
               soundManager.playSound('click');
           }
           
           if (e.ctrlKey && e.shiftKey && e.key === 'T' && DEBUG_MODE) {
               dataSimulator.stopSimulation();
               notificationManager.showNotification('تم إيقاف وضع الاختبار', 3000, 'info');
               soundManager.playSound('notification');
           }
       },
       
       handleMessage: (event) => {
           const data = event.data;
           const now = Date.now();
           
           if (data.type === 'updateHUD') {
               if (!state.animationFrameId) {
                   state.animationFrameId = requestAnimationFrame(() => {
                       if (data.health !== undefined && now - state.lastUpdateTimestamps.health > THROTTLE_DELAY) {
                           state.health = data.health;
                           state.lastUpdateTimestamps.health = now;
                       }
                       
                       if (data.armor !== undefined && now - state.lastUpdateTimestamps.armor > THROTTLE_DELAY) {
                           state.armor = data.armor;
                           state.lastUpdateTimestamps.armor = now;
                       }
                       
                       if (data.hunger !== undefined && now - state.lastUpdateTimestamps.hunger > THROTTLE_DELAY) {
                           state.hunger = data.hunger;
                           state.lastUpdateTimestamps.hunger = now;
                       }
                       
                       if (data.thirst !== undefined && now - state.lastUpdateTimestamps.thirst > THROTTLE_DELAY) {
                           state.thirst = data.thirst;
                           state.lastUpdateTimestamps.thirst = now;
                       }
                       
                       if (data.cash !== undefined && now - state.lastUpdateTimestamps.cash > DATA_UPDATE_DELAY) {
                           state.cash = data.cash;
                           state.lastUpdateTimestamps.cash = now;
                           document.querySelector('.cash')?.classList.add('updated');
                           setTimeout(() => document.querySelector('.cash')?.classList.remove('updated'), 500);
                       }
                       
                       if (data.bank !== undefined && now - state.lastUpdateTimestamps.bank > DATA_UPDATE_DELAY) {
                           state.bank = data.bank;
                           state.lastUpdateTimestamps.bank = now;
                           document.querySelector('.bank')?.classList.add('updated');
                           setTimeout(() => document.querySelector('.bank')?.classList.remove('updated'), 500);
                       }
                       
                       if (data.job !== undefined && now - state.lastUpdateTimestamps.job > DATA_UPDATE_DELAY) {
                           state.job = data.job;
                           state.lastUpdateTimestamps.job = now;
                       }
                       
                       if (data.rank !== undefined && now - state.lastUpdateTimestamps.rank > DATA_UPDATE_DELAY) {
                           state.rank = data.rank;
                           state.lastUpdateTimestamps.rank = now;
                       }
                       
                       if (data.wantedLevel !== undefined) state.wantedLevel = data.wantedLevel;
                       if (data.inCombat !== undefined) state.inCombat = data.inCombat;
                       
                       hudManager.updateHUD();
                       state.animationFrameId = null;
                   });
               }
           } else if (data.type === 'showHUD') {
               hudManager.toggleHUD(true);
           } else if (data.type === 'hideHUD') {
               hudManager.toggleHUD(false);
           } else if (data.type === 'notification') {
               notificationManager.showNotification(data.message, data.duration, data.type || 'info');
           }
       },
       
       /**
        * إعداد مستمعي أحداث الإعدادات - الإصلاح الرئيسي هنا
        */
       setupSettingsEvents: () => {
           // التأكد من وجود العناصر قبل إضافة event listeners
           if (!elements.settingsToggle || !elements.settingsPanel) {
               console.error('❌ عناصر الإعدادات غير موجودة لإضافة event listeners');
               return;
           }
           
           console.log('✅ بدء إعداد event listeners للإعدادات');
           
           // زر فتح/غلق الإعدادات
           elements.settingsToggle.addEventListener('click', () => {
               if (!elements.settingsPanel) return;
           
               elements.settingsPanel.classList.toggle('hidden');
               const isHidden = elements.settingsPanel.classList.contains('hidden');
               elements.settingsPanel.setAttribute('aria-hidden', isHidden ? 'true' : 'false');
               soundManager.playSound('open');
           
               console.log(isHidden ? '📁 تم إغلاق لوحة الإعدادات' : '📂 تم فتح لوحة الإعدادات');
               notificationManager.showNotification(
                   isHidden ? 'تم إغلاق الإعدادات' : 'تم فتح الإعدادات',
                   2000,
                   'info'
               );
           });
           
           // زر الإغلاق داخل الإعدادات
           if (elements.closeSettingsBtn) {
               elements.closeSettingsBtn.addEventListener('click', () => {
                   elements.settingsPanel.classList.add('hidden');
                   elements.settingsPanel.setAttribute('aria-hidden', 'true');
                   notificationManager.showNotification('تم إغلاق الإعدادات', 2000, 'info');
                   soundManager.playSound('click');
               });
           }
           
           // الأحداث الأخرى للإعدادات
           if (elements.themeSelect) {
               elements.themeSelect.addEventListener('change', () => {
                   elements.hudContainer.classList.add('theme-changing');
                   setTimeout(() => {
                       hudManager.applyTheme();
                       elements.hudContainer.classList.remove('theme-changing');
                   }, 500);
                   hudManager.saveSettings();
                   soundManager.playSound('click');
               });
           }
           
           if (elements.fontSizeSelect) {
               elements.fontSizeSelect.addEventListener('change', () => {
                   const fontSizeMap = { 
                       small: '12px', medium: '14px', 
                       large: '16px', 'x-large': '18px'
                   };
                   document.documentElement.style.setProperty('--hud-font-size', fontSizeMap[elements.fontSizeSelect.value]);
                   hudManager.saveSettings();
                   soundManager.playSound('click');
               });
           }
           
           if (elements.opacitySlider) {
               elements.opacitySlider.addEventListener('input', () => {
                   elements.hudContainer.style.opacity = elements.opacitySlider.value;
                   if (elements.opacityValue) {
                       elements.opacityValue.textContent = Math.round(elements.opacitySlider.value * 100) + '%';
                   }
                   hudManager.saveSettings();
                   soundManager.playSound('click');
               });
           }
           
           if (elements.layoutSelect) {
               elements.layoutSelect.addEventListener('change', () => {
                   hudManager.applyTheme();
                   hudManager.saveSettings();
                   soundManager.playSound('click');
               });
           }
           
           if (elements.accessibilitySelect) {
               elements.accessibilitySelect.addEventListener('change', () => {
                   state.settings.accessibility = elements.accessibilitySelect.value;
                   hudManager.applyTheme();
                   hudManager.saveSettings();
                   soundManager.playSound('click');
               });
           }
           
           if (elements.resetPositionBtn) {
               elements.resetPositionBtn.addEventListener('click', hudManager.resetPosition);
           }
           
           console.log('✅ تم إعداد جميع event listeners للإعدادات');
       }
   };
   
   /* ==========================================================================
      تهيئة النظام - INITIALIZATION
      ========================================================================== */
   
   const initHUD = () => {
       try {
           console.log('🚀 بدء تهيئة نظام HUD...');
           
           // 1. تهيئة عناصر DOM أولاً
           initializeDOMElements();
           
           // 2. التحقق من وجود العناصر الأساسية
           if (!elements.settingsToggle || !elements.settingsPanel) {
               console.error('❌ عناصر الإعدادات غير موجودة في DOM');
               console.log('settingsToggle:', elements.settingsToggle);
               console.log('settingsPanel:', elements.settingsPanel);
               return;
           }
           
           console.log('✅ تم العثور على جميع عناصر الإعدادات');
           
           // 3. تحميل الإعدادات والتطبيق
           hudManager.loadSettings();
           hudManager.updateHUD();
           
           // 4. إخفاء شاشة التحميل
           setTimeout(hudManager.hideLoader, 1500);
           
           // 5. تطبيق حالة الإظهار/الإخفاء
           hudManager.toggleHUD(state.hudVisible);
           
           // 6. تهيئة نظام الأصوات
           soundManager.initializeSounds();
           
           // 7. إعداد event listeners للإعدادات (الأهم)
           eventHandlers.setupSettingsEvents();
           
           // 8. إعداد أنظمة المساعدة
           activityManager.setupActivityListeners();
           performanceMonitor.updateFPS();
           setInterval(performanceMonitor.updateClock, 1000);
           
           // 9. إضافة مستمع حدث للأصوات
           window.addEventListener('hud:sound:play', eventHandlers.handleSoundPlay);
           
           // 10. إعداد مستمعي الأحداث الأخرى
           if (elements.hudContainer) {
               elements.hudContainer.addEventListener('mousedown', eventHandlers.handleDragStart);
               elements.hudContainer.addEventListener('touchstart', eventHandlers.handleDragStart, { passive: false });
           }
           
           document.addEventListener('mousemove', eventHandlers.handleDragMove);
           document.addEventListener('touchmove', eventHandlers.handleDragMove, { passive: false });
           
           document.addEventListener('mouseup', eventHandlers.handleDragEnd);
           document.addEventListener('touchend', eventHandlers.handleDragEnd);
           
           document.addEventListener('keydown', eventHandlers.handleKeyDown);
           window.addEventListener('message', eventHandlers.handleMessage);
           
           // 11. معالج تغيير حجم النافذة
           window.addEventListener('resize', utils.debounce(() => {
               if (elements.hudContainer) {
                   const hudRect = elements.hudContainer.getBoundingClientRect();
                   const viewportWidth = window.innerWidth;
                   const viewportHeight = window.innerHeight;
                   
                   if (hudRect.right > viewportWidth) {
                       elements.hudContainer.style.left = (viewportWidth - hudRect.width - 10) + 'px';
                   }
                   
                   if (hudRect.bottom > viewportHeight) {
                       elements.hudContainer.style.top = (viewportHeight - hudRect.height - 10) + 'px';
                   }
               }
           }, 250));
           
           console.log('✅ تم تهيئة HUD بنجاح - الإصدار 2.2.2');
           
       } catch (error) {
           console.error('❌ فشل في تهيئة HUD:', error);
           notificationManager.showNotification('خطأ في تحميل HUD', 5000, 'error');
       }
   };
   
   /* ==========================================================================
      بدء التشغيل - STARTUP EXECUTION
      ========================================================================== */
   
   // الانتظار حتى تحميل DOM بالكامل
   document.addEventListener('DOMContentLoaded', function() {
       console.log('📄 تم تحميل DOM بالكامل');
       setTimeout(initHUD, 100);
   });
   
   /* ==========================================================================
      واجهة برمجة التطبيقات العامة - PUBLIC API
      ========================================================================== */
   
   if (typeof window !== 'undefined') {
       window.HUD = {
           toggle: hudManager.toggleHUD,
           showNotification: notificationManager.showNotification,
           updateData: (data) => window.dispatchEvent(new MessageEvent('message', { data })),
           simulateData: dataSimulator.simulateData,
           stopSimulation: dataSimulator.stopSimulation,
           getPerformanceStats: performanceMonitor.getStats,
           resetSettings: hudManager.resetToDefaults,
           playSound: soundManager.playSound
       };
   }