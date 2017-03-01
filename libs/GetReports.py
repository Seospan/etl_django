# coding: utf-8

# In[5]:

from ftplib import FTP_TLS
import os

import os
import sys
import django
from libs_settings import path_paramount, path_program, data_path, ftp_host, ftp_user, ftp_passwd
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
ftp = FTP_TLS(ftp_host)
ftp.login(ftp_user, ftp_passwd)
# ftp.dir()
ftp.cwd('www')


for dataSource in DataSource.objects.all():
    print("Data source " + dataSource.name +" ( " + str(dataSource.retrieve_method.pk) + " ) ")

    out_folder = dataSource.out_directory

    is_mail = False
    is_ftp = False
    try:
        ftp_folder = RetrieveFtp.objects.get(pk=dataSource.retrieve_method.pk).folder
        is_ftp = True
    except ObjectDoesNotExist:
        try:
            search_string = RetrieveMail.objects.get(pk=dataSource.retrieve_method.pk).search_string
            is_mail = True
        except ObjectDoesNotExist:
            raise Exception("No Retrieve Object found (FTP or Mail)")

    if is_mail :
        print("Retrieve method : mail, search string : "+search_string)
    if is_ftp :
        #local folder : remove first slash
        local_folder = os.path.join(data_path, out_folder.strip('/'))
        print("Retrieve method : ftp, folder : " + ftp_folder + ", going to " + local_folder)
        ftp.cwd(ftp_folder)
        ftp.dir()
        print("get list file ftp")
        linesdir = ftp.nlst()
        print("checking directory "+local_folder)
        if not os.path.exists(local_folder):
            print("creating "+local_folder)
            os.makedirs(local_folder)
        os.chdir(local_folder)
        print("get files delivery")
        for line in linesdir:
            filename = line
            print(line)
            file = FileConversion.objects.filter(name=filename)
            if len(file) == 0:
                print("put file %s in %s" % (filename, local_folder + filename))
                ftp.retrbinary("RETR " + filename, open(local_folder + "/" + filename, 'wb').write)
                print("put file %s in database" % (filename))
                file = FileConversion(name=filename, path=local_folder, state_process=1)
                file.save()
            else:
                print(filename+" already downloaded")

   # print("Folder : " + folder)
    #if RetrieveFtp.objects.get(pk=dataSource.retrieve_method.pk):
    #    print("Folder : " + RetrieveFtp.objects.get(pk=dataSource.retrieve_method.pk).folder)
    #for a in RetrieveFtp.objects.filter(pk=dataSource.retrieve_method.pk):
     #   print("Folder"+a.folder)

#
#
#         if len(delivery) == 0:
#             print("put file %s in %s" % (filename, data_folder + 'Delivery/' + filename))
#             ftp.retrbinary("RETR " + filename, open(data_folder + 'Delivery/' + filename, 'wb').write)
#             print("put file %s in database" % (filename))
#             delivery = Delivery(name=filename, path="Delivery", state_process=1)
#             delivery.save()

# print("finished")
#
#
# # In[ ]:
#
#
#
#
# # In[ ]:
