import pandas as pd

# Vytvoř DataFrame BAND a vlož záznamy
data = {'name': ['John Lennon', 'Paul McCartney',
                 'George Harrison', 'Ringo Starr']}
band = pd.DataFrame(data)

# Vyber Ringa
ringo = band['name'] == 'Ringo Starr'
print(band[ringo])
