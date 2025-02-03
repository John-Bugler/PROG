import os
import pandas as pd
import urllib.parse
from sqlalchemy import create_engine, text
from opencage.geocoder import OpenCageGeocode

# =============================================================================
# Funkce pro vytvoření připojení k MS SQL databázi pomocí SQLAlchemy.
# =============================================================================
def get_db_engine():
    # Parametry připojení – dle vašeho zadání
    params = urllib.parse.quote_plus(
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=localhost;"
        "Database=VALUO;"
        "Trusted_Connection=yes"
    )
    connection_string = f"mssql+pyodbc:///?odbc_connect={params}"
    engine = create_engine(connection_string)
    return engine

# =============================================================================
# Načte z databáze již existující záznamy (kombinaci sloupců z Excelu) do množiny,
# aby bylo možno kontrolovat duplicity.
# =============================================================================
def load_existing_records_keys(engine):
    query = text("""
        SELECT cislo_vkladu, datum_podani, datum_zlatneni, listina, nemovitost, typ, adresa, 
               cenovy_udaj, mena, plocha, typ_plochy, popis, okres, kat_uzemi, rok, mesic 
        FROM Valuo_data
    """)
    existing_keys = set()
    with engine.connect() as connection:
        result = connection.execute(query)
        for row in result:
            # Vytvoříme n-tici se všemi hodnotami (případně s hodnotou None místo NaN)
            key = tuple(row)
            existing_keys.add(key)
    return existing_keys

# =============================================================================
# Projde zadaný adresář rekurzivně a vrátí seznam cest ke všem Excel souborům.
# =============================================================================
def traverse_directory(directory):
    excel_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".xls") or file.endswith(".xlsx"):
                excel_files.append(os.path.join(root, file))
    return excel_files

# =============================================================================
# Zpracuje jeden Excel soubor – načte data a porovná jednotlivé řádky s již 
# existujícími záznamy (na základě kombinace hodnot). Vrací seznam nových záznamů 
# (každý jako slovník) a počet řádků (mimo hlavičku) v souboru.
# =============================================================================
def process_excel_file(file_path, existing_keys):
    try:
        df = pd.read_excel(file_path)
    except Exception as e:
        print(f"Chyba při čtení souboru {file_path}: {e}")
        return [], 0

    new_records = []
    total_records = 0

    # Definice sloupců, které odpovídají struktuře tabulky v DB (v Excelu)
    required_columns = ['cislo_vkladu', 'datum_podani', 'datum_zlatneni', 'listina',
                        'nemovitost', 'typ', 'adresa', 'cenovy_udaj', 'mena', 'plocha',
                        'typ_plochy', 'popis', 'okres', 'kat_uzemi', 'rok', 'mesic']

    # Kontrola, zda jsou všechny požadované sloupce přítomny
    for col in required_columns:
        if col not in df.columns:
            print(f"Sloupec '{col}' nebyl nalezen v souboru {file_path}. Soubor přeskočuji.")
            return [], 0

    # Projdeme jednotlivé řádky
    for index, row in df.iterrows():
        total_records += 1
        # Vytvoříme n-tici s hodnotami; pokud je hodnota NaN, použijeme None
        key = tuple(row[col] if pd.notnull(row[col]) else None for col in required_columns)
        if key not in existing_keys:
            # Uložíme záznam jako slovník
            record = {col: row[col] if pd.notnull(row[col]) else None for col in required_columns}
            new_records.append(record)
            # Přidáme do množiny, abychom předešli duplicitě mezi soubory
            existing_keys.add(key)
    return new_records, total_records

# =============================================================================
# Vloží nové záznamy do DB. Vkládají se pouze sloupce načtené z Excelu,
# ostatní (timestamp, LAT, LON) jsou buď defaultní, nebo se později doplní.
# =============================================================================
def insert_new_records(engine, new_records):
    insert_query = text("""
        INSERT INTO Valuo_data 
        (cislo_vkladu, datum_podani, datum_zlatneni, listina, nemovitost, typ, adresa, 
         cenovy_udaj, mena, plocha, typ_plochy, popis, okres, kat_uzemi, rok, mesic)
        VALUES 
        (:cislo_vkladu, :datum_podani, :datum_zlatneni, :listina, :nemovitost, :typ, :adresa, 
         :cenovy_udaj, :mena, :plocha, :typ_plochy, :popis, :okres, :kat_uzemi, :rok, :mesic)
    """)
    count_inserted = 0
    with engine.begin() as connection:
        for record in new_records:
            try:
                connection.execute(insert_query, **record)
                count_inserted += 1
            except Exception as e:
                print(f"Chyba při vkládání záznamu {record}: {e}")
    return count_inserted

