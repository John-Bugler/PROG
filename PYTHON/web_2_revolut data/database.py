import pyodbc

def get_data():
    # Připojení k databázi
    server = 'localhost'
    database = 'reports' 
   
    connection_string = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes'
    connection = pyodbc.connect(connection_string)

    # Získání dat z tabulky
    cursor = connection.cursor()
    cursor.execute('''
               with rankedrows as (
                    select  
                        row_number() over (partition by portfolio.ticker order by act_prices.timestamp desc) as row_num, 
                        portfolio.ticker, 
                        count(portfolio.type) as trades,
                        format(round(sum(portfolio.quantity), 2), '0.###') as quantity, 
                        format(round(avg(portfolio.price), 2), '0.###') as avg_price, 
                        format(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), '0.###') as wavg_price, 
                        format(act_prices.close_price, '0.0') as actual_price,		
                        act_prices.timestamp as actual_price_date,
                 		-- pocet zaznamu s cenami 
                 		(select count(timestamp) from [reports].[dbo].[revolut_stocks_prices] where ticker = portfolio.ticker) as act_prices_count,
                        format(
                            round(((act_prices.close_price / nullif(round(sum(portfolio.quantity * portfolio.price) / sum(portfolio.quantity), 2), 0)) - 1) * 100, 1), '0.0'
                        ) as profit
                    from 
                        [reports].[dbo].[revolut_stocks] portfolio
                    left join 
                        [reports].[dbo].[revolut_stocks_prices] act_prices on portfolio.ticker = act_prices.ticker
                    where 
                        portfolio.price > 0
                        and portfolio.type = 'buy - market'
                    group by 
                        portfolio.ticker, act_prices.timestamp, act_prices.close_price
                    )                  
                select *
                from rankedrows
                where row_num = 1
                order by ticker asc, actual_price_date desc;
    ''')
    
    columns = [column[0] for column in cursor.description]
    rows = cursor.fetchall()

    # Převedení výsledků na seznam slovníků pro snazší manipulaci v HTML šabloně
    data = [dict(zip(columns, row)) for row in rows]

    return data
