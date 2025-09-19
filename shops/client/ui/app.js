// تطبيق متاجر Melix Files
class ShopsApp {
    constructor() {
        this.currentShop = null;
        this.cart = [];
        this.isCartOpen = false;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadShopData();
        this.updateCartDisplay();
    }

    setupEventListeners() {
        // البحث
        document.getElementById('searchInput').addEventListener('input', (e) => {
            this.filterItems(e.target.value);
        });

        // الفرز
        document.getElementById('sortSelect').addEventListener('change', (e) => {
            this.sortItems(e.target.value);
        });

        // السلة
        document.getElementById('cartButton').addEventListener('click', () => {
            this.toggleCart();
        });

        document.getElementById('closeCart').addEventListener('click', () => {
            this.closeCart();
        });

        document.getElementById('checkoutButton').addEventListener('click', () => {
            this.checkout();
        });

        document.getElementById('clearCartButton').addEventListener('click', () => {
            this.clearCart();
        });

        // إغلاق السلة بالنقر خارجها
        document.addEventListener('click', (e) => {
            const cartModal = document.getElementById('cartModal');
            if (e.target === cartModal) {
                this.closeCart();
            }
        });
    }

    async loadShopData() {
        try {
            // طلب بيانات المتجر من السيرفر
            const shopData = await API.getShopData();
            this.currentShop = shopData;
            this.displayItems(shopData.items);
        } catch (error) {
            this.showNotification('فشل في تحميل بيانات المتجر', 'error');
            console.error('Error loading shop data:', error);
        }
    }

    displayItems(items) {
        const itemsGrid = document.getElementById('itemsGrid');
        itemsGrid.innerHTML = '';

        items.forEach(item => {
            const itemCard = this.createItemCard(item);
            itemsGrid.appendChild(itemCard);
        });
    }

    createItemCard(item) {
        const card = document.createElement('div');
        card.className = 'item-card';
        card.innerHTML = `
            <img src="assets/images/${item.image}" alt="${item.label}" class="item-image">
            <h3 class="item-name">${item.label}</h3>
            <div class="item-price">${this.formatPrice(item.price)}</div>
            <div class="item-stock">المخزون: ${item.stock}</div>
            <div class="item-actions">
                <input type="number" class="quantity-input" value="1" min="1" max="${item.stock}">
                <button class="buy-btn" data-item='${JSON.stringify(item)}'>شراء</button>
            </div>
        `;

        // إضافة حدث الشراء
        card.querySelector('.buy-btn').addEventListener('click', (e) => {
            const itemData = JSON.parse(e.target.dataset.item);
            const quantity = parseInt(card.querySelector('.quantity-input').value);
            this.addToCart(itemData, quantity);
        });

        return card;
    }

    addToCart(item, quantity) {
        if (quantity < 1 || quantity > item.stock) {
            this.showNotification('الكمية غير صالحة', 'error');
            return;
        }

        // التحقق إذا كان العنصر موجودًا بالفعل في السلة
        const existingItem = this.cart.find(cartItem => cartItem.name === item.name);
        
        if (existingItem) {
            existingItem.quantity += quantity;
        } else {
            this.cart.push({
                ...item,
                quantity: quantity
            });
        }

        this.updateCartDisplay();
        this.showNotification(`تم إضافة ${quantity} من ${item.label} إلى السلة`, 'success');
        this.playSound('purchaseSound');
    }

    removeFromCart(itemName) {
        this.cart = this.cart.filter(item => item.name !== itemName);
        this.updateCartDisplay();
    }

    updateCartItemQuantity(itemName, newQuantity) {
        const item = this.cart.find(item => item.name === itemName);
        if (item) {
            if (newQuantity < 1) {
                this.removeFromCart(itemName);
            } else if (newQuantity > item.stock) {
                this.showNotification('لا يوجد مخزون كافٍ', 'error');
            } else {
                item.quantity = newQuantity;
                this.updateCartDisplay();
            }
        }
    }

