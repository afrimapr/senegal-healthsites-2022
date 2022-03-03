# 2022-02-senegal-facilities.r
# andy south

#library(afrihealthsites)
library(tidyverse)

# saved first sheet from xls as csv
# xls emailed from Mark 

# get local file data, can't share yet
folder <- "C:\\Users\\andy.south\\Google Drive\\afrimapr-gdrive\\Proposals\\2022-01-senegal-covidaction\\data\\"
filename <- "2022-02-senegal-structures.csv"
filename <- paste0(folder,filename)

filenamecous_sl <- "2022-02-20-cous10-stlouis-anon.csv"
filenamecous_sl <- paste0(folder,filenamecous_sl)

filename_lamine <- "2022-02-28-lamine-kobo.csv"
filename_lamine <- paste0(folder,filename_lamine)
  
#dprss file just contains names of facilities - with names of admin regions in too
filename_dprss <- "2022-02-dprss-names.csv"
filename_dprss <- paste0(folder,filename_dprss)

#read in csv
dfhf <- read_csv(filename)
#this doesn't fix accents!
#dfhf <- read_csv(filename, locale=locale("fr"))

names(dfhf)
# [1] "R\xe9gion M\xe9dicale" "District de Sant\xe9"  "Structure sanitaire"   "Type structure"       
# [5] "Autre type structure"  "Statut" "Latitude"              "Longitude"    

#1 convert encoding, 2 remove accents 3 to-lower
#names(dfhf) <- str_to_lower(stringi::stri_trans_general(str_conv(names(dfhf), encoding = "ISO-8859-1"), "Latin-ASCII"))

names(dfhf) <- names(dfhf) %>% 
  #fix accents
  str_conv(encoding = "ISO-8859-1") %>% 
  #remove accents
  stringi::stri_trans_general("Latin-ASCII") %>%
  #lower case
  str_to_lower() %>% 
  #replace spaces with _
  str_replace_all("\\s", "_")
  
  
  
# [1] "region_medicale"      "district_de_sante"    "structure_sanitaire"  "type_structure"      
# [5] "autre_type_structure" "statut"               "latitude"             "longitude"                "latitude"             "longitude"         

#hf has 1485 facilities
#121 in St Louis district
dfhf_sl <- dfhf %>% filter(region_medicale=="Saint Louis")

table(dfhf_sl$type_structure)
# autre   CMG    CS    HP    PS    RM 
#     2     1     6     1   110     1 
#HP hopital - level 3
#CS centre de sante - level 2
#PS poste de sante - level 1
#RM
#CMG


dfcous_sl <- read_csv(filenamecous_sl)
#names(dfcous_sl) #127!

#the Longitude of #9 needed to be -ve to stop it being in Chad
#I corrected in the csv
#dfcous_sl$Longitude[9]
#[1] -16.1452

#library(afrihealthsites)
#compare_hs_sources("senegal", datasources=c("healthsites", dfcous_sl))
# in compare_hs_sources country=senegal admin_level= admin_names=
#   Error in afrihealthsites(country, datasource = datasources[[2]], plot = FALSE,  : 
#                              object 'sfcountry' not found

# convert cous column names to be more manageable
names(dfcous_sl) <- names(dfcous_sl) %>% 
  #fix accents
  #str_conv(encoding = "ISO-8859-1") %>% 
  #remove accents
  stringi::stri_trans_general("Latin-ASCII") %>%
  #remove some long text
  str_replace_all("Quel est le nombre de ","") %>%
  str_replace_all("Quel est le nombre d'","") %>%
  str_replace_all("Quel est le nombre d ","") %>%
  str_replace_all("Quel est le ","") %>% 
  str_replace_all(" de la structure de sante","") %>% 
  str_replace_all("\\?", "") %>% 
  str_replace_all(" \\?", "") %>%  
  #lower case
  str_to_lower() %>%
  #replace spaces with _
  str_replace_all("\\s", "_")


#select most important columns from the cous data



sfcous_sl <- st_as_sf(dfcous_sl, 
                      coords=c("longitude", "latitude"), 
                      crs=4326)

