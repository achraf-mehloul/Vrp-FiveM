fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

client_scripts {
    'client/main.lua',
    'client/nui_handler.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/index_en.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'locales/*.json'
}

dependencies {
    '/onesync'
}
