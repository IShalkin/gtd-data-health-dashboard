# GTD — Kvalita dat & pokrytí

Interaktivní dashboard pro workshop **Czechitas** postavený nad datasetem [Global Terrorism Database](https://www.start.umd.edu/gtd/) (1970–2020) v Snowflake schématu `COURSES.SCH_TEROR`, hlavní tabulka `TEROR_FULLDATA`.

**Live demo:** https://ishalkin.github.io/gtd-data-health-dashboard/

## O čem to je

Tohle **není** reportáž o terorismu. Je to reportáž o **datech** — co v nich je, co chybí, který rok zmizel, kde sedí sentinely, jaké sloupce mají špatný typ. Dashboard slouží studentům Czechitas k pochopení, jak vypadá reálný surový dataset, než se pustí do analýzy.

## Klíčová zjištění

| # | Zjištění | Závažnost |
|---|---|---|
| 1 | **Rok 1993 v datech vůbec není** — START přiznává ztrátu záloh | kritické |
| 2 | **Číselník zemí `COUNTRY_DIRTYDATA` má 408 řádků, ale jen 204 unikátních jmen** — každá země 2× | kritické |
| 3 | **`LATITUDE` a `LONGITUDE` jsou `VARCHAR(255)`** místo čísel — pozor na řazení | pozor |
| 4 | **`TEROR2` (84 341), `TEROR2_OLD` (26 828), `TEROR_FULLDATA` (209 706)** — tři verze, žádný README | pozor |
| 5 | **44 % útoků má `GNAME = 'Unknown'`** — sentinel string, ne NULL | pozor |
| 6 | **74 % záznamů má `MOTIVE = NULL`** — kódovací standard se měnil v čase | pozor |

## Stack

- **Snowflake** (`COURSES.SCH_TEROR`) — datový sklad, 209 706 řádků
- **Plotly.js 2.35.2** — interaktivní grafy v prohlížeči
- **Vanilla HTML/CSS/JS** — žádný build step, jeden soubor
- **GitHub Pages** — hosting

## Lokální spuštění

```bash
git clone https://github.com/IShalkin/gtd-data-health-dashboard.git
cd gtd-data-health-dashboard
# žádný build, jen otevři:
start index.html
```

## Použité SQL agregáty

Všech sedm dotazů je v [`queries.sql`](./queries.sql). Stačí je spustit nad `COURSES.SCH_TEROR` a výsledky vložit do `index.html` (data jsou hardcoded jako JSON, dashboard je samonosný).

## Licence

Data: GTD je dostupný pro akademické použití podle podmínek START. Kód: MIT.
