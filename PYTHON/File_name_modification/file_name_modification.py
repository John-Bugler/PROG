import os

# Cesta k vaší složce
folder_path = "C:/Users/ijttr/OneDrive/Dokumenty/OCEŇOVÁNÍ/_IJK/076339-2024 - POZ - Praha - západ - Dolní Břežany/valuo"

# Text, který chcete přidat
text_to_add = "Libuš_"

# Projdeme všechny soubory ve složce
for filename in os.listdir(folder_path):
    old_file_path = os.path.join(folder_path, filename)
    
    # Zkontrolujeme, zda se jedná o soubor, nikoliv složku
    if os.path.isfile(old_file_path):
        # Rozdělíme název na jméno souboru a příponu
        name, extension = os.path.splitext(filename)
        
        # Sestavíme nový název
        new_name = f"{text_to_add}{name}{extension}"
        new_file_path = os.path.join(folder_path, new_name)
        
        # Přejmenujeme soubor
        os.rename(old_file_path, new_file_path)

print("Přejmenování dokončeno.")
