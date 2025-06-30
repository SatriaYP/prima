# Dokumentasi API Wilayah

API Wilayah menyediakan data administratif wilayah Indonesia yang dapat digunakan untuk mengisi dropdown wilayah secara dinamis, memfilter data berdasarkan wilayah, dan keperluan lainnya.

## Base URL

```
https://wilayah.partaiprima.id
```

## Endpoints

### 1. Daftar Provinsi

Mendapatkan daftar seluruh provinsi di Indonesia.

- **URL**: `/provinsi.json`
- **Method**: GET
- **Response Format**: Array JSON
- **Response Example**:

```json
[
  {
    "id": "11",
    "name": "ACEH"
  },
  {
    "id": "12",
    "name": "SUMATERA UTARA"
  },
  ...
]
```

### 2. Daftar Kabupaten/Kota per Provinsi

Mendapatkan daftar kabupaten/kota dalam suatu provinsi.

- **URL**: `/regencies/{id_provinsi}.json`
- **Method**: GET
- **URL Parameters**:
  - `id_provinsi`: ID provinsi (contoh: "11" untuk ACEH)
- **Response Format**: Array JSON
- **Response Example**:

```json
[
  {
    "id": "11.01",
    "name": "KAB. ACEH SELATAN"
  },
  {
    "id": "11.02",
    "name": "KAB. ACEH TENGGARA"
  },
  ...
]
```

### 3. Daftar Kecamatan per Kabupaten/Kota

Mendapatkan daftar kecamatan dalam suatu kabupaten/kota.

- **URL**: `/districts/{id_kabupaten}.json`
- **Method**: GET
- **URL Parameters**:
  - `id_kabupaten`: ID kabupaten/kota (contoh: "11.01" untuk KAB. ACEH SELATAN)
- **Response Format**: Array JSON
- **Response Example**:

```json
[
  {
    "id": "11.01.01",
    "name": "BAKONGAN"
  },
  {
    "id": "11.01.02",
    "name": "KLUET UTARA"
  },
  ...
]
```

### 4. Daftar Kelurahan/Desa per Kecamatan

Mendapatkan daftar kelurahan/desa dalam suatu kecamatan.

- **URL**: `/villages/{id_kecamatan}.json`
- **Method**: GET
- **URL Parameters**:
  - `id_kecamatan`: ID kecamatan (contoh: "11.01.01" untuk BAKONGAN)
- **Response Format**: Array JSON
- **Response Example**:

```json
[
  {
    "id": "11.01.01.2001",
    "name": "KEUDE BAKONGAN"
  },
  {
    "id": "11.01.01.2002",
    "name": "UJONG MANGKI"
  },
  ...
]
```

## Struktur ID Wilayah

Format ID wilayah mengikuti standar kode wilayah dari Kementerian Dalam Negeri (Kemendagri) Republik Indonesia. Kode ini memiliki struktur hierarkis yang mencerminkan pembagian administratif wilayah Indonesia.

### Format Kode Wilayah

Kode wilayah menggunakan format pemisahan dengan titik (.) sebagai berikut:

- **Provinsi**: 2 digit (contoh: "11" untuk ACEH)
- **Kabupaten/Kota**: 2 digit provinsi + "." + 2 digit kabupaten/kota (contoh: "11.01" untuk KAB. ACEH SELATAN)
- **Kecamatan**: 2 digit provinsi + "." + 2 digit kabupaten/kota + "." + 2 digit kecamatan (contoh: "11.01.01" untuk BAKONGAN)
- **Kelurahan/Desa**: 2 digit provinsi + "." + 2 digit kabupaten/kota + "." + 2 digit kecamatan + "." + 4 digit kelurahan/desa (contoh: "11.01.01.2001" untuk KEUDE BAKONGAN)

### Contoh Lengkap

Sebagai contoh, kode wilayah **31.74.06.1003** dapat diuraikan sebagai berikut:
- **31** adalah kode Provinsi DKI Jakarta
- **31.74** adalah kode Kota Jakarta Selatan
- **31.74.06** adalah kode Kecamatan Cilandak
- **31.74.06.1003** adalah kode Kelurahan Pondok Labu

### Penggunaan dalam Aplikasi

Struktur kode wilayah ini memungkinkan:
1. **Pelacakan Hierarki**: Dengan melihat kode, kita dapat langsung mengetahui provinsi, kabupaten/kota, dan kecamatan dari suatu kelurahan/desa
2. **Filtering Data**: Memudahkan filtering data berdasarkan wilayah administratif
3. **Integrasi Sistem**: Kompatibel dengan sistem pemerintahan dan aplikasi lain yang menggunakan standar kode wilayah Kemendagri
4. **Validasi Data**: Memungkinkan validasi data wilayah berdasarkan struktur kode yang konsisten

### Catatan Penting

- Kode wilayah ini adalah standar resmi yang digunakan oleh pemerintah Indonesia
- Struktur kode ini dapat berubah jika terjadi pemekaran wilayah atau perubahan administratif lainnya
- Data wilayah dalam API ini mencakup 38 provinsi di Indonesia dengan pembagian administratif terkini

