/**
 * Admin System - Client UI Application
 * Handles user interface interactions for the admin system
 */

class AdminApp {
    constructor() {
        this.currentView = 'players';
        this.currentPlayer = null;
        this.players = [];
        this.serverStats = {};
        this.isLoading = false;
        this.adminLevel = null;
        
        this.initialize();
    }

    /**
     * Initialize the admin application
     */
    initialize() {
        this.bindEvents();
        this.setupLanguage();
        
        // Listen for NUI messages
        window.addEventListener('message', this.handleNuiMessage.bind(this));
        
        console.log('Admin UI initialized');
    }

    /**
     * Bind DOM events
     */
    bindEvents() {
        // Close button
        document.getElementById('closeAdmin').addEventListener('click', this.closeAdmin.bind(this));
        
        // Tab navigation
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab);
            });
        });

        // Player actions
        document.addEventListener('click', this.handlePlayerActions.bind(this));
        
        // Search functionality
        document.getElementById('playerSearch').addEventListener('input', this.handleSearch.bind(this));
        
        // Form submissions
        document.querySelectorAll('.admin-form').forEach(form => {
            form.addEventListener('submit', this.handleFormSubmit.bind(this));
        });

        // Quick actions
        document.querySelectorAll('.quick-action-btn').forEach(btn => {
            btn.addEventListener('click', this.handleQuickAction.bind(this));
        });
    }

    /**
     * Handle NUI messages from Lua
     */
    handleNuiMessage(event) {
        const data = event.data;
        
        switch (data.type) {
            case 'openAdminMenu':
                this.openAdminMenu(data.players, data.adminLevel, data.config);
                break;
                
            case 'updatePlayerList':
                this.updatePlayerList(data.players);
                break;
                
            case 'showNotification':
                this.showNotification(data.message, data.notificationType, data.duration);
                break;
                
            case 'playerInfoReceived':
                this.showPlayerInfo(data.playerInfo);
                break;
                
            case 'serverStatsReceived':
                this.showServerStats(data.stats);
                break;
        }
    }

    /**
     * Open admin menu
     */
    openAdminMenu(players, adminLevel, config) {
        this.players = players;
        this.adminLevel = adminLevel;
        
        this.renderPlayerList(players);
        this.applyConfig(config);
        
        document.getElementById('adminContainer').style.display = 'block';
        this.switchTab('players');
        
        // Load server stats
        this.loadServerStats();
    }

    /**
     * Close admin menu
     */
    closeAdmin() {
        document.getElementById('adminContainer').style.display = 'none';
        
        fetch('https://admin/closeAdminMenu', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).catch(console.error);
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
     * Render player list
     */
    renderPlayerList(players) {
        const container = document.getElementById('playersList');
        container.innerHTML = '';

        if (players.length === 0) {
            container.innerHTML = '<div class="no-players">No players online</div>';
            return;
        }

        players.forEach(player => {
            const playerEl = this.createPlayerElement(player);
            container.appendChild(playerEl);
        });
    }

    /**
     * Create player list element
     */
    createPlayerElement(player) {
        const el = document.createElement('div');
        el.className = 'player-item';
        el.dataset.playerId = player.id;
        
        el.innerHTML = `
            <div class="player-info">
                <div class="player-name">${this.escapeHtml(player.name)}</div>
                <div class="player-details">
                    <span class="player-id">ID: ${player.id}</span>
                    <span class="player-ping">Ping: ${player.ping}</span>
                </div>
            </div>
            <div class="player-actions">
                <button class="btn btn-sm btn-info" data-action="info" data-player-id="${player.id}">
                    <i class="fas fa-info-circle"></i>
                </button>
                <button class="btn btn-sm btn-warning" data-action="warn" data-player-id="${player.id}">
                    <i class="fas fa-exclamation-triangle"></i>
                </button>
                <button class="btn btn-sm btn-danger" data-action="kick" data-player-id="${player.id}">
                    <i class="fas fa-door-open"></i>
                </button>
                <button class="btn btn-sm btn-danger" data-action="ban" data-player-id="${player.id}">
                    <i class="fas fa-ban"></i>
                </button>
            </div>
        `;
        
        return el;
    }

    /**
     * Handle player actions
     */
    handlePlayerActions(e) {
        if (!e.target.closest('[data-action]')) return;
        
        const actionBtn = e.target.closest('[data-action]');
        const action = actionBtn.dataset.action;
        const playerId = actionBtn.dataset.playerId;
        const player = this.players.find(p => p.id == playerId);
        
        if (!player) return;
        
        switch (action) {
            case 'info':
                this.showPlayerInfoModal(player);
                break;
            case 'warn':
                this.showWarnModal(player);
                break;
            case 'kick':
                this.showKickModal(player);
                break;
            case 'ban':
                this.showBanModal(player);
                break;
            case 'teleport':
                this.teleportToPlayer(player);
                break;
            case 'bring':
                this.bringPlayer(player);
                break;
        }
    }

    /**
     * Show player info modal
     */
    showPlayerInfoModal(player) {
        this.currentPlayer = player;
        
        // Show modal with player info
        const modal = document.getElementById('playerInfoModal');
        modal.style.display = 'block';
        
        // Load detailed player info
        fetch('https://admin/getPlayerInfo', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: player.id
            })
        })
        .then(response => response.json())
        .then(data => {
            this.populatePlayerInfo(data);
        })
        .catch(console.error);
    }

    /**
     * Populate player info in modal
     */
    populatePlayerInfo(playerInfo) {
        if (!playerInfo) return;
        
        document.getElementById('playerInfoName').textContent = playerInfo.name || 'N/A';
        document.getElementById('playerInfoId').textContent = playerInfo.id || 'N/A';
        document.getElementById('playerInfoSteam').textContent = playerInfo.steam || 'N/A';
        document.getElementById('playerInfoLicense').textContent = playerInfo.license || 'N/A';
        document.getElementById('playerInfoDiscord').textContent = playerInfo.discord || 'N/A';
        document.getElementById('playerInfoIp').textContent = playerInfo.ip || 'N/A';
        document.getElementById('playerInfoPing').textContent = playerInfo.ping || 'N/A';
        
        // Job information
        if (playerInfo.job) {
            document.getElementById('playerInfoJob').textContent = 
                `${playerInfo.job.name} - Grade ${playerInfo.job.grade}`;
        }
        
        // Money information
        if (playerInfo.money) {
            document.getElementById('playerInfoCash').textContent = 
                this.formatCurrency(playerInfo.money.cash || 0);
            document.getElementById('playerInfoBank').textContent = 
                this.formatCurrency(playerInfo.money.bank || 0);
        }
        
        // Inventory
        if (playerInfo.inventory && playerInfo.inventory.length > 0) {
            const inventoryList = document.getElementById('playerInfoInventory');
            inventoryList.innerHTML = '';
            
            playerInfo.inventory.forEach(item => {
                const li = document.createElement('li');
                li.textContent = `${item.name} x${item.count}`;
                inventoryList.appendChild(li);
            });
        }
    }

    /**
     * Show warn modal
     */
    showWarnModal(player) {
        this.currentPlayer = player;
        
        const modal = document.getElementById('warnModal');
        modal.style.display = 'block';
        document.getElementById('warnPlayerName').textContent = player.name;
    }

    /**
     * Show kick modal
     */
    showKickModal(player) {
        this.currentPlayer = player;
        
        const modal = document.getElementById('kickModal');
        modal.style.display = 'block';
        document.getElementById('kickPlayerName').textContent = player.name;
        
        // Populate reason dropdown
        const reasonSelect = document.getElementById('kickReason');
        reasonSelect.innerHTML = '';
        
        Config.KickReasons.forEach(reason => {
            const option = document.createElement('option');
            option.value = reason;
            option.textContent = reason;
            reasonSelect.appendChild(option);
        });
    }

    /**
     * Show ban modal
     */
    showBanModal(player) {
        this.currentPlayer = player;
        
        const modal = document.getElementById('banModal');
        modal.style.display = 'block';
        document.getElementById('banPlayerName').textContent = player.name;
        
        // Populate reason dropdown
        const reasonSelect = document.getElementById('banReason');
        reasonSelect.innerHTML = '';
        
        Config.BanReasons.forEach(reason => {
            const option = document.createElement('option');
            option.value = reason;
            option.textContent = reason;
            reasonSelect.appendChild(option);
        });
    }

    /**
     * Handle form submissions
     */
    handleFormSubmit(e) {
        e.preventDefault();
        
        const formId = e.target.id;
        const formData = new FormData(e.target);
        
        switch (formId) {
            case 'warnForm':
                this.submitWarn(formData);
                break;
            case 'kickForm':
                this.submitKick(formData);
                break;
            case 'banForm':
                this.submitBan(formData);
                break;
        }
    }

    /**
     * Submit warn form
     */
    submitWarn(formData) {
        const reason = formData.get('reason');
        const severity = formData.get('severity');
        
        if (!reason) {
            this.showNotification('Please enter a warning reason', 'error');
            return;
        }
        
        fetch('https://admin/warnPlayer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: this.currentPlayer.id,
                reason,
                severity
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Player warned successfully', 'success');
                this.closeModal('warnModal');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Submit kick form
     */
    submitKick(formData) {
        const reason = formData.get('reason') || formData.get('customReason');
        
        if (!reason) {
            this.showNotification('Please enter a kick reason', 'error');
            return;
        }
        
        fetch('https://admin/kickPlayer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: this.currentPlayer.id,
                reason
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Player kicked successfully', 'success');
                this.closeModal('kickModal');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Submit ban form
     */
    submitBan(formData) {
        const reason = formData.get('reason') || formData.get('customReason');
        const duration = parseInt(formData.get('duration'));
        
        if (!reason) {
            this.showNotification('Please enter a ban reason', 'error');
            return;
        }
        
        if (!duration || duration <= 0) {
            this.showNotification('Please enter a valid ban duration', 'error');
            return;
        }
        
        fetch('https://admin/banPlayer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: this.currentPlayer.id,
                duration,
                reason
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Player banned successfully', 'success');
                this.closeModal('banModal');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Teleport to player
     */
    teleportToPlayer(player) {
        fetch('https://admin/teleportToPlayer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: player.id
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Teleported to player', 'success');
                this.closeAdmin();
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Bring player to me
     */
    bringPlayer(player) {
        fetch('https://admin/teleportPlayerToMe', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: player.id
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Player brought to you', 'success');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Close modal
     */
    closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
        this.currentPlayer = null;
    }

    /**
     * Handle search input
     */
    handleSearch(e) {
        const searchTerm = e.target.value.toLowerCase();
        
        if (!searchTerm) {
            this.renderPlayerList(this.players);
            return;
        }
        
        const filteredPlayers = this.players.filter(player => 
            player.name.toLowerCase().includes(searchTerm) ||
            player.id.toString().includes(searchTerm) ||
            (player.steam && player.steam.toLowerCase().includes(searchTerm))
        );
        
        this.renderPlayerList(filteredPlayers);
    }

    /**
     * Load server statistics
     */
    loadServerStats() {
        fetch('https://admin/getServerStats', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(stats => {
            this.serverStats = stats;
            this.updateServerStats(stats);
        })
        .catch(console.error);
    }

    /**
     * Update server statistics display
     */
    updateServerStats(stats) {
        document.getElementById('statsTotalPlayers').textContent = stats.totalPlayers || 0;
        document.getElementById('statsActivePlayers').textContent = stats.activePlayers || 0;
        document.getElementById('statsBannedPlayers').textContent = stats.bannedPlayers || 0;
        document.getElementById('statsRecentActions').textContent = stats.recentActions || 0;
        document.getElementById('statsTotalWarnings').textContent = stats.totalWarnings || 0;
        document.getElementById('statsAvgSession').textContent = 
            stats.avgSessionTime ? stats.avgSessionTime.toFixed(1) + 'm' : 'N/A';
    }

    /**
     * Handle quick actions
     */
    handleQuickAction(e) {
        const action = e.target.dataset.action;
        
        switch (action) {
            case 'noclip':
                this.toggleNoclip();
                break;
            case 'revive':
                this.reviveSelf();
                break;
            case 'invisible':
                this.toggleInvisible();
                break;
            case 'car':
                this.spawnVehicle();
                break;
        }
    }

    /**
     * Toggle noclip
     */
    toggleNoclip() {
        fetch('https://admin/toggleNoclip', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification(data.message, 'success');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Revive self
     */
    reviveSelf() {
        fetch('https://admin/revivePlayer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: -1 // -1 means self
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Revived successfully', 'success');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Toggle invisible
     */
    toggleInvisible() {
        fetch('https://admin/toggleInvisible', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification(data.message, 'success');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
    }

    /**
     * Spawn vehicle
     */
    spawnVehicle() {
        const vehicle = prompt('Enter vehicle model:', 'adder');
        if (!vehicle) return;
        
        fetch('https://admin/spawnVehicle', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                vehicle
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Vehicle spawned', 'success');
            } else {
                this.showNotification(data.message, 'error');
            }
        })
        .catch(console.error);
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
     * Format currency amount
     */
    formatCurrency(amount) {
        return '$' + amount.toLocaleString();
    }

    /**
     * Escape HTML characters
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Apply configuration settings
     */
    applyConfig(config) {
        if (config.UI) {
            // Apply theme
            const theme = config.Themes[config.UI.theme] || config.Themes.default;
            document.documentElement.style.setProperty('--primary-color', theme.primary);
            document.documentElement.style.setProperty('--secondary-color', theme.secondary);
            document.documentElement.style.setProperty('--accent-color', theme.accent);
            
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
            document.querySelectorAll('.player-info, .player-actions').forEach(el => {
                el.style.textAlign = 'right';
            });
        }
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.adminApp = new AdminApp();
});

// Handle NUI callbacks
window.addEventListener('message', function(event) {
    if (window.adminApp) {
        window.adminApp.handleNuiMessage(event);
    }
});

// Close admin menu when escape is pressed
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (window.adminApp) {
            window.adminApp.closeAdmin();
        }
        
        // Close any open modals
        document.querySelectorAll('.modal').forEach(modal => {
            modal.style.display = 'none';
        });
    }
});

// Close modals when clicking outside
window.addEventListener('click', function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.style.display = 'none';
    }
});