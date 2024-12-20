fx_version 'bodacious'
game 'gta5'
lua54 'yes'

ui_page 'interface/build/index.html'

shared_scripts {
    "@vrp/lib/utils.lua",
    "shared/*"
}
files {
    'interface/build/**/*',
}

client_scripts {
    'client/*'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server/*'
}

dependency {
    'oxmysql'
}