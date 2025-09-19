/**
 * HUD API Interface - واجهة برمجة تطبيقات الـHUD
 * للتكامل مع الأنظمة الأخرى عبر JavaScript
 */

class HUDAPI {
    constructor() {
        this.version = '2.2.0';
        this.isInitialized = false;
    }

    /**
     * تهيئة الواجهة البرمجية
     */
    initialize() {
        this.isInitialized = true;
        console.log('✅ HUD API Initialized - Version', this.version);
        return this;
    }

    /**
     * تحديث بيانات HUD
     * @param {Object} data - بيانات التحديث
     */
    updateData(data) {
        if (!this.isInitialized) {
            console.warn('⚠️ HUD API not initialized');
            return false;
        }

        window.dispatchEvent(new CustomEvent('hud:update', {
            detail: data
        }));
        return true;
    }

    /**
     * إظهار/إخفاء HUD
     * @param {Boolean} show - true للإظهار, false للإخفاء
     */
    toggleHUD(show) {
        window.dispatchEvent(new CustomEvent('hud:toggle', {
            detail: { show: show }
        }));
    }

    /**
     * عرض إشعار للمستخدم
     * @param {String} message - نص الإشعار
     * @param {String} type - نوع الإشعار (info, success, error, warning)
     * @param {Number} duration - مدة العرض (ms)
     */
    showNotification(message, type = 'info', duration = 3000) {
        window.dispatchEvent(new CustomEvent('hud:notification', {
            detail: { message, type, duration }
        }));
    }

    /**
     * تشغيل صوت معين
     * @param {String} soundName - اسم الصوت (click, notification, open)
     * @param {Number} volume - مستوى الصوت (0 إلى 1)
     */
    playSound(soundName, volume = 0.7) {
        if (!this.isInitialized) {
            console.warn('⚠️ HUD API not initialized');
            return false;
        }

        window.dispatchEvent(new CustomEvent('hud:sound:play', {
            detail: { soundName, volume }
        }));
        return true;
    }

    /**
     * الحصول على إحصائيات الأداء
     */
    getPerformanceStats() {
        return {
            fps: window.currentFps || 0,
            memory: performance.memory ? performance.memory.usedJSHeapSize : 0,
            loadTime: performance.timing ? performance.timing.loadEventEnd - performance.timing.navigationStart : 0
        };
    }

    /**
     * تغيير سمة الواجهة
     * @param {String} theme - اسم السمة (dark, light, blue, green)
     */
    changeTheme(theme) {
        window.dispatchEvent(new CustomEvent('hud:theme:change', {
            detail: { theme }
        }));
    }

    /**
     * إعادة تعيين إعدادات HUD
     */
    resetSettings() {
        window.dispatchEvent(new CustomEvent('hud:settings:reset'));
    }
}

// إنشاء نسخة عامة من API
window.HUDAPI = new HUDAPI().initialize();

// التصدير للاستخدام في модуالات أخرى
if (typeof module !== 'undefined' && module.exports) {
    module.exports = window.HUDAPI;
}
