library(shiny)
library(readxl)

# Read the survey questions
#Qlist <- read.csv("Qlist.csv")
Qlist <- as.data.frame(read_xlsx("Qlist.xlsx"))
# Qlist <- Qlist[1,]

shinyServer(function(input, output) {
  
  # Create an empty vector to hold survey results
  results <<- rep("", nrow(Qlist))
  # Name each element of the vector based on the
  # second column of the Qlist
  names(results)  <<- Qlist[,2]
  
  # Hit counter
  output$counter <- 
    renderText({
      if (!file.exists("counter.Rdata")) counter <- 0
      if (file.exists("counter.Rdata")) load(file = "counter.Rdata")
      counter <- counter <<- counter + 1
      
      save(counter, file = "counter.Rdata")     
      paste0("Hits: ", counter)
    })
  
  # This renderUI function holds the primary actions of the
  # survey area.
  output$MainAction <- renderUI( {
    dynamicUi()
  })
  
  # Dynamic UI is the interface which changes as the survey
  # progresses.  
  dynamicUi <- reactive({
    # Initially it shows a welcome message. 
    if (input$Click.Counter == 0) 
      return(
        list(
          h3("Welcome Choice Task Survey!"),
          h4("by Oscar Javier Robayo Pinzon")
        )
      )
    
    # Once the next button has been clicked once we see each question
    # of the survey.
    if (input$Click.Counter > 0 & input$Click.Counter <= nrow(Qlist))  
      return(
        list(
          h2(textOutput("question")),
          h4(radioButtons("survey", "Please Select:", 
                       c("Prefer not to answer", option.list())))
        )
      )
    
    # Finally we see results of the survey as well as a
    # download button.
    if (input$Click.Counter > nrow(Qlist))
      return(
        list(
          h4("View aggregate results"),
          tableOutput("surveyresults"),
          h4("Thanks for taking the survey!"),
          downloadButton('downloadData', 'Download Individual Results'),
          br(),
          h6("Haven't figured out how to get rid of 'next' button yet")
        )
      )    
  })
  
  # This reactive function is concerned primarily with
  # saving the results of the survey for this individual.
  output$save.results <- renderText({
    # After each click, save the results of the radio buttons.
    if ((input$Click.Counter > 0) & (input$Click.Counter > !nrow(Qlist)))
      try(results[input$Click.Counter] <<- input$survey)
    # try is used because there is a brief moment in which
    # the if condition is true but input$survey = NULL
    
    # If the user has clicked through all of the survey questions
    # then R saves the results to the survey file.
    if (input$Click.Counter == nrow(Qlist) + 1) {
      if (file.exists("survey_results.Rdata")) 
        load(file = "survey_results.Rdata")
      if (!file.exists("survey_results.Rdata")) 
        presults <- NULL
        subpresults <- NULL
      subpresults <- subpresults <<- rbind(input$user, results)
      subpresults <- subpresults <<- as.data.frame(subpresults) #
      subpresults <- subpresults <<- cbind(subset(subpresults, grepl("User", subpresults$`¿Qué prefieres?`))[[1]],
                                     subset(subpresults, !grepl("User", subpresults$`¿Qué prefieres?`)))
      colnames(subpresults) <- colnames(subpresults) <<- c("User", colnames(subpresults)[-1])
      presults <- presults <<- rbind(presults, subpresults)
      presults <- presults <<- as.data.frame(presults) #
      #colnames(presults) <- colnames(presults) <<- c("User",colnames(presults)[-1])
      save(presults, file = "survey_results.Rdata")
    }
    # Because there has to be a UI object to call this
    # function I set up render text that distplays the content
    # of this funciton.
    ""
  })
  
  # This function renders the table of results from the
  # survey.
  output$surveyresults <- renderTable({
    results
  })
  
  # This renders the data downloader
  output$downloadData <- downloadHandler(
    filename = "data.xlsx",
    content = function(file) {write_xlsx(as.data.frame(presults), path = file)}
  ) #downloadHandler(filename = "Data.csv", content = function(file) {write.csv(presults, file)})
    
   
  
  # The option list is a reative list of elements that
  # updates itself when the click counter is advanced.
  option.list <- reactive({
    qlist <- Qlist[input$Click.Counter,3:ncol(Qlist)]
    # Remove items from the qlist if the option is empty.
    # Also, convert the option list to matrix. 
    as.matrix(qlist[qlist != ""])
  })
  
  # This function show the question number (Q:)
  # Followed by the question text.
  output$question <- renderText({
    paste0(
      "Q", input$Click.Counter,": ", 
      Qlist[input$Click.Counter,2]
    )
  })
  
})