fx_version 'cerulean'
game 'gta5'

author 'You'
description 'Advanced Kill Feed System'
version '2.0.0'

ui_page 'client/ui/index.html'

client_scripts {
    'shared/config.lua',
    'client/main.lua'
}

server_scripts {
    'shared/config.lua',
    'server/main.lua'
}

files {
    'client/ui/index.html',
    'client/ui/style.css',
    'client/ui/app.js',
    'client/ui/api.js',
    'client/ui/sounds/*.ogg' 
}
