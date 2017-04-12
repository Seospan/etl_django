require(data.table)
require(bit64)
require(DBI)


main_function <- function(overwrite = FALSE,
                          start_date = as.Date("2000-01-01"),
                          end_date = Sys.Date()-1) {
        
        # source files
        source("db_functions.R")
        source("libs_settings.py")
        
        # retrieve the list of files
        needed_states <- 0
        if(overwrite) { needed_states <- c(1, needed_states)}
        file_list <- db_get_data_files_to_process(needed_states, start_date, end_date)
        message(nrow(file_list)," files in Database")

        if(nrow(file_list) >0){
                file_list[, path := paste(extract_root, dir_name, name, sep = "/")]
                file_list <- file_list[file.exists(path)]
                # rajouter test nrow(file_list) != 0
                file_list <- split(file_list, as.factor(file_list$data_source_id))
                message(length(file_list)," data sources to process :")
                lapply(file_list, process_one_data_source)   
        }else{
              message("No unprocessed file. Stopping.")  
        }

}

process_one_data_source <- function(file_list) {
        source(paste0(rfunctions_dir, file_list[1]$r_function, ".R"))
        message("Processing source from folder '",file_list[1]$dir_name,"' with function '", file_list[1]$r_function,"' (",nrow(file_list)," files)")
        lapply(file_list$path, function(x) { do.call(file_list[1]$r_function, 
                                                list(x,
                                                     file_list[1]$lines_to_delete_start, 
                                                     file_list[1]$lines_to_delete_end, 
                                                     file_list[1]$date_format_input, 
                                                     file_list[1]$date_format_output, 
                                                     file_list[1]$file_format_id)) })
}