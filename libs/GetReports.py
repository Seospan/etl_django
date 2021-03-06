# coding: utf-8

# In[5]:

from ftplib import FTP_TLS
import os

import os
import sys
import django
from libs_settings import path_paramount, path_program, extract_root, ftp_host, ftp_user, ftp_passwd, server_path_root
from django.core.exceptions import ObjectDoesNotExist

os.chdir(path_program)
# print(os.getcwd())
sys.path.append(path_paramount)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "paramount_etl.settings")

django.setup()
print(os.getcwd())
# Django models import
from django import db
from csv_etl.models import DataSource, RetrieveMethod, RetrieveFtp, RetrieveMail, FileConversion

#print(db.connections.databases)

print("connection to ftp")
#ftp = FTP_TLS(ftp_host)
#ftp.login(ftp_user, ftp_passwd)
# ftp.dir()
#ftp.cwd('www')

nb_data_source = len(DataSource.objects.all())
i = 0
for dataSource in DataSource.objects.all():
    i=i+1
    print(str(i)+"/"+str(nb_data_source)+" Data source " + dataSource.name +" ( " + str(dataSource.retrieve_method.pk) + " ) ")

    #out_folder = dataSource.out_directory

    #ind if FTP or Mail retrieval method
    is_mail = False
    is_ftp = False
    try:
        ftp_folder = RetrieveFtp.objects.get(pk=dataSource.retrieve_method.pk).folder
        extract_dir = dataSource.dir_name
        is_ftp = True
    except ObjectDoesNotExist:
        try:
            search_string = RetrieveMail.objects.get(pk=dataSource.retrieve_method.pk).search_string
            is_mail = True
        except ObjectDoesNotExist:
            raise Exception("No Retrieve Object found (FTP or Mail)")

    if is_mail :
        print("  Retrieve method : mail, search string : "+search_string)
    if is_ftp :
        #local folder : remove first slash
        extract_folder = os.path.join(extract_root, extract_dir.strip('/'))
        origin_folder = os.path.join(server_path_root, ftp_folder.strip('/'))
        print("    Retrieve method : ftp, folder : " + origin_folder + ", going to " + extract_folder)
        os.system('lftp -e "set ftp:ssl-allow false; mirror --verbose '+origin_folder+' '+extract_folder+'; quit" '+ftp_host+' -u '+ftp_user+','+ftp_passwd)
        files_in_folder_list = os.listdir(extract_folder)
        print("    Listing files in "+extract_folder+" --> "+str(len(files_in_folder_list))+" files")
        db_files_for_source = map(str,FileConversion.objects.values_list("name", flat=True).filter(data_source=dataSource))
        print("    Listing files in database for " + dataSource.name +" --> "+str(len(db_files_for_source))+" files")
        files_to_add = list(set(files_in_folder_list) - set(db_files_for_source))
        print("    "+str(len(files_to_add))+" new  files to add to DB for "+extract_dir.strip('/'))
        for file in files_to_add:
            print("      "+"Adding to DB : "+file+" from path "+extract_dir.strip('/'))
            conversion = FileConversion(name=file, data_source=dataSource, state_process=0)
            conversion.save()

