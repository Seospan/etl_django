from django.contrib import admin
from .models import RetrieveFtp, RetrieveMail, FileFormatCsv, FileFormatXls, DataSource, Column, FileConversion, ColumnName


@admin.register(RetrieveFtp)
class RetrieveFtpAdmin(admin.ModelAdmin):
    list_display = ('name', 'folder')


@admin.register(RetrieveMail)
class RetrieveMailAdmin(admin.ModelAdmin):
    list_display = ('name', 'search_string')


@admin.register(FileFormatCsv)
class FileFormatCsvAdmin(admin.ModelAdmin):
    list_display = ('name', 'country')


@admin.register(FileFormatXls)
class FileFormatXlsAdmin(admin.ModelAdmin):
    list_display = ('name', 'tab_name')


@admin.register(ColumnName)
class ColumnNameAdmin(admin.ModelAdmin):
    list_display = ('name',)


class ColumnAdminInline(admin.TabularInline):
    model = Column


@admin.register(DataSource)
class DataSourceAdmin(admin.ModelAdmin):
    list_display = ('name', 'file_format', 'retrieve_method', 'r_function', 'out_directory')
    inlines = [ColumnAdminInline, ]


@admin.register(FileConversion)
class FileConversionAdmin(admin.ModelAdmin):
    list_display = ('name', 'path', 'state_process', 'last_step_date', 'data_source')
    date_hierarchy = 'last_step_date'