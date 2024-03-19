# Vytvoř seznam BAND
band = list()

# Vlož záznamy
band.append([1, 'John Lennon'])
band.append([2, 'Paul McCartney'])
band.append([3, 'George Harrison'])
band.append([4, 'Ringo Starr'])

# Vyber Ringa
for member in band:
    id, name = member
    if name == 'Ringo Starr':
        print(member)