# =============================================================================
# Načte z DB již existující GPS souřadnice – vrátí slovník {adresa: (LAT, LON)}.
# Úprava: Sloupec adresa (typ TEXT) převedeme na VARCHAR(MAX), aby bylo možné použít DISTINCT.
# =============================================================================
def fetch_existing_gps_cache(engine):
    query = text("""
        SELECT DISTINCT CONVERT(VARCHAR(MAX), adresa) as adresa, LAT, LON 
        FROM Valuo_data
        WHERE adresa IS NOT NULL AND LAT IS NOT NULL AND LON IS NOT NULL
    """)
    gps_cache = {}
    with engine.connect() as connection:
        result = connection.execute(query)
        for row in result:
            # Předpokládáme, že sloupce jsou ve stejném pořadí: adresa, LAT, LON
            adresa = row[0]
            gps_cache[adresa] = (row[1], row[2])
    return gps_cache

# =============================================================================
# Aktualizuje všechny záznamy s danou adresou, u kterých chybí GPS souřadnice.
# =============================================================================
def update_gps_for_address(engine, adresa, lat, lon):
    update_query = text("""
        UPDATE Valuo_data
        SET LAT = :lat, LON = :lon
        WHERE adresa = :adresa AND (LAT IS NULL OR LON IS NULL)
    """)
    with engine.begin() as connection:
        result = connection.execute(update_query, {"lat": lat, "lon": lon, "adresa": adresa})
        return result.rowcount

# =============================================================================
# Vrátí seznam záznamů z DB, u kterých chybí GPS souřadnice (a adresa není prázdná).
# =============================================================================
def get_missing_gps_records(engine):
    query = text("""
        SELECT id, cislo_vkladu, datum_podani, datum_zlatneni, listina, nemovitost, typ, adresa, 
               cenovy_udaj, mena, plocha, typ_plochy, popis, okres, kat_uzemi, rok, mesic
        FROM Valuo_data
        WHERE adresa IS NOT NULL AND (LAT IS NULL OR LON IS NULL)
    """)
    records = []
    with engine.connect() as connection:
        result = connection.execute(query)
        for row in result:
            records.append(dict(row))
    return records

