// Test script untuk memverifikasi fungsi OCR
// Jalankan dengan: node test-ocr.js

const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const API_BASE_URL = 'http://localhost:4000/api';

async function testOcrApi() {
  console.log('🧪 Testing OCR API...\n');
  
  try {
    // Test 1: Health check
    console.log('1. Testing health check...');
    try {
      const healthResponse = await axios.get(`${API_BASE_URL}/health`);
      console.log('✅ Health check passed:', healthResponse.data);
    } catch (error) {
      console.log('⚠️  Health check failed (optional):', error.message);
    }
    
    // Test 2: Check if test image exists
    console.log('\n2. Checking test image...');
    const testImagePath = path.join(__dirname, '../api-v2/uploads/temp/ktp01.jpeg');
    if (fs.existsSync(testImagePath)) {
      console.log('✅ Test image found:', testImagePath);
    } else {
      console.log('❌ Test image not found. Please upload a KTP image first.');
      return;
    }
    
    // Test 3: OCR processing
    console.log('\n3. Testing OCR processing...');
    const formData = new FormData();
    formData.append('image', fs.createReadStream(testImagePath));
    
    const ocrResponse = await axios.post(`${API_BASE_URL}/ktp-ocr`, formData, {
      headers: {
        ...formData.getHeaders(),
        'Content-Type': 'multipart/form-data'
      },
      timeout: 120000 // 2 minutes timeout untuk OCR
    });
    
    console.log('✅ OCR processing successful!');
    console.log('Response status:', ocrResponse.status);
    console.log('Response data keys:', Object.keys(ocrResponse.data));
    
    if (ocrResponse.data.success) {
      console.log('✅ OCR success flag is true');
      
      if (ocrResponse.data.data) {
        console.log('✅ OCR data extracted:');
        console.log('  - NIK:', ocrResponse.data.data.nik || 'Not found');
        console.log('  - Nama:', ocrResponse.data.data.nama || 'Not found');
        console.log('  - TTL:', ocrResponse.data.data.ttl || 'Not found');
        console.log('  - Kelamin:', ocrResponse.data.data.kelamin || 'Not found');
      }
      
      if (ocrResponse.data.processed_image_url) {
        console.log('✅ Processed image URL:', ocrResponse.data.processed_image_url);
        
        // Test 4: Check if processed image is accessible
        console.log('\n4. Testing processed image accessibility...');
        try {
          const imageResponse = await axios.get(ocrResponse.data.processed_image_url, {
            responseType: 'arraybuffer',
            timeout: 10000
          });
          console.log('✅ Processed image is accessible!');
          console.log('  - Status:', imageResponse.status);
          console.log('  - Content-Type:', imageResponse.headers['content-type']);
          console.log('  - Size:', imageResponse.data.length, 'bytes');
        } catch (imageError) {
          console.log('❌ Processed image not accessible:', imageError.message);
        }
      } else {
        console.log('❌ No processed_image_url in response');
      }
    } else {
      console.log('❌ OCR success flag is false');
      console.log('Error:', ocrResponse.data.message || 'Unknown error');
    }
    
  } catch (error) {
    console.log('❌ Test failed:', error.message);
    
    if (error.response) {
      console.log('Response status:', error.response.status);
      console.log('Response data:', error.response.data);
    }
  }
}

async function testStaticFileServing() {
  console.log('\n🧪 Testing static file serving...\n');
  
  try {
    // Check if processed directory exists
    const processedDir = path.join(__dirname, '../api-v2/public/processed');
    if (fs.existsSync(processedDir)) {
      console.log('✅ Processed directory exists:', processedDir);
      
      const files = fs.readdirSync(processedDir);
      console.log('📁 Files in processed directory:', files.length);
      
      if (files.length > 0) {
        const testFile = files[0];
        const testUrl = `http://localhost:4000/static/processed/${testFile}`;
        
        console.log('🔗 Testing URL:', testUrl);
        
        try {
          const response = await axios.get(testUrl, {
            responseType: 'arraybuffer',
            timeout: 10000
          });
          console.log('✅ Static file serving works!');
          console.log('  - Status:', response.status);
          console.log('  - Content-Type:', response.headers['content-type']);
          console.log('  - Size:', response.data.length, 'bytes');
        } catch (error) {
          console.log('❌ Static file serving failed:', error.message);
        }
      } else {
        console.log('⚠️  No files in processed directory');
      }
    } else {
      console.log('❌ Processed directory does not exist');
    }
  } catch (error) {
    console.log('❌ Static file test failed:', error.message);
  }
}

async function runTests() {
  console.log('🚀 Starting OCR API Tests\n');
  console.log('=' .repeat(50));
  
  await testOcrApi();
  await testStaticFileServing();
  
  console.log('\n' + '=' .repeat(50));
  console.log('🏁 Tests completed!');
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests().catch(console.error);
}

module.exports = { testOcrApi, testStaticFileServing }; 