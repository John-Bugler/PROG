import os
import tkinter as tk
from tkinter import filedialog, simpledialog, messagebox

# Funkce pro výběr souborů
def select_files():
    root = tk.Tk()
    root.withdraw()  # Skryje hlavní okno
    file_paths = filedialog.askopenfilenames(title="Vyberte soubory pro přejmenování")
    return root.tk.splitlist(file_paths)  # Vrátí vybrané soubory jako seznam

# Hlavní funkce pro přejmenování souborů
def rename_files(file_paths, text_to_add, position):
    for old_file_path in file_paths:
        folder_path, filename = os.path.split(old_file_path)
        name, extension = os.path.splitext(filename)
        
        # Sestavíme nový název podle pozice (začátek/konec)
        if position == "start":
            new_name = f"{text_to_add}{name}{extension}"
        elif position == "end":
            new_name = f"{name}{text_to_add}{extension}"
        
        new_file_path = os.path.join(folder_path, new_name)
        os.rename(old_file_path, new_file_path)
    
    messagebox.showinfo("Dokončeno", "Přejmenování souborů bylo dokončeno.")

# Funkce pro získání textu a volby pozice od uživatele
def get_user_input():
    root = tk.Tk()
    root.withdraw()  # Skryje hlavní okno
    
    # Získáme text, který chceme přidat
    text_to_add = simpledialog.askstring("Text k přidání", "Zadejte text, který chcete přidat k názvům souborů:")
    
    # Získáme volbu pozice (začátek nebo konec)
    position = simpledialog.askstring("Pozice textu", "Zadejte, zda chcete text přidat na začátek nebo konec názvu ('start' nebo 'end'):")
    
    return text_to_add, position

# Spuštění skriptu
if __name__ == "__main__":
    # Krok 1: Výběr souborů
    file_paths = select_files()
    
    # Krok 2: Získání textu a volby pozice
    if file_paths:
        text_to_add, position = get_user_input()
        
        if text_to_add and position in ["start", "end"]:
            # Krok 3: Přejmenování souborů
            rename_files(file_paths, text_to_add, position)
        else:
            messagebox.showwarning("Chyba", "Nebyla zadána správná volba pozice nebo žádný text.")
    else:
        messagebox.showwarning("Chyba", "Nebyly vybrány žádné soubory.")
