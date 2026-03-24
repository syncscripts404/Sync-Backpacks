fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Sync Scripts'
description 'Backpacks with persistent stash + synced prop - Works with ox_inventory & qb-inventory'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependency 'ox_lib'
