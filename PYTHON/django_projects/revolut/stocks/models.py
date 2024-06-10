from django.db import models
from django.db import connection

import pandas as pd
#import matplotlib.pyplot as plt


#Detailni prehled investic po spolecnostech
class StockData(models.Model):
    ticker = models.CharField(max_length=10)
    currency = models.CharField(max_length=5)
    trades = models.IntegerField()
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    value = models.DecimalField(max_digits=10, decimal_places=2)
    avg_price = models.DecimalField(max_digits=10, decimal_places=2)
    wavg_price = models.DecimalField(max_digits=10, decimal_places=2)
    actual_price = models.DecimalField(max_digits=10, decimal_places=2)
    actual_price_date = models.DateTimeField()
    act_prices_count = models.IntegerField()
    profit = models.DecimalField(max_digits=10, decimal_places=1)

    class Meta: 
        ordering = ['ticker', '-actual_price_date']

    def __str__(self):
        return f"{self.year} - {self.investment}"

    @classmethod
    def get_data(cls):    # dotaz na cele portfolio bez omezeni 
        print("--------------------------------TEST-def get_data - START-------------------------------------")
        with connection.cursor() as cursor:
            cursor.execute('''
                    -- Prehled portfolia = stock/trades/quantity/weighted price/actual price/PROFIT
                    with rankedrows as (
                        select  
                            row_number() over (partition by portfolio.ticker order by act_prices.timestamp desc) as row_num, 
                            portfolio.ticker,
                            portfolio.currency,   
                            count(portfolio.date) as trades,
                            round(sum(portfolio.quantity), 2) as quantity,
                            round(sum(portfolio.quantity), 2) as num_quantity,
                                
                            round(sum(portfolio.quantity * act_prices.close_price), 2) as actual_value,

                           
                         
                            round(avg(portfolio.price), 2) as avg_price, 
                            round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2) as wavg_price, 
                            act_prices.close_price as actual_price,
                            act_prices.close_price as num_actual_price,
                            
                            act_prices.timestamp as actual_price_date,
                            -- pocet zaznamu s cenami 
                            (select count(timestamp) from [reports].[dbo].[revolut_stocks_prices] where ticker = portfolio.ticker) as act_prices_count,
                            cast(
                                round(((act_prices.close_price / nullif(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), 0)) - 1) * 100, 1) as decimal(5,1)
                            ) as profit
                        from 
                            [reports].[dbo].[revolut_stocks] portfolio
                        left join 
                            [reports].[dbo].[revolut_stocks_prices] act_prices on portfolio.ticker = act_prices.ticker
                        where 
                            portfolio.price > 0
                            and portfolio.type = 'buy - market'
                            --and year(portfolio.date) = '2024' -- Filtrování portfolia podle roku
                        group by 
                            portfolio.ticker, portfolio.currency, act_prices.timestamp, act_prices.close_price
                    ),
                    invest as (
                        select 
                            ticker, 
                            currency,
                            trades,     
                            quantity, 
                            actual_value,
                            profit,
                            --avg_price, 
                            wavg_price, 
                            actual_price, 
                            
                            actual_price_date,
                            act_prices_count
                        from rankedrows
                        where row_num = 1
                    ),
                    dividends_filtered as (
                        select 
                            ticker,
                            round(sum(amount), 2) as num_actual_dividend_value,
                            round(sum(amount), 2) as actual_dividend_value,
                            count(amount) as payouts
                        from [reports].[dbo].[revolut_stocks]
                        where 
                            type = 'DIVIDEND'
                            --and year(date) = '2024' -- Filtrování dividend podle roku
                        group by 
                            ticker
                    )
                    select 
                        invest.ticker, 
                        invest.currency,
                        invest.trades,     
                        invest.quantity, 
                        invest.actual_value,
                        invest.profit,
                        div.actual_dividend_value as dividend,
                        round((div.actual_dividend_value / (invest.quantity * invest.actual_price))*100,2) as DY,
                        div.payouts,
                        wavg_price, 
                        invest.actual_price, 
                        invest.actual_price_date,
                        invest.act_prices_count
                    from invest
                    left join dividends_filtered as div on invest.ticker = div.ticker
                    order by invest.actual_value desc;

            ''')
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()
            print("--------------------------------TEST-def get_data - END-------------------------------------")
        return columns, rows



    @classmethod
    def get_data_by_year(cls, year):    # dotaz na cele portfolio s omezenim = rozsah dle pozadovaneho roku
    #def get_data_by_year(cls):    # dotaz na cele portfolio s omezenim = rozsah dle pozadovaneho roku
        print("--------------------------------TEST-def get_data_by_year - START-------------------------------------")
        with connection.cursor() as cursor:
                sql = """
                    -- Prehled portfolia = stock/trades/quantity/weighted price/actual price/PROFIT
                    with rankedrows as (
                        select  
                            row_number() over (partition by portfolio.ticker order by act_prices.timestamp desc) as row_num, 
                            portfolio.ticker,
                            portfolio.currency,   
                            count(portfolio.date) as trades,
                            format(round(sum(portfolio.quantity), 2), '0.###') as quantity,
                            round(sum(portfolio.quantity), 2) as num_quantity,
                            format(round(sum(portfolio.quantity * act_prices.close_price), 2), '0.###') as actual_value, 
                            round(sum(portfolio.quantity * act_prices.close_price), 2) as num_actual_value, 
                            format(round(avg(portfolio.price), 2), '0.###') as avg_price, 
                            format(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), '0.###') as wavg_price, 
                            format(act_prices.close_price, '0.0') as actual_price,
                            act_prices.close_price as num_actual_price,
                            act_prices.timestamp as actual_price_date,
                            -- pocet zaznamu s cenami 
                            (select count(timestamp) from [reports].[dbo].[revolut_stocks_prices] where ticker = portfolio.ticker) as act_prices_count,
                            cast(
                                round(((act_prices.close_price / nullif(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), 0)) - 1) * 100, 1) as decimal(5,1)
                            ) as profit
                        from 
                            [reports].[dbo].[revolut_stocks] portfolio
                        left join 
                            [reports].[dbo].[revolut_stocks_prices] act_prices on portfolio.ticker = act_prices.ticker
                        where 
                            portfolio.price > 0
                            and portfolio.type = 'buy - market'
                            and year(portfolio.date) = %s -- Filtrování portfolia podle roku
                        group by 
                            portfolio.ticker, portfolio.currency, act_prices.timestamp, act_prices.close_price
                    ),
                    invest as (
                        select 
                            ticker, 
                            currency,
                            trades,     
                            quantity, 
                            num_quantity,
                            actual_value,
                            num_actual_value,
                            profit,
                            --avg_price, 
                            wavg_price, 
                            actual_price, 
                            num_actual_price,
                            actual_price_date,
                            act_prices_count
                        from rankedrows
                        where row_num = 1
                    ),
                    dividends_filtered as (
                        select 
                            ticker,
                            round(sum(amount), 2) as num_actual_dividend_value,
                            format(round(sum(amount), 2), '0.###') as actual_dividend_value,
                            count(amount) as payouts
                        from [reports].[dbo].[revolut_stocks]
                        where 
                            type = 'DIVIDEND'
                            and year(date) = %s -- Filtrování dividend podle roku
                        group by 
                            ticker
                    )
                    select 
                        invest.ticker, 
                        invest.currency,
                        invest.trades,     
                        invest.quantity, 
                        invest.actual_value,
                        invest.profit,
                        div.actual_dividend_value as dividend,
                        format(round((div.num_actual_dividend_value / (invest.num_quantity * invest.num_actual_price))*100,2), '0.###') as DY,
                        div.payouts,
                        wavg_price, 
                        invest.actual_price, 
                        invest.actual_price_date,
                        invest.act_prices_count
                    from invest
                    left join dividends_filtered as div on invest.ticker = div.ticker
                    order by invest.num_actual_value desc;

                """
                print(sql)
                cursor.execute(sql, (year,year))
                #cursor.execute(sql, {'year': year})
                #cursor.execute(sql)
                columns = [column[0] for column in cursor.description]
                rows = cursor.fetchall()
                print("--------------------------------TEST-def get_data_by_year - END-------------------------------------")
        return columns, rows




