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
                                with purchaseandsplits as (
                                    -- získání všech relevantních záznamů o nákupech, dividendách a splitech
                                    select
                                        ticker,
                                        currency,
                                        [date],
                                        type,
                                        (case when type = 'buy - market' then quantity
                                            when type = 'sell - market' then -quantity
                                            when type = 'sell - stop' then -quantity			  
                                            when type = 'stock split' then quantity
                                            else 0
                                        end) as quantity,

                                        price,
                                        (case when type = 'buy - market' then amount
                                            when type = 'sell - market' then -amount
                                            when type = 'sell - stop' then -quantity
                                            when type = 'dividend' then amount

                                            else 0
                                        end) as amount,
                                        row_number() over (partition by ticker order by [date]) as rn
                                    from [reports].[dbo].[revolut_stocks]
                                    where ticker <> ''
                                        and type in ('buy - market', 'sell - market', 'sell - stop', 'stock split', 'dividend')
                                        --and year([date]) = '2024'
                                        and [date] between '2021-01-01' and getdate()  -- za cele obdobi po soucasnost
                                        --and ticker like 'amzn'
                                ),
                                lastsplitdates as (
                                    -- určení posledního data splitu pro každý ticker
                                    select
                                        ticker,
                                        max([date]) as last_split_date
                                    from purchaseandsplits
                                    where type = 'stock split'
                                    group by ticker
                                ),

                                cumulativequantities as (
                                    -- výpočet kumulativní quantity s ohledem na nákupy a split
                                    select
                                        ticker,
                                        sum(quantity) over (partition by ticker) as cumulative_quantity,
                                        row_number() over (partition by ticker order by (select null)) as rn
                                    from purchaseandsplits
                                    where type in ('buy - market', 'sell - market', 'sell - stop', 'stock split')
                                ),

                                cumulativetrades as (
                                    -- výpočet kumulativního počtu provedených nákupů
                                    select
                                        ticker,
                                        count(*) over (partition by ticker) as cumulative_trades,
                                        row_number() over (partition by ticker order by (select null)) as rn
                                    from purchaseandsplits
                                    where type = 'buy - market'
                                ),


                                cumulativesplits as (
                                    -- výpočet kumulativní splity a q1 = kumulativní quantity pred poslednim splitem
                                    select
                                        ps.ticker,
                                        count(case when ps.type = 'stock split' then 1 end) as cumulative_splits,
                                        ls.last_split_date,
                                        sum(case 
                                                when ps.[date] < ls.last_split_date then ps.quantity 
                                                else 0 
                                            end) as q1,
                                        sum(case 
                                                when ps.type = 'stock split' then ps.quantity 
                                                else 0 
                                            end) as split_quantity,
                                        row_number() over (partition by ps.ticker order by (select null)) as rn
                                    from purchaseandsplits ps
                                    left join lastsplitdates ls on ps.ticker = ls.ticker
                                    group by ps.ticker, ls.last_split_date
                                ),
                                cumulativedividends as (
                                    -- výpočet kumulativní dividendy
                                    select
                                        ticker,
                                        sum(amount) over (partition by ticker) as cumulative_dividend,  
                                        row_number() over (partition by ticker order by (select null)) as rn
                                    from purchaseandsplits
                                    where type = 'dividend'
                                ),

                                cumulativeamounts_buy as (
                                    -- výpočet kumulativních investic
                                    select
                                        ticker,
                                        sum(amount) over (partition by ticker) as cumulative_amount,  
                                        row_number() over (partition by ticker order by (select null)) as rn
                                    from purchaseandsplits
                                    where type = 'buy - market'
                                ),

                                cumulativeamounts_sell as (
                                    -- výpočet kumulativních investic
                                    select
                                        ticker,
                                        sum(amount) over (partition by ticker) as cumulative_amount,  
                                        row_number() over (partition by ticker order by (select null)) as rn
                                    from purchaseandsplits
                                    where type = 'sell - market' or type = 'sell - stop'
                                ),

                                cumulativefees as (
                                    -- výpočet kumulativních fee
                                    select
                                        ticker,
                                        sum(case 
                                            when amount - (quantity * price) < 0 or abs(amount - (quantity * price)) < 0.0001 then 0
                                            else amount - (quantity * price)
                                            end) over (partition by ticker order by date) as cumulative_fee,
                                        row_number() over (partition by ticker order by date desc) as rn
                                    from purchaseandsplits
                                    where type = 'buy - market' or type = 'sell - market' or type = 'sell - stop'
                                ),

                                /*
                                actualprices as (
                                    -- získání aktuálních cen
                                    select
                                        ticker,
                                        close_price,  
                                        timestamp,
                                        row_number() over (partition by ticker order by timestamp desc) as rn
                                    from [reports].[dbo].[revolut_stocks_prices]
                                    --where ticker  like '%EXX5%'   
                                ),

                                */

                                actualprices AS (
                                    -- Získání aktuálních cen a vytvoření tickeru bez suffixu
                                    SELECT
                                        ticker,
                                        close_price,  
                                        timestamp,
                                        LEFT(ticker, CHARINDEX('.', ticker + '.') - 1) AS cleaned_ticker,  -- Přidáme ticker bez suffixu
                                        ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY timestamp DESC) AS rn
                                    FROM [reports].[dbo].[revolut_stocks_prices]
                                ),

                                weightedaverageprice as (
                                    select
                                        ps.ticker,
                                        sum(ps.quantity * ps.price) as total_weighted_price,
                                        sum(ps.quantity) as total_quantity,
                                        row_number() over (partition by ps.ticker order by (select null)) as rn
                                    from purchaseandsplits ps
                                    where ps.type in ('buy - market', 'stock split')
                                    group by ps.ticker
                                )

                                select
                                    p.ticker,
                                    p.currency,
                                    (case when t.cumulative_trades is not NULL then t.cumulative_trades
                                        else 0
                                    end) as trades,
                                    
                                    q.cumulative_quantity as quantity,

                                    a.cumulative_amount as cumulative_investment,
                                    a.cumulative_amount - f.cumulative_fee as cumulative_investment_nofee,
                                            ase.cumulative_amount as cumulative_sell,

                                    f.cumulative_fee,
                                    q.cumulative_quantity * prs.close_price as actual_value,
                                    round((q.cumulative_quantity * prs.close_price) - (q.cumulative_quantity * (w.total_weighted_price / nullif(w.total_quantity, 0))),2) as profit,
                                    
                                    
                                    --(((q.cumulative_quantity * prs.close_price) + abs(ase.cumulative_amount) - (a.cumulative_amount - f.cumulative_fee)) / (a.cumulative_amount - f.cumulative_fee)) * 100  as profit_percent,
                                    
                                    (case when (q.cumulative_quantity * prs.close_price) > 0 then 
                                        (((q.cumulative_quantity * prs.close_price) - (q.cumulative_quantity * (w.total_weighted_price / nullif(w.total_quantity, 0))))/((q.cumulative_quantity * prs.close_price)-((q.cumulative_quantity * prs.close_price) - (q.cumulative_quantity * (w.total_weighted_price / nullif(w.total_quantity, 0)))))) * 100 
                                        else 0 
                                    end) as profit_percent,

                                    prs.timestamp as actual_price_date,
                                    prs.close_price as actual_price,
                                    w.total_weighted_price / nullif(w.total_quantity, 0) as average_purchase_price, -- výpočet průměrné nákupní ceny

                                    d.cumulative_dividend,

                                    s.cumulative_splits,
                                    s.last_split_date,
                                    s.q1 as quantity_before_last_split,
                                    s.split_quantity,
                                    (s.q1 + s.split_quantity) / nullif(s.q1, 0) as last_split_ratio


                                from purchaseandsplits p
                                        left join cumulativequantities q on p.ticker = q.ticker and q.rn = 1
                                        left join cumulativetrades t on p.ticker = t.ticker and t.rn = 1
                                        left join cumulativesplits s on p.ticker = s.ticker and s.rn = 1
                                        left join cumulativedividends d on p.ticker = d.ticker and d.rn = 1
                                        left join actualprices prs on p.ticker = prs.cleaned_ticker and prs.rn = 1
                                        left join cumulativeamounts_buy a on p.ticker = a.ticker and a.rn = 1
                                        left join cumulativeamounts_sell ase on p.ticker = ase.ticker and ase.rn = 1
                                        left join cumulativefees f on p.ticker = f.ticker and f.rn = 1
                                        left join weightedaverageprice w on p.ticker = w.ticker and w.rn = 1
                                where 1=1 
                                    and p.rn = 1
                                --and p.ticker = 'nvda'
                                order by ticker asc;



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
                        round(invest.profit, 2) as profit,
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
    buy = models.DecimalField(max_digits=10, decimal_places=2)
    sell = models.DecimalField(max_digits=10, decimal_places=2)
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
                    ) as '$buy',

                    (
                        select round(sum(amount), 2)
                        from [reports].[dbo].[revolut_stocks] sub
                        where sub.type = 'sell - market' and year(sub.date) = year(r.date)
                    ) as '$sell',                             

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


