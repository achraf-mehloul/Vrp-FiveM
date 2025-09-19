fx_version 'cerulean'
game 'gta5'

author 'Melix Files'
description 'نظام متاجر متكامل مع واجهة ثلاثية الأبعاد - إصدار ميلكس V1'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/items.lua',
    'shared/functions.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/shop_repository.lua',
    'server/shop_service.lua',
    'server/shop_controller.lua',
    'server/admin_commands.lua',
    'server/transaction_manager.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/blip_manager.lua',
    'client/shop_interaction.lua',
    'client/nui_handler.lua',
    'client/player_manager.lua'
}

ui_page 'client/ui/index.html'

files {
    'client/ui/index.html',
    'client/ui/style.css',
    'client/ui/app.js',
    'client/ui/api.js',

    'client/ui/assets/images/weapons/*.png',
    'client/ui/assets/images/vehicles/*.png',
    'client/ui/assets/images/foods/*.png',
    'client/ui/assets/images/clothing/*.png',
    'client/ui/assets/images/pharmacy/*.png',
    'client/ui/assets/images/electronics/*.png',
    'client/ui/assets/images/barber/*.png',
    'client/ui/assets/images/jewelry/*.png',

    'client/ui/assets/icons/*.png',
    'client/ui/assets/sounds/*.ogg',

    'client/ui/assets/fonts/*.ttf',
    'client/ui/assets/fonts/*.otf'
}

dependencies {
    'oxmysql',
    'es_extended'
}

lua54 'yes'
