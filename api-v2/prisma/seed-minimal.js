import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');
  
  // Create admin user
  const password = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
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

  console.log('✅ Admin user created:', admin.username);
  console.log('🔑 Login credentials: admin / admin123');
}

main()
  .then(() => {
    console.log('🎉 Database seeded successfully!');
    return prisma.$disconnect();
  })
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  }); 