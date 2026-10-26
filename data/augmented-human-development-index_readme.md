# Augmented Human Development Index - Data package

This data package contains the data that powers the chart ["Augmented Human Development Index"](https://ourworldindata.org/grapher/augmented-human-development-index?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

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


### Augmented Human Development Index (AHDI)
The AHDI seeks to give a historical perspective on human development, in four dimensions: healthy life, knowledge, a decent standard of living, and civil and political freedom.

Last updated: September 8, 2023  
Next expected update: November 2026  
Date range: 1870–2020  
Source: Leandro Prados de la Escosura (2022) – with minor processing by Our World in Data  

#### How to cite this data

Leandro Prados de la Escosura (2022) – with minor processing by Our World in Data

#### What you should know about this data
- Each of the dimensions of the AHDI is measured with four indicators: a long and healthy life is measured by _life expectancy at birth_, knowledge is measured by _mean_ _years of schooling_; a decent standard of living is measured by _GDP per capita_, logarithmized to reflect that incomes become less important as they increase; and civil and political freedom is measured by [_Varieties of Democracy's Liberal democracy index_](https://ourworldindata.org/vdem-electoral-democracy-data).
- The index is then calculated by normalizing the indicators. First, the indicators are brought onto the same scale, ranging from 0 to 1. This is done by setting minimum and maximum values for each indicator, and a country at or below the minimum value receiving a score of 0, and a country at or above the maximum value receiving a score of 1.
- The minimum and maximum values for each indicator are defined as follows: _Life expectancy at birth_ ranges between 20 and 85 years; _mean years of schooling_, between 0 and 15 years; _GDP per capita_ between 100 and 47,000 international-$ at 1990 prices; and V-Dem's Liberal democracy index is already standardized between 0 and 1 (most democratic).
- The AHDI is then estimated as the geometric mean of these indices, or _AHDI = (Health index * Education index * Income index * Freedom index)^(1/4)_.

#### How this data is described by its producers
Human wellbeing is widely viewed as a multidimensional phenomenon, in which income is only one facet. Human development, originally defined as a process of enlarging people’s choices, namely, enjoying a healthy life, acquiring knowledge and achieving a decent standard of living, provides a multidimensional measure of wellbeing.

These achievements provide individuals with freedom to choose and the opportunity to lead their own lives. Thus, human development can be depicted as positive freedom by which individuals are granted access to resources, including property, that allow them to develop their personal potential.

In order to provide a synthetic measure of augmented human development, its different dimensions are expressed in index form,

  - life expectancy at birth as a proxy for a healthy life,
  - years of schooling as a proxy for access to knowledge,
  - liberal democracy as a proxy for freedom,
  - and discounted GDP per head as a surrogate for wellbeing dimensions other than education and health.

The indices for each dimension are, then, combined using equal weights into an index of human development.

In an attempt to reduce the substitutability between its different dimensions –namely, to avoid that a high achievement in one dimension linearly compensates for a low achievement in another–, the indices for each dimension are combined into a historical index of human development using a geometric average.

If we denote the non-linearly transformed values of life expectancy and education as LEB and EDU, LD to represent those of liberal democracy, and the adjusted per capita income as UNY, the historical index of human development can be expressed as,

_AHDI = (LEB * EDU * LD * UNY)^(1/4)_


### World region according to OWID
Regions defined by Our World in Data, which are used in OWID charts and maps.
Last updated: January 1, 2023  
Date range: 2023–2023  
Source: Our World in Data  

#### How to cite this data

Our World in Data


## Sources

These are the sources behind the data in this package. Each time series above names the ones it draws on in its citation.

### Leandro Prados de la Escosura – Augmented Human Development Index (AHDI) – Country data

The economic historian Leandro Prados de la Escosura has calculated the AHDI over the last 150 years. He refers to it as the Augmented Human Development Index.

## Dimensions of Augmented Human Development

In order to provide a synthetic measure of augmented human development, its different dimensions are expressed in index form,

  - life expectancy at birth as a proxy for a healthy life,
  - years of schooling as a proxy for access to knowledge,
  - liberal democracy as a proxy for freedom,
  - and discounted GDP per head as a surrogate for wellbeing dimensions other than education and health.

Life expectancy is defined as the average number of years of life which would remain for males and females reaching the ages specified if they continued to be subjected to the same mortality experienced in the year(s) to which these life expectancies refer.

Education attainment is measured by the average years of total schooling (primary, secondary, and tertiary) for the population aged 15 and over.

The Liberal Democracy Index combines the electoral democracy index and the liberal component index. The former incorporates indices of freedom of association, expression, suffrage, and clean elections. The latter includes indices of equality before the law and individual liberty, judicial constraints on the executive, and legislative constraints on the executive.

GDP per head is expressed in 1990 dollars adjusted for its purchasing power adjusted, that it, for the difference in price level across countries (the so-called Geary-Khamis [G-K] 1990 $).

## Time and Spatial Coverage

Over the entire time span, 1870-2020, 115 countries are considered, and its number rises up to 121, 146, 161, and 162 countries for the samples starting in 1913, 1950, 1980, and 1990, respectively. These samples represent above 90 percent of the world population (and practically 100 percent after 1950).

## Alert: measuring changes in the index

By how much did human development improve over the long run? Given the way in which the index has been computed, the conventional logarithmic rate of variation (as in the case of GDP per head) can be used.

Producer: Leandro Prados de la Escosura  
Published: 2022  
Retrieved on: 2026-09-04  
Retrieved from: https://frdelpino.es/investigacion/en_gb/world-economy/human-development-world-economy/  
Direct download: https://frdelpino.es/investigacion/wp-content/uploads/2025/11/AHDI_countries_1870-2020_dataset.xlsx  
License: Creative Commons BY 4.0 (https://frdelpino.es/investigacion/en_gb/world-economy/human-development-world-economy/)  

Citation: Leandro Prados de la Escosura (2022), Human Development and the Path to Freedom: 1870 to the Present, Cambridge: Cambridge University Press. https://doi.org/10.1017/9781108769655

### Leandro Prados de la Escosura – Augmented Human Development Index (AHDI) – Regional data

The economic historian Leandro Prados de la Escosura has calculated the AHDI over the last 150 years. He refers to it as the Augmented Human Development Index.

## Dimensions of Augmented Human Development

In order to provide a synthetic measure of augmented human development, its different dimensions are expressed in index form,

  - life expectancy at birth as a proxy for a healthy life,
  - years of schooling as a proxy for access to knowledge,
  - liberal democracy as a proxy for freedom,
  - and discounted GDP per head as a surrogate for wellbeing dimensions other than education and health.

Life expectancy is defined as the average number of years of life which would remain for males and females reaching the ages specified if they continued to be subjected to the same mortality experienced in the year(s) to which these life expectancies refer.

Education attainment is measured by the average years of total schooling (primary, secondary, and tertiary) for the population aged 15 and over.

The Liberal Democracy Index combines the electoral democracy index and the liberal component index. The former incorporates indices of freedom of association, expression, suffrage, and clean elections. The latter includes indices of equality before the law and individual liberty, judicial constraints on the executive, and legislative constraints on the executive.

GDP per head is expressed in 1990 dollars adjusted for its purchasing power adjusted, that it, for the difference in price level across countries (the so-called Geary-Khamis [G-K] 1990 $).

## Time and Spatial Coverage

Over the entire time span, 1870-2020, 115 countries are considered, and its number rises up to 121, 146, 161, and 162 countries for the samples starting in 1913, 1950, 1980, and 1990, respectively. These samples represent above 90 percent of the world population (and practically 100 percent after 1950).

## Alert: measuring changes in the index

By how much did human development improve over the long run? Given the way in which the index has been computed, the conventional logarithmic rate of variation (as in the case of GDP per head) can be used.

Producer: Leandro Prados de la Escosura  
Published: 2022  
Retrieved on: 2026-09-04  
Retrieved from: https://frdelpino.es/investigacion/en_gb/world-economy/human-development-world-economy/  
Direct download: https://frdelpino.es/investigacion/wp-content/uploads/2025/11/AHDI_regions_1870-2020_dataset.xlsx  
License: Creative Commons BY 4.0 (https://frdelpino.es/investigacion/en_gb/world-economy/human-development-world-economy/)  

Citation: Leandro Prados de la Escosura (2022), Human Development and the Path to Freedom: 1870 to the Present, Cambridge: Cambridge University Press. https://doi.org/10.1017/9781108769655

### Our World in Data – Regions

Producer: Our World in Data  

    