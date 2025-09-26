import Handlebars from 'handlebars'; // ✅ Import default
import fs from 'fs/promises';
import path from 'path';
import { PDFDocument } from 'pdf-lib'; // Pastikan sudah install pdf-lib

export async function generateSuratPDF(jenisSurat, data) {
    try {
        // 🔍 LOG UNTUK DEBUG
        console.log('🔧 [PDF Generator] jenisSurat:', jenisSurat);

        const templatePath = path.join(
            process.cwd(),
            'src',
            'modules',
            'secrecy',
            'templates',
            `${jenisSurat}.hbs`
        );

        console.log('📄 Path template yang dicari:', templatePath);

        let source;
        try {
            source = await fs.readFile(templatePath, 'utf8');
            console.log('✅ Template berhasil dibaca');
        } catch (err) {
            console.error('❌ Gagal baca template:', err.message);
            throw new Error(`Template ${jenisSurat} tidak ditemukan atau gagal dibaca.`);
        }
        // Buat Handlebars compiler
        const template = Handlebars.compile(source); // ✅ Gunakan compile(), bukan create()

        // Render HTML dengan data
        const html = template(data);

        // Konversi HTML ke PDF (minimalis)
        const pdfDoc = await PDFDocument.create();
        const page = pdfDoc.addPage([595, 842]); // A4 size
        const fontSize = 12;

        // ⚠️ pdf-lib TIDAK bisa render HTML langsung.
        // Jadi kita tulis teks sederhana sebagai contoh dasar
        page.drawText(html.replace(/<[^>]+>/g, '').slice(0, 500), {
            x: 50,
            y: 750,
            size: fontSize,
            maxWidth: 500,
            lineHeight: fontSize * 1.5,
        });

        // Simpan PDF
        const pdfBytes = await pdfDoc.save();

        return pdfBytes;
    } catch (err) {
        console.error("Gagal generate PDF:", err);
        throw new Error(`Template ${jenisSurat} tidak ditemukan atau gagal dibaca.`);
    }
}