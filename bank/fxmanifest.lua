fx_version 'cerulean'
game 'gta5'

ui_page 'client/ui/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/bank_controller.lua',
    'server/bank_service.lua',
    'server/bank_repository.lua'
}

shared_scripts {
    'shared/bank_config.lua'
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