mapview::mapview(sfcous_sl)

#rows 1 & 6 seem on the same site

#TODO select most important columns from the cous data 
#and make the column names more manageable
#try to do that in a reproducible way so that the code can be useful to COUS
#and share in slack
#(better maybe that it doesn't use afrihealthsites)

#read in the data from Lamine
#todo: get accents right

#dfosm <- read_csv(filename_lamine)
#394 rows 289 columns
#sorts accents
dfosm <- read_csv(filename_lamine, locale=locale(encoding = "ISO-8859-1"))

#convert column names to lowercase & remove any accents and spaces
names(dfosm) <- names(dfosm) %>% 
  #fix accents
  str_conv(encoding = "ISO-8859-1") %>% 
  #remove accents
  stringi::stri_trans_general("Latin-ASCII") %>%
  #lower case
  str_to_lower() %>% 
  #replace spaces with _
  str_replace_all("\\s", "_") %>% 
  #remove _facility_location_ before coords
  str_replace_all("_facility_location_", "") %>% 
  str_replace_all("\\?", "") %>%   
  str_replace_all("what_is_the_number_of_", "") 

#dfosm$in_which_health_zone_is_the_facility_located
#[1] NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA 

dfosm2 <- dfosm %>% select(name_of_facility, 
                           city, 
                           operator_type, 
                           longitude, 
                           latitude, 
                           operational_status,
                           facility_category,
                           number_of_beds,
                           number_of_doctors,
                           number_of_nurses)

table(dfosm2$facility_category)
# Clinic  Dentist  Doctors Hospital Pharmacy 
# 15        2      294       22       61 

sfosm <- st_as_sf(dfosm2, 
                  coords=c("longitude", "latitude"), 
                  crs=4326)

mapview::mapview(sfosm, zcol="facility_category")

filename_dprss <- "2022-02-dprss-names.csv"
filename_dprss <- paste0(folder,filename_dprss)

dfdprss <- read_csv(filename_dprss, col_names = "dprss_names")

#todo: be able to subset facilities by department
#may not be necessary spatially if files have the dept column

#maybe subset other csvs by St Louis province to provide in the repo ?

#https://en.wikipedia.org/wiki/Departments_of_Senegal
#The 14 regions of Senegal are subdivided into 46 departments and 103 arrondissements 

library(afriadmin)
library(rgeoboundaries)

#14 admin1 regions
sfadm1 <- rgeoboundaries::geoboundaries("senegal","adm1")
#45 admin2 departments
sfadm2 <- rgeoboundaries::geoboundaries("senegal","adm2")

sfadm1$shapeName
# [1] "Dakar"       "Diourbel"    "Fatick"      "Kaffrine"    "Kaolack"     "Kedougou"   
# [7] "Kolda"       "Louga"       "Matam"       "Saint Louis" "Sedhiou"     "Tambacounda"
# [13] "Thies"       "Ziguinchor" 

sfadm2$shapeName
# [1] "Bakel"             "Bambey"            "Bignona"           "Birkelane"        
# [5] "Bounkiling"        "Dagana"            "Dakar"             "Diourbel"         
# [9] "Fatick"            "Foundiougne"       "Gossas"            "Goudiry"          
# [13] "Goudomp"           "Guediawaye"        "Guinguineo"        "Kaffrine"         
# [17] "Kanel"             "Kaolack"           "Kebemer"           "Kedougou"         
# [21] "Kolda"             "Koumpentoum"       "Koungheul"         "Linguere"         
# [25] "Louga"             "Malem Hodar"       "Matam"             "Mbacke"           
# [29] "Mbour"             "Medina Yoroufoula" "Nioro Du Rip"      "Oussouye"         
# [33] "Pikine"            "Podor"             "Ranerou"           "Rufisque"         
# [37] "Saint Louis"       "Salemata"          "Saraya"            "Sedhiou"          
# [41] "Tambacounda"       "Thies"             "Tivaoune"          "Velingara"        
# [45] "Ziguinchor" 


