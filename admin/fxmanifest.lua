fx_version 'cerulean'
game 'gta5'

ui_page 'client/ui/index.html'

client_scripts {
    'client/main.lua',
    'client/commands.lua',
    'client/events.lua',
    'client/admin_menu.lua'
}

server_scripts {
    'server/main.lua',
    'server/admin_controller.lua',
    'server/admin_service.lua',
    'server/admin_repository.lua'
}

shared_scripts {
    'shared/admin_config.lua',
    'shared/permissions.lua'
}

files {
    'client/ui/index.html',
    'client/ui/style.css',
    'client/ui/app.js',
    'client/ui/api.js'
}

dependencies {
    'es_extended'
}
