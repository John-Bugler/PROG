from django.db import models
from django.db import connection


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
    def get_data(cls):
        with connection.cursor() as cursor:
            cursor.execute('''
                 with rankedrows as (
                    select  
                        row_number() over (partition by portfolio.ticker order by act_prices.timestamp desc) as row_num, 
                        portfolio.ticker,
                        portfolio.currency,   
                        count(portfolio.type) as trades,
                        format(round(sum(portfolio.quantity), 2), '0.###') as quantity,
                           
                        format(round(sum(portfolio.quantity * act_prices.close_price), 2), '0.###') as actual_value, 
                        format(round(avg(portfolio.price), 2), '0.###') as avg_price, 
                        format(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), '0.###') as wavg_price, 
                        format(act_prices.close_price, '0.0') as actual_price,		
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
                    group by 
                        portfolio.ticker, portfolio.currency, act_prices.timestamp, act_prices.close_price
                    )                  
                select 
                      ticker, 
                      currency,
                      trades,     
                      quantity, 
                      actual_value,
					  profit,
                      avg_price, 
                      wavg_price, 
                      actual_price, 
                      actual_price_date,
                      act_prices_count
                from rankedrows
                where row_num = 1
                order by ticker asc, actual_price_date desc;
            ''')
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()

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
                    ) as 'investment',
                    
                    (
                        select round(sum(amount), 2)
                        from [reports].[dbo].[revolut_stocks] sub
                        where sub.type = 'dividend' and year(sub.date) = year(r.date)
                    ) as 'dividend'

                from [reports].[dbo].[revolut_stocks] r
                where r.type = 'buy - market' or r.type = 'dividend'
                group by year(date)
                order by year desc;
                
            ''')
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()

        return columns, rows
