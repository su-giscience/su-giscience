members <- readxl::read_excel("members.xlsx")

library(foreach)
asHTMLtext <- function(df) {
  paste.br <- function(lhs, rhs) paste(lhs, rhs, sep = "<br>")
  foreach(ic = seq_along(df), .combine = "paste.br") %do% {
    paste(names(df)[ic], df[[ic]], sep = ": ")
  }
}

suppressWarnings(library(leaflet))

m <- leaflet(width = "100%") %>% setView(lng = 5.767249, lat = 45.190590, zoom = 12)
m %>% 
  addTiles() %>% 
  addMeasure(position = "topright", primaryLengthUnit = "kilometers") %>%
  addMarkers(lng = 5.767249, lat = 45.190590, popup = "Meeting location") %>%
  addMarkers(lng = members$Longitude, 
             lat = members$Latitude, 
             popup = asHTMLtext(subset(members, select = -c(Longitude, Latitude))))
