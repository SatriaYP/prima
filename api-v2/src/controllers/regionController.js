import axios from 'axios';

// URL API Wilayah dari environment variable atau default
const WILAYAH_API_URL = process.env.WILAYAH_API_URL || 'https://wilayah.partaiprima.id';

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

// Get semua provinsi
export const getProvinces = async (req, res) => {
  try {
    const provinces = await fetchFromWilayahApi('/provinsi.json');
    res.json(provinces);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get kabupaten/kota berdasarkan provinsi
export const getRegencies = async (req, res) => {
  const { provinceId } = req.query;
  if (!provinceId) {
    return res.status(400).json({ message: 'Parameter provinceId diperlukan' });
  }

  try {
    const regencies = await fetchFromWilayahApi(`/regencies/${provinceId}.json`);
    res.json(regencies);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get kecamatan berdasarkan kabupaten/kota
export const getDistricts = async (req, res) => {
  const { regencyId } = req.query;
  if (!regencyId) {
    return res.status(400).json({ message: 'Parameter regencyId diperlukan' });
  }

  try {
    const districts = await fetchFromWilayahApi(`/districts/${regencyId}.json`);
    res.json(districts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get kelurahan/desa berdasarkan kecamatan
export const getVillages = async (req, res) => {
  const { districtId } = req.query;
  if (!districtId) {
    return res.status(400).json({ message: 'Parameter districtId diperlukan' });
  }

  try {
    const villages = await fetchFromWilayahApi(`/villages/${districtId}.json`);
    res.json(villages);
  } catch (error) {
    res.status(500).json({ message: error.message });
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
