import fs from "fs";
import path from "path";

function maintest() {
  const provinsi = path.resolve("data/wilayah/provinces.json");
  const provinsiData = JSON.parse(fs.readFileSync(provinsi, "utf-8"));
  const city = path.resolve("data/wilayah/regencies.json");
  const cityData = JSON.parse(fs.readFileSync(city, "utf-8"));

  const provCodes = new Set(provinsiData.map((p) => p.code));
  const unmatched = [];

  for (const cty of cityData) {
    if (!provCodes.has(cty.province_code)) {
      unmatched.push({ city: cty.name, province_code: cty.province_code });
    }
  }

  if (unmatched.length) {
    console.log(
      "Ada kota yang memiliki province_code tidak cocok dengan provinsi:"
    );
    console.table(unmatched);
    process.exit(1);
  } else {
    console.log("Semua kota/kabupaten cocok dengan provinsi.");
  }
}

maintest();
