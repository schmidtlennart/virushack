library(tidyverse)
library(eurostat)
library(sf)

#Schlüssel von NUTS zu AGS
schluessel_nuts_ags <- read_csv2("schluessel_nuts_ags_kreise.csv") %>% 
  select(-bez_nuts)

#shape file von eurostat
nuts_sf <- get_eurostat_geospatial(nuts_level="all", year = "2016") %>% 
  filter(CNTR_CODE == "DE" & LEVL_CODE == "3")


#zuordnung lat/lon:
#beispiel daten
daten_punkte_raw <- tibble(
  "id" = 1:3,
  "lat" = c(11.5727, 6.9646, 9.439),
  "long" = c(48.1368, 50.9489, 54.7843))

#zu simple feature umwandeln
daten_punkte <- daten_punkte_raw %>% 
  st_as_sf(coords = c("lat", "long"), crs = st_crs(nuts_sf))

#punkte dem entsprechenden kreis anhand des shape files zuordnen
punkte_mit_kreis <- daten_punkte %>% mutate(
  intersection_id = as.integer(st_intersects(geometry, nuts_sf)),
  kreis = case_when(is.na(intersection_id) ~ 'keine kreis zuordnung!',
                    !is.na(intersection_id) ~ nuts_sf$NUTS_NAME[intersection_id]),
  nuts = case_when(is.na(intersection_id) ~ 'keine kreis zuordnung!',
                     !is.na(intersection_id) ~ nuts_sf$NUTS_ID[intersection_id])
) %>% 
  select(-intersection_id) %>% 
  left_join(y = schluessel_nuts_ags, by = ("nuts"))

