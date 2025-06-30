# Software Requirements Specification (SRS)
# Aplikasi Database Keanggotaan PRIMA

## 1. Pendahuluan

### 1.1 Tujuan Dokumen
Dokumen Software Requirements Specification (SRS) ini menjelaskan secara detail spesifikasi teknis untuk pengembangan Aplikasi Database Keanggotaan PRIMA.

### 1.2 Ruang Lingkup
Dokumen ini mencakup kebutuhan fungsional dan non-fungsional sistem, alur kerja, arsitektur teknis, dan integrasi teknologi untuk mengimplementasikan Aplikasi Database Keanggotaan PRIMA.

### 1.3 Definisi dan Singkatan
- **PRIMA**: Partai politik yang menggunakan sistem ini
- **DPP**: Dewan Pimpinan Pusat
- **DPW**: Dewan Pimpinan Wilayah (tingkat Provinsi)
- **DPK**: Dewan Pimpinan Kabupaten/Kota
- **KTA**: Kartu Tanda Anggota
- **NIK**: Nomor Induk Kependudukan
- **OCR**: Optical Character Recognition
- **LO**: Liaison Officer
- **REST API**: Representational State Transfer Application Programming Interface

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
Aplikasi Database Keanggotaan PRIMA merupakan sistem manajemen keanggotaan berbasis web dan mobile yang terintegrasi dengan database pusat. Sistem ini akan menggantikan proses manual yang ada dengan solusi digital yang efisien dan terstruktur.

### 2.2 Fungsi Produk
1. Manajemen akun pengurus partai berdasarkan tingkatan
2. Pendaftaran anggota baru (oleh admin/operator atau mandiri)
3. Validasi data NIK dan KTP
4. Penerbitan otomatis KTA digital
5. Pencarian dan filtering data anggota
6. Pengunduhan KTA individu atau batch
7. Visualisasi dan analitik data keanggotaan
8. Manajemen LO untuk pendaftaran mandiri

### 2.3 Karakteristik Pengguna
1. **Admin Tingkat Pusat (DPP)**: Pengalaman tinggi dengan teknologi, frekuensi penggunaan tinggi
2. **Admin/Operator Tingkat Wilayah (DPW)**: Pengalaman menengah, frekuensi penggunaan menengah hingga tinggi
3. **Admin/Operator Tingkat Kabupaten (DPK)**: Pengalaman bervariasi, frekuensi penggunaan menengah
4. **Anggota Partai**: Pengalaman teknologi bervariasi, frekuensi penggunaan rendah (umumnya hanya untuk pendaftaran)

### 2.4 Batasan
1. Sistem harus dapat diakses baik melalui web browser maupun aplikasi mobile
2. Validasi NIK memerlukan integrasi dengan database kependudukan atau metode verifikasi lainnya
3. Pemrosesan gambar KTP memerlukan teknologi OCR yang akurat
4. Penyimpanan data harus mematuhi regulasi perlindungan data yang berlaku
5. Koneksi internet diperlukan untuk semua operasi kecuali beberapa fungsi dasar di aplikasi mobile yang dapat bekerja secara offline

## 3. Kebutuhan Spesifik

### 3.1 Kebutuhan Antarmuka Eksternal

#### 3.1.1 Antarmuka Pengguna
1. **Web Interface**
   - Dashboard admin yang responsif untuk semua ukuran layar
   - Form pendaftaran anggota dengan validasi real-time
   - Tabel data anggota dengan sorting, filtering, dan pagination
   - Preview dan unduh KTA
   - Visualisasi data dan infografis

2. **Mobile Interface**
   - Login dan autentikasi
   - Form pendaftaran dengan akses kamera untuk foto KTP
   - Pencarian data anggota (sesuai tingkat akses)
   - Preview dan download KTA
   - Notifikasi status pendaftaran

#### 3.1.2 Antarmuka Hardware
1. Akses kamera untuk pengambilan foto KTP
2. Printer untuk mencetak KTA (opsional)
3. Scanner barcode (opsional, untuk verifikasi KTA)

