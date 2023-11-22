# Importujeme modul pro manipulaci s cestami (cesta k souboru HTML)
import os
# Importujeme modul pro otevírání URL v prohlížeči
import webbrowser

# Definujeme obsah HTML stránky
html_content = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <link rel="stylesheet" type="text/css" href="styles.css">
    <title>Moje První HTML Stránka</title>
</head>
<body>
    
    <h1>Vítejte na mé první HTML stránce!</h1>
    <p>Toto je jednoduchý příklad.</p>
</body>
</html>
"""

# Definujeme název souboru HTML
html_file_path = 'moje_prvni_stranka.html'

# Otevřeme soubor v režimu zápisu
with open(html_file_path, 'w') as html_file:
    # Zapíšeme obsah HTML do souboru
    html_file.write(html_content)

# Získáme úplnou cestu k souboru HTML
absolute_path = os.path.abspath(html_file_path)

# Otevřeme výchozí webový prohlížeč s vytvořenou HTML stránkou
webbrowser.open('file://' + absolute_path)

