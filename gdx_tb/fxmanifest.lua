fx_version 'adamant'
game 'gta5'

author 'Gdany#2835'
description 'Script to punish players instead of banning'
version '1.0.0'

client_scripts {
	'@es_extended/locale.lua',
	'lang.lua',
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'lang.lua',
	'config.lua',
	'server/main.lua'
}

dependencies {
    'es_extended',
    'mysql_async',
    'esx_skin',
    'skinchanger'
}