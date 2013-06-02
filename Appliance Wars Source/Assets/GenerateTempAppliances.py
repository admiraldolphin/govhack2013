#!/usr/bin/python

import csv
import sys
import os
import pprint
import string
import json
import random

pp = pprint.PrettyPrinter(indent=4)

namePrefixes = ["Hyper", "Quasi", "Mega", "Inter", "Domesto", "Tidy", "Sani", "Valu", "Ezi", "Cleano", "Auto"];
nameSuffixes = ["tron", "bar", "dyne", "zap", "clean", "bux", "san", "matic", "oni"];

applianceTypes = ["Refrigerator", "Air Conditioner", "Television", "Dish Washer", "Clothes Washer", "Clothes Dryer"]

appliances = []

def main():
    
    for i in range(0, 100):
        appliance = {}
        appliance["capacity"] = random.randint(0, 20);
        appliance["durability"] = random.randint(3, 7);
        appliance["cost"] = random.randrange(100, 500, 50);
        appliance["rating"] = random.randint(0, 10) / 2.0;
        appliance["name"] = random.choice(namePrefixes) + random.choice(nameSuffixes) + " " + str(random.randrange(100, 9000, 100))
        appliance["type"] = random.choice(applianceTypes)
        appliances.append(appliance)
    
    print json.dumps(appliances, indent=4)
    

if __name__ == '__main__':
    main()