#### 3.1.3 Antarmuka Software
1. API untuk integrasi dengan database kependudukan (opsional)
2. API untuk layanan OCR
3. API untuk integrasi dengan WhatsApp/SMS untuk verifikasi
4. API untuk sistem ekspor data ke format Excel/PDF

#### 3.1.4 Antarmuka Komunikasi
1. HTTPS untuk semua komunikasi server-client
2. WebSocket untuk notifikasi real-time
3. REST API untuk komunikasi antar layanan

### 3.2 Kebutuhan Fungsional

#### 3.2.1 Manajemen Akun dan Autentikasi
1. **F1.1 Registrasi Akun Admin/Operator**
   - Input: Data admin/operator (nama, email, password, tingkat akses, wilayah)
   - Proses: Verifikasi data, pembuatan akun, notifikasi ke admin tingkat atas
   - Output: Akun pending approval

2. **F1.2 Persetujuan Akun**
   - Input: Daftar akun pending approval
   - Proses: Review oleh admin tingkat atas, persetujuan/penolakan
   - Output: Akun aktif/ditolak dengan pemberitahuan

3. **F1.3 Login**
   - Input: Email/username dan password
   - Proses: Autentikasi dua faktor (opsional)
   - Output: Akses ke dashboard sesuai hak akses

4. **F1.4 Manajemen Hak Akses**
   - Input: Akun dan level akses yang dipilih
   - Proses: Update hak akses di database
   - Output: Hak akses terupdate dengan notifikasi

#### 3.2.2 Pendaftaran Anggota
1. **F2.1 Pendaftaran Single via Admin/Operator**
   - Input: Data anggota (NIK, nama, alamat, dll.), foto KTP
   - Proses: Validasi data, OCR KTP, penerbitan nomor KTA
   - Output: Anggota terdaftar dengan KTA

2. **F2.2 Pendaftaran Batch via Excel**
   - Input: File Excel dengan format template yang ditentukan
   - Proses: Validasi batch, pemrosesan data, penerbitan nomor KTA
   - Output: Report sukses/gagal, data anggota terdaftar

3. **F2.3 Pendaftaran Mandiri**
   - Input: Link pendaftaran, data diri, foto KTP
   - Proses: Validasi NIK, verifikasi via WA/SMS, pemrosesan KTP
   - Output: Anggota terdaftar dengan KTA digital, kontak LO

#### 3.2.3 Manajemen Data Anggota
1. **F3.1 Pencarian dan Filter**
   - Input: Kata kunci, filter wilayah, parameter lainnya
   - Proses: Query database sesuai parameter
   - Output: Daftar anggota yang sesuai kriteria

2. **F3.2 Edit Data Anggota**
   - Input: ID anggota, data yang diubah
   - Proses: Validasi perubahan, update database
   - Output: Data anggota terupdate

3. **F3.3 Hapus Anggota**
   - Input: ID anggota atau batch anggota
   - Proses: Validasi status kepengurusan, konfirmasi penghapusan
   - Output: Anggota terhapus/notifikasi gagal hapus

#### 3.2.4 Kartu Tanda Anggota (KTA)
1. **F4.1 Penerbitan KTA**
   - Input: Data anggota tervalidasi
   - Proses: Generasi nomor KTA unik, render template KTA
   - Output: File KTA digital

2. **F4.2 Download KTA**
   - Input: ID anggota atau batch anggota
   - Proses: Generasi file PDF yang berisi KTA dan KTP
   - Output: File PDF KTA siap unduh

#### 3.2.5 Analitik dan Pelaporan
1. **F5.1 Dashboard Statistik**
   - Input: Parameter filter (wilayah, periode)
   - Proses: Agregasi data anggota
   - Output: Visualisasi statistik (grafik, chart)

