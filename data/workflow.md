TODO:

https://github.com/Project-OSRM/osrm-backend/wiki/Graph-representation

Pozor: tag Highway může mít několik verzí - nahrávejte pouze ty, které dávají smysl
1. načíst soubor s mapou ve formátu OSM
2. vyfiltrovat pouze hrany potřebné pro konstrukci uliční sítě (tudíž například ne okraje budov)
   - filter highway attributes
3. Zkonstruovat neorientovaný graf
4. Uložte také informaci o délce každého segmentu ulice (pozor, jedná se o geografickou vzdálenost)
5. a povolené rychlosti pokud informace o povolené rychlosti nebude dostupná, pak ji nastavte jako 50 km/h