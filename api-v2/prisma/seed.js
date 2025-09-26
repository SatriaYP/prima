import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import fs from "fs";
import path from "path";
import { faker } from "@faker-js/faker/locale/id_ID";
import RegionService from "../src/modules/region/region.service.js";

const prisma = new PrismaClient();

const provinsi = path.resolve("data/wilayah/provinces.json");
const provinsiData = JSON.parse(fs.readFileSync(provinsi, "utf-8"));
const city = path.resolve("data/wilayah/regencies.json");
const cityData = JSON.parse(fs.readFileSync(city, "utf-8"));
const district = path.resolve("data/wilayah/districts.json");
const districtData = JSON.parse(fs.readFileSync(district, "utf-8"));
const village = path.resolve("data/wilayah/villages.json");
const villageData = JSON.parse(fs.readFileSync(village, "utf-8"));

// async function getRegionCodes() {
//   const provinces = await RegionService.getProvinces();
//   // const provinces = await prisma.region.findMany({ where: { level: 'province' }, select: { code: true } });
//   const cities = await RegionService.getCities("32");
//   // const cities = await prisma.region.findMany({ where: { level: 'city' }, select: { code: true } });
//   const districts = await RegionService.getDistricts("32.04");
//   const villages = await RegionService.getVillages("32.04.05");
//   // const districts = await prisma.region.findMany({
//   //   where: { level: "district" },
//   //   select: { code: true },
//   // });
//   // const villages = await prisma.region.findMany({
//   //   where: { level: "village" },
//   //   select: { code: true },
//   // });

//   return { provinces, cities, districts, villages };
// }

// const generateFakeMember = (index, codes) => {
//   const genders = ["Laki-laki", "Perempuan"];
//   const gender = faker.helpers.arrayElement(genders);
//   const maritalStatus = faker.helpers.arrayElement(["Kawin", "Belum Kawin"]);
//   const registrationTypes = ["admin", "member"];

//   return {
//     nik: faker.helpers.uniqueArray(faker.string.numeric, [16]),
//     ktaNumber: `KTA-2025${String(index).padStart(4, "0")}`,
//     name: faker.person.fullName({
//       sex: gender === "Laki-laki" ? "male" : "female",
//     }),
//     gender,
//     birthPlace: faker.location.city(),
//     birthDate: faker.date.birthdate({ min: 18, max: 60, mode: "age" }),
//     address: faker.location.streetAddress(),
//     phone: faker.phone.number("08##########"),
//     // email: faker.internet.email(),
//     // email: faker.helpers.unique(faker.internet.email),
//     email: faker.helpers.uniqueArray(() =>
//       faker.internet.email().toLowerCase()
//     ),
//     maritalStatus,
//     occupation: faker.person.jobTitle(),
//     skills: faker.word.words({ count: { min: 2, max: 4 } }),
//     interests: faker.word.words({ count: { min: 2, max: 4 } }),
//     provinceCode: faker.helpers.arrayElement(codes.provinces).code,
//     cityCode: faker.helpers.arrayElement(codes.cities).code,
//     districtCode: faker.helpers.arrayElement(codes.districts).code,
//     villageCode: faker.helpers.arrayElement(codes.villages).code,
//     // registrationType: faker.helpers.arrayElement(registrationTypes),
//     isOfficial: false,
//   };
// };