#Prehled investic a dividend po letech
class StockYearsOverview(models.Model):
    year = models.DateTimeField()
    investment = models.DecimalField(max_digits=10, decimal_places=2)
    dividend = models.DecimalField(max_digits=10, decimal_places=2)


    class Meta:
        ordering = ['year']

    def __str__(self):
        return f"{self.ticker} - {self.actual_price_date}"

    @classmethod
    def get_data(cls):
        with connection.cursor() as cursor:
            cursor.execute('''
                select
                    year(date) as year,
                    (
                        select round(sum(amount), 2)
                        from [reports].[dbo].[revolut_stocks] sub
                        where sub.type = 'buy - market' and year(sub.date) = year(r.date)
                    ) as '$investment',
                    
                    (
                        select round(sum(amount), 2)
                        from [reports].[dbo].[revolut_stocks] sub
                        where sub.type = 'dividend' and year(sub.date) = year(r.date)
                    ) as '$dividend'

                from [reports].[dbo].[revolut_stocks] r
                where r.type = 'buy - market' or r.type = 'dividend'
                group by year(date)
                order by year desc;
                
            ''')
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()
            #  vytvoreni dataframu z dat dotazu
            df = pd.DataFrame(rows, columns=columns)    
            #  prevod dataframu na json se kteryn pak pracuje javasript
            chart_data = df.to_json(orient='split')     
            print('chart data : ',chart_data)
        return columns, rows, chart_data


