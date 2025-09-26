<template>
    <div class="secrecy-container">
        <h2>🔍 Kesekretariatan — Generate Surat Resmi</h2>

        <!-- Pilih Jenis Surat -->
        <div class="form-group">
            <label>Jenis Surat *</label>
            <select v-model="selectedSuratType" @change="resetForm">
                <option value="">-- Pilih Jenis Surat --</option>
                <option value="undangan">Surat Undangan</option>
                <option value="pemberitahuan">Surat Pemberitahuan</option>
                <option value="tugas">Surat Tugas</option>
                <option value="keterangan">Surat Keterangan</option>
            </select>
        </div>

        <!-- 👇 UNTUK DEBUG SAJA — HAPUS SETELAH YAKIN -->
        <!-- <p><strong>Debug:</strong> selectedSuratType = "{{ selectedSuratType }}"</p> -->

        <!-- Form Dinamis Berdasarkan Jenis Surat -->
        <div v-if="selectedSuratType" class="dynamic-form">
            <h4>📝 Input Surat</h4>

            <!-- Judul -->
            <div class="form-group">
                <label>Judul Surat *</label>
                <input v-model="form.judul" placeholder="Contoh: Undangan Rapat Umum" required />
            </div>

            <!-- Isi Surat (dinamis) -->
            <div class="form-group">
                <label>Isi Surat *</label>
                <textarea v-model="form.isi" rows="8" :placeholder="getPlaceholder()" required></textarea>
            </div>

            <!-- Informasi Tambahan (Opsional) -->
            <div class="form-group">
                <label>Tanggal Surat</label>
                <input v-model="form.tanggal" type="date" />
            </div>

            <div class="form-group">
                <label>Dibuat oleh (Nama)</label>
                <input v-model="form.createdBy" placeholder="Nama petugas" />
            </div>

            <!-- Tombol -->
            <div class="form-actions">
                <button class="btn btn-primary" @click="generatePDF" :disabled="loading">
                    📄 Simpan & Generate PDF
                </button>
                <button class="btn btn-secondary" @click="resetForm" :disabled="loading">
                    🔄 Reset Form
                </button>
            </div>
        </div>

        <!-- Tampilkan PDF -->
        <div v-if="pdfUrl" class="pdf-preview">
            <h4>📄 Preview PDF</h4>
            <iframe :src="pdfUrl" width="100%" height="600px" frameborder="0" title="Surat PDF"></iframe>
            <button class="btn btn-success" @click="downloadPDF" style="margin-top: 16px;">
                💾 Download PDF
            </button>
        </div>

        <div v-if="error" class="error-message">
            {{ error }}
        </div>
    </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import api from '@/services/api.service';

// STATE
const selectedSuratType = ref('');
const form = ref({
    judul: '',
    isi: '',
    tanggal: new Date().toISOString().split('T')[0],
    createdBy: '',
});

const pdfUrl = ref('');
const loading = ref(false);
const error = ref('');
const getPlaceholder = () => {
    const map = {
        undangan: 'Isi surat undangan... Contoh: Dengan ini kami mengundang Bapak/Ibu untuk hadir pada rapat rutin...',
        pemberitahuan: 'Isi surat pemberitahuan... Contoh: Dengan ini kami beritahukan bahwa kegiatan akan dilaksanakan pada...',
        tugas: 'Isi surat tugas... Contoh: Dengan ini diberikan tugas kepada Bapak/Ibu untuk mengikuti pelatihan di...',
        keterangan: 'Isi surat keterangan... Contoh: Dengan ini diberikan keterangan bahwa Bapak/Ibu merupakan anggota aktif...',
    };
    return map[selectedSuratType.value] || '';
};
// DEBUG: LOG SEMUA PERUBAHAN
watch(selectedSuratType, (val) => {
    console.log('[DEBUG] Jenis Surat berubah:', val);
});