async function main() {
  // "province", "city", "district", "village"
  // for (const prov of provinsiData) {
  //   await prisma.region.upsert({
  //     where: { code: prov.code },
  //     update: {},
  //     create: {
  //       code: prov.code,
  //       name: prov.name,
  //       level: "province",
  //     },
  //   });
  // }
  // for (const cty of cityData) {
  //   const parentExists = await prisma.region.findUnique({
  //     where: { code: cty.province_code },
  //   });
  //   if (!parentExists) {
  //     console.error(
  //       `Provinsi dengan kode ${cty.province_code} tidak ditemukan untuk kota ${cty.name}`
  //     );
  //     continue; // skip supaya tidak error
  //   }
  //   if (parentExists) {
  //     // console.log(typeof cty.province_code);
  //     await prisma.region.upsert({
  //       where: { code: cty.code },
  //       update: {},
  //       create: {
  //         code: cty.code,
  //         name: cty.name,
  //         level: "city",
  //         parentId: cty.province_code,
  //       },
  //     });
  //   }
  // }
  // for (const district of districtData) {
  //   await prisma.region.upsert({
  //     where: { code: district.code },
  //     update: {},
  //     create: {
  //       code: district.code,
  //       name: district.name,
  //       level: "district",
  //       parentId: district.regency_code,
  //     },
  //   });
  // }
  // for (const village of villageData) {
  //   await prisma.region.upsert({
  //     where: { code: village.code },
  //     update: {},
  //     create: {
  //       code: village.code,
  //       name: village.name,
  //       level: "village",
  //       parentId: village.district_code,
  //     },
  //   });
  // }
  // const password = await bcrypt.hash("admin123", 10);
  // await prisma.user.upsert({
  //   where: { username: "admin" },
  //   update: {},
  //   create: {
  //     username: "admin",
  //     password,
  //     email: "admin@example.com",
  //     role: "admin",
  //     name: "Administrator",
  //     level: "dpp",
  //     status: "active",
  //   },
  // });
  // const codes = await getRegionCodes();
  // console.log(codes);
  // const members = Array.from({ length: 10 }, (_, i) =>
  //   generateFakeMember(i + 1, codes)
  // );
  // await prisma.member.createMany({
  //   data: members,
  //   skipDuplicates: true,
  // });
  // for (let i = 0; i <= 10; i++) {
  //   await prisma.member.upsert({
  //     where: {},
  //     update: {},
  //     create: {
  //       nik: "1234567890123456",
  //       ktaNumber: "KTA-20250001",
  //       name: "Budi Santoso",
  //       gender: "Laki-laki",
  //       birthPlace: "Bandung",
  //       birthDate: new Date("1990-05-15"),
  //       address: "Jl. Merdeka 1",
  //       phone: "081234567890",
  //       email: "budi@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Wiraswasta",
  //       skills: "Organisasi, Kepemimpinan",
  //       interests: "Politik, Sosial",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //       // Optional: connect ke region jika sudah ada
  //       // province: { connect: { code: '11' } },
  //     },
  //   });
  // }
  await prisma.member.create({
    data: {
      nik: "1234567890123453",
      ktaNumber: "KTA-20250003",
      name: "Salman",
      gender: "Laki-laki",
      birthPlace: "Bandung",
      birthDate: new Date("1990-05-15"),
      address: "Jl. Merdeka 1",
      phone: "081234567890",
      email: "salman@example.com",
      maritalStatus: "Kawin",
      occupation: "Wiraswasta",
      skills: "Organisasi, Kepemimpinan",
      interests: "Politik, Sosial",
      registrationType: "admin",
      provinceCode: "32",
      cityCode: "3204",
      districtCode: "320405",
      villageCode: "3204052005",
      isOfficial: false,
      // Optional: connect ke region jika sudah ada
      // province: { connect: { code: '11' } },
    },
  });

  // await prisma.member.createMany({
  //   data: [
  //     {
  //       nik: "1234567890123451",
  //       ktaNumber: "KTA-20250001",
  //       name: "Budi Santoso",
  //       gender: "Laki-laki",
  //       birthPlace: "Bandung",
  //       birthDate: new Date("1990-05-15"),
  //       address: "Jl. Merdeka 1",
  //       phone: "081234567890",
  //       email: "budi@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Wiraswasta",
  //       skills: "Organisasi, Kepemimpinan",
  //       interests: "Politik, Sosial",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123452",
  //       ktaNumber: "KTA-20250002",
  //       name: "Andi Wijaya",
  //       gender: "Laki-laki",
  //       birthPlace: "Jakarta",
  //       birthDate: new Date("1988-08-20"),
  //       address: "Jl. Sudirman 10",
  //       phone: "081234567891",
  //       email: "andi@example.com",
  //       maritalStatus: "Belum Kawin",
  //       occupation: "Pengusaha",
  //       skills: "Manajemen, Negosiasi",
  //       interests: "Ekonomi, Politik",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123453",
  //       ktaNumber: "KTA-20250003",
  //       name: "Citra Lestari",
  //       gender: "Perempuan",
  //       birthPlace: "Bandung",
  //       birthDate: new Date("1992-01-10"),
  //       address: "Jl. Asia Afrika 15",
  //       phone: "081234567892",
  //       email: "citra@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Karyawan Swasta",
  //       skills: "Komunikasi, Presentasi",
  //       interests: "Sosial, Pendidikan",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123454",
  //       ktaNumber: "KTA-20250004",
  //       name: "Dedi Kurniawan",
  //       gender: "Laki-laki",
  //       birthPlace: "Garut",
  //       birthDate: new Date("1985-03-25"),
  //       address: "Jl. Cihampelas 20",
  //       phone: "081234567893",
  //       email: "dedi@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Petani",
  //       skills: "Pertanian, Organisasi",
  //       interests: "Lingkungan, Sosial",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123455",
  //       ktaNumber: "KTA-20250005",
  //       name: "Eka Putri",
  //       gender: "Perempuan",
  //       birthPlace: "Cimahi",
  //       birthDate: new Date("1995-07-07"),
  //       address: "Jl. Raya Cimahi 5",
  //       phone: "081234567894",
  //       email: "eka@example.com",
  //       maritalStatus: "Belum Kawin",
  //       occupation: "Guru",
  //       skills: "Mengajar, Menulis",
  //       interests: "Pendidikan, Seni",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123456",
  //       ktaNumber: "KTA-20250006",
  //       name: "Fajar Nugraha",
  //       gender: "Laki-laki",
  //       birthPlace: "Bandung",
  //       birthDate: new Date("1991-11-11"),
  //       address: "Jl. Gatot Subroto 3",
  //       phone: "081234567895",
  //       email: "fajar@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Programmer",
  //       skills: "Coding, Problem Solving",
  //       interests: "Teknologi, Startup",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123457",
  //       ktaNumber: "KTA-20250007",
  //       name: "Gita Prameswari",
  //       gender: "Perempuan",
  //       birthPlace: "Tasikmalaya",
  //       birthDate: new Date("1993-09-09"),
  //       address: "Jl. Veteran 8",
  //       phone: "081234567896",
  //       email: "gita@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Wiraswasta",
  //       skills: "Marketing, Public Speaking",
  //       interests: "Bisnis, Sosial",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123458",
  //       ktaNumber: "KTA-20250008",
  //       name: "Hendra Saputra",
  //       gender: "Laki-laki",
  //       birthPlace: "Cianjur",
  //       birthDate: new Date("1987-12-01"),
  //       address: "Jl. Cianjur Raya 6",
  //       phone: "081234567897",
  //       email: "hendra@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Sopir",
  //       skills: "Mengemudi, Perawatan Kendaraan",
  //       interests: "Otomotif, Musik",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123459",
  //       ktaNumber: "KTA-20250009",
  //       name: "Intan Maharani",
  //       gender: "Perempuan",
  //       birthPlace: "Bandung",
  //       birthDate: new Date("1996-04-04"),
  //       address: "Jl. Braga 12",
  //       phone: "081234567898",
  //       email: "intan@example.com",
  //       maritalStatus: "Belum Kawin",
  //       occupation: "Desainer",
  //       skills: "Desain Grafis, Fotografi",
  //       interests: "Seni, Fashion",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //     {
  //       nik: "1234567890123460",
  //       ktaNumber: "KTA-20250010",
  //       name: "Joko Prabowo",
  //       gender: "Laki-laki",
  //       birthPlace: "Subang",
  //       birthDate: new Date("1984-02-28"),
  //       address: "Jl. Subang Indah 4",
  //       phone: "081234567899",
  //       email: "joko@example.com",
  //       maritalStatus: "Kawin",
  //       occupation: "Peternak",
  //       skills: "Peternakan, Manajemen",
  //       interests: "Pertanian, Sosial",
  //       registrationType: "admin",
  //       provinceCode: "32",
  //       cityCode: "32.04",
  //       districtCode: "32.04.05",
  //       villageCode: "32.04.05.2005",
  //       isOfficial: false,
  //     },
  //   ],
  // });

  // await prisma.member.createMany({
  //   data: Array.from({ length: 10 }).map((_, i) => ({
  //     nik: `12345678901234${50 + i}`, // unik
  //     ktaNumber: `KTA-${Date.now()}-${i}`, // selalu unik
  //     name: `Member ${i + 1}`,
  //     gender: i % 2 === 0 ? "Laki-laki" : "Perempuan",
  //     birthPlace: "Bandung",
  //     birthDate: new Date(`199${i}-01-01`),
  //     address: `Jl. Merdeka ${i + 1}`,
  //     phone: `0812345678${i}0`,
  //     email: `member${i + 1}@example.com`,
  //     maritalStatus: "Kawin",
  //     occupation: "Wiraswasta",
  //     skills: "Organisasi, Kepemimpinan",
  //     interests: "Politik, Sosial",
  //     registrationType: "admin",
  //     provinceCode: "32",
  //     cityCode: "32.04",
  //     districtCode: "32.04.05",
  //     villageCode: "32.04.05.2005",
  //     isOfficial: false,
  //   })),
  // });

  // await prisma.member.create({
  //   data: {
  //     nik: "123456789012342334",
  //     ktaNumber: "KTA-20250003",
  //     name: "Adit",
  //     gender: "Laki-laki",
  //     birthPlace: "Bandung",
  //     birthDate: new Date("1990-05-15"),
  //     address: "Jl. Merdeka 1",
  //     phone: "081234567890",
  //     email: "adit@example.com",
  //     maritalStatus: "Kawin",
  //     occupation: "Wiraswasta",
  //     skills: "Organisasi, Kepemimpinan",
  //     interests: "Politik, Sosial",
  //     registrationType: "admin",
  //     provinceCode: "32",
  //     cityCode: "32.04",
  //     districtCode: "32.04.05",
  //     villageCode: "32.04.05.2005",
  //     isOfficial: false,
  //     // Optional: connect ke region jika sudah ada
  //     // province: { connect: { code: '11' } },
  //   },
  // });
  // await prisma.member.create({
  //   data: {
  //     name: "Budi Santoso",
  //     email: "budi@example.com",
  //     ktp: "1234567890",
  //     address: "Jl. Merdeka 1",
  //     phone: "081234567890",
  //   },
  // });
  // await prisma.member.create({
  //   data: {
  //     name: "Siti Aminah",
  //     email: "siti@example.com",
  //     ktp: "9876543210",
  //     address: "Jl. Pahlawan 2",
  //     phone: "081298765432",
  //   },
  // });
  // await prisma.official.create({
  //   data: {
  //     name: "Agus Setiawan",
  //     position: "Ketua",
  //     region: "DKI Jakarta",
  //     email: "agus@prima.id",
  //     phone: "081211112222",
  //   },
  // });
  // await prisma.official.create({
  //   data: {
  //     name: "Rina Dewi",
  //     position: "Sekretaris",
  //     region: "Jawa Barat",
  //     email: "rina@prima.id",
  //     phone: "081233344455",
  //   },
  // });
}

main()
  .then(() => {
    console.log("Database seeded!");
    // return prisma.$disconnect();
  })
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
