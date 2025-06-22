const http = require('http');

// Fungsi untuk melakukan request HTTP GET
function httpGet(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode !== 200) {
        error = new Error(`Request Failed.\nStatus Code: ${statusCode}`);
      } else if (!/^application\/json/.test(contentType)) {
        error = new Error(`Invalid content-type.\nExpected application/json but received ${contentType}`);
      }
      
      if (error) {
        console.error(error.message);
        res.resume();
        reject(error);
        return;
      }

      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(rawData);
          resolve(parsedData);
        } catch (e) {
          console.error(e.message);
          reject(e);
        }
      });
    }).on('error', (e) => {
      console.error(`Got error: ${e.message}`);
      reject(e);
    });
  });
}

// Fungsi untuk menguji endpoint API
async function testApi() {
  try {
    console.log('Menguji API Wilayah Indonesia...');
    
    // Test root endpoint
    console.log('\n1. Menguji endpoint root:');
    const rootResponse = await httpGet('http://localhost:3000/');
    console.log('Response:', JSON.stringify(rootResponse, null, 2));
    
    // Test provinsi endpoint
    console.log('\n2. Menguji endpoint provinsi:');
    const provinsiResponse = await httpGet('http://localhost:3000/api/wilayah/provinsi');
    console.log(`Jumlah provinsi: ${provinsiResponse.data.length}`);
    console.log('Contoh data provinsi:', JSON.stringify(provinsiResponse.data[0], null, 2));
    
    // Test kabupaten endpoint untuk provinsi DKI Jakarta (id: 31)
    console.log('\n3. Menguji endpoint kabupaten untuk provinsi DKI Jakarta:');
    const kabupatenResponse = await httpGet('http://localhost:3000/api/wilayah/provinsi/31/kabupaten');
    console.log(`Jumlah kabupaten/kota: ${kabupatenResponse.data.length}`);
    console.log('Contoh data kabupaten/kota:', JSON.stringify(kabupatenResponse.data[0], null, 2));
    
    // Test kecamatan endpoint untuk Jakarta Pusat (id: 3171)
    console.log('\n4. Menguji endpoint kecamatan untuk Jakarta Pusat:');
    const kecamatanResponse = await httpGet('http://localhost:3000/api/wilayah/kabupaten/3171/kecamatan');
    console.log(`Jumlah kecamatan: ${kecamatanResponse.data.length}`);
    console.log('Contoh data kecamatan:', JSON.stringify(kecamatanResponse.data[0], null, 2));
    
    // Test kelurahan endpoint untuk Gambir (id: 317101)
    console.log('\n5. Menguji endpoint kelurahan untuk Gambir:');
    const kelurahanResponse = await httpGet('http://localhost:3000/api/wilayah/kecamatan/317101/kelurahan');
    console.log(`Jumlah kelurahan: ${kelurahanResponse.data.length}`);
    console.log('Contoh data kelurahan:', JSON.stringify(kelurahanResponse.data[0], null, 2));
    
    console.log('\nSemua test berhasil!');
  } catch (error) {
    console.error('Error saat menguji API:', error);
  }
}

// Jalankan test
testApi();
