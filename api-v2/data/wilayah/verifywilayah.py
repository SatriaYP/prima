import json

with open("./provinces.json", "r", encoding="utf-8") as file:
    data_prov = json.load(file)

with open("./regencies.json", "r", encoding="utf-8") as file:
    data_city = json.load(file)

province_codes = {province['code'] for province in data_prov}

mismatch_found = False
for regency in data_city:
    if regency['province_code'] not in province_codes:
        print(f"Regency '{regency['name']}' has an invalid province_code: {regency['province_code']}")
        mismatch_found = True

if not mismatch_found:
    print("All province_code in regencies.json are valid.")