## Penggunaan dalam Aplikasi

### Contoh Penggunaan dengan Axios (Vue.js)

```javascript
import axios from 'axios';

// Mendapatkan daftar provinsi
async function getProvinces() {
  try {
    const response = await axios.get('https://wilayah.partaiprima.id/provinsi.json');
    return response.data;
  } catch (error) {
    console.error('Error fetching provinces:', error);
    return [];
  }
}

// Mendapatkan daftar kabupaten/kota berdasarkan provinsi
async function getRegencies(provinceId) {
  try {
    const response = await axios.get(`https://wilayah.partaiprima.id/regencies/${provinceId}.json`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching regencies for province ${provinceId}:`, error);
    return [];
  }
}

// Mendapatkan daftar kecamatan berdasarkan kabupaten/kota
async function getDistricts(regencyId) {
  try {
    const response = await axios.get(`https://wilayah.partaiprima.id/districts/${regencyId}.json`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching districts for regency ${regencyId}:`, error);
    return [];
  }
}

// Mendapatkan daftar kelurahan/desa berdasarkan kecamatan
async function getVillages(districtId) {
  try {
    const response = await axios.get(`https://wilayah.partaiprima.id/villages/${districtId}.json`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching villages for district ${districtId}:`, error);
    return [];
  }
}
```

### Implementasi Dropdown Cascade

```vue
<template>
  <div>
    <div class="form-group">
      <label>Provinsi</label>
      <select v-model="selectedProvince" @change="onProvinceChange">
        <option value="">Pilih Provinsi</option>
        <option v-for="province in provinces" :key="province.id" :value="province.id">
          {{ province.name }}
        </option>
      </select>
    </div>
    
    <div class="form-group" v-if="selectedProvince">
      <label>Kabupaten/Kota</label>
      <select v-model="selectedRegency" @change="onRegencyChange">
        <option value="">Pilih Kabupaten/Kota</option>
        <option v-for="regency in regencies" :key="regency.id" :value="regency.id">
          {{ regency.name }}
        </option>
      </select>
    </div>
    
    <div class="form-group" v-if="selectedRegency">
      <label>Kecamatan</label>
      <select v-model="selectedDistrict" @change="onDistrictChange">
        <option value="">Pilih Kecamatan</option>
        <option v-for="district in districts" :key="district.id" :value="district.id">
          {{ district.name }}
        </option>
      </select>
    </div>
    
    <div class="form-group" v-if="selectedDistrict">
      <label>Kelurahan/Desa</label>
      <select v-model="selectedVillage">
        <option value="">Pilih Kelurahan/Desa</option>
        <option v-for="village in villages" :key="village.id" :value="village.id">
          {{ village.name }}
        </option>
      </select>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      provinces: [],
      regencies: [],
      districts: [],
      villages: [],
      selectedProvince: '',
      selectedRegency: '',
      selectedDistrict: '',
      selectedVillage: ''
    };
  },
  async mounted() {
    // Load provinces on component mount
    this.provinces = await this.getProvinces();
  },
  methods: {
    async getProvinces() {
      try {
        const response = await axios.get('https://wilayah.partaiprima.id/provinsi.json');
        return response.data;
      } catch (error) {
        console.error('Error fetching provinces:', error);
        return [];
      }
    },
    async onProvinceChange() {
      this.selectedRegency = '';
      this.selectedDistrict = '';
      this.selectedVillage = '';
      this.regencies = [];
      this.districts = [];
      this.villages = [];
      
      if (this.selectedProvince) {
        try {
          const response = await axios.get(`https://wilayah.partaiprima.id/regencies/${this.selectedProvince}.json`);
          this.regencies = response.data;
        } catch (error) {
          console.error(`Error fetching regencies for province ${this.selectedProvince}:`, error);
        }
      }
    },
    async onRegencyChange() {
      this.selectedDistrict = '';
      this.selectedVillage = '';
      this.districts = [];
      this.villages = [];
      
      if (this.selectedRegency) {
        try {
          const response = await axios.get(`https://wilayah.partaiprima.id/districts/${this.selectedRegency}.json`);
          this.districts = response.data;
        } catch (error) {
          console.error(`Error fetching districts for regency ${this.selectedRegency}:`, error);
        }
      }
    },
    async onDistrictChange() {
      this.selectedVillage = '';
      this.villages = [];
      
      if (this.selectedDistrict) {
        try {
          const response = await axios.get(`https://wilayah.partaiprima.id/villages/${this.selectedDistrict}.json`);
          this.villages = response.data;
        } catch (error) {
          console.error(`Error fetching villages for district ${this.selectedDistrict}:`, error);
        }
      }
    }
  }
};
</script>
```

## Catatan Penting

- API ini menyediakan data wilayah administratif Indonesia yang dapat digunakan untuk berbagai keperluan dalam aplikasi.
- Format ID wilayah mengikuti standar kode wilayah dari Kemendagri, yang memudahkan integrasi dengan sistem lain.
- Pastikan untuk menangani error dengan baik saat mengakses API ini, terutama jika koneksi internet tidak stabil.
