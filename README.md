# Implementing the Census' Proposed Inflation Measure
In this repository, I implement the Census Bureau [proposal](https://www2.census.gov/programs-surveys/demo/guidance/income-poverty/record-layouts/data-extracts/Inflation_frn_response.pdf) for a revised inflation measure for adjusting historic incomes. The proposed measure uses the [CPI-U series](https://fred.stlouisfed.org/series/CPIAUCSL) between 1947-1966, the [CPI-U-X1 series](https://www.census.gov/topics/income-poverty/income/guidance/current-vs-constant-dollars.html) between 1967-1977, the [R-CPI-U-RS series](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm) between 1978-1999, and the series [C-CPI-U](https://www.bls.gov/cpi/additional-resources/chained-cpi.htm) from 2000-Present.

### Data Sources
- [CPI-U](https://fred.stlouisfed.org/series/CPIAUCSL) [Retrieved July 14, 2023]
- [CPI-U-X1](https://www.census.gov/topics/income-poverty/income/guidance/current-vs-constant-dollars.html) [Retrieved July 14, 2023]
- [R-CPI-U-RS](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm) [Retrieved July 14, 2023]
- [C-CPI-U](https://fred.stlouisfed.org/series/SUUR0000SA0) [Retrieved July 14, 2023]

### Methodology
I construct and provide two series in this repository. The first is an annual inflation index based directly on the Census' proposal to use all four surveys (CPI-U, CPI-U-X1, R-CPI-U-RS, and C-CPI-U between 1947-Present. In the second, I construct a monthly inflation index based on the CPI-U, R-CPI-U-RS, and C-CPI-U between 1947-Present. The second, monthly, index departs from the direct Census proposal since the Census Bureau was primarily concerned with a new inflation measure to adjust income estimates for the annual ASEC supplement to the CPS. However, three of the four inflation indices used in the Census proposal contain monthly inflation estimates. However, the CPI-U-X1 index is only available on an annual basis. Therefore, I substitute estimates from the CPI-U-X1 proposed period (1967-1977) with estimates from the CPI-U. These two measures and corresponding dates for each series are summarized in the table below.

| Dates | Annual Measure | Monthly Measure |
| ----- | -------------- | --------------- |
| 1947-1966 | CPI-U | CPI-U |
| 1967-1977 | CPI-U-X1 | CPI-U |
| 1978-1999 | R-CPI-U-RS | R-CPI-U-RS |
| 2000-Present | C-CPI-U | C-CPI-U |

### Results
All results can be found in the "[Output](https://github.com/jamesohawkins/Inflation-Measure/tree/main/Output)" folder.

The monthly series is named "seriesCensusRec_mthly" and can be found in "[adjustment_monthly.dta](https://github.com/jamesohawkins/Inflation-Measure/blob/main/Output/adjustment_monthly.dta)" and "[adjustment_monthly.csv](https://github.com/jamesohawkins/Inflation-Measure/blob/main/Output/adjustment_monthly.csv)". The annual series is named "seriesCensusRec" and can be found in "[adjustment_annual.dta](https://github.com/jamesohawkins/Inflation-Measure/blob/main/Output/adjustment_annual.dta)" and "[adjustment_annual.csv](https://github.com/jamesohawkins/Inflation-Measure/blob/main/Output/adjustment_annual.csv)".

### Code Replication
To replicate the construction of these series, follow the procedure below:
1) Download this Github repository.
2) Download each data source (listed above) and place in a new folder titled "Raw-Data" within your local version of the repository.
3) Create a folder titled "Derived-Data' within your local version of the repository.
4) Replace the open and closed brackets on line 25 of the "[construct-inflation-measure.do](https://github.com/jamesohawkins/Inflation-Measure/tree/main/Scripts)" script with the directory of the repository.
5) Execute the "construct-inflation-measure.do" script.

I use Stata 17 to construct all series.

### Citations
U.S. Bureau of Labor Statistics, Chained Consumer Price Index for All Urban Consumers: All Items in U.S. City Average [SUUR0000SA0], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/SUUR0000SA0, July 14, 2023.

U.S. Bureau of Labor Statistics, Consumer Price Index for All Urban Consumers: All Items in U.S. City Average [CPIAUCSL], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/CPIAUCSL, July 14, 2023.
