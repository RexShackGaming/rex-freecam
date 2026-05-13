fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name 'rex-freecam'
description 'Rework script by kibook with added copy function'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    'server/versionchecker.lua'
}

client_scripts {
    'client/client.lua',
    'client/timecycles.lua'
}

dependencies {
    'ox_lib'
}

lua54 'yes'
