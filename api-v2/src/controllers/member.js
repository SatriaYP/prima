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
