# GTD — Kvalita dat & pokrytí

Interaktivní dashboard pro workshop **Czechitas** postavený nad datasetem [Global Terrorism Database](https://www.start.umd.edu/gtd/) (1970–2020) v Snowflake schématu `COURSES.SCH_TEROR`.

**Live demo:** https://ishalkin.github.io/gtd-data-health-dashboard/

## O čem to je

Dashboard nevypráví o terorismu — vypráví o **datech**. Pět sekcí:

1. **Pokrytí** — počet událostí a obětí po letech (1993 zcela chybí — START fyzicky ztratil záznamy)
2. **Kvalita dat** — heatmap chybějících hodnot v polích × dekádách
3. **Rozložení** — top země / typy útoků / typy zbraní
4. **Regiony** — bubble chart smrtnosti
5. **Audit integrity** — duplikáty, sentinelové hodnoty (-99), špatné typy, pochybné záznamy

## Klíčová zjištění

- 209 706 událostí, 50 let, 204 zemí
- **44 %** událostí — pachatel `Unknown`
- **74 %** událostí — `MOTIVE = NULL`
- `COUNTRY_DIRTYDATA` má 408 řádků, ale jen 204 unikátních — každá země je tam **dvakrát**
- `TEROR2_OLD` obsahuje pouze třetinu dat z `TEROR2` — zastaralý snapshot
- `LATITUDE` / `LONGITUDE` jsou uloženy jako `VARCHAR(255)` — geo-dotazy vyžadují `TRY_CAST`

## Stack

- **Snowflake** — datový zdroj (`COURSES.SCH_TEROR`, account GN56074)
- **Plotly.js 2.35** — všechny grafy
- **Single-file HTML** — žádný build, žádné závislosti, agregáty jsou hardcoded jako JSON

## Lokální spuštění

Stáhněte `index.html` a otevřete v prohlížeči. To je celé.

## Použité SQL agregáty

Viz [`queries.sql`](queries.sql) — všechny dotazy, které vracejí data zobrazená na dashboardu.

## Licence

MIT (kód). Data: GTD používá vlastní [terms of use](https://www.start.umd.edu/gtd/contact/license).