# =============================================================================
# Provede aktualizaci GPS souřadnic pro záznamy v DB, u kterých chybí souřadnice.
# Při zpracování se:
#   - nejprve zkontroluje, zda již v DB existuje záznam se stejnou adresou, který má GPS
#     (tedy doplní záznam z cache)
#   - pokud ne, zavolá API OpenCage (pouze jednou pro danou adresu) a výsledek uloží do lokální cache
#   - pro každý záznam se zároveň rozlišuje, zda se jedná o nově vložený záznam (na základě předané množiny new_inserted_keys)
#
# Funkce vrací slovník se statistikami:
#   - počet dotazů na API,
#   - kolik záznamů bylo doplněno pomocí API pro stará a nové záznamy,
#   - kolik záznamů bylo doplněno z cache,
#   - počet záznamů, u kterých GPS chybí i po zpracování.
# =============================================================================
def update_gps_coordinates(engine, opencage_key, new_inserted_keys):
    stats = {
        "pocet_dotazu_api": 0,
        "pocet_doplneno_api_old": 0,
        "pocet_doplneno_api_new": 0,
        "pocet_doplneno_cache_old": 0,
        "pocet_doplneno_cache_new": 0,
    }
    # Načteme všechny záznamy, kde chybí GPS a je uvedena adresa
    missing_records = get_missing_gps_records(engine)
    total_missing_before = len(missing_records)
    print(f"Celkem záznamů v DB bez GPS souřadnic: {total_missing_before}")
    
    # Načteme existující GPS souřadnice z DB (cache)
    gps_cache = fetch_existing_gps_cache(engine)
    
    # Lokální cache pro výsledky z API – aby se API nevolalo víckrát pro stejnou adresu
    local_api_cache = {}
    
    # Seskupíme záznamy podle adresy – pro každou adresu provedeme jen jedno volání/aktualizaci
    records_by_address = {}
    for record in missing_records:
        adresa = record['adresa']
        if adresa not in records_by_address:
            records_by_address[adresa] = []
        records_by_address[adresa].append(record)
    
    for adresa, records in records_by_address.items():
        # Pokud pro danou adresu již existují GPS v DB, použijeme je
        if adresa in gps_cache:
            lat, lon = gps_cache[adresa]
            zdroj = "cache (DB)"
            updated_count = update_gps_for_address(engine, adresa, lat, lon)
            print(f"Aktualizuji adresu '{adresa}' s GPS ({lat}, {lon}) z {zdroj}. Počet aktualizovaných záznamů: {updated_count}")
            # Rozlišení nových a starých záznamů
            for rec in records:
                key = (rec['cislo_vkladu'], rec['datum_podani'], rec['datum_zlatneni'], rec['listina'],
                       rec['nemovitost'], rec['typ'], rec['adresa'], rec['cenovy_udaj'], rec['mena'],
                       rec['plocha'], rec['typ_plochy'], rec['popis'], rec['okres'], rec['kat_uzemi'],
                       rec['rok'], rec['mesic'])
                if key in new_inserted_keys:
                    stats["pocet_doplneno_cache_new"] += 1
                else:
                    stats["pocet_doplneno_cache_old"] += 1
            continue

        # Pokud již bylo v tomto běhu API voláno pro danou adresu, použijeme lokální cache
        if adresa in local_api_cache:
            lat, lon = local_api_cache[adresa]
            zdroj = "lokální cache API"
            updated_count = update_gps_for_address(engine, adresa, lat, lon)
            print(f"Aktualizuji adresu '{adresa}' s GPS ({lat}, {lon}) z {zdroj}. Počet aktualizovaných záznamů: {updated_count}")
            for rec in records:
                key = (rec['cislo_vkladu'], rec['datum_podani'], rec['datum_zlatneni'], rec['listina'],
                       rec['nemovitost'], rec['typ'], rec['adresa'], rec['cenovy_udaj'], rec['mena'],
                       rec['plocha'], rec['typ_plochy'], rec['popis'], rec['okres'], rec['kat_uzemi'],
                       rec['rok'], rec['mesic'])
                if key in new_inserted_keys:
                    stats["pocet_doplneno_cache_new"] += 1
                else:
                    stats["pocet_doplneno_cache_old"] += 1
            continue
        
        # Pokud zatím GPS souřadnice neznáme, zavoláme API OpenCage
        geocoder = OpenCageGeocode(opencage_key)
        print(f"Získávám GPS souřadnice pro adresu: {adresa}")
        try:
            results = geocoder.geocode(adresa, no_annotations=1, limit=1)
        except Exception as e:
            print(f"Chyba při dotazu na API pro adresu '{adresa}': {e}")
            continue
        stats["pocet_dotazu_api"] += 1
        if results and len(results) > 0:
            lat = results[0]['geometry']['lat']
            lon = results[0]['geometry']['lng']
            local_api_cache[adresa] = (lat, lon)
            print(f"API vrátilo pro adresu '{adresa}': ({lat}, {lon})")
            updated_count = update_gps_for_address(engine, adresa, lat, lon)
            print(f"Aktualizuji adresu '{adresa}' s GPS ({lat}, {lon}). Počet aktualizovaných záznamů: {updated_count}")
            for rec in records:
                key = (rec['cislo_vkladu'], rec['datum_podani'], rec['datum_zlatneni'], rec['listina'],
                       rec['nemovitost'], rec['typ'], rec['adresa'], rec['cenovy_udaj'], rec['mena'],
                       rec['plocha'], rec['typ_plochy'], rec['popis'], rec['okres'], rec['kat_uzemi'],
                       rec['rok'], rec['mesic'])
                if key in new_inserted_keys:
                    stats["pocet_doplneno_api_new"] += 1
                else:
                    stats["pocet_doplneno_api_old"] += 1
        else:
            print(f"API nenašlo žádné souřadnice pro adresu '{adresa}'.")
    
    # Zjistíme počet záznamů, u kterých GPS souřadnice stále chybí
    with engine.connect() as connection:
        result = connection.execute(text("""
            SELECT COUNT(*) AS cnt FROM Valuo_data 
            WHERE adresa IS NOT NULL AND (LAT IS NULL OR LON IS NULL)
        """))
        remaining = result.fetchone()[0]
    
    stats["zaznamu_bez_gps_na_konce"] = remaining
    stats["celkem_bez_gps_pred_update"] = total_missing_before
    return stats

