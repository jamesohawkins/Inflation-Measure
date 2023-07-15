////////////////////////////////////////////////////////////////////////////////
// Script: construct-inflation-measure.do
// Author: James Hawkins
// Stata Version: 17
// Datasets Used: CPIAUCSL.csv; R_CPI_U_RS.xlsx; r-cpi-u-rs-allitems.xlsx; 
//				  SUUR0000SA0.csv. 
// Description: This script implements I implement Census Bureau recommendations
// for a revised inflation measure for adjusting historic incomes.
// 
// Code is separated into three sections:
//		1. Initialize Script
//		2. Import and Wrangle Inflation Series
//		3. Combine Series into Census-Recommended Measure
////////////////////////////////////////////////////////////////////////////////


// =============================================================================
// 1. Initialize Script
// =============================================================================

// Packages
ssc install nrow, replace

// Directory
global directory "[]" // Insert directory here


// =============================================================================
// 2. Import and Wrangle Inflation Series
// =============================================================================

// CPI-U
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory/raw-data"
import delimited using CPIAUCSL.csv, clear

// Wrangle data
gen date_ = date(date, "YMD")
drop date
rename date_ date
rename cpiaucsl cpiu
lab var cpiu "Consumer Price Index for All Urban Consumers"
gen month = month(date)
gen year = year(date)
keep year month cpiu
order year month cpiu

// Save monthly measure
cd "$directory\derived-data"
compress
save cpiu_monthly.dta, replace

// Save annual measure
collapse (mean) cpiu, by(year)
cd "$directory\derived-data"
compress
save cpiu_annual.dta, replace


// CPI-U-X1
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory/raw-data"
import excel using R_CPI_U_RS.xlsx, clear

// Wrangle data
drop in 1/2
nrow 1
destring _all, replace force
rename Year year
rename B cpiux1
lab var cpiux1 "CPI-U experimental series"
keep year cpiux1
drop if year == .
keep if inrange(year, 1966, 1977)

// Save wrangled data
cd "$directory\derived-data"
compress
save cpiux1.dta, replace


// R-CPI-U-RS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory/raw-data"
import excel using r-cpi-u-rs-allitems.xlsx, clear

// Wrangle data
drop in 1/5
nrow 1
destring _all, replace force
drop AVG
foreach x of var * {
	rename `x' var_`x'
}
rename var_YEAR year
reshape long var_, i(year) j(month) string
drop if month == "_"
gen month_ = 1 if month == "JAN"
replace month_ = 2 if month == "FEB"
replace month_ = 3 if month == "MAR"
replace month_ = 4 if month == "APR"
replace month_ = 5 if month == "MAY"
replace month_ = 6 if month == "JUNE"
replace month_ = 7 if month == "JULY"
replace month_ = 8 if month == "AUG"
replace month_ = 9 if month == "SEP"
replace month_ = 10 if month == "OCT"
replace month_ = 11 if month == "NOV"
replace month_ = 12 if month == "DEC"
drop month
rename month_ month
sort year month
rename var_ rcpiurs
lab var rcpiurs "CPI-U Research Series"
order year month rcpiurs

// Save monthly measure
cd "$directory\derived-data"
compress
save rcpiurs_monthly.dta, replace

// Save annual measure
collapse (mean) rcpiurs, by(year)
cd "$directory\derived-data"
compress
save rcpiurs_annual.dta, replace


// C-CPI-U
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory/raw-data"
import delimited using SUUR0000SA0.csv, clear

// Wrangle data
gen date_ = date(date, "YMD")
drop date
rename date_ date
gen month = month(date)
gen year = year(date)
rename suur0000sa0 ccpiu
lab var ccpiu "Chained Consumer Price Index for All Urban Consumers"
keep year month ccpiu
order year month ccpiu

// Save monthly measure
cd "$directory\derived-data"
compress
save ccpiu_monthly.dta, replace

// Save annual measure
collapse (mean) ccpiu, by(year)
cd "$directory\derived-data"
compress
save ccpiu_annual.dta, replace


// =============================================================================
// 3. Combine Series into Census-Recommended Measure
// =============================================================================
/* For more information, see: https://tinyurl.com/343th6mn */

// Annual Series
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory\derived-data"
use cpiu_annual.dta, clear

// Combine CPI-U, CPI-U-X1, R-CPI-U-RS, and C-CPI-U
merge 1:1 year using cpiux1.dta, nogen
merge 1:1 year using rcpiurs_annual.dta, nogen
merge 1:1 year using ccpiu_annual.dta, nogen

// Define Census-Recommended Measure
gen seriesCensusRec = cpiu if inrange(year, 1947, 1966)
* adjust series for cpiux1
replace seriesCensusRec = seriesCensusRec[_n-1] * (cpiux1 / cpiux1[_n-1]) if inrange(year, 1967, 1977)
* adjust series for rcpiurs
replace seriesCensusRec = seriesCensusRec[_n-1] * (rcpiurs / rcpiurs[_n-1]) if inrange(year, 1978, 1999)
* adjust series for ccpiu
replace seriesCensusRec = seriesCensusRec[_n-1] * (ccpiu / ccpiu[_n-1]) if year >= 2000
lab var seriesCensusRec "Census-recommended inflation measure, annual (1947-2022)"

// Save monthly series
cd "$directory\output"
compress
save adjustment_annual, replace


// Monthly Series
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory\derived-data"
use cpiu_monthly.dta, clear

// Combine CPI-U, R-CPI-U-RS, and C-CPI-U
merge 1:1 year month using rcpiurs_monthly.dta, nogen
merge 1:1 year month using ccpiu_monthly.dta, nogen

// Define Census-Recommended Measure
gen seriesCensusRec_mthly = cpiu if inrange(year, 1947, 1977)
* adjust series for rcpiurs
replace seriesCensusRec_mthly = seriesCensusRec[_n-1] * (rcpiurs / rcpiurs[_n-1]) if inrange(year, 1978, 1999)
* adjust series for ccpiu
replace seriesCensusRec_mthly = seriesCensusRec[_n-1] * (ccpiu / ccpiu[_n-1]) if year >= 2000
lab var seriesCensusRec_mthly "Census-recommended inflation measure, monthly (XX XX to June 2023)"

// Save monthly series
cd "$directory\output"
compress
save adjustment_monthly, replace