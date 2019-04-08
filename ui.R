library(shiny)
library(writexl)
library(dplyr)

# Define UI for slider demo application
shinyUI(pageWithSidebar(
  
  #  Application title
  headerPanel("Intertemporal Choice Task v.01"),
  
  sidebarPanel(
    # This is intentionally an empty object.
    h6(textOutput("save.results")),
    h5("Created by:"),
    tags$a("Analytical & Technology Department of the Politécnico Grancolombiano", 
           href = "https://www.poli.edu.co/"), #este link o otro?
    h5("For details on how data is generated:"),
    tags$a("Contact: Mora, S.", 
           href = "https://co.linkedin.com/in/sergiomorapardo"),
    h5("Github Repository:"),
    tags$a("Survey implementation", 
           href = paste0("https://github.com/sergiomora03/",
                       "survey")),
    # Display the page counter text.
    h5(textOutput("counter"))
  ),
  
  
  # Show a table summarizing the values entered
  mainPanel(
    # Main Action is where most everything is happenning in the
    # object (where the welcome message, survey, and results appear)
    uiOutput("MainAction"),
    # This displays the action putton Next.
    actionButton("Click.Counter", "Next"),
    br(),
    br(),
    hr(),
    selectInput(inputId = "user", label = "User", choices = paste("User -", 1:25))
    
  )
))