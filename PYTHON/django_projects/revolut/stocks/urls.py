from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),             # '' nedefinovana url = http://localhost:8080/
    path('revolut/', views.index, name='revolut')    # revolut/ definovana url = http://localhost:8080/revolut/
]