local ModulesLoader = {
    loadedModules = {},
    moduleCallbacks = {},
    moduleDependencies = {},
    moduleStates = {}
}

function ModulesLoader:init()
    print('^2[Core] ⚡ جاري تحميل النواة الأساسية...^0')
    
    -- تحميل الإعدادات
    self:loadConfigurations()
    
    -- إعداد قاعدة البيانات
    self:setupDatabase()
    
    -- تهيئة أنظمة الأمان
    self:initSecuritySystems()
    
    -- تحميل جميع المودات
    self:loadAllModules()
    
    -- بدء مراقبة الأداء
    self:startPerformanceMonitor()
    
    print('^2[Core] ✅ تم تحميل النواة الأساسية بنجاح!^0')
    print('^2[Core] 📦 عدد المودات المحملة: ' .. countTable(self.loadedModules) .. '^0')
end

function ModulesLoader:loadConfigurations()
    self.config = {
        server = require 'core/config/server_config',
        client = require 'core/config/client_config',
        modules = require 'core/config/modules_config',
        hud = require 'core/config/hud_config'
    }
    
    -- تطبيق الإعدادات
    self:applyConfigurations()
end

function ModulesLoader:applyConfigurations()
    -- تطبيق إعدادات الأداء
    if self.config.server.Performance then
        self:applyPerformanceSettings(self.config.server.Performance)
    end
    
    -- تطبيق إعدادات الأمان
    if self.config.server.Security then
        self:applySecuritySettings(self.config.server.Security)
    end
end

function ModulesLoader:applyPerformanceSettings(settings)
    SetRoutingBucketEntityLockdownMode(0, 'strict')
    Set
