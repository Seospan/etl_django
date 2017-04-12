library(data.table)

youtube <- function(filename, lines_to_delete_start = 13, lines_to_delete_end = 1, date_format_input, date_format_output = "%d/%m/%Y", file_format_id){
	#Read file
	DT <- data.table(read.csv(filename, sep="\t", fileEncoding = 'UTF-16LE'))
        
	#Delete useless columns
	DT[,c("Account","Ad.group.ID","Ad.group.state",
		  "Ad.type", "Base.Ad.group.ID", "Base.Campaign.ID", "Business.name",
		  "Call.only.ad.phone.number", "Campaign.ID", "Campaign.state",
		  "Ad.Approval.Status", "Destination.URL", "App.final.URL","Mobile.final.URL",
		  "Tracking.template", "Custom.parameter", "Criteria.Type",
		  "Client.name", "Description", "Description.line.1", "Description.line.2",
		  "Device.preference","Display.URL", "Customer.ID",
		  "Headline.1", "Headline.2", "Ad.ID", "Image.Ad.URL",
		  "Image.Height", "Image.Width", "Image.ad.name", "Is.negative",
		  "Label.IDs", "Labels", "Long.headline", "Path.1",
		  "Path.2", "Company.name", "Short.headline", "Ad.state",
		  "Trademarks", "Network"
	) := NULL]
	
	# Delete lines with 0 impressions
	DT <- DT[Impressions>0]
	
	#Uppercase campaign name
	DT[,Campaign:=toupper(Campaign)]
	
	#Format
	DT[,Formats := ifelse(grepl("IN-DISPLAY",Campaign),"INDISPLAY",
	                        ifelse(grepl("INDISPLAY",Campaign),"INDISPLAY",
	                               ifelse(grepl("DISCOVERY",Campaign),"INDISPLAY",
	                                      ifelse(grepl("TRV",Campaign),"TRUEVIEW",
	                                             ifelse(grepl("TRUEVIEW",Campaign),"TRUEVIEW",
	                                                    ifelse(grepl("GDN",Campaign),"GDN",
	                                                           ifelse(grepl("AUCTION",Campaign),"AUCTION",
	                                                                  ifelse(grepl("AUCTIONCPM",Campaign),"AUCTION",
	                                                                         ifelse(grepl("BUMPER",Campaign),"BUMPER",
	                                                                                'null'
	                                                                         )
	                                                                  )
	                                                           )
	                                                    )
	                                             )
	                                      )
	                               )  
	                         )
	                     )]
	
	#Calculate number of views from percentage depending of format
	DT[,"25pc" := ifelse(Formats=="INDISPLAY",floor(Views*Video.played.to.25./100),floor(Impressions*Video.played.to.25./100))]
	DT[,"50pc" := ifelse(Formats=="INDISPLAY",floor(Views*Video.played.to.50./100),floor(Impressions*Video.played.to.50./100))]
	DT[,"75pc" := ifelse(Formats=="INDISPLAY",floor(Views*Video.played.to.75./100),floor(Impressions*Video.played.to.75./100))]
	DT[,"100pc" := ifelse(Formats=="INDISPLAY",floor(Views*Video.played.to.100./100),floor(Impressions*Video.played.to.100./100))]
	
	#Fill Booking column : clicks if CPC, impressions if anything else
	DT[,Bookings := ifelse(Formats %in% c("AUCTION","BUMPER"),Impressions,
	                                ifelse(Formats =="GDN",Clicks,
	                                        Views
	                                )
	                       )]
	
	DT[,"Video started" := ifelse( Formats =="INDISPLAY" , Views,
	                                        ifelse( Formats =="GDN" , 0,
	                                                Impressions
	                                        )
	                               )]
	
	#Calculate EE ID
	DT[,EE_ID:=sapply(strsplit(as.character(Campaign), "@"), function(x) { return(paste0("@", x[2], "@"))})]
	DT[,Campaign:=sapply(strsplit(as.character(Campaign), "@"), function(x) { return(x[1])})]
	
	#Remove when EE_ID not compliant
	DT<-DT[grepl("@[1-9]*@",EE_ID)]
	
	DT[,Site := ifelse(Formats=="GDN","GDN","YOUTUBE")]
	
	DT[,Mode_achat := ifelse(Formats %in% c("AUCTION","BUMPER"),"CPM",
	                       ifelse(Formats %in% c("INDISPLAY","GDN"),"CPC",
	                              ifelse(Formats =="TRUEVIEW","CPV",
	                                     "Autre"
	                              )
	                       )
	)]
	
	DT[,"Tracking type" := "Régie"]
	
	DT[,Clics_indisplay := ifelse(Formats=="INDISPLAY",Bookings, 0)]
	
	DT[,"Clics" := Clics_indisplay + Clicks]
	
	DT[, Skips := ifelse(Formats=="TRUEVIEW",Impressions - Views,0)]
	
	#Extract yotuube ID
	DT[, ID_YOUTUBE := strsplit(strsplit(as.character(Final.URL),"&")[[1]][1],"v=")[[1]][2]]
	
	#??? Rien ou NULL ?
	DT[, Message := ifelse(grepl("youtube.com",Final.URL), paste0("http://youtube.com/watch?v=",ID_YOUTUBE),"")]
	
	DT[,Source := "ADWORDS"]
	
	#Replace device names to french versions
	old_devices <- c("Tablets with full browsers",
	                 "Mobile devices with full browsers",
	                 "Computers",
	                 "Other")
	new_devices <- c("Tablettes dotées d'un navigateur Internet complet",
	                 "Mobiles dotés d'un navigateur Internet complet",
	                 "Ordinateurs",
	                 "Autre")
	
	DT[Device %in% old_devices, Device := new_devices[match(Device,old_devices)]]

	#Date
	DT[,Date := format(as.Date(as.character(Day),"%Y-%m-%d"),date_format_output)]

	#Rename
	setnames(DT, c("EE_ID","Device","Ad","Campaign","Ad.group","Cost","Views","25pc","50pc","75pc","100pc","Mode_achat","ID_YOUTUBE"),
	                c("EE ID","Appareil","Adname","Placement","Groupe d'annonces","Coût","Affichage","25%","50%","75%","100%","Mode d'achat","ID YOUTUBE")
	         )
	
	#Delete columns that are not used anymore
	DT[,c("Final.URL","Day","Clicks","Video.played.to.100.","Video.played.to.75.","Video.played.to.50.","Video.played.to.25.","Clics_indisplay"
	) := NULL]
	
	#Export file
	min_date<-min(format(as.Date(as.character(DT$Date),date_format_output),"%Y-%m-%d"))
	max_date<-max(format(as.Date(as.character(DT$Date),date_format_output),"%Y-%m-%d"))
	
	exported_filename = paste0("Adwords_Youtube_export_",min_date,"_",max_date,".csv")
	export_to <- paste(out_root,"Adwords",exported_filename,sep="/")
	
	write.csv2(DT,export_to, na="",row.names=FALSE)
	
	#Update the database.
	source("db_functions.R")
	filename_split <-strsplit(filename,"/")
	filename_end = tail(filename_split[[1]],1)
	res = db_change_file_state(filename_end,1)
	message("Updated file ",filename," to state 'Processed'")

	View(DT)
	return(TRUE)
}
                                 
