// src/modules/secrecy/services/surat.service.js
import prisma from "../../../lib/prisma.js";

export async function createSurat(jenisSurat, data) {
    try {
        const surat = await prisma.surat.create({
            data: {
                id: crypto.randomUUID(), // Opsional: jika ingin custom ID
                jenisSurat,
                judul: data.judul,
                isi: data.isi, // Json field
                tanggal: data.tanggal ? new Date(data.tanggal) : new Date(),
                createdBy: data.createdBy || 'Petugas Sekretariat',
            },
        });

        return surat;
    } catch (err) {
        console.error('Gagal membuat surat:', err);
        throw err;
    }
}

export async function getSuratById(id) {
    try {
        return await prisma.surat.findUnique({
            where: { id },
        });
    } catch (err) {
        console.error('Gagal ambil surat:', err);
        throw err;
    }
}