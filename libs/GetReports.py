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
#ftp = FTP_TLS(ftp_host)
#ftp.login(ftp_user, ftp_passwd)
# ftp.dir()
#ftp.cwd('www')


for dataSource in DataSource.objects.all():
    print("Data source " + dataSource.name +" ( " + str(dataSource.retrieve_method.pk) + " ) ")

    out_folder = dataSource.out_directory

    #ind if FTP or Mail retrieval method
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

        os.system('lftp -e "set ftp:ssl-allow false; mirror /www ../Data; quit" '+ftp_host+' -u '+ftp_user+','+ftp_passwd)

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