2. **F5.2 Laporan Keanggotaan**
   - Input: Parameter laporan (format, filter)
   - Proses: Generasi laporan sesuai parameter
   - Output: File laporan (PDF/Excel)

### 3.3 Kebutuhan Non-Fungsional

#### 3.3.1 Keamanan
1. **NF1.1 Enkripsi Data**
   - Semua data sensitif harus dienkripsi saat disimpan (at rest)
   - Semua komunikasi harus menggunakan HTTPS (in transit)

2. **NF1.2 Autentikasi**
   - Password harus memenuhi kebijakan kompleksitas
   - Opsi autentikasi dua faktor untuk semua akun admin

3. **NF1.3 Otorisasi**
   - Batasan akses berdasarkan tingkat dan wilayah
   - Log audit untuk semua tindakan sensitif

#### 3.3.2 Performa
1. **NF2.1 Waktu Respon**
   - Operasi umum harus selesai dalam 3 detik
   - Pendaftaran batch harus diproses maksimal 100 entri per menit

2. **NF2.2 Skalabilitas**
   - Sistem harus mendukung 10,000 pendaftaran serentak
   - Database harus optimal untuk menyimpan 10 juta anggota

#### 3.3.3 Keandalan
1. **NF3.1 Ketersediaan**
   - Uptime 99.9% dengan maksimal 4 jam downtime terencana per bulan
   - Pemulihan bencana dengan RTO < 4 jam dan RPO < 1 jam

2. **NF3.2 Backup**
   - Backup inkremental harian
   - Backup penuh mingguan dengan retensi 1 bulan

#### 3.3.4 Penggunaan
1. **NF4.1 Usabilitas**
   - Antarmuka intuitif yang sesuai dengan pengalaman pengguna
   - Bantuan kontekstual untuk fungsi kompleks

2. **NF4.2 Aksesibilitas**
   - Mendukung pembaca layar untuk aksesibilitas
   - Komponen UI harus memenuhi standar WCAG 2.1 level AA

## 4. Arsitektur Sistem

### 4.1 Diagram Arsitektur
[Diagram arsitektur akan ditambahkan]

### 4.2 Komponen Sistem
1. **Frontend**
   - Web client (React/Vue.js)
   - Mobile client (React Native/Flutter)

2. **Backend**
   - REST API server (Node.js/Express)
   - Authentication service
   - OCR & Image Processing service
   - Notification service

3. **Database**
   - Primary DB (PostgreSQL)
   - Cache (Redis)
   - File storage (S3 compatible)

4. **Infrastruktur**
   - Load balancer
   - CDN untuk aset statis
   - Service monitoring

### 4.3 Alur Data Utama
1. **Pendaftaran Anggota**
   - User input → Validasi frontend → API → Validasi backend → OCR → Database
   - Response: Database → API → Rendering KTA → Frontend

2. **Pencarian & Filter**
   - Query parameters → API → Database query → Pagination processing → Frontend display

3. **Download KTA Batch**
   - Selection → API → Database fetch → PDF generation → File storage → Download link

## 5. Spesifikasi Teknis

### 5.1 Model Data
1. **Tabel User (Akun)**
   - id, username, password_hash, email, role, level, region_id, status, created_by

2. **Tabel Member (Anggota)**
   - id, nik, name, gender, phone, address, village_id, district_id, city_id, province_id, 
     marital_status, occupation, kta_number, photo_url, ktp_url, registration_date, 
     registration_type, registered_by

3. **Tabel Region (Wilayah)**
   - id, name, level (province/city/district/village), parent_id, kemendagri_code

4. **Tabel LO (Liaison Officer)**
   - id, name, phone, region_id, status

### 5.2 API Endpoints
1. **Autentikasi**
   - POST /api/auth/login
   - POST /api/auth/logout
   - POST /api/auth/register

2. **Manajemen User**
   - GET /api/users
   - POST /api/users
   - PUT /api/users/:id
   - DELETE /api/users/:id
   - PUT /api/users/:id/approve

