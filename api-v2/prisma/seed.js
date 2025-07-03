import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('admin123', 10);
  await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      password,
      role: 'admin',
      name: 'Administrator',
      level: 'dpp',
    },
  });

  await prisma.member.create({
    data: {
      name: 'Budi Santoso',
      email: 'budi@example.com',
      ktp: '1234567890',
      address: 'Jl. Merdeka 1',
      phone: '081234567890',
    },
  });
  await prisma.member.create({
    data: {
      name: 'Siti Aminah',
      email: 'siti@example.com',
      ktp: '9876543210',
      address: 'Jl. Pahlawan 2',
      phone: '081298765432',
    },
  });

  await prisma.official.create({
    data: {
      name: 'Agus Setiawan',
      position: 'Ketua',
      region: 'DKI Jakarta',
      email: 'agus@prima.id',
      phone: '081211112222',
    },
  });
  await prisma.official.create({
    data: {
      name: 'Rina Dewi',
      position: 'Sekretaris',
      region: 'Jawa Barat',
      email: 'rina@prima.id',
      phone: '081233344455',
    },
  });
}

main()
  .then(() => {
    console.log('Database seeded!');
    return prisma.$disconnect();
  })
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
