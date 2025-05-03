name "Jim-BlipController"
author "Jimathy"
version "0.1"
description "Blip Controller Script"
fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
games { 'gta5', 'rdr3' }
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
	'config/*.lua',
    -- Required core scripts
    '@ox_lib/init.lua',
    '@ox_core/lib/init.lua',

    '@es_extended/imports.lua',

    '@qbx_core/modules/playerdata.lua',

    --Jim Bridge
    '@jim_bridge/starter.lua',

    'shared/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

dependency 'jim_bridge'