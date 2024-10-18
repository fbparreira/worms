






# Function to run WoRMS taxonomical matching engine
# This function requires a vector containing all the species to be searched and matched.
# All the names to which WoRMS don't find a match will be classified as "unmatched".
# For some species (i.e. Gobius niger), WoRMS will give 2 results. The function will detect that 
#and give an Error message. Than, the user should decide between the two and create a vector with 
#the species to be deleted.

worms <- function(names, names_to_delete){
  
  # Install dependencies
  suppressPackageStartupMessages(if(!require("worrms")){install.packages("worrms")})
  suppressPackageStartupMessages(if(!require("tidyverse")){install.packages("tidyverse")})
  
  worms_results <<- data.frame()
  
  for (i in names) {
    
    tryCatch({
      # here goes the expressions to try
      temp <<- wm_records_names(name = i)
      worms_results <<- dplyr::bind_rows(worms_results, temp)
    }, error = function(e){
      # here gow what to do when a an Error occurs
      # the "<<-" allows to assign towords the Global Environment
      temp <<- data.frame("scientificname" = i)%>%
        mutate("status" = "unmatched")
      worms_results <<- dplyr::bind_rows(worms_results, temp)
      print(paste("No match was found for ----", i))})
    
    
    
    if (exists("names_to_delete") == TRUE) {
      
      try({ worms_results <<- worms_results %>%
        filter(!AphiaID %in% names_to_delete)
      
      temp <<- temp %>%
        as.data.frame() %>%
        filter(!AphiaID %in% names_to_delete)},
      silent = TRUE)} else {}
    
    
    if (nrow(as.data.frame(temp)) > 1) {
      stop(paste("More than one match was found for ----", i,
                 "
               
To resolve this issue please:

1. go to worms_results;
2. take note of the AphiaID of the species you want to remove;
3. Add them together in a vector;
4. Give that vector to the function in the argument 'names_to_delete'
               
i.e. names_to_delete = c(AphiaID_1, AphiaID_2, ...)"), call. = FALSE)}}
  
  
  
  if(nrow(worms_results) == length(names)) {
    message(paste("
  
---- WoRMS records ---- was created succefully!
                
          
A total of ---- ",nrow(worms_results)," ---- species were searched."))
    
    
    print( 
      knitr::kable(
        worms_results %>%
          group_by(status) %>%
          summarise(total = length(status))))
    
  }else{
    message("
    
---- Something went wrong! :(
            
The number of observations in the input and output is not the same...")}
  
  
  
  
  worms_results
}


