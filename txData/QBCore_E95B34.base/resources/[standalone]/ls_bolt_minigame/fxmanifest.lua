fx_version 'cerulean'
games      { 'gta5' }
lua54 'yes'

author 'Lith Studios | Swizz'
description 'Bolt Minigame by Lith Studios'
version '1.0.5'

files {
    'stream/wheel_spacer.ytyp'
}

data_file "DLC_ITYP_REQUEST" "stream/wheel_spacer.ytyp"

client_scripts {
    'config.lua',
    'client/editables.lua',
    'client/client.lua',
    'client/functions.lua'
}

escrow_ignore {
    'config.lua',
    'stream/*',
    'client/editables.lua'
}


dependency '/assetpacks'