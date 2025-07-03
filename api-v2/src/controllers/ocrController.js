import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { v4 as uuidv4 } from 'uuid';

// Mendapatkan direktori saat ini
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// URL API OCR dari environment variable
const OCR_API_URL = process.env.OCR_API_URL || 'http://localhost:9000';
const OCR_API_KEY = process.env.OCR_API_KEY;

// Memastikan API key tersedia
if (!OCR_API_KEY) {
  console.error('WARNING: OCR_API_KEY tidak ditemukan di environment variables!');
}

/**
 * Generate base URL berdasarkan environment
 * @param {Object} req - Request object
 * @returns {string} Base URL
 */
const generateBaseUrl = (req) => {
  const hostname = req.get('host');
  
  if (hostname.includes('localhost') || hostname.includes('127.0.0.1')) {
    return `${req.protocol}://${hostname}`;
  } else if (hostname.includes('staging')) {
    return `https://web-staging.partaiprima.id`;
  } else if (hostname.includes('partaiprima.id')) {
    return `https://web.partaiprima.id`;
  } else {
    return `${req.protocol}://${hostname}`;
  }
};

/**
 * Memproses gambar KTP menggunakan API OCR eksternal
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 */
export const processKtp = async (req, res) => {
  try {
    // Pastikan ada file yang diunggah
    if (!req.file) {
      console.log('Error: Tidak ada file yang diunggah');
      return res.status(400).json({ 
        success: false, 
        message: 'Tidak ada file yang diunggah' 
      });
    }

    console.log('File diterima:', req.file);
    console.log('File path:', req.file.path);
    console.log('File size:', req.file.size);
    console.log('File mimetype:', req.file.mimetype);

    // Pastikan file ada dan dapat diakses
    try {
      const stats = fs.statSync(req.file.path);
      console.log('File stats:', stats);
    } catch (fsError) {
      console.error('Error mengakses file:', fsError);
      return res.status(500).json({
        success: false,
        message: 'Error mengakses file upload',
        error: fsError.message
      });
    }

    // Buat form data untuk dikirim ke API OCR
    const formData = new FormData();
    
    // Baca file sebagai buffer
    const fileBuffer = fs.readFileSync(req.file.path);
    
    // Pastikan nama field adalah 'image' sesuai yang diharapkan API OCR eksternal
    formData.append('image', fileBuffer, {
      filename: req.file.originalname || 'ktp.jpg',
      contentType: req.file.mimetype || 'image/jpeg'
    });
    
    console.log('OCR API URL:', OCR_API_URL);
    console.log('OCR API Key tersedia:', !!OCR_API_KEY);
    console.log('Headers:', formData.getHeaders());
    console.log('File buffer size:', fileBuffer.length);
    console.log('File name:', req.file.originalname || 'ktp.jpg');
    console.log('File mimetype:', req.file.mimetype || 'image/jpeg');

    // Kirim request ke API OCR eksternal
    console.log('Mengirim request ke API OCR...');
    const response = await axios.post(`${OCR_API_URL}/process/file`, formData, {
      headers: {
        'X-API-Key': OCR_API_KEY,
        ...formData.getHeaders()
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity
    });

    console.log('Response dari API OCR:', response.status);
    console.log('Response data:', JSON.stringify(response.data).substring(0, 200) + '...');

    // Hapus file temporary setelah diproses
    fs.unlink(req.file.path, (err) => {
      if (err) console.error('Error menghapus file temporary:', err);
    });

    // Kembalikan hasil OCR ke frontend
    let ocrData = response.data;
    if (ocrData.enhanced_image) {
      try {
        const processedDir = path.join(process.cwd(), 'public', 'processed');
        fs.mkdirSync(processedDir, { recursive: true });
        const fileName = `ktp-${uuidv4()}.jpg`;
        const outPath = path.join(processedDir, fileName);
        fs.writeFileSync(outPath, Buffer.from(ocrData.enhanced_image, 'base64'));
        const baseUrl = generateBaseUrl(req);
        ocrData.processed_image_url = `${baseUrl}/api/static/processed/${fileName}`;
        console.log('Enhanced image saved to:', outPath);
        console.log('Generated processed_image_url:', ocrData.processed_image_url);
      } catch (errSave) {
        console.error('Gagal menyimpan enhanced image:', errSave);
      }
    }
    return res.json(ocrData);
  } catch (error) {
    console.error('Error memproses KTP:', error.message);
    console.error('Error detail:', error);
    
    if (error.response) {
      console.error('Error response status:', error.response.status);
      console.error('Error response data:', error.response.data);
    }
    
    // Hapus file temporary jika terjadi error
    if (req.file) {
      fs.unlink(req.file.path, (err) => {
        if (err) console.error('Error menghapus file temporary:', err);
      });
    }

    // Kembalikan pesan error yang sesuai
    return res.status(500).json({
      success: false,
      message: 'Gagal memproses KTP',
      error: error.response?.data?.message || error.message
    });
  }
};

/**
 * Memproses gambar KTP dalam format base64 menggunakan API OCR eksternal
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 */
export const processKtpBase64 = async (req, res) => {
  try {
    // Pastikan ada data base64 yang dikirim
    if (!req.body.image_base64) {
      return res.status(400).json({ 
        success: false, 
        message: 'Data gambar base64 tidak ditemukan' 
      });
    }

    // Kirim request ke API OCR eksternal
    const response = await axios.post(`${OCR_API_URL}/process/base64`, {
      image_base64: req.body.image_base64
    }, {
      headers: {
        'X-API-Key': OCR_API_KEY,
        'Content-Type': 'application/json'
      }
    });

    // Kembalikan hasil OCR ke frontend
    let ocrData = response.data;
    if (ocrData.enhanced_image) {
      try {
        const processedDir = path.join(process.cwd(), 'public', 'processed');
        fs.mkdirSync(processedDir, { recursive: true });
        const fileName = `ktp-${uuidv4()}.jpg`;
        const outPath = path.join(processedDir, fileName);
        fs.writeFileSync(outPath, Buffer.from(ocrData.enhanced_image, 'base64'));
        const baseUrl = generateBaseUrl(req);
        ocrData.processed_image_url = `${baseUrl}/api/static/processed/${fileName}`;
        console.log('Enhanced image saved to:', outPath);
        console.log('Generated processed_image_url:', ocrData.processed_image_url);
      } catch (errSave) {
        console.error('Gagal menyimpan enhanced image:', errSave);
      }
    }
    return res.json(ocrData);
  } catch (error) {
    console.error('Error memproses KTP base64:', error.message);
    
    // Kembalikan pesan error yang sesuai
    return res.status(500).json({
      success: false,
      message: 'Gagal memproses KTP',
      error: error.response?.data?.message || error.message
    });
  }
};
