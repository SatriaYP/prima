import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Mendapatkan direktori saat ini
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// URL API OCR dari environment variable
const OCR_API_URL = process.env.OCR_API_URL || 'https://ocr.partaiprima.id';
const OCR_API_KEY = process.env.OCR_API_KEY;

// Memastikan API key tersedia
if (!OCR_API_KEY) {
  console.error('WARNING: OCR_API_KEY tidak ditemukan di environment variables!');
}

/**
 * Memproses gambar KTP menggunakan API OCR eksternal
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 */
export const processKtp = async (req, res) => {
  try {
    // Pastikan ada file yang diunggah
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'Tidak ada file yang diunggah' 
      });
    }

    // Buat form data untuk dikirim ke API OCR
    const formData = new FormData();
    formData.append('file', fs.createReadStream(req.file.path));

    // Kirim request ke API OCR eksternal
    const response = await axios.post(`${OCR_API_URL}/process/file`, formData, {
      headers: {
        'X-API-Key': OCR_API_KEY,
        ...formData.getHeaders()
      }
    });

    // Hapus file temporary setelah diproses
    fs.unlink(req.file.path, (err) => {
      if (err) console.error('Error menghapus file temporary:', err);
    });

    // Kembalikan hasil OCR ke frontend
    return res.json(response.data);
  } catch (error) {
    console.error('Error memproses KTP:', error.message);
    
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
    return res.json(response.data);
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
