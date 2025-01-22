import yfinance as yf
import pandas as pd

def calculate_average_dividend_yield(ticker_symbol):
    try:
        # Načtení dat tickeru
        ticker = yf.Ticker(ticker_symbol)
        
        # Získání historických dat za posledních 5 let
        historical_data = ticker.history(period="5y")
        dividends = ticker.dividends
        prices = historical_data["Close"]
        
        # Ověření, zda jsou dostupná data
        if dividends.empty or prices.empty:
            return "No data available"
        
        # Výpočet dividendového výnosu
        dividend_yields = dividends / prices.reindex(dividends.index, method="nearest")
        average_yield = dividend_yields.mean() * 100  # Převod na procenta
        return average_yield
    except Exception as e:
        return f"Error: {str(e)}"

# ETF tickery
tickers = ["ISPA.DE", "VHYL.L"]

# Výpočet pro každý ticker
results = {ticker: calculate_average_dividend_yield(ticker) for ticker in tickers}
print(results)
