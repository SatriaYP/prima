import { PrismaClient } from '@prisma/client';
import { performance } from 'perf_hooks';

const prisma = new PrismaClient();

async function testSQLitePerformance() {
  console.log('🚀 Testing SQLite Performance untuk Prima.id\n');

  // Test 1: Insert Performance
  console.log('1. Test Insert Performance:');
  const startInsert = performance.now();
  
  try {
    // Insert 100 members (simulasi batch registration)
    // SQLite tidak support createMany, jadi gunakan individual inserts
    for (let i = 1; i <= 100; i++) {
      await prisma.member.create({
        data: {
          nik: `1234567890${i.toString().padStart(6, '0')}`,
          ktaNumber: `KTA${i.toString().padStart(8, '0')}`,
          name: `Anggota Test ${i}`,
          gender: i % 2 === 0 ? 'Laki-laki' : 'Perempuan',
          email: `anggota${i}@test.com`,
          phone: `0812345678${i.toString().padStart(2, '0')}`,
          address: `Jl. Test No. ${i}`,
          registrationType: 'admin',
          isOfficial: false
        }
      });
    }

    const endInsert = performance.now();
    console.log(`✅ Inserted 100 members in ${((endInsert - startInsert) / 1000).toFixed(2)}s`);
    console.log(`📊 Rate: ${(100 / ((endInsert - startInsert) / 1000)).toFixed(0)} records/second\n`);
  } catch (error) {
    console.log(`❌ Insert failed: ${error.message}\n`);
  }

  // Test 2: Query Performance
  console.log('2. Test Query Performance:');
  const startQuery = performance.now();
  
  try {
    // Search by name (most common query)
    const searchResults = await prisma.member.findMany({
      where: {
        name: {
          contains: 'Test'
        }
      },
      take: 100
    });
    
    const endQuery = performance.now();
    console.log(`✅ Found ${searchResults.length} members in ${((endQuery - startQuery) / 1000).toFixed(2)}s`);
  } catch (error) {
    console.log(`❌ Query failed: ${error.message}`);
  }

  // Test 3: Concurrent Access Simulation
  console.log('\n3. Test Concurrent Access:');
  
  const concurrentQueries = 10;
  const promises = [];
  
  for (let i = 0; i < concurrentQueries; i++) {
    promises.push(
      prisma.member.findMany({
        where: {
          gender: i % 2 === 0 ? 'Laki-laki' : 'Perempuan'
        },
        take: 50
      })
    );
  }

  const startConcurrent = performance.now();
  
  try {
    const results = await Promise.all(promises);
    const endConcurrent = performance.now();
    
    console.log(`✅ ${concurrentQueries} concurrent queries completed in ${((endConcurrent - startConcurrent) / 1000).toFixed(2)}s`);
    console.log(`📊 Average: ${((endConcurrent - startConcurrent) / concurrentQueries / 1000).toFixed(2)}s per query`);
  } catch (error) {
    console.log(`❌ Concurrent test failed: ${error.message}`);
  }

  // Test 4: Database Size
  console.log('\n4. Database Size Analysis:');
  
  try {
    const totalMembers = await prisma.member.count();
    const totalUsers = await prisma.user.count();
    const totalAuditLogs = await prisma.auditLog.count();
    
    console.log(`📊 Total Records:`);
    console.log(`   - Members: ${totalMembers.toLocaleString()}`);
    console.log(`   - Users: ${totalUsers.toLocaleString()}`);
    console.log(`   - Audit Logs: ${totalAuditLogs.toLocaleString()}`);
    
    // Estimate file size (rough calculation)
    const estimatedSizeMB = (totalMembers * 2 + totalUsers * 1 + totalAuditLogs * 1) / 1024;
    console.log(`💾 Estimated DB Size: ${estimatedSizeMB.toFixed(2)} MB`);
  } catch (error) {
    console.log(`❌ Size analysis failed: ${error.message}`);
  }

  await prisma.$disconnect();
}

// Run test
testSQLitePerformance().catch(console.error); 