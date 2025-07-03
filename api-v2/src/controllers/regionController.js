import axios from 'axios';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Mendapatkan direktori saat ini
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// URL API Wilayah dari environment variable atau default
const WILAYAH_API_URL = process.env.WILAYAH_API_URL || 'http://localhost:3001';

// Fungsi helper untuk fetch data dari API Wilayah
const fetchFromWilayahApi = async (endpoint) => {
  try {
    const response = await axios.get(`${WILAYAH_API_URL}${endpoint}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching from Wilayah API: ${endpoint}`, error.message);
    throw new Error('Gagal mengambil data wilayah');
  }
};

// Fungsi helper untuk membaca file JSON statis
const readStaticWilayahData = (filename) => {
  try {
    const dataPath = path.join(__dirname, '..', '..', 'data', 'wilayah', filename);
    const data = fs.readFileSync(dataPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`Error reading static wilayah data: ${filename}`, error.message);
    throw new Error('Gagal membaca data wilayah statis');
  }
};

// Get semua provinsi
export const getProvinces = async (req, res) => {
  try {
    // Coba ambil dari API eksternal dulu
    const provinces = await fetchFromWilayahApi('/provinsi.json');
    res.json(provinces);
  } catch (error) {
    // Fallback ke data statis jika API eksternal gagal
    try {
      console.log('Falling back to static data for provinces');
      const provinces = readStaticWilayahData('provinsi.json');
      res.json(provinces);
    } catch (staticError) {
      res.status(500).json({ message: 'Gagal mengambil data provinsi' });
    }
  }
};

// Get kabupaten/kota berdasarkan provinsi
export const getRegencies = async (req, res) => {
  const { provinceId } = req.query;
  if (!provinceId) {
    return res.status(400).json({ message: 'Parameter provinceId diperlukan' });
  }

  try {
    // Coba ambil dari API eksternal dulu
    const regencies = await fetchFromWilayahApi(`/regencies/${provinceId}.json`);
    res.json(regencies);
  } catch (error) {
    // Fallback ke data statis jika API eksternal gagal
    try {
      console.log(`Falling back to static data for regencies of province ${provinceId}`);
      const regencies = readStaticWilayahData(`regencies-${provinceId}.json`);
      res.json(regencies);
    } catch (staticError) {
      res.status(500).json({ message: 'Gagal mengambil data kabupaten/kota' });
    }
  }
};

// Get kecamatan berdasarkan kabupaten/kota
export const getDistricts = async (req, res) => {
  const { regencyId } = req.query;
  if (!regencyId) {
    return res.status(400).json({ message: 'Parameter regencyId diperlukan' });
  }

  try {
    // Coba ambil dari API eksternal dulu
    const districts = await fetchFromWilayahApi(`/districts/${regencyId}.json`);
    res.json(districts);
  } catch (error) {
    // Fallback ke data statis jika API eksternal gagal
    try {
      console.log(`Falling back to static data for districts of regency ${regencyId}`);
      const districts = readStaticWilayahData(`districts-${regencyId}.json`);
      res.json(districts);
    } catch (staticError) {
      res.status(500).json({ message: 'Gagal mengambil data kecamatan' });
    }
  }
};

// Get kelurahan/desa berdasarkan kecamatan
export const getVillages = async (req, res) => {
  const { districtId } = req.query;
  if (!districtId) {
    return res.status(400).json({ message: 'Parameter districtId diperlukan' });
  }

  try {
    // Coba ambil dari API eksternal dulu
    const villages = await fetchFromWilayahApi(`/villages/${districtId}.json`);
    res.json(villages);
  } catch (error) {
    // Fallback ke data statis jika API eksternal gagal
    try {
      console.log(`Falling back to static data for villages of district ${districtId}`);
      const villages = readStaticWilayahData(`villages-${districtId}.json`);
      res.json(villages);
    } catch (staticError) {
      res.status(500).json({ message: 'Gagal mengambil data kelurahan/desa' });
    }
  }
};

// Search region name (provinsi) simple contains query param
export const searchRegions = async (req, res) => {
  const { query } = req.query;
  if (!query || query.length < 2) {
    return res.json([]);
  }
  try {
    const provinces = await fetchFromWilayahApi('/provinsi.json');
    const result = provinces.filter(p => p.name.toLowerCase().includes(query.toLowerCase()));
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