    updateCartDisplay() {
        const cartCount = document.querySelector('.cart-count');
        const cartTotal = document.querySelector('.cart-total');
        const cartItems = document.getElementById('cartItems');

        // تحديث العدد والإجمالي
        const totalItems = this.cart.reduce((sum, item) => sum + item.quantity, 0);
        const totalAmount = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

        cartCount.textContent = totalItems;
        cartTotal.textContent = `المجموع: ${this.formatPrice(totalAmount)}`;

        // تحديث عناصر السلة
        cartItems.innerHTML = '';
        this.cart.forEach(item => {
            const cartItem = document.createElement('div');
            cartItem.className = 'cart-item';
            cartItem.innerHTML = `
                <div class="cart-item-info">
                    <img src="assets/images/${item.image}" alt="${item.label}" class="cart-item-image">
                    <div class="cart-item-details">
                        <div class="cart-item-name">${item.label}</div>
                        <div class="cart-item-price">${this.formatPrice(item.price)} لكل وحدة</div>
                    </div>
                </div>
                <div class="cart-item-quantity">
                    <button class="quantity-btn decrease" data-item="${item.name}">-</button>
                    <span>${item.quantity}</span>
                    <button class="quantity-btn increase" data-item="${item.name}">+</button>
                    <button class="remove-item-btn" data-item="${item.name}">×</button>
                </div>
            `;

            // إضافة الأحداث
            cartItem.querySelector('.decrease').addEventListener('click', (e) => {
                const itemName = e.target.dataset.item;
                this.updateCartItemQuantity(itemName, item.quantity - 1);
            });

            cartItem.querySelector('.increase').addEventListener('click', (e) => {
                const itemName = e.target.dataset.item;
                this.updateCartItemQuantity(itemName, item.quantity + 1);
            });

            cartItem.querySelector('.remove-item-btn').addEventListener('click', (e) => {
                const itemName = e.target.dataset.item;
                this.removeFromCart(itemName);
            });

            cartItems.appendChild(cartItem);
        });
    }

    toggleCart() {
        const cartModal = document.getElementById('cartModal');
        this.isCartOpen = !this.isCartOpen;
        
        if (this.isCartOpen) {
            cartModal.style.display = 'flex';
        } else {
            cartModal.style.display = 'none';
        }
    }

    closeCart() {
        const cartModal = document.getElementById('cartModal');
        cartModal.style.display = 'none';
        this.isCartOpen = false;
    }

    async checkout() {
        if (this.cart.length === 0) {
            this.showNotification('السلة فارغة', 'error');
            return;
        }

        try {
            // إرسال طلب الشراء إلى السيرفر
            const result = await API.purchaseItems(this.cart);
            
            if (result.success) {
                this.showNotification('تم الشراء بنجاح!', 'success');
                this.clearCart();
                this.closeCart();
                this.playSound('purchaseSound');
                
                // تحديث الرصيد
                this.updateBalance(result.newBalance);
            } else {
                this.showNotification(result.message || 'فشل في الشراء', 'error');
                this.playSound('errorSound');
            }
        } catch (error) {
            this.showNotification('خطأ في النظام', 'error');
            console.error('Checkout error:', error);
        }
    }

    clearCart() {
        this.cart = [];
        this.updateCartDisplay();
        this.showNotification('تم تفريغ السلة', 'warning');
    }

    filterItems(searchTerm) {
        const items = this.currentShop.items;
        const filteredItems = items.filter(item => 
            item.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.category.toLowerCase().includes(searchTerm.toLowerCase())
        );
        
        this.displayItems(filteredItems);
    }

    sortItems(sortOption) {
        const items = [...this.currentShop.items];
        
        switch (sortOption) {
            case 'name_asc':
                items.sort((a, b) => a.label.localeCompare(b.label));
                break;
            case 'name_desc':
                items.sort((a, b) => b.label.localeCompare(a.label));
                break;
            case 'price_asc':
                items.sort((a, b) => a.price - b.price);
                break;
            case 'price_desc':
                items.sort((a, b) => b.price - a.price);
                break;
            case 'category':
                items.sort((a, b) => a.category.localeCompare(b.category));
                break;
        }
        
        this.displayItems(items);
    }

    showNotification(message, type = 'info') {
        const container = document.getElementById('notificationContainer');
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        container.appendChild(notification);
        
        // إزالة الإشعار بعد 5 ثواني
        setTimeout(() => {
            notification.remove();
        }, 5000);
    }

    playSound(soundId) {
        const sound = document.getElementById(soundId);
        if (sound) {
            sound.currentTime = 0;
            sound.play().catch(e => console.log('Sound play failed:', e));
        }
    }

    updateBalance(newBalance) {
        const bankAmount = document.querySelector('.bank-amount');
        if (bankAmount) {
            bankAmount.textContent = `$${this.formatNumber(newBalance)}`;
        }
    }

    formatPrice(amount) {
        return `$${this.formatNumber(amount)}`;
    }

    formatNumber(number) {
        return new Intl.NumberFormat('ar-EG').format(number);
    }
}

// تهيئة التطبيق عند تحميل الصفحة
document.addEventListener('DOMContentLoaded', () => {
    window.ShopsApp = new ShopsApp();
});
