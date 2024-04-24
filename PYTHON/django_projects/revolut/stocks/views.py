from django.shortcuts import render
from django.http import HttpResponse
from .models import StockData, StockYearsOverview


# Create your views here.


# def index(request) :
#     if request.resolver_match.url_name == 'index':
#         return HttpResponse('<h1>Test, hi lol !!!</h1>')
#     elif request.resolver_match.url_name == 'revolut':
#         return HttpResponse('<h1>Revolut lol !!!</h1>')
#     else:
#         return HttpResponse('<h1>Unknown page</h1>')
    


def index(request) :
    print("--------------------------------TEST-def index-------------------------------------")
    columns, rows = StockYearsOverview.get_data()
    print("Columns:", columns)
    print("Rows:", rows)
    context = {'columns': columns, 'rows': rows}
    return render(request, 'index.html', context)


def stocks(request):
    print("--------------------------------TEST-def stocks-------------------------------------")
    columns, rows = StockData.get_data()
    print("Columns:", columns)
    print("Rows:", rows)
    context = {'columns': columns, 'rows': rows}
    return render(request, 'stocks.html', context)

#def stocks_by_year(request, year):
def stocks_by_year(request):
    print("--------------------------------TEST-def stocks_by_year-------------------------------------")
    #print(year)
    #columns, rows = StockData.get_data_by_year(year)
    columns, rows = StockData.get_data_by_year()
    print("Columns:", columns)
    print("Rows:", rows)
    #context = {'columns': columns, 'rows': rows, 'year': year}
    context = {'columns': columns, 'rows': rows}
    return render(request, 'stocks_by_year.html', context)

# def stocks_view(request):
# return HttpResponse('<h1>Test</h1>')