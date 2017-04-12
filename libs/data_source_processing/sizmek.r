require(data.table)

sizmek <- function(filename, lines_to_delete_start = 13, lines_to_delete_end = 1, date_format_input="%m/%d/%Y", date_format_output="", file_format_id=""){
  DT <- fread(filename, skip = lines_to_delete_start, encoding = "UTF-8")
  DT <- DT[1:nrow(DT)-lines_to_delete_end]
  
  #file.info("Paramount_FR__Custom_Report_151003_715216.csv")$ctime
  
  #Skip "," for thousands
  setnames(DT, c("* Served Impressions", "* Clicks"), c("X..Served.Impressions", "X..Clicks"))
  setnames(DT, names(DT), gsub(" ", ".", gsub("%", "", names(DT))))
  
  DT[, X..Served.Impressions := as.integer( gsub(",", "", as.character(X..Served.Impressions)) )]
  DT[, X..Clicks := as.integer( gsub(",", "", as.character(X..Clicks)) )]
  DT[, Total.Media.Cost := as.numeric( gsub(",", "", as.character(Total.Media.Cost)) )] 
  DT[, Video.Started := as.integer( gsub(",", "", as.character(Video.Started)) )]
  DT[, Video.Played.25 := as.integer( gsub(",", "", as.character(Video.Played.25)) )]
  DT[, Video.Played.50 := as.integer( gsub(",", "", as.character(Video.Played.50)) )]
  DT[, Video.Played.75 := as.integer( gsub(",", "", as.character(Video.Played.75)) )]
  DT[, Video.Fully.Played := as.integer( gsub(",", "", as.character(Video.Fully.Played)) )]
  
  #Skip clicks + imp == 0
  DT<-DT[as.integer(as.character(X..Clicks)) + as.integer(as.character(X..Served.Impressions))>0]
  #Fractionner Placement
  DT[,Site:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(toupper(x[1]))})]
  DT[,Achat:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(toupper(x[2]))})]
  DT[,Placement:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(x[3])})]
  DT[,Formats:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(toupper(x[4]))})]
  DT[,Tracking.type:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(x[5])})]
  DT[,EE.ID:=sapply(strsplit(as.character(Placement.Name), "_"), function(x) { return(toupper(x[6]))})]
  
  DT[,Placement.Name:=NULL]
  
  #Fractionner adname
  DT[,Adname:=sapply(strsplit(as.character(Ad.Name), "_"), function(x) { return(toupper(x[2]))})]
  
  #Remove when EE_ID not compliant
  DT<-DT[grepl("@[1-9]*@",EE.ID)]
  
  #Split Ad.name to get adname in a new column
  DT[,Adname:=sapply(strsplit(as.character(Ad.Name), "_"), function(x) { return(toupper(x[2]))})]
  
  #Fill Booking column : clicks if CPC, impressions if anything else
  DT[,Bookings := ifelse(Achat=="CPC",X..Clicks,X..Served.Impressions)]
  
  #Remove True View & Bumper Ad
  DT[!(Formats %in% c('TRUEVIEW','BUMPERAD','BUMPER AD'))]
  
  DT[,c("Campaign.ID","Campaign.Name","Site.ID","Site.Name","Placement.ID","Ad.ID","Ad.Name","Ad.Format","Impressions.with.Video.Start"):=NULL]
  
  setnames(DT,c("Achat","Total.Media.Cost","X..Served.Impressions","X..Clicks","Video.Played.25","Video.Played.50","Video.Played.75","Video.Fully.Played","Tracking.type","Video.Started","EE.ID"),
           c("Mode d'achat","Coût","Impressions","Clics","25%","50%","75%","100%","Tracking type","Video Started","EE ID"))
  setcolorder(DT,c("Site","Mode d'achat","Placement","Formats","Tracking type","EE ID","Adname","Impressions","Clics","Coût","Video Started","25%","50%","75%","100%","Date","Bookings"))
  
  min_date<-min(as.Date(as.character(DT$Date),date_format_input))
  max_date<-max(as.Date(as.character(DT$Date),date_format_input))
  
  #Export file
  exported_filename = paste0("Sizmek_export_",min_date,"_",max_date,".csv")
  export_to <- paste(out_root,"Sizmek",exported_filename,sep="/")

  write.csv2(DT,export_to, na="",row.names=FALSE)
  
  #Update the database.
  source("db_functions.R")
  filename_split <-strsplit(filename,"/")
  filename_end = tail(filename_split[[1]],1)
  res = db_change_file_state(filename_end,1)
  message("Updated file ",filename," to state 'Processed'")
  #source("libs_settings.py")
  return(TRUE)
  
  #export_to <- paste(out_root,sep="/")
  #write.csv2
  #export : NA == empty string
 
}

