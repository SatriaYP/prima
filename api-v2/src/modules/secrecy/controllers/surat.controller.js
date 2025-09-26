// src/modules/secrecy/controllers/surat.controller.js
import { createSurat, getSuratById } from '../services/surat.service.js';
import { generateSuratPDF } from '../utils/generate-pdf.js';
import path from 'path';
import fs from 'fs/promises';
export async function createSuratAndGeneratePDF(req, res) {
    // 🚨 DEBUG: LIHAT APA YANG DITERIMA
    console.log('\n\n=== [BACKEND] Menerima request ===');
    console.log('Request Body:', req.body);

    const { jenisSurat, judul, isi, createdBy } = req.body;

    // Validasi input
    if (!jenisSurat || !judul || !isi) {
        console.log('❌ Validasi gagal: data tidak lengkap');
        return res.status(400).json({
            message: 'Jenis surat, judul, dan isi wajib diisi.',
        });
    }

    try {
        // Coba baca template
        const templatePath = path.join(
            process.cwd(),
            'src',
            'modules',
            'secrecy',
            'templates',
            `${jenisSurat}.hbs`
        );

        console.log('📄 Template Path:', templatePath);
        await fs.access(templatePath);

        // Cek apakah file benar-benar ada
        try {
            await fs.access(templatePath);
            console.log('✅ File template ditemukan!');
        } catch (e) {
            console.log('❌ File template TIDAK ditemukan!');
            return res.status(500).json({
                message: `Template ${jenisSurat}.hbs tidak ditemukan. Pastikan file ada di folder templates.`
            });
        }

        // Render PDF
        const pdfBuffer = await generateSuratPDF(jenisSurat, {
            judul,
            isi: Array.isArray(isi) ? isi : [isi],
            tanggal: new Date().toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric'
            })
        });

        console.log('✅ PDF berhasil digenerate, ukuran:', pdfBuffer.length, 'bytes');

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename="${judul.replace(/\s+/g, '_')}.pdf"`);
        res.send(pdfBuffer);
    } catch (err) {
        console.error('❌ Error saat generate PDF:', err);
        console.error('Stack:', err.stack);

        res.status(500).json({
            message: 'Gagal membuat surat atau PDF.',
            error: err.message,
            stack: err.stack,
        });
    }
}

// ✅ Tidak ada konflik nama — kita gunakan createSurat dari service
export async function saveSurat(req, res) {
    const { jenisSurat, judul, isi, tanggal, createdBy } = req.body;

    if (!jenisSurat || !judul || !isi) {
        return res.status(400).json({ message: 'Data surat tidak lengkap.' });
    }

    try {
        const surat = await createSurat(jenisSurat, { judul, isi, createdBy, tanggal });
        res.status(201).json({
            success: true,
            message: 'Surat berhasil disimpan.',
            surat,
        });
    } catch (err) {
        console.error('Gagal menyimpan surat ke database:', err);
        res.status(500).json({ message: 'Gagal menyimpan surat.' });
    }
}

export async function getSurat(req, res) {
    const { id } = req.params;
    const surat = await getSuratById(id);

    if (!surat) {
        return res.status(404).json({ message: 'Surat tidak ditemukan' });
    }

    res.json(surat);
}