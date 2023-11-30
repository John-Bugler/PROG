from django.shortcuts import render
from django.http import HttpResponse

# Create your views here.
def index(request) :
    if request.resolver_match.url_name == 'index':
        return HttpResponse('<h1>Test, hi lol !!!</h1>')
    elif request.resolver_match.url_name == 'revolut':
        return HttpResponse('<h1>Revolut lol !!!</h1>')
    else:
        return HttpResponse('<h1>Unknown page</h1>')