members <- readxl::read_excel("members.xlsx")
members_infos <- asHTMLtext(
  subset(members, select = -c(Longitude, Latitude, Status)))
ind.admin <- which(members$Status == "admin")

library(foreach)
asHTMLtext <- function(df) {
  paste.br <- function(lhs, rhs) paste(lhs, rhs, sep = "<br>")
  foreach(ic = seq_along(df), .combine = "paste.br") %do% {
    paste(names(df)[ic], df[[ic]], sep = ": ")
  }
}

suppressWarnings(library(leaflet))

icon.meetup <- makeAwesomeIcon("android-locate", library = "ion", 
                               markerColor = "red")
# icon.meetup <- makeAwesomeIcon("arrow-down", library = "fa", 
#                                markerColor = "red")
icon.admin <- makeAwesomeIcon("person", library = "ion", 
                              markerColor = "darkblue")
icon.member <- makeAwesomeIcon("person", library = "ion")


m <- leaflet(width = "100%") %>% setView(lng = 5.767249, lat = 45.190590, zoom = 12)
print(m %>% 
        addTiles() %>% 
        addMeasure(position = "topright", primaryLengthUnit = "kilometers") %>%
        addAwesomeMarkers(lng = 5.767249, lat = 45.190590, popup = "Meeting location",
                          icon = icon.meetup) %>%
        addAwesomeMarkers(lng = members$Longitude[ind.admin], 
                          lat = members$Latitude[ind.admin], 
                          popup = members_infos[ind.admin],
                          icon = icon.admin) %>%
        addAwesomeMarkers(lng = members$Longitude[-ind.admin], 
                          lat = members$Latitude[-ind.admin], 
                          popup = members_infos[-ind.admin],
                          icon = icon.member)
)
  
