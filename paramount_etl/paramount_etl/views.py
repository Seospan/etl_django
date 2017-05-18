from rest_framework import viewsets
from django.contrib.auth.models import User
from paramount_etl.serializer import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

