const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Path ke file CSV
const DATA_DIR = path.join(__dirname, '../../data');
const PROVINCES_CSV = path.join(DATA_DIR, 'provinces.csv');
const REGENCIES_CSV = path.join(DATA_DIR, 'regencies.csv');
const DISTRICTS_CSV = path.join(DATA_DIR, 'districts.csv');
const VILLAGES_CSV = path.join(DATA_DIR, 'villages.csv');

/**
 * Fungsi untuk membaca file CSV dan mengembalikan data dalam bentuk array
 * @param {string} filePath - Path ke file CSV
 * @param {Array} headers - Header untuk CSV (jika tidak ada header di file)
 * @returns {Promise<Array>} Data dari CSV dalam bentuk array
 */
function readCsvFile(filePath, headers) {
  return new Promise((resolve, reject) => {
    const results = [];
    
    const stream = fs.createReadStream(filePath);
    
    // Jika headers disediakan, gunakan transformasi sederhana
    if (headers) {
      let lineCount = 0;
      let buffer = '';
      
      stream.on('data', (chunk) => {
        buffer += chunk.toString();
        const lines = buffer.split('\n');
        buffer = lines.pop(); // Simpan baris yang belum lengkap
        
        for (const line of lines) {
          if (line.trim()) {
            const values = line.split(',');
            const row = {};
            
            headers.forEach((header, index) => {
              row[header] = values[index] ? values[index].trim() : '';
            });
            
            results.push(row);
            lineCount++;
          }
        }
      });
      
      stream.on('end', () => {
        // Proses baris terakhir jika ada
        if (buffer.trim()) {
          const values = buffer.trim().split(',');
          const row = {};
          
          headers.forEach((header, index) => {
            row[header] = values[index] ? values[index].trim() : '';
          });
          
          results.push(row);
        }
        
        resolve(results);
      });
      
      stream.on('error', (error) => reject(error));
    } else {
      // Jika tidak ada headers, gunakan csv-parser
      stream
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', () => resolve(results))
        .on('error', (error) => reject(error));
    }
  });
}

/**
 * Fungsi utama untuk mengimpor data wilayah
 */
async function importData() {
  try {
    console.log('Mulai mengimpor data wilayah...');
    
    // Buat direktori data jika belum ada
    if (!fs.existsSync(DATA_DIR)) {
      fs.mkdirSync(DATA_DIR, { recursive: true });
      console.log(`Direktori ${DATA_DIR} dibuat.`);
    }
    
    // Cek apakah file CSV ada
    const csvFilesExist = fs.existsSync(PROVINCES_CSV) && 
                          fs.existsSync(REGENCIES_CSV) && 
                          fs.existsSync(DISTRICTS_CSV) && 
                          fs.existsSync(VILLAGES_CSV);
    
    if (!csvFilesExist) {
      console.log('File CSV tidak ditemukan. Silakan unduh file CSV terlebih dahulu.');
      console.log('Format CSV yang diharapkan:');
      console.log('provinces.csv: id,name');
      console.log('regencies.csv: id,province_id,name');
      console.log('districts.csv: id,regency_id,name');
      console.log('villages.csv: id,district_id,name');
      return;
    }
    
    // Impor provinsi
    console.log('Mengimpor data provinsi...');
    const provinces = await readCsvFile(PROVINCES_CSV, ['id', 'name']);
    
    for (const province of provinces) {
      await prisma.province.upsert({
        where: { id: province.id },
        update: {
          name: province.name,
          code: province.id // Gunakan ID sebagai code jika tidak ada
        },
        create: {
          id: province.id,
          name: province.name,
          code: province.id // Gunakan ID sebagai code jika tidak ada
        }
      });
    }
    console.log(`${provinces.length} provinsi berhasil diimpor.`);
    
    // Impor kabupaten/kota
    console.log('Mengimpor data kabupaten/kota...');
    const regencies = await readCsvFile(REGENCIES_CSV, ['id', 'province_id', 'name']);
    
    for (const regency of regencies) {
      await prisma.regency.upsert({
        where: { id: regency.id },
        update: {
          provinceId: regency.province_id,
          name: regency.name,
          code: regency.id // Gunakan ID sebagai code jika tidak ada
        },
        create: {
          id: regency.id,
          provinceId: regency.province_id,
          name: regency.name,
          code: regency.id // Gunakan ID sebagai code jika tidak ada
        }
      });
    }
    console.log(`${regencies.length} kabupaten/kota berhasil diimpor.`);
    
    // Impor kecamatan
    console.log('Mengimpor data kecamatan...');
    const districts = await readCsvFile(DISTRICTS_CSV, ['id', 'regency_id', 'name']);
    
    for (const district of districts) {
      await prisma.district.upsert({
        where: { id: district.id },
        update: {
          regencyId: district.regency_id,
          name: district.name,
          code: district.id // Gunakan ID sebagai code jika tidak ada
        },
        create: {
          id: district.id,
          regencyId: district.regency_id,
          name: district.name,
          code: district.id // Gunakan ID sebagai code jika tidak ada
        }
      });
    }
    console.log(`${districts.length} kecamatan berhasil diimpor.`);
    
    // Impor kelurahan/desa
    console.log('Mengimpor data kelurahan/desa...');
    const villages = await readCsvFile(VILLAGES_CSV, ['id', 'district_id', 'name']);
    
    // Impor kelurahan/desa dalam batch untuk menghindari memory issue
    const batchSize = 1000;
    for (let i = 0; i < villages.length; i += batchSize) {
      const batch = villages.slice(i, i + batchSize);
      
      await Promise.all(
        batch.map(village => 
          prisma.village.upsert({
            where: { id: village.id },
            update: {
              districtId: village.district_id,
              name: village.name,
              code: village.id // Gunakan ID sebagai code jika tidak ada
            },
            create: {
              id: village.id,
              districtId: village.district_id,
              name: village.name,
              code: village.id // Gunakan ID sebagai code jika tidak ada
            }
          })
        )
      );
      
      console.log(`Diimpor ${i + batch.length} dari ${villages.length} kelurahan/desa...`);
    }
    
    console.log(`${villages.length} kelurahan/desa berhasil diimpor.`);
    console.log('Impor data wilayah selesai!');
    
  } catch (error) {
    console.error('Error saat mengimpor data:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Jalankan fungsi impor
importData();
