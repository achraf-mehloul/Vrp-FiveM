fx_version 'cerulean'
game 'gta5'
author 'Deepseek'
description 'نظام الأبطال الخارقين بتقنيات عالية'

client_scripts {
    'client/main.lua',
    'client/powers.lua',
    'client/power_ui.lua',
    'client/nui_handler.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/hero_controller.lua',
    'server/hero_service.lua',
    'server/hero_repository.lua',
    'server/cooldown_manager.lua',
    'server/admin_commands.lua'
}

shared_scripts {
    'shared/config.lua',
    'shared/locales.lua',
    'shared/powers_catalog.lua',
    'shared/utils.lua'
}

ui_page 'client/ui/index.html'

files {
    'client/ui/index.html',
    'client/ui/app.js',
    'client/ui/style.css',
    'client/ui/assets/*.png',
    'client/ui/assets/*.jpg'
}

dependencies {
    'qb-core',
    'oxmysql'
}
