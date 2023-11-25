fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Yibtag'
version '1.0.0'
description 'This is a simple shop script for roleplay servers!'

dependencies {
    'oxmysql',
    'qb-inventory'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua'
}

ui_page 'html/index.html'

files {
    'html/*.*',
    'html/assets/*.*',
    'html/inventory_images/*.*'
}