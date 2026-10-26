# Human Development Index - Data package

This data package contains the data that powers the chart ["Human Development Index"](https://ourworldindata.org/grapher/human-development-index?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

### Active Filters

A filtered subset of the full data was downloaded. The following filters were applied:

## CSV structure

Each row is an observation for an entity (usually a country or region) at a timepoint.

- "Entity" — the name of the entity, e.g. "United States".
- "Code" — our internal entity code. For most countries this is the [ISO alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code, e.g. "USA"; historical and other non-standard entities get a custom code.
- "Year" or "Day" — the timepoint. Annual data has a "Year" column holding an integer year; otherwise a "Day" column holds a date string in the form "YYYY-MM-DD".
- Every remaining column is a data column, each one a time series. Downloaded with the "full data" option each corresponds to one time series below; with "only selected data visible in the chart" they are transformed depending on the chart type, so the correspondence may be less direct.


## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc.

## How we process data at Our World in Data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stitch together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

Preparing this data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/).

## Detailed information about each time series


### Human Development Index
The Human Development Index (HDI) is a summary measure of key dimensions of human development: a long and healthy life, a good education, and a decent standard of living. Higher values indicate higher human development.
Last updated: May 7, 2025  
Next expected update: November 2026  
Date range: 1990–2023  
Source: UNDP, Human Development Report (2025) – with minor processing by Our World in Data  

#### How to cite this data

UNDP, Human Development Report (2025) – with minor processing by Our World in Data

#### What you should know about this data
- The Human Development Index (HDI) provides a broad, intuitive measure for comparing overall human progress across countries and over time. A higher HDI implies longer, healthier lives, better education and higher command over resources; however, it does not capture inequality, sustainability or subjective wellbeing
- It is a composite summary of a country's average achievement in three basic dimensions of human development – health (life expectancy), knowledge (schooling) and material wellbeing (GNI per capita) – combined through a geometric mean into a single 0‑to‑1 score.
- Each dimension of the HDI is captured by a specific index:
  - **Healthy life**: Captured by the _Life Expectancy Index_, which is based on life expectancy at birth.
  - **Good education (knowledge)**: Captured by _Education Index_, which is based on the expected and mean years of schooling.
  - **Decent standard of living**: Captured by _Gross National Income (GNI) Index_, which is based on the GNI per capita (PPP$).
- The index is estimated by normalizing and aggregating the above indicators. First, the indicators are brought onto the same scale, ranging from 0 to 1. This is done by setting minimum and maximum values for each indicator. The minimum and maximum values for each indicator are defined as follows:
  - Life expectancy at birth ranges between 20 and 85 years
  - Expected years of schooling between 0 and 18 years; Mean years of schooling, between 0 and 15 years
  - GNI per capita between 100 and 75,000 international-$ at 2021 prices.
- The HDI is then estimated as the geometric mean of these indices. The education index is the arithmetic mean (average) of the mean years of schooling and expected years of schooling.

#### How this data is described by its producers
The Human Development Index (HDI) is a summary measure of average achievement in key dimensions of human development: a long and healthy life, being knowledgeable and having a decent standard of living. The HDI is the geometric mean of normalized indices for each of the three dimensions.

The health dimension is assessed by life expectancy at birth, the education dimension is measured by mean of years of schooling for adults aged 25 years and more and expected years of schooling for children of school entering age. The standard of living dimension is measured by gross national income per capita. The HDI uses the logarithm of income, to reflect the diminishing importance of income with increasing GNI. The scores for the three HDI dimension indices are then aggregated into a composite index using geometric mean. Refer to Technical notes for more details.

The HDI can be used to question national policy choices, asking how two countries with the same level of GNI per capita can end up with different human development outcomes. These contrasts can stimulate debate about government policy priorities.

The HDI simplifies and captures only part of what human development entails. It does not reflect on inequalities, poverty, human security, empowerment, etc. The HDRO provides other composite indices as broader proxy on some of the key issues of human development, inequality, gender disparity and poverty.

A fuller picture of a country's level of human development requires analysis of other indicators and information presented in the HDR statistical annex.


### World region according to OWID
Regions defined by Our World in Data, which are used in OWID charts and maps.
Last updated: January 1, 2023  
Date range: 2023–2023  
Source: Our World in Data  

#### How to cite this data

Our World in Data


## Sources

These are the sources behind the data in this package. Each time series above names the ones it draws on in its citation.

### UNDP, Human Development Report – Human Development Report

Artificial intelligence (AI) has broken into a dizzying gallop. While AI feats grab headlines, they privilege technology in a make-believe vacuum, obscuring what really matters: people's choices.

The choices that people have and can realize, within ever expanding freedoms, are essential to human development, whose goal is for people to live lives they value and have reason to value. A world with AI is flush with choices the exercise of which is both a matter of human development and a means to advance it.

Going forward, development depends less on what AI can do—not on how human-like it is perceived to be—and more on mobilizing people's imaginations to reshape economies and societies to make the most of it. Instead of trying vainly to predict what will happen, the 2025's Human Development Report asks what choices can be made so that new development pathways for all countries dot the horizon, helping everyone have a shot at thriving in a world with AI.

For more details, refer to https://hdr.undp.org/data-center/documentation-and-downloads

Producer: UNDP, Human Development Report  
Published: 2025-05-06  
Retrieved on: 2025-05-07  
Retrieved from: https://hdr.undp.org/  
Direct download: https://hdr.undp.org/sites/default/files/2025_HDR/HDR25_Composite_indices_complete_time_series.csv  
License: CC BY 3.0 IGO (https://hdr.undp.org/copyright-and-terms-use)  

Citation: UNDP (United Nations Development Programme). 2025. Human Development Report 2025: A matter of choice: People and possibilities in the age of AI. New York.

### Our World in Data – Regions

Producer: Our World in Data  

    