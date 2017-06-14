library(dplyr)
library(leaflet)

crosstalk::SharedData$new()

members <- googlesheets::gs_read(
  googlesheets::gs_key(
    "1WyfmLfoAQUP2iRogqcOfYA9Hum7DT0BcVyTtei_6Xjw", 
    lookup = TRUE, visibility = "private"
  )
) %>% 
  tidyr::unite_(col = "Name", from = c("First name", "Last name"),
                sep = " ", remove = TRUE) %>%
  mutate(Name = if_else(is.na(Website), Name, 
                        paste0("<a href='", Website, "' target='_blank'>", Name, "</a>")))

members$Status[is.na(members$Status)] <- "member"
stopifnot(all(members$Status %in% c("member", "referent", "admin")))
ind.member <- which(members$Status == "member")

members2 <- subset(members, select = -Website) %>% 
  mutate(infos = paste0(
    Name, "<br>",
    if_else(is.na(Institution), "", paste0("at ", Institution, "<br>")),
    if_else(is.na(Field), "", paste0("in ", Field, "<br>")),
    if_else(is.na(Keywords), "", paste0("knows ", Keywords)))
  )


icon.meetup <- makeAwesomeIcon("android-locate", library = "ion", markerColor = "red")
icon.member <- makeAwesomeIcon("person", library = "ion")
icon.referent <- makeAwesomeIcon("person", library = "ion", markerColor = "darkblue")

suppressWarnings(
  leaflet(data = members2, width = "100%") %>% 
    setView(lng = 5.767249, lat = 45.190590, zoom = 12) %>% 
    addTiles(options = providerTileOptions(minZoom = 2, maxZoom = 20)) %>%
    addAwesomeMarkers(lng = 5.767249, lat = 45.190590, popup = "Meeting location",
                      icon = icon.meetup) %>%
    addAwesomeMarkers(lng = members2$Longitude, 
                      lat = members2$Latitude, 
                      popup = members2$infos,
                      icon = if_else(members2$Status == "member",
                                     icon.member,
                                     icon.referent)) %>%
    # addAwesomeMarkers(data = members2, lng = Longitude[-ind.member], 
    #                   lat = Latitude[-ind.member], 
    #                   popup = infos[-ind.member],
    #                   icon = icon.referent) %>%
    htmlwidgets::onRender('
      function(el, x) {
        var myMap = this;
        myMap.on("click", function(e) {
          alert("Latitude: " + e.latlng.lat + "\\nLongitude: " + e.latlng.lng)
        })
      }')
)

DT::datatable(select(members2, -c(Latitude, Longitude, infos)),
              rownames = FALSE, escape = FALSE)
