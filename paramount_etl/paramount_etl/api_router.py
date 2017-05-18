from rest_framework import routers
from rest_framework.routers import Route, DynamicDetailRoute, SimpleRouter


# Import ViewSets
from paramount_etl.views import UserViewSet


class CustomReadOnlyRouter(SimpleRouter):
    """
    A router for read-only APIs, which doesn't use trailing slashes.
    """
    routes = [
        Route(
            url=r'^{prefix}$',
            mapping={'get': 'list'},
            name='{basename}-list',
            initkwargs={'suffix': 'List'}
        ),
        Route(
            url=r'^{prefix}/{lookup}$',
            mapping={'get': 'retrieve'},
            name='{basename}-detail',
            initkwargs={'suffix': 'Detail'}
        ),
        DynamicDetailRoute(
            url=r'^{prefix}/{lookup}/{methodnamehyphen}$',
            name='{basename}-{methodnamehyphen}',
            initkwargs={}
        )
    ]

# Routers provide an easy way of automatically determining the URL conf.
router = routers.DefaultRouter()

#router = CustomReadOnlyRouter()
router.register(r'users', UserViewSet)

