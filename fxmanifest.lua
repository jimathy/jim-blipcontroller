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

    --Jim Bridge - https://github.com/jimathy/jim-bridge
    '@jim_bridge/starter.lua',

    'shared/*.lua',
}

client_scripts {
    'client/*.lua'
}

dependency 'jim_bridge'