function resetForm() {
    console.log('[DEBUG] Reset form dipanggil');
    form.value = {
        judul: '',
        isi: '',
        tanggal: new Date().toISOString().split('T')[0],
        createdBy: '',
    };
}

async function generatePDF() {
    // LOG DATA YANG AKAN DIKIRIM
    const payload = {
        jenisSurat: selectedSuratType.value,
        judul: form.value.judul,
        isi: form.value.isi,
        tanggal: form.value.tanggal,
        createdBy: form.value.createdBy,
    };

    console.log('[DEBUG] Payload dikirim ke backend:', payload);

    if (!payload.jenisSurat || !payload.judul.trim() || !payload.isi.trim()) {
        error.value = 'Semua field wajib diisi!';
        return;
    }

    loading.value = true;
    error.value = '';

    try {
        const response = await api.post('secrecy/generate', payload);
        // Jika berhasil, tapi bukan PDF → akan error parsing JSON
        console.log('[DEBUG] Response dari backend:', response);

        // Buat URL untuk preview PDF
        const blob = new Blob([response.data], { type: 'application/pdf' });
        const url = URL.createObjectURL(blob);
        pdfUrl.value = url;

        console.log('[DEBUG] PDF berhasil dibuat. URL:', url);

        // Simpan juga ke database
        await api.post('secrecy/save', payload);

    } catch (err) {
        console.error('[ERROR] Gagal generate PDF:', err);

        // Log lengkap — sangat penting!
        if (err.response) {
            console.log('[ERROR] Status:', err.response.status);
            console.log('[ERROR] Data:', err.response.data); // 👈 INI PALING PENTING
            console.log('[ERROR] Headers:', err.response.headers);
        }

        error.value =
            err.response?.data?.message ||
            err.message ||
            'Gagal membuat surat. Cek console untuk detail.';
    } finally {
        loading.value = false;
    }
}

function downloadPDF() {
    if (!pdfUrl.value) return;
    const link = document.createElement('a');
    link.href = pdfUrl.value;
    link.download = `${form.value.judul || 'surat'}_${selectedSuratType.value}.pdf`;
    link.click();
}
</script>

<style scoped>
.secrecy-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 32px;
    background: #f9f9ff;
    border-radius: 16px;
    font-family: 'Plus Jakarta Sans', sans-serif;
}

h2 {
    color: #333;
    text-align: center;
    margin-bottom: 32px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #444;
}

.form-group input,
.form-group select,
.form-group textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
}

.form-group textarea {
    resize: vertical;
}

.dynamic-form {
    background: white;
    padding: 24px;
    border-radius: 12px;
    border: 1px solid #e0e0e0;
    margin-bottom: 32px;
}

.form-actions {
    display: flex;
    gap: 12px;
    margin-top: 24px;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.2s;
}

.btn-primary {
    background-color: #6c63ff;
    color: white;
}

.btn-primary:hover:not(:disabled) {
    background-color: #5a54e0;
}

.btn-secondary {
    background-color: #f0f0f0;
    color: #333;
    border: 1px solid #ccc;
}

.btn-secondary:hover:not(:disabled) {
    background-color: #e0e0e0;
}

.btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-success {
    background-color: #27ae60;
    color: white;
}

.btn-success:hover {
    background-color: #219955;
}

.pdf-preview {
    margin-top: 32px;
    background: white;
    border-radius: 12px;
    border: 1px solid #e0e0e0;
    padding: 24px;
}

.pdf-preview h4 {
    margin-bottom: 16px;
    color: #333;
}

.error-message {
    margin-top: 16px;
    padding: 12px;
    background-color: #fee;
    color: #c33;
    border-radius: 8px;
    border-left: 4px solid #e74c3c;
}

/* Responsive */
@media (max-width: 768px) {
    .secrecy-container {
        padding: 16px;
    }

    .form-actions {
        flex-direction: column;
    }

    .btn {
        width: 100%;
    }
}
</style>