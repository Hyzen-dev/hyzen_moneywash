fx_version 'adamant'
games { 'gta5' }

author 'Hyzen Team'

shared_scripts {
    'shared/config.lua',
    'locale/*.lua',
    'shared/locale.lua',
    'shared/functions.lua'
};

server_scripts {
    'server/main.lua'
};

client_scripts {
    'client/variables.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/main.lua'
};