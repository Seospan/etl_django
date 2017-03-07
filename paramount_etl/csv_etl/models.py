# coding: utf-8
from django.db import models
from datetime import datetime
from django.utils import timezone
from exclusivebooleanfield.fields import ExclusiveBooleanField
# Create your models here.

class RetrieveMethod(models.Model):
    name = models.CharField(max_length=128)

    def __str__(self):
        return str(self.pk)+" : "+self.name


class RetrieveFtp(RetrieveMethod):
    folder = models.CharField(max_length=512, verbose_name="Dossier ou le rapport est envoyé sur le ftp")


class RetrieveMail(RetrieveMethod):
    search_string = models.CharField(max_length=512, verbose_name="Gmail search string", help_text="As seen in gmail search engine")


class FileFormat(models.Model):
    name = models.CharField(max_length=128)

    def __str__(self):
        return str(self.pk)+" : "+self.name


class FileFormatXls(FileFormat):
    tab_name = models.CharField(max_length=128)


class FileFormatCsv(FileFormat):
    CSV_COUNTRY = (
        ('fr', 'fr'),
        ('en', 'en'),
        ('utf16_LE', 'utf16_LE'),
    )
    country = models.CharField(max_length=64, choices=CSV_COUNTRY, verbose_name="Format d'encodage du csv")


class DataSource(models.Model):
    name = models.CharField(max_length=128)
    r_function = models.CharField(max_length=512, null=True, blank=True, verbose_name="R function to use", help_text='Leave blank to use default function.')
    retrieve_method = models.ForeignKey(RetrieveMethod)
    file_format = models.ForeignKey(FileFormat)
    out_directory = models.CharField(max_length=256, verbose_name="Dossier d'export après traitement")
    lines_to_delete_start = models.IntegerField(default=0)
    lines_to_delete_end = models.IntegerField(default=0)
    date_format_input = models.CharField(max_length=128)
    date_format_output = models.CharField(max_length=128)
    #columns

    def ___str__(self):
        return self.id + " : " + self.file.name + " : " + self.state_process


class ColumnName(models.Model):
    name = models.CharField(max_length=256)

    def __str__(self):
        return self.name


class Column(models.Model):
    TYPE_TRANSFORM = (
        ('r_func','name'),
    )
    old_name = models.CharField(max_length=128)
    new_name = models.ForeignKey(ColumnName)
    type_transform = models.CharField(max_length=512, choices=TYPE_TRANSFORM)
    data_source = models.ForeignKey(DataSource)
    is_adname_container = ExclusiveBooleanField(on=('data_source'), default=False, verbose_name="Colonne contenant l'adname entre '__'")


class FileConversion(models.Model):
    STATE_CONVERSION = (
        (0, 'Step 1'),
        (1, 'Step 2'),
        (2, 'Step 3'),
        (3, 'Step 4'),
        (4, 'Step 5'),
    )
    name = models.CharField(max_length=256)
    path = models.CharField(max_length=512)
    state_process = models.IntegerField(choices=STATE_CONVERSION, default=0)
    last_step_date = models.DateTimeField(default=timezone.now)

    def ___str__(self):
        return self.id + " : " + self.file.name + " : " + self.state_process