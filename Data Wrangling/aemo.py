#!/usr/bin/python
import requests
from bs4 import BeautifulSoup
import json

r = requests.get('http://www.aemo.com.au/Electricity/Data/Price-and-Demand/Average-Price-Tables')
soup = BeautifulSoup(r.content)
tables = soup.find_all('table')
rows = tables[1].find_all('tr')
links = rows[-1].find_all('a')
url = links[-1]['href']

r = requests.get('http://www.aemo.com.au/Electricity/Data/Price-and-Demand/' + url)

soup = BeautifulSoup(r.content)
rows = soup.table.find_all('tr')
headers = rows[0].find_all('td')
fields = rows[-1].find_all('td')
data = {'Date' : fields[0].text.strip(), headers[1].text.strip() : fields[1].text.strip(), headers[2].text.strip() : fields[3].text.strip(), headers[3].text.strip() : fields[5].text.strip(), headers[4].text.strip() : fields[7].text.strip(), headers[5].text.strip() : fields[9].text.strip(), }
with open('/var/www/GovHackTas/aemo.json', 'w') as f:
	f.write(json.dumps(data))