3. **Manajemen Anggota**
   - GET /api/members
   - GET /api/members/:id
   - POST /api/members
   - PUT /api/members/:id
   - DELETE /api/members/:id
   - POST /api/members/batch
   - DELETE /api/members/batch

4. **KTA & Dokumen**
   - GET /api/members/:id/kta
   - GET /api/kta/batch
   - POST /api/ocr/ktp

5. **Wilayah**
   - GET /api/regions/provinces
   - GET /api/regions/cities/:provinceId
   - GET /api/regions/districts/:cityId
   - GET /api/regions/villages/:districtId

6. **Analitik**
   - GET /api/analytics/gender
   - GET /api/analytics/region
   - GET /api/analytics/growth

### 5.3 Teknologi & Framework
1. **Frontend**
   - React.js / Vue.js
   - Material UI / Tailwind CSS
   - Chart.js / D3.js untuk visualisasi

2. **Backend**
   - Node.js dengan Express.js
   - Prisma/TypeORM untuk ORM
   - JWT untuk autentikasi
   - Multer untuk upload file
   - Tesseract.js / Cloud Vision API untuk OCR
   - PDFKit untuk generasi PDF

3. **Database**
   - PostgreSQL
   - Redis untuk caching

4. **DevOps & Infra**
   - Docker
   - CI/CD via GitHub Actions / GitLab CI
   - AWS / GCP / Azure untuk hosting

## 6. Implementation Guidelines

### 6.1 Validasi NIK
- Validasi format 16 digit
- Validasi kode wilayah sesuai Kemendagri
- Validasi tanggal lahir dalam NIK (digit ke-7 sampai 12)

### 6.2 Generasi Nomor KTA
- Format: `[2 digit kode provinsi][2 digit kode kab/kota][2 digit kode kecamatan][4 digit nomor urut]`
- Nomor urut dimulai dari 0001 untuk setiap kecamatan
- Auto-increment untuk setiap pendaftaran baru

### 6.3 Pemrosesan Gambar KTP
- Deteksi tepi KTP
- Cropping otomatis untuk fokus pada area KTP
- Peningkatan kontras dan kualitas gambar
- OCR untuk ekstrak data NIK, nama, alamat, dll

### 6.4 Keamanan
- Sanitasi semua input user
- Rate limiting untuk API endpoints
- CSRF protection
- Validasi file upload (tipe, ukuran, konten)

## 7. Pengujian

### 7.1 Strategi Pengujian
1. Unit testing untuk komponen dan fungsi inti
2. Integration testing untuk alur kerja utama
3. Performance testing untuk fungsi batch dan concurrent users
4. Security testing dengan penetration testing
5. UI/UX testing dengan user acceptance testing

### 7.2 Test Cases
[Akan dikembangkan dalam dokumen terpisah]

## 8. Implementasi dan Timeline

### 8.1 Phased Release
1. **Phase 1: Core System (3 bulan)**
   - Manajemen akun
   - Pendaftaran anggota basic
   - View & search data anggota
   - KTA generation

2. **Phase 2: Enhanced Features (2 bulan)**
   - OCR KTP
   - Pendaftaran mandiri
   - Batch processing
   - Analitik dasar

3. **Phase 3: Analytics & Optimization (2 bulan)**
   - Dashboard analitik lengkap
   - Performance optimization
   - Mobile app
   - Integrasi sistem eksternal

### 8.2 Requirements Prioritization
1. **Must Have (P0)**
   - Manajemen akun dan hak akses
   - Pendaftaran anggota
   - Generasi KTA
   - Search & filter dasar

2. **Should Have (P1)**
   - OCR KTP
   - Batch processing
   - Basic analytics

3. **Nice to Have (P2)**
   - Advanced analytics
   - Mobile app
   - Export/import beragam format
   - Integrasi sistem lain

## 9. Lampiran
- Contoh format KTA
- Template Excel untuk batch import
- Wireframes UI/UX
- Diagram alur pendaftaran
