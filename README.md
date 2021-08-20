# gdx_tb
Script na potrestnání hráčů místo banu

### Funkce:
- Odeslaní hráče na ostrov, kde musí udělat určitý počet prácí
- Obnova prácí, když se hráč odpojí a připojí
- Discord log

### Požadavky:
- es_extended
- essentialmode (pro cmd, lze předělat na esx)
- mysql-async
- esx_skin
- skinchanger

### Instalace:
- Vložte `gdx_tb` do `resources`
- Importujte `gdx_tb.sql` do databáze
- Do `server.cfg` vložte `ensure gdx_tb`
- Nastavte webhook a čísla oblečení v `config.lua`
