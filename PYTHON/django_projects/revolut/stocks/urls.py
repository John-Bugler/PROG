from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),                                               #    '' nedefinovana url = http://localhost:8080/
    path('stocks/', views.stocks, name='stocks'),                                      #      definovana url = http://localhost:8080/stocks/
    #path('stocks_by_year/<str:year>/', views.stocks_by_year, name='stocks_by_year'),             #      definovana url = http://localhost:8080/stocks_by_year/
    path('stocks_by_year/', views.stocks_by_year, name='stocks_by_year'),
]