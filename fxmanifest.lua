fx_version 'cerulean'
game 'gta5'

author 'DOGON <dogon309.dev@gmail.com>'
description '[DG]コア'
version '0.1.1'

client_scripts {
    'cache.lua',
    'commands.lua',
    'config.lua',
    'events.lua',
    'sync.lua',
    'user.lua',
    'utils.lua',
    'models/*.lua',
    'client/*.lua',
    'client/ui/*.lua',
    'client/commands/*.lua',
    'client/events/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'cache.lua',
    'commands.lua',
    'config.lua',
    'events.lua',
    'sync.lua',
    'user.lua',
    'utils.lua',
    'models/*.lua',
    'server/database/*.lua',
    'server/*.lua',
    'server/events/*.lua',
}

ui_page 'ui/dist/index.html'
files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'ui/dist/images/**/*'
}

lua54 'yes'
dependency 'oxmysql'