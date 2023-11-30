import sys
#print(sys.version)
from os.path import dirname, abspath

# Přidání cesty ke kořenovému adresáři projektu
sys.path.insert(0, 'C:/Apache24/htdocs/webrevolut')

from app import app

if __name__ == "__main__":
    app.run()
