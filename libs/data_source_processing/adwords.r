library(data.table)

#Read file
DT <- data.table(read.csv('541_636238545695431503.csv',sep="\t", fileEncoding = 'UTF-16LE'))

#Delete ueseless columns
DT[,c("Ad.group.ID","Ad.group","Ad.group.state",
     "Ad.type", "Base.Ad.group.ID", "Base.Campaign.ID", "Business.name",
     "Call.only.ad.phone.number", "Campaign.ID", "Campaign.state",
     "Ad.Approval.Status", "Destination.URL", "App.final.URL","Mobile.final.URL",
     "Final.URL", "Tracking.template", "Custom.parameter", "Criteria.Type",
     "Client.name", "Description", "Description.line.1", "Description.line.2",
     "Device.preference" , "Display.URL", "Customer.ID", "Ad",
     "Headline.1", "Headline.2", "Ad.ID", "Image.Ad.URL",
     "Image.Height", "Image.Width", "Image.ad.name", "Is.negative",
     "Label.IDs", "Labels", "Long.headline", "Path.1",
     "Path.2", "Company.name", "Short.headline", "Ad.state",
     "Trademarks", "Network",
     "Video.played.to.100.", "Video.played.to.25.", "Video.played.to.50.", "Video.played.to.75."
     ) := NULL]

# Delete lines with 0 impressions
DT <- DT[Impressions>0]

#Reformat date
DT[, Year := format(as.Date(Day),'%Y'),]

#Delete old 'day' column
DT[,Day:=NULL,]

#Calculate view rate
DT[,Taux:=Views/Impressions,]

#Calculate EE ID
DT[,EE_ID:=sapply(strsplit(as.character(Campaign), "@"), function(x) { return(paste0("@", x[2], "@"))})]
DT[,Campaign:=sapply(strsplit(as.character(Campaign), "@"), function(x) { return(x[1])})]

#Replace device names to french versions
old_devices <- c("Tablets with full browsers","Mobile devices with full browsers")
new_devices <- c("Tablette","Mobile")

DT[Device %in% old_devices, Device := new_devices[match(Device,old_devices)]]

#Rename
setnames(DT, c("Account","Campaign","Device","Clicks","Cost","Views","Taux","Year"), c("Compte","Campagne","Appareil","Clics","Cout","Affichage","Taux de visionnage","Annee"))
setcolorder(DT, c("Compte","Annee","Appareil","Campagne","Clics","Impressions","Cout","Affichage","Taux de visionnage","EE_ID"))
