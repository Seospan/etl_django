require(data.table)
require(bit64)

db_postgresql_connect <- function() {
  require(DBI)
  require(RPostgreSQL)
  pw <- {
    "jJeanAdrien1666"
  }
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname = "paramount",
                   host = "37.59.31.134", port = 5432,
                   user = "root", password = pw)
  rm(pw)
  return(con)
}


db_connect <- function() {
  suppressWarnings(require(DBI))
  return(db_postgresql_connect())
}

db_get_data_files_to_process <- function(needed_state, start_date, end_date) {
        con <- db_connect()
        on.exit(dbDisconnect(con))
        sqlreq <- paste0("
        SELECT *
                FROM csv_etl_fileconversion
        LEFT JOIN csv_etl_datasource ON csv_etl_datasource.id = csv_etl_fileconversion.data_source_id
        WHERE csv_etl_fileconversion.state_process IN (", paste(as.character(needed_state), collapse = ", ") ,") 
                         AND csv_etl_fileconversion.extract_date::date >= '", start_date, "' ",
                         "AND csv_etl_fileconversion.extract_date::date <='", end_date, "'")
        #message(sqlreq)
        res <- dbSendQuery(con, sqlreq)
        res <- as.data.table(dbFetch(res))
        dbDisconnect(con)
        return(res)
}

db_change_file_state <- function(filename,new_state){
        con <- db_connect()
        on.exit(dbDisconnect(con))
        sqlreq <- paste0("
                UPDATE csv_etl_fileconversion set state_process=",new_state," where name='",filename,"'")
        res <- dbSendQuery(con, sqlreq)
        dbDisconnect(con)
        return(res)
}