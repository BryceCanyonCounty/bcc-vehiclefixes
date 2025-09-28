fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'

author 'Bytesizd'
description 'Advanced vehicle fixes with comprehensive wagon component removal and configurable detection systems.'

shared_script {
    'config.lua',
    'debug_init.lua'
}

client_script {
    'client/wagons.lua'
}

server_script {
    'server/versioncheck.lua',
    'server/boats.lua'
}

version '2.0.0'
