from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),                  # '' nedefinovana url = http://localhost:8080/
    path('stocks/', views.stocks_view, name='stocks'),    #      definovana url = http://localhost:8080/stocks/
]