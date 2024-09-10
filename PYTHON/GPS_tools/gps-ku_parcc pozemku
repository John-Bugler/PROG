import pandas as pd
import os
import requests
import time
from geopy.geocoders import Nominatim

# Cesta k souboru gps.xlsx na ploše
desktop = os.path.join(os.path.join(os.environ['USERPROFILE']), 'OneDrive', 'Plocha')  
file_path = os.path.join(desktop, 'gps-parcely.xlsx')
df = pd.read_excel(file_path, header=None)

# Zobrazení prvních několika řádků pro kontrolu
print(df.head())

# Inicializace geokodéru Nominatim
geolocator = Nominatim(user_agent="your_app_name")

# Funkce pro získání GPS souřadnic z Nominatim API na základě adresy
def get_gps(katastralni_uzemi, parc_cislo):
    address = f"{katastralni_uzemi} {parc_cislo}, Czech Republic"
    try:
        location = geolocator.geocode(address)
        if location:
            lat, lon = location.latitude, location.longitude
            print(lat, lon)
            return lat, lon
        return None, None
    except Exception as e:
        print(f"Chyba při získávání dat pro {katastralni_uzemi}, {parc_cislo}: {e}")
        return None, None

# Seznamy pro ukládání získaných souřadnic
latitudes = []
longitudes = []

# Přiřadíme prvnímu sloupci číslo 0 a druhému číslo 1, protože není záhlaví
for index, row in df.iterrows():
    katastralni_uzemi = row[0]  # První sloupec (katastrální území)
    parc_cislo = row[1]         # Druhý sloupec (parcelní číslo)
    
    lat, lon = get_gps(katastralni_uzemi, parc_cislo)
    
    # Uložíme výsledky do seznamů (zajistíme, aby None hodnoty nebyly uloženy)
    latitudes.append(lat if lat is not None else "")
    longitudes.append(lon if lon is not None else "")
    
    # Přidáme malé zpoždění, aby nedošlo k přetížení API (např. 1 sekunda)
    time.sleep(1)

# Přidání sloupců do DataFrame na pozici C (sloupec 2) a D (sloupec 3)
df[2] = latitudes  # Sloupec C (LAT)
df[3] = longitudes # Sloupec D (LON)

# Uložení výsledků zpět do stejného XLSX souboru
df.to_excel(file_path, index=False, header=False)

print(f"Souřadnice byly úspěšně zapsány do {file_path}")





""" import pandas as pd
import os
import requests
import time

# Cesta k souboru gps.xlsx na ploše
desktop = os.path.join(os.path.join(os.environ['USERPROFILE']), 'OneDrive', 'Plocha')  
file_path = os.path.join(desktop, 'gps-parcely.xlsx')
df = pd.read_excel(file_path, header=None)

# Zobrazení prvních několika řádků pro kontrolu
print(df.head())

# Funkce pro získání GPS souřadnic z Nominatim API na základě adresy
def get_gps(katastralni_uzemi, parc_cislo):
    # Nominatim API URL
    base_url = "https://nominatim.openstreetmap.org/search"
    address = f"{katastralni_uzemi} {parc_cislo}, Czech Republic"
    params = {
        'q': address,
        'format': 'json',
        'addressdetails': 1,
        'limit': 1
    }
    try:
        response = requests.get(base_url, params=params)
        if response.status_code == 200:
            data = response.json()
            if data:
                lat, lon = data[0]['lat'], data[0]['lon']
                print(lat, lon)
                return lat, lon
        return None, None
    except Exception as e:
        print(f"Chyba při získávání dat pro {katastralni_uzemi}, {parc_cislo}: {e}")
        return None, None

# Seznamy pro ukládání získaných souřadnic
latitudes = []
longitudes = []

# Přiřadíme prvnímu sloupci číslo 0 a druhému číslo 1, protože není záhlaví
for index, row in df.iterrows():
    katastralni_uzemi = row[0]  # První sloupec (katastrální území)
    parc_cislo = row[1]         # Druhý sloupec (parcelní číslo)
    
    lat, lon = get_gps(katastralni_uzemi, parc_cislo)
    
    # Uložíme výsledky do seznamů (zajistíme, aby None hodnoty nebyly uloženy)
    latitudes.append(lat if lat is not None else "")
    longitudes.append(lon if lon is not None else "")
    
    # Přidáme malé zpoždění, aby nedošlo k přetížení API (např. 1 sekunda)
    time.sleep(1)

# Přidání sloupců do DataFrame na pozici C (sloupec 2) a D (sloupec 3)
df[2] = latitudes  # Sloupec C (LAT)
df[3] = longitudes # Sloupec D (LON)

# Uložení výsledků zpět do stejného XLSX souboru
df.to_excel(file_path, index=False, header=False)

print(f"Souřadnice byly úspěšně zapsány do {file_path}")
 """