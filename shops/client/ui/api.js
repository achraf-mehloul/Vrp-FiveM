// API للتواصل مع سيرفر المتاجر
class ShopsAPI {
    constructor() {
        this.baseURL = 'https://cfx-nui-shops';
        this.eventHandlers = {};
        this.setupMessageListeners();
    }

    setupMessageListeners() {
        window.addEventListener('message', (event) => {
            const { action, data } = event.data;
            
            if (this.eventHandlers[action]) {
                this.eventHandlers[action](data);
            }
        });
    }

    on(action, callback) {
        this.eventHandlers[action] = callback;
    }

    emit(action, data = {}) {
        fetch(`${this.baseURL}/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        }).catch(error => {
            console.error('API Error:', error);
        });
    }

    // الحصول على بيانات المتجر
    async getShopData() {
        return new Promise((resolve, reject) => {
            this.on('shopDataReceived', (data) => {
                resolve(data);
            });

            this.emit('getShopData');
            
            // timeout للسلامة
            setTimeout(() => reject(new Error('Timeout loading shop data')), 10000);
        });
    }

    // شراء العناصر
    async purchaseItems(items) {
        return new Promise((resolve, reject) => {
            this.on('purchaseResult', (data) => {
                resolve(data);
            });

            this.emit('purchaseItems', { items });
            
            setTimeout(() => reject(new Error('Purchase timeout')), 10000);
        });
    }

    // حفظ السلة
    saveCart(items) {
        this.emit('saveCart', { items });
    }

    // تحميل السلة
    async loadCart() {
        return new Promise((resolve) => {
            this.on('cartLoaded', (data) => {
                resolve(data);
            });

            this.emit('loadCart');
        });
    }

    // البحث في المتجر
    searchItems(query) {
        this.emit('searchItems', { query });
    }

    // الفرز
    sortItems(sortBy) {
        this.emit('sortItems', { sortBy });
    }

    // الحصول على رصيد اللاعب
    async getPlayerBalance() {
        return new Promise((resolve) => {
            this.on('balanceReceived', (data) => {
                resolve(data);
            });

            this.emit('getBalance');
        });
    }

    // إغلاق المتجر
    closeShop() {
        this.emit('closeShop');
    }

    // فتح إدارة المتجر (للمسؤولين)
    openAdminPanel() {
        this.emit('openAdminPanel');
    }

    // تحديث بيانات المتجر (للمسؤولين)
    updateShopItems(updates) {
        this.emit('updateShopItems', { updates });
    }

    // إضافة عنصر جديد (للمسؤولين)
    addNewItem(itemData) {
        this.emit('addNewItem', { itemData });
    }

    // حذف عنصر (للمسؤولين)
    removeItem(itemName) {
        this.emit('removeItem', { itemName });
    }

    // إعادة تعيين المخزون (للمسؤولين)
    restockShop() {
        this.emit('restockShop');
    }

    // الحصول على الإحصائيات
    async getStatistics() {
        return new Promise((resolve) => {
            this.on('statisticsReceived', (data) => {
                resolve(data);
            });

            this.emit('getStatistics');
        });
    }

    // تصدير البيانات
    async exportData(format = 'json') {
        return new Promise((resolve) => {
            this.on('dataExported', (data) => {
                resolve(data);
            });

            this.emit('exportData', { format });
        });
    }

    // استيراد البيانات
    importData(data) {
        this.emit('importData', { data });
    }

    // النسخ الاحتياطي
    createBackup() {
        this.emit('createBackup');
    }

    // الاستعادة من النسخة
    restoreBackup(backupId) {
        this.emit('restoreBackup', { backupId });
    }

    // إدارة الصلاحيات
    managePermissions(permissions) {
        this.emit('managePermissions', { permissions });
    }

    // تسجيل الأخطاء
    logError(error) {
        this.emit('logError', { error });
    }

    // إرسال إشعار
    showNotification(message, type = 'info') {
        this.emit('showNotification', { message, type });
    }

    // تشغيل صوت
    playSound(soundName) {
        this.emit('playSound', { soundName });
    }

    // تحديث الواجهة
    updateUI(data) {
        this.emit('updateUI', { data });
    }

    // التحقق من التحديثات
    async checkForUpdates() {
        return new Promise((resolve) => {
            this.on('updateCheckComplete', (data) => {
                resolve(data);
            });

            this.emit('checkForUpdates');
        });
    }

    // إعادة تحميل المتجر
    reloadShop() {
        this.emit('reloadShop');
    }

    // إغلاق جميع النوافذ
    closeAllWindows() {
        this.emit('closeAllWindows');
    }
}

// إنشاء instance من API
window.API = new ShopsAPI();
