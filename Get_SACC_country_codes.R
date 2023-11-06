# COUNTRY AND REGION CODES FROM ABS
## This script compiles SACC country codes, country names and regions from
## ABS data. ABS data is messy and needs to be cleaned.

# Load packages
pacman::p_load(here,tidyverse,httr)

# The raw data is in the following url
url1 <- 
  'https://www.abs.gov.au/statistics/classifications/standard-australian-classification-countries-sacc/2016/sacc_12690do0001_202301.xlsx'


GET(url1,write_disk(here('Raw','SACC_Countries_2016.xlsx'),overwrite=TRUE))


Region <- 
  read_excel(
    here('Raw','SACC_Countries_2016.xlsx'),
    sheet=2,
    col_names = F
             ) %>% 
  rename(region_code=`...1`,region=`...2`) %>% 
  filter(!is.na(region)) %>% 
  mutate(across(ends_with('code'),~as.numeric(.)))

Sub_region <- 
  read_excel(
    here('Raw','SACC_Countries_2016.xlsx'),
    sheet=3,
    col_names = F
  ) %>% 
  rename(sub_region_code=`...2`,sub_region=`...3`) %>%
  filter(!is.na(sub_region)) %>% 
  select(-`...1`) %>% 
  mutate(across(ends_with('code'),~as.numeric(.)))

Country <-
  read_excel(
    here('Raw','SACC_Countries_2016.xlsx'),
    sheet=4,
    col_names = F
  ) %>% 
  rename(country_code=`...3`,country=`...4`) %>%
  filter(!is.na(country)) %>% 
  select(-`...2`,-`...1`) %>%
  mutate(
    country_code=as.character(country_code),
    region_code=substr(country_code,1,1),
    sub_region_code=substr(country_code,1,2),
    across(ends_with('code'),~as.numeric(.))
  )

Country <- 
  left_join(Country,Sub_region,by='sub_region_code') %>% 
  left_join(.,Region,by='region_code') %>%
  mutate(
    across(
      where(is.character),
      ~str_to_title(.)
    )
  )

write_csv(Country,here('Raw','SACC_Countries_2016.csv'))