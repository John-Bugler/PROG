# vstupní data = soubor "gps.xlsx" na plose, ve sloupci A od bunky A1 vlozena data s adresama 
# vystupni soubor "timestamp_gps.xlsx" pada na plochu


import datetime
import pandas as pd
import os
from opencage.geocoder import OpenCageGeocode

# API klíč
api_key = 'fe6bc2506ac04e1285831d7b0e96ff84'
geocoder = OpenCageGeocode(api_key)

# Slovník pro udržení již zpracovaných adres a GPS souřadnic
processed_addresses = {}
queries_count = 0

def get_coordinates(address):
    global queries_count
    # Pokud jsme již zpracovali tuto adresu, vrátíme již uložené GPS souřadnice
    if address in processed_addresses:
        return processed_addresses[address]
    
    result = geocoder.geocode(address)
    queries_count += 1
    if result and len(result):
        latitude = result[0]['geometry']['lat']
        longitude = result[0]['geometry']['lng']
        # Uložíme GPS souřadnice do slovníku pro pozdější použití
        processed_addresses[address] = (latitude, longitude)
        return (latitude, longitude)
    else:
        # Pokud není možné získat souřadnice, vrátíme (None, None)
        return (None, None)

def export_to_excel():
    # Cesta k souboru gps.xlsx na ploše
    desktop = os.path.join(os.path.join(os.environ['USERPROFILE']), 'OneDrive', 'Plocha')  
    file_path = os.path.join(desktop, 'gps.xlsx')

   # Načtení adres ze souboru gps.xlsx

    try:
        df = pd.read_excel(file_path, header=None, names=['Address'])

        #df.columns = ['Address']
    except FileNotFoundError:
        print("Soubor gps.xlsx nebyl nalezen.")
        return
    except Exception as e:
        print(f"Chyba při načítání souboru: {e}")
        return

    print("Načtené adresy ze souboru gps.xlsx:")
    print(df)

    # Aplikace funkce na sloupec s adresami
    df['Latitude'], df['Longitude'] = zip(*df['Address'].apply(get_coordinates))
    print(df)

    # Aktuální čas pro název výstupního souboru
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M")
    # Název výstupního souboru s aktuálním časem na ploše
    output_file = os.path.join(desktop, f"{now}_gps.xlsx")  

    # Uložení DataFrame do Excelu
    df.to_excel(output_file, index=False)
    print(f"Data byla úspěšně exportována do souboru: {output_file}")

    # Výpis počtu dotazů na zpracování GPS souřadnic
    print(f"Počet dotazů na zpracování GPS souřadnic: {queries_count}")

export_to_excel()