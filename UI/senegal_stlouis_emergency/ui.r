#/ui.r

# cran_packages <- c("shiny","leaflet","remotes")
# lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(shiny)
library(leaflet)
library(remotes)

# if(!require(afrihealthsites)){
#   remotes::install_github("afrimapr/afrihealthsites")
# }
# 
# library(afrihealthsites)

library(mapview)


pageWithSidebar(
  headerPanel('Senegal St Louis emergency care pilot viewer'),
  sidebarPanel( width=2,

    # checkboxGroupInput("hs_amenity", label = h5("healthsites amenities"),
    #                    choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
    #                    selected = c("hospital","clinic","doctors","pharmacy")),

    # radioButtons("attribute_to_plot", label = h3("Attribute to plot"),
    #              choices = list("Number.of.Beds" = "Number.of.Beds",
    #                             "Number.of.Doctors" = "Number.of.Doctors",
    #                             "Number.of.Nurses"= "Number.of.Nurses",
    #                             "Operator.Type" = "Operator.Type",
    #                             "When.is.the.facility.open." = "When.is.the.facility.open.",
    #                             "Facility.Category" = "Facility.Category",
    #                             "Does.this.facility.provide.Emergency.Services." = "Does.this.facility.provide.Emergency.Services.",
    #                             "Types.of.insurance.accepted." = "Types.of.insurance.accepted."),
    #              selected = "Number.of.Beds"),

    p("PROTOTYPE March 2022, not to be used for decision making"),

    p("Developed by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"),
      "Open source ", a("R code", href="https://github.com/afrimapr/senegal-healthsites-2022", target="_blank")),
 
    #p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),
    #p(tags$small("Disclaimer : Data used by afrimapr are sourced from published open data sets. We provide no guarantee of accuracy.")),

  ),
  mainPanel(
    leafletOutput("serve_healthsites_map", height=1000)
  )
)


