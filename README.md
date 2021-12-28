# gdx_tb
Script to punish players instead of banning

Created from this script `esx_communityservice`

### Features:
- Sending a player to an island where they must do a certain number of jobs
- Resume work when the player disconnects and reconnects
- Discord log

### Requirements:
- es_extended
- mysql-async
- esx_skin
- skinchanger

### Install:
- Put `gdx_tb` into `resources`
- Import `gdx_tb.sql` into the database
- Insert `ensure gdx_tb` into `server.cfg`
- Set webhook and outfit numbers in `config.lua`