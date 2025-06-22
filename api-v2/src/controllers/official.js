import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export async function getOfficials(req, res, next) {
  try {
    const officials = await prisma.official.findMany();
    res.json(officials);
  } catch (err) {
    next(err);
  }
}

export async function getOfficial(req, res, next) {
  try {
    const official = await prisma.official.findUnique({ where: { id: req.params.id } });
    if (!official) return res.status(404).json({ message: 'Pengurus tidak ditemukan' });
    res.json(official);
  } catch (err) {
    next(err);
  }
}

export async function createOfficial(req, res, next) {
  try {
    const official = await prisma.official.create({ data: req.body });
    res.status(201).json(official);
  } catch (err) {
    next(err);
  }
}

export async function updateOfficial(req, res, next) {
  try {
    const official = await prisma.official.update({ where: { id: req.params.id }, data: req.body });
    res.json(official);
  } catch (err) {
    next(err);
  }
}

export async function deleteOfficial(req, res, next) {
  try {
    await prisma.official.delete({ where: { id: req.params.id } });
    res.json({ message: 'Pengurus dihapus' });
  } catch (err) {
    next(err);
  }
}
