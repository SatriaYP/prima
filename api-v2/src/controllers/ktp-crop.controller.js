const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const docscanner = require('docscanner');

// Setup upload
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads/ktp/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, 'ktp-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
    }
});

const upload = multer({ storage });

// Crop KTP
router.post('/crop', upload.single('image'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No image uploaded' });
    }

    try {
        const imagePath = req.file.path;

        // Gunakan docscanner untuk deteksi dan crop KTP
        const result = await docscanner.scan(imagePath);

        // Simpan hasil crop
        const outputImagePath = imagePath.replace('.jpg', '_cropped.jpg').replace('.png', '_cropped.png');
        await fs.writeFile(outputImagePath, result.image);

        // Hapus file asli (opsional)
        // await fs.unlink(imagePath);

        // Kirim URL file hasil crop
        const imageUrl = `/static/${path.basename(outputImagePath)}`;
        res.json({
            success: true,
            processed_image_url: imageUrl,
            message: 'KTP berhasil diproses'
        });
    } catch (error) {
        console.error('Error processing KTP:', error);
        res.status(500).json({ error: 'Gagal memproses KTP. Pastikan gambar jelas.' });
    }
});

module.exports = router;