# =============================================================================
# Hlavní funkce – orchestruje celý proces:
#   1. Připojí se k DB a načte existující záznamy pro kontrolu duplicit.
#   2. Projde zadaný adresář, načte Excel soubory a vyfiltruje nové záznamy.
#   3. Vloží nové záznamy do DB.
#   4. Před aktualizací GPS vypíše počet záznamů bez GPS.
#   5. Aktualizuje GPS souřadnice (využívá API i cache) a vypíše přehledné statistiky.
# =============================================================================
def main():
    # Cesta ke zdrojovému adresáři s Excel soubory
    directory = r"C:\Users\ijttr\OneDrive\Dokumenty\PROG\PYTHON\DATA_ANALYSIS\VALUO\data"
    # API klíč pro OpenCage
    opencage_key = "85af71fbd7334627a5b84894066a8a18"
    
    engine = get_db_engine()
    
    print("Načítám existující záznamy z DB pro kontrolu duplicit...")
    existing_keys = load_existing_records_keys(engine)
    pocet_existujicich = len(existing_keys)
    print(f"Načteno {pocet_existujicich} existujících záznamů z DB.")
    
    # Množina unikátních klíčů pro nově vložené záznamy – pro rozlišení starých a nových záznamů u GPS aktualizace
    new_inserted_keys = set()
    
    # Načteme seznam Excel souborů
    excel_files = traverse_directory(directory)
    pocet_souboru = len(excel_files)
    print(f"Nalezeno {pocet_souboru} excelovských souborů ke zpracování.")
    
    celkovy_pocet_radku = 0
    new_records_all = []
    
    # Pro každý soubor provedeme zpracování
    for file in excel_files:
        print(f"\nZpracovávám soubor: {file}")
        new_records, pocet_radku = process_excel_file(file, existing_keys)
        celkovy_pocet_radku += pocet_radku
        print(f"Soubor '{file}' obsahoval {pocet_radku} řádků, z toho {len(new_records)} nových záznamů.")
        # Uložíme unikátní klíče nových záznamů
        for record in new_records:
            key = (record['cislo_vkladu'], record['datum_podani'], record['datum_zlatneni'], record['listina'],
                   record['nemovitost'], record['typ'], record['adresa'], record['cenovy_udaj'], record['mena'],
                   record['plocha'], record['typ_plochy'], record['popis'], record['okres'], record['kat_uzemi'],
                   record['rok'], record['mesic'])
            new_inserted_keys.add(key)
        new_records_all.extend(new_records)
    
    print("\n--- Shrnutí načtených dat ---")
    print(f"Celkem zpracovaných souborů: {pocet_souboru}")
    print(f"Celkem řádků (mimo hlavičky) ve všech souborech: {celkovy_pocet_radku}")
    print(f"Celkem nových záznamů určených k vložení: {len(new_records_all)}")
    
    # Vloží nové záznamy do DB
    inserted = insert_new_records(engine, new_records_all)
    print(f"V DB bylo úspěšně vloženo {inserted} nových záznamů.")
    
    # Zjistíme počet záznamů bez GPS souřadnic před spuštěním GPS aktualizace
    with engine.connect() as connection:
        result = connection.execute(text("""
            SELECT COUNT(*) AS cnt FROM Valuo_data 
            WHERE adresa IS NOT NULL AND (LAT IS NULL OR LON IS NULL)
        """))
        pocet_bez_gps_pred = result.fetchone()[0]
    print(f"\nPřed aktualizací GPS bylo v DB {pocet_bez_gps_pred} záznamů bez GPS souřadnic.")
    
    # Provedeme aktualizaci GPS souřadnic – vrátí statistiky
    gps_stats = update_gps_coordinates(engine, opencage_key, new_inserted_keys)
    
    # Vypíšeme přehlednou statistiku k aktualizaci GPS
    print("\n--- Statistiky GPS aktualizací ---")
    print(f"Počáteční počet záznamů bez GPS: {gps_stats['celkem_bez_gps_pred_update']}")
    print(f"Celkový počet API dotazů: {gps_stats['pocet_dotazu_api']}")
    print(f"Počet doplněných GPS (API) pro stará data: {gps_stats['pocet_doplneno_api_old']}")
    print(f"Počet doplněných GPS (API) pro nově vložená data: {gps_stats['pocet_doplneno_api_new']}")
    print(f"Počet doplněných GPS (z cache DB) pro stará data: {gps_stats['pocet_doplneno_cache_old']}")
    print(f"Počet doplněných GPS (z cache DB) pro nově vložená data: {gps_stats['pocet_doplneno_cache_new']}")
    print(f"Počet záznamů stále bez GPS po aktualizaci: {gps_stats['zaznamu_bez_gps_na_konce']}")
    
    print("\n--- Shrnutí celého běhu kódu ---")
    print(f"Celkem zpracovaných souborů: {pocet_souboru}")
    print(f"Celkem řádků (mimo hlavičky) ve všech souborech: {celkovy_pocet_radku}")
    print(f"Celkem nových vložených záznamů: {inserted}")
    print(f"Před spuštěním kódu bylo v DB záznamů bez GPS: {pocet_bez_gps_pred}")
    print(f"Celkem API dotazů: {gps_stats['pocet_dotazu_api']}")

if __name__ == "__main__":
    main()
