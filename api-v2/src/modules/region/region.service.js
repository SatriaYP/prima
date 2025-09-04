import prisma from "../../lib/prisma.js";
import axios from "axios";

class RegionService {
  // "province", "city", "district", "village"
  getProvinces = async () => {
    // return await prisma.region.findMany({
    //   where: { level: "province" },
    //   orderBy: { code: "asc" },
    // });
    // return await axios.get("https://wilayah.id/api/provinces.json");
    try {
      let prov = await prisma.region.findMany({
        where: { level: "province" },
        orderBy: { code: "asc" },
      });
      if (prov.length > 0) {
        return prov;
      }

      const { data } = await axios.get("https://wilayah.id/api/provinces.json");

      for (const prov of data.data) {
        await prisma.region.upsert({
          where: { code: prov.code },
          update: {}, // kalau sudah ada, biarin
          create: {
            code: prov.code,
            name: prov.name,
            level: "province",
          },
        });
      }
      return data;
    } catch (error) {
      console.error("Gagal mengambil data provinsi:", error.message);
      throw new Error("Tidak bisa mengambil data provinsi");
    }
  };

  getCities = async (provincesCode) => {
    console.log(provincesCode);

    try {
      let city = await prisma.region.findMany({
        where: { level: "city", parentId: provincesCode },
        orderBy: { code: "asc" },
      });
      if (city.length > 0) {
        return city;
      }
      const { data } = await axios.get(
        `https://wilayah.id/api/regencies/${provincesCode}.json`
      );
      for (const city of data.data) {
        await prisma.region.upsert({
          where: { code: city.code },
          update: {}, // kalau sudah ada, biarin
          create: {
            code: city.code,
            name: city.name,
            level: "city",
            parentId: provincesCode,
          },
        });
      }
      return data;
    } catch (error) {
      console.error("Gagal mengambil data kota/kabupaten:", error.message);
      throw new Error("Tidak bisa mengambil data kota/kabupaten");
    }
  };

  getDistricts = async (cityCode) => {
    // return await prisma.region.findMany({
    //   where: { level: "district", parentId: cityId },
    //   orderBy: { code: "asc" },
    // });
    try {
      let district = await prisma.region.findMany({
        where: { level: "district", parentId: cityCode },
        orderBy: { code: "asc" },
      });
      if (district.length > 0) {
        return district;
      }

      const { data } = await axios.get(
        `https://wilayah.id/api/districts/${cityCode}.json`
      );
      for (const district of data.data) {
        await prisma.region.upsert({
          where: { code: district.code },
          update: {}, // kalau sudah ada, biarin
          create: {
            code: district.code,
            name: district.name,
            level: "district",
            parentId: cityCode,
          },
        });
      }
      return data;
    } catch (error) {
      console.error("Gagal mengambil data Kecamatan:", error.message);
      throw new Error("Tidak bisa mengambil data Kecamatan");
    }
  };

  getVillages = async (districtCode) => {
    try {
      let village = await prisma.region.findMany({
        where: { level: "village", parentId: districtCode },
        orderBy: { code: "asc" },
      });
      if (village.length > 0) {
        return village;
      }

      const { data } = await axios.get(
        `https://wilayah.id/api/villages/${districtCode}.json`
      );
      for (const village of data.data) {
        await prisma.region.upsert({
          where: { code: village.code },
          update: {}, // kalau sudah ada, biarin
          create: {
            code: village.code,
            name: village.name,
            level: "village",
            parentId: districtCode,
          },
        });
      }
      return data;
    } catch (error) {
      console.error("Gagal mengambil data Desa:", error.message);
      throw new Error("Tidak bisa mengambil data Desa");
    }
  };
}

export default new RegionService();
