import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export async function getMembers(req, res, next) {
  try {
    const members = await prisma.member.findMany();
    res.json(members);
  } catch (err) {
    next(err);
  }
}

export async function getMember(req, res, next) {
  try {
    const member = await prisma.member.findUnique({ where: { id: req.params.id } });
    if (!member) return res.status(404).json({ message: 'Anggota tidak ditemukan' });
    res.json(member);
  } catch (err) {
    next(err);
  }
}

export async function createMember(req, res, next) {
  try {
    const member = await prisma.member.create({ data: req.body });
    res.status(201).json(member);
  } catch (err) {
    next(err);
  }
}

export async function updateMember(req, res, next) {
  try {
    const member = await prisma.member.update({ where: { id: req.params.id }, data: req.body });
    res.json(member);
  } catch (err) {
    next(err);
  }
}

export async function deleteMember(req, res, next) {
  try {
    await prisma.member.delete({ where: { id: req.params.id } });
    res.json({ message: 'Anggota dihapus' });
  } catch (err) {
    next(err);
  }
}
// Fungsi baru untuk memeriksa keunikan NIK
export async function checkNikUniqueness(req, res, next) {
  try {
    const { nik } = req.query;

    // Validasi: Pastikan NIK disediakan
    if (!nik) {
      return res.status(400).json({
        error: 'Parameter NIK wajib diisi'
      });
    }

    // Validasi: Pastikan NIK adalah string 16 digit
    if (typeof nik !== 'string' || nik.length !== 16 || !/^\d{16}$/.test(nik)) {
      return res.status(400).json({
        error: 'NIK harus terdiri dari 16 digit angka'
      });
    }

    // Cek ke database apakah NIK sudah ada
    const existingMember = await prisma.member.findUnique({
      where: {
        nik: nik
      }
    });

    // Kirim respons
    res.json({
      exists: !!existingMember, // true jika ditemukan, false jika unik
      message: existingMember
        ? 'NIK sudah terdaftar di sistem'
        : 'NIK tersedia untuk digunakan'
    });

  } catch (error) {
    console.error('Error checking NIK uniqueness:', error);
    next(error); // Gunakan error handler global
  }
}