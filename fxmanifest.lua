fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Alireza'
description 'AJ Scoreboard - player list, nearby players, recent disconnects, on-duty services and heist availability'
version '1.0.0'

-- Drop-in replacement: anything that depends on qb-scoreboard resolves to this.
provide 'qb-scoreboard'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/app.js',
    'html/fonts/*.woff2',
}

dependency 'qb-core'
