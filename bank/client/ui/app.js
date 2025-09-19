/**
 * Bank System - Client UI Application
 * Handles user interface interactions for the banking system
 */

class BankApp {
    constructor() {
        this.currentView = 'main';
        this.currentAccount = null;
        this.transactions = [];
        this.isLoading = false;
        
        this.initialize();
    }

    /**
     * Initialize the bank application
     */
    initialize() {
        this.bindEvents();
        this.setupLanguage();
        
        // Listen for NUI messages
        window.addEventListener('message', this.handleNuiMessage.bind(this));
        
        console.log('Bank UI initialized');
    }

    /**
     * Bind DOM events
     */
    bindEvents() {
        // Close button
        document.getElementById('closeBank').addEventListener('click', this.closeBank.bind(this));
        
        // Tab navigation
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab);
            });
        });

        // Transfer form
        document.getElementById('transferForm').addEventListener('submit', this.handleTransfer.bind(this));
        
        // Deposit form
        document.getElementById('depositForm').addEventListener('submit', this.handleDeposit.bind(this));
        
        // Withdraw form
        document.getElementById('withdrawForm').addEventListener('submit', this.handleWithdraw.bind(this));
        
        // Load more transactions
        document.getElementById('loadMoreTransactions').addEventListener('click', this.loadMoreTransactions.bind(this));
    }

    /**
     * Handle NUI messages from Lua
     */
    handleNuiMessage(event) {
        const data = event.data;
        
        switch (data.type) {
            case 'openBank':
                this.openBank(data.account, data.transactions, data.config);
                break;
                
            case 'updateBalance':
                this.updateBalance(data.balance);
                break;
                
            case 'showNotification':
                this.showNotification(data.message, data.notificationType, data.duration);
                break;
                
            case 'addTransaction':
                this.addTransaction(data.transaction);
                break;
        }
    }

    /**
     * Open bank interface
     */
    openBank(account, transactions, config) {
        this.currentAccount = account;
        this.transactions = transactions;
        
        this.updateAccountInfo(account);
        this.renderTransactions(transactions);
        this.applyConfig(config);
        
        document.getElementById('bankContainer').style.display = 'block';
        this.switchTab('main');
    }

    /**
     * Close bank interface
     */
    closeBank() {
        document.getElementById('bankContainer').style.display = 'none';
        
        // Send message to close NUI
        fetch('https://bank/closeBank', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        }).catch(console.error);
    }

    /**
     * Update account information display
     */
    updateAccountInfo(account) {
        document.getElementById('accountNumber').textContent = account.number;
        document.getElementById('accountBalance').textContent = this.formatCurrency(account.balance);
        document.getElementById('accountType').textContent = this.translate(account.type);
        document.getElementById('accountSince').textContent = new Date(account.created_at).toLocaleDateString();
    }

    /**
     * Update balance display
     */
    updateBalance(balance) {
        document.getElementById('accountBalance').textContent = this.formatCurrency(balance);
        
        // Update balance in all relevant places
        document.querySelectorAll('.balance-display').forEach(el => {
            el.textContent = this.formatCurrency(balance);
        });
    }

    /**
     * Render transactions list
     */
    renderTransactions(transactions) {
        const container = document.getElementById('transactionsList');
        container.innerHTML = '';

        if (transactions.length === 0) {
            container.innerHTML = '<div class="no-transactions">No transactions found</div>';
            return;
        }

        transactions.forEach(transaction => {
            const transactionEl = this.createTransactionElement(transaction);
            container.appendChild(transactionEl);
        });
    }

    /**
     * Create transaction element
     */
    createTransactionElement(transaction) {
        const el = document.createElement('div');
        el.className = `transaction ${transaction.transaction_type}`;
        
        const isDebit = transaction.sender_account === this.currentAccount.number;
        const amountClass = isDebit ? 'debit' : 'credit';
        const amountPrefix = isDebit ? '-' : '+';
        
        el.innerHTML = `
            <div class="transaction-icon">
                <i class="fas ${this.getTransactionIcon(transaction.transaction_type)}"></i>
            </div>
            <div class="transaction-details">
                <div class="transaction-description">${transaction.description || 'No description'}</div>
                <div class="transaction-date">${new Date(transaction.created_at).toLocaleString()}</div>
            </div>
            <div class="transaction-amount ${amountClass}">
                ${amountPrefix}${this.formatCurrency(transaction.amount)}
            </div>
            <div class="transaction-status ${transaction.status}">
                ${this.translate(transaction.status)}
            </div>
        `;
        
        return el;
    }

    /**
     * Handle transfer form submission
     */
    async handleTransfer(e) {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const targetAccount = formData.get('targetAccount');
        const amount = parseFloat(formData.get('amount'));
        const description = formData.get('description');
        
        if (!this.validateTransfer(targetAccount, amount)) {
            return;
        }
        
        this.setLoading(true);
        
        try {
            const response = await fetch('https://bank/transferMoney', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    targetAccount,
                    amount,
                    description
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showNotification(result.message, 'success');
                e.target.reset();
            } else {
                this.showNotification(result.message, 'error');
            }
        } catch (error) {
            this.showNotification('Transfer failed', 'error');
            console.error('Transfer error:', error);
        }
        
        this.setLoading(false);
    }

    /**
     * Handle deposit form submission
     */
    async handleDeposit(e) {
        e.preventDefault();
        // Similar implementation to handleTransfer
    }

    /**
     * Handle withdraw form submission
     */
    async handleWithdraw(e) {
        e.preventDefault();
        // Similar implementation to handleTransfer
    }

    /**
     * Load more transactions
     */
    async loadMoreTransactions() {
        const currentCount = this.transactions.length;
        
        this.setLoading(true);
        
        try {
            const response = await fetch('https://bank/loadMoreTransactions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    limit: 10,
                    offset: currentCount
                })
            });
            
            const data = await response.json();
            
            if (data.transactions && data.transactions.length > 0) {
                this.transactions = [...this.transactions, ...data.transactions];
                this.renderTransactions(this.transactions);
            }
            
            document.getElementById('loadMoreTransactions').style.display = 
                data.hasMore ? 'block' : 'none';
                
        } catch (error) {
            console.error('Failed to load more transactions:', error);
        }
        
        this.setLoading(false);
    }

    /**
     * Switch between tabs
     */
    switchTab(tabName) {
        // Hide all tab contents
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.style.display = 'none';
        });
        
        // Deactivate all tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // Show selected tab
        document.getElementById(`${tabName}Tab`).style.display = 'block';
        
        // Activate selected button
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        
        this.currentView = tabName;
    }

    /**
     * Show notification
     */
    showNotification(message, type = 'info', duration = 3000) {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        document.getElementById('notifications').appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, duration);
    }

    /**
     * Set loading state
     */
    setLoading(loading) {
        this.isLoading = loading;
        
        document.querySelectorAll('button').forEach(btn => {
            btn.disabled = loading;
        });
        
        document.getElementById('loadingOverlay').style.display = 
            loading ? 'flex' : 'none';
    }

    /**
     * Format currency amount
     */
    formatCurrency(amount) {
        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
        });
        
        return formatter.format(amount);
    }

    /**
     * Get transaction type icon
     */
    getTransactionIcon(type) {
        const icons = {
            transfer: 'fa-exchange-alt',
            deposit: 'fa-plus-circle',
            withdraw: 'fa-minus-circle',
            payment: 'fa-credit-card'
        };
        
        return icons[type] || 'fa-receipt';
    }

    /**
     * Translate text
     */
    translate(key) {
        const translations = {
            'personal': 'Personal',
            'business': 'Business',
            'completed': 'Completed',
            'pending': 'Pending',
            'failed': 'Failed'
        };
        
        return translations[key] || key;
    }

    /**
     * Validate transfer parameters
     */
    validateTransfer(targetAccount, amount) {
        if (!targetAccount || targetAccount.length < 8) {
            this.showNotification('Invalid account number', 'error');
            return false;
        }
        
        if (!amount || amount <= 0) {
            this.showNotification('Invalid amount', 'error');
            return false;
        }
        
        if (amount > this.currentAccount.balance) {
            this.showNotification('Insufficient funds', 'error');
            return false;
        }
        
        return true;
    }

    /**
     * Apply configuration settings
     */
    applyConfig(config) {
        if (config.UI) {
            document.documentElement.style.setProperty('--primary-currency', config.UI.currency);
            
            if (config.UI.language === 'ar') {
                document.dir = 'rtl';
            }
        }
    }

    /**
     * Setup language and RTL support
     */
    setupLanguage() {
        // Add RTL support if needed
        if (document.dir === 'rtl') {
            document.querySelectorAll('.transaction-details, .transaction-amount').forEach(el => {
                el.style.textAlign = 'right';
            });
        }
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.bankApp = new BankApp();
});

// Handle NUI callbacks
window.addEventListener('message', function(event) {
    if (window.bankApp) {
        window.bankApp.handleNuiMessage(event);
    }
});

// Close bank when escape is pressed
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (window.bankApp) {
            window.bankApp.closeBank();
        }
    }
});
