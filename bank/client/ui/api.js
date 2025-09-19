/**
 * Bank System API - Client-side Interface
 * Provides programmatic access to bank functionality
 */

class BankAPI {
    constructor() {
        this.initialized = false;
        this.eventHandlers = {
            onBalanceUpdate: [],
            onTransactionComplete: []
        };
    }

    /**
     * Initialize the bank API
     */
    initialize() {
        if (this.initialized) return true;
        
        // Listen for NUI messages
        window.addEventListener('message', this._handleNuiMessage.bind(this));
        
        this.initialized = true;
        console.log('Bank API initialized');
        return true;
    }

    /**
     * Open bank menu
     */
    openBankMenu() {
        fetch('https://bank/openBank', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        }).catch(console.error);
    }

    /**
     * Get current balance
     * @returns {Promise<number>} Current bank balance
     */
    async getBalance() {
        try {
            const response = await fetch('https://bank/getBalance', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();
            return data.balance || 0;
        } catch (error) {
            console.error('Failed to get balance:', error);
            return 0;
        }
    }

    /**
     * Transfer money to another account
     * @param {string} targetAccount - Target account number
     * @param {number} amount - Amount to transfer
     * @param {string} description - Transfer description
     * @returns {Promise<Object>} Transfer result
     */
    async transferMoney(targetAccount, amount, description = '') {
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
            return await response.json();
        } catch (error) {
            console.error('Transfer failed:', error);
            return { success: false, message: 'Transfer failed' };
        }
    }

    /**
     * Deposit money to bank
     * @param {number} amount - Amount to deposit
     * @param {string} description - Deposit description
     * @returns {Promise<Object>} Deposit result
     */
    async depositMoney(amount, description = '') {
        try {
            const response = await fetch('https://bank/depositMoney', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    amount,
                    description
                })
            });
            return await response.json();
        } catch (error) {
            console.error('Deposit failed:', error);
            return { success: false, message: 'Deposit failed' };
        }
    }

    /**
     * Withdraw money from bank
     * @param {number} amount - Amount to withdraw
     * @param {string} description - Withdrawal description
     * @returns {Promise<Object>} Withdrawal result
     */
    async withdrawMoney(amount, description = '') {
        try {
            const response = await fetch('https://bank/withdrawMoney', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    amount,
                    description
                })
            });
            return await response.json();
        } catch (error) {
            console.error('Withdrawal failed:', error);
            return { success: false, message: 'Withdrawal failed' };
        }
    }

    /**
     * Get transaction history
     * @param {number} limit - Number of transactions to fetch
     * @param {number} offset - Offset for pagination
     * @returns {Promise<Array>} Transaction history
     */
    async getTransactionHistory(limit = 10, offset = 0) {
        try {
            const response = await fetch('https://bank/getTransactionHistory', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    limit,
                    offset
                })
            });
            const data = await response.json();
            return data.transactions || [];
        } catch (error) {
            console.error('Failed to get transaction history:', error);
            return [];
        }
    }

    /**
     * Add event listener
     * @param {string} event - Event name
     * @param {Function} callback - Event handler
     */
    on(event, callback) {
        if (this.eventHandlers[event]) {
            this.eventHandlers[event].push(callback);
        }
    }

    /**
     * Remove event listener
     * @param {string} event - Event name
     * @param {Function} callback - Event handler to remove
     */
    off(event, callback) {
        if (this.eventHandlers[event]) {
            this.eventHandlers[event] = this.eventHandlers[event].filter(cb => cb !== callback);
        }
    }

    /**
     * Handle NUI messages
     * @private
     */
    _handleNuiMessage(event) {
        const data = event.data;
        
        switch (data.type) {
            case 'balanceUpdate':
                this.eventHandlers.onBalanceUpdate.forEach(callback => {
                    callback(data.balance);
                });
                break;
                
            case 'transactionComplete':
                this.eventHandlers.onTransactionComplete.forEach(callback => {
                    callback(data.transaction);
                });
                break;
        }
    }
}

// Create global instance
window.BankAPI = new BankAPI();

// Auto-initialize
document.addEventListener('DOMContentLoaded', function() {
    window.BankAPI.initialize();
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = window.BankAPI;
}
