# devtools::install_github("privefl/googlesheets")
library(googlesheets)
library(dplyr)

stopifnot("missingAsBlank" %in% formalArgs("gs_add_row"))

# gs_auth()
membersToAdd.gs <- gs_key(
  "1qdG7PPlRCAU8L6Hhq1D2zT0q9LWDUzBfq7mIzz_6Dm8", 
  lookup = TRUE, visibility = "private"
) 
to.add <- gs_read(membersToAdd.gs, skip = 6)

n <- nrow(to.add)
if (n > 1) {
  # add new members to true list
  gs_key("1WyfmLfoAQUP2iRogqcOfYA9Hum7DT0BcVyTtei_6Xjw", 
         lookup = TRUE, visibility = "private") %>%
    gs_add_row(input = cbind(to.add[-1, ], Status = NA), missingAsBlank = TRUE)
  # remove them from the add list
  to.add[] <- NA
  gs_edit_cells(membersToAdd.gs, input = to.add[-1, ], byrow = TRUE, 
                anchor = "R9C1", col_names = FALSE, missingAsBlank = TRUE)
} else {
  message("No new member to add!")
}
