/**
 * Admin System API - Client-side Interface
 * Provides programmatic access to admin functionality
 */

class AdminAPI {
    constructor() {
        this.initialized = false;
        this.isAdmin = false;
        this.adminLevel = null;
        this.eventHandlers = {
            onAdminStatusChange: [],
            onPlayerListUpdate: []
        };
    }

    /**
     * Initialize the admin API
     */
    initialize() {
        if (this.initialized) return true;
        
        // Listen for NUI messages
        window.addEventListener('message', this._handleNuiMessage.bind(this));
        
        // Check admin status
        this._checkAdminStatus();
        
        this.initialized = true;
        console.log('Admin API initialized');
        return true;
    }

    /**
     * Check admin status from server
     * @private
     */
    async _checkAdminStatus() {
        try {
            const response = await fetch('https://admin/checkAdmin', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            const data = await response.json();
            this.isAdmin = data.isAdmin;
            this.adminLevel = data.level;
            
            // Notify listeners
            this.eventHandlers.onAdminStatusChange.forEach(callback => {
                callback(this.isAdmin, this.adminLevel);
            });
            
        } catch (error) {
            console.error('Failed to check admin status:', error);
        }
    }

    /**
     * Open admin menu
     */
    openAdminMenu() {
        if (!this.isAdmin) {
            this.showNotification('You do not have admin permissions', 'error');
            return false;
        }
        
        fetch('https://admin/openAdminMenu', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).catch(console.error);
        
        return true;
    }

    /**
     * Close admin menu
     */
    closeAdminMenu() {
        fetch('https://admin/closeAdminMenu', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).catch(console.error);
    }

    /**
     * Kick a player
     * @param {number} playerId - Target player ID
     * @param {string} reason - Kick reason
     * @returns {Promise<Object>} Operation result
     */
    async kickPlayer(playerId, reason) {
        if (!this.isAdmin) {
            return { success: false, message: 'Insufficient permissions' };
        }

        try {
            const response = await fetch('https://admin/kickPlayer', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    playerId,
                    reason
                })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Kick failed:', error);
            return { success: false, message: 'Kick failed' };
        }
    }

    /**
     * Ban a player
     * @param {number} playerId - Target player ID
     * @param {number} duration - Ban duration in days
     * @param {string} reason - Ban reason
     * @returns {Promise<Object>} Operation result
     */
    async banPlayer(playerId, duration, reason) {
        if (!this.isAdmin) {
            return { success: false, message: 'Insufficient permissions' };
        }

        try {
            const response = await fetch('https://admin/banPlayer', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    playerId,
                    duration,
                    reason
                })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Ban failed:', error);
            return { success: false, message: 'Ban failed' };
        }
    }

    /**
     * Teleport to a player
     * @param {number} playerId - Target player ID
     * @returns {Promise<Object>} Operation result
     */
    async teleportToPlayer(playerId) {
        if (!this.isAdmin) {
            return { success: false, message: 'Insufficient permissions' };
        }

        try {
            const response = await fetch('https://admin/teleportToPlayer', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    playerId
                })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Teleport failed:', error);
            return { success: false, message: 'Teleport failed' };
        }
    }

    /**
     * Get player information
     * @param {number} playerId - Target player ID
     * @returns {Promise<Object>} Player information
     */
    async getPlayerInfo(playerId) {
        if (!this.isAdmin) {
            return { success: false, message: 'Insufficient permissions' };
        }

        try {
            const response = await fetch('https://admin/getPlayerInfo', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    playerId
                })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Failed to get player info:', error);
            return { success: false, message: 'Failed to get player info' };
        }
    }

    /**
     * Get server statistics
     * @returns {Promise<Object>} Server statistics
     */
    async getServerStats() {
        if (!this.isAdmin) {
            return { success: false, message: 'Insufficient permissions' };
        }

        try {
            const response = await fetch('https://admin/getServerStats', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            return await response.json();
        } catch (error) {
            console.error('Failed to get server stats:', error);
            return { success: false, message: 'Failed to get server stats' };
        }
    }

    /**
     * Show notification
     * @param {string} message - Notification message
     * @param {string} type - Notification type (info, success, warning, error)
     */
    showNotification(message, type = 'info') {
        fetch('https://admin/showNotification', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message,
                type
            })
        }).catch(console.error);
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
            case 'adminStatusUpdate':
                this.isAdmin = data.isAdmin;
                this.adminLevel = data.level;
                this.eventHandlers.onAdminStatusChange.forEach(callback => {
                    callback(this.isAdmin, this.adminLevel);
                });
                break;
                
            case 'playerListUpdate':
                this.eventHandlers.onPlayerListUpdate.forEach(callback => {
                    callback(data.players);
                });
                break;
        }
    }

    /**
     * Check if user is admin
     * @returns {boolean} Admin status
     */
    isUserAdmin() {
        return this.isAdmin;
    }

    /**
     * Get admin level
     * @returns {string} Admin level
     */
    getAdminLevel() {
        return this.adminLevel;
    }
}

// Create global instance
window.AdminAPI = new AdminAPI();

// Auto-initialize
document.addEventListener('DOMContentLoaded', function() {
    window.AdminAPI.initialize();
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = window.AdminAPI;
}