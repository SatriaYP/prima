<template>
  <div class="kta-generation-step">
    <h3>Cetak Kartu Tanda Anggota</h3>
    
    <div class="kta-preview">
      <div class="kta-card">
        <div class="kta-header">
          <div class="kta-logo">
            <img src="../../assets/logo.png" alt="Logo Partai" />
          </div>
          <div class="kta-title">
            <h4>KARTU TANDA ANGGOTA</h4>
            <h5>PARTAI PRIMA INDONESIA</h5>
          </div>
        </div>
        
        <div class="kta-body">
          <div class="kta-photo">
            <div class="kta-photo-placeholder">
              <span>Foto 3x4</span>
            </div>
          </div>
          
          <div class="kta-data">
            <div class="kta-field">
              <span class="kta-label">No. KTA:</span>
              <span class="kta-value">{{ form.noKta }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">Nama:</span>
              <span class="kta-value">{{ form.nama }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">NIK:</span>
              <span class="kta-value">{{ form.nik }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">TTL:</span>
              <span class="kta-value">{{ form.tempatLahir }}, {{ formatTanggalLahir }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">Alamat:</span>
              <span class="kta-value">{{ form.alamat }}</span>
            </div>
          </div>
        </div>
        
        <div class="kta-footer">
          <div class="kta-qr">
            <div class="kta-qr-placeholder">
              <span>QR Code</span>
            </div>
          </div>
          
          <div class="kta-signature">
            <p>{{ form.penerbitKta }}</p>
            <div class="kta-sign-placeholder"></div>
            <p>Ketua Umum</p>
          </div>
        </div>
      </div>
    </div>
    
    <div class="form-group form-checkbox">
      <input type="checkbox" :checked="form.isConfirmed" @change="updateConfirmation($event)" id="isConfirmed" required />
      <label for="isConfirmed">Saya menyatakan data di atas benar</label>
    </div>
    
    <div class="kta-actions">
      <button type="button" class="btn btn-blue" @click="downloadKta" :disabled="!form.isConfirmed">
        <i class="fas fa-download"></i> Download KTA
      </button>
      <button type="button" class="btn btn-green" @click="printKta" :disabled="!form.isConfirmed">
        <i class="fas fa-print"></i> Cetak KTA
      </button>
    </div>
    
    <!-- Navigation -->
    <div class="step-navigation">
      <button type="button" class="btn" @click="prevStep">Kembali</button>
      <button type="submit" class="btn btn-green" :disabled="!form.isConfirmed">{{ isEdit ? 'Simpan Perubahan' : 'Tambah Anggota' }}</button>
    </div>
  </div>
</template>

<script>
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';

export default {
  name: 'KtaGenerationStep',
  props: {
    form: {
      type: Object,
      required: true
    },
    isEdit: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    formatTanggalLahir() {
      if (!this.form.tanggalLahir) return '';
      
      const date = new Date(this.form.tanggalLahir);
      return date.toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
      });
    }
  },
  methods: {
    updateConfirmation(event) {
      this.$emit('update:form', {
        ...this.form,
        isConfirmed: event.target.checked
      });
    },
    prevStep() {
      this.$emit('prev-step');
    },
    downloadKta() {
      if (!this.form.isConfirmed) return;
      
      html2canvas(document.querySelector('.kta-card')).then(canvas => {
        // Create image
        const imgData = canvas.toDataURL('image/png');
        
        // Create link and trigger download
        const link = document.createElement('a');
        link.download = `KTA_${this.form.noKta || 'anggota'}.png`;
        link.href = imgData;
        link.click();
      });
    },
    printKta() {
      if (!this.form.isConfirmed) return;
      
      html2canvas(document.querySelector('.kta-card')).then(canvas => {
        const imgData = canvas.toDataURL('image/png');
        
        // Create PDF
        const pdf = new jsPDF({
          orientation: 'landscape',
          unit: 'mm',
          format: [85, 55] // ID card size
        });
        
        // Add image to PDF
        pdf.addImage(imgData, 'PNG', 0, 0, 85, 55);
        
        // Print PDF
        pdf.autoPrint();
        pdf.output('dataurlnewwindow');
      });
    }
  }
};
</script>

<style scoped>
h3 {
  margin-bottom: 20px;
  color: var(--primary);
}

.kta-preview {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

.kta-card {
  width: 340px;
  height: 220px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 15px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #ddd;
}

.kta-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  border-bottom: 1px solid #eee;
  padding-bottom: 8px;
}

.kta-logo {
  width: 40px;
  height: 40px;
  margin-right: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.kta-logo img {
  max-width: 100%;
  max-height: 100%;
}

.kta-title h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 700;
  color: var(--primary);
}

.kta-title h5 {
  margin: 2px 0 0;
  font-size: 12px;
  font-weight: 600;
}

.kta-body {
  display: flex;
  flex-grow: 1;
}

.kta-photo {
  width: 80px;
  padding-right: 10px;
}

.kta-photo-placeholder {
  width: 70px;
  height: 90px;
  background: #f5f5f5;
  border: 1px dashed #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  color: #888;
}

.kta-data {
  flex-grow: 1;
}

.kta-field {
  margin-bottom: 5px;
  font-size: 11px;
  display: flex;
}

.kta-label {
  width: 60px;
  font-weight: 600;
}

.kta-value {
  flex-grow: 1;
}

.kta-footer {
  display: flex;
  margin-top: 10px;
  border-top: 1px solid #eee;
  padding-top: 8px;
}

.kta-qr {
  width: 50px;
}

.kta-qr-placeholder {
  width: 40px;
  height: 40px;
  background: #f5f5f5;
  border: 1px dashed #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 8px;
  color: #888;
}

.kta-signature {
  flex-grow: 1;
  text-align: center;
  font-size: 9px;
}

.kta-sign-placeholder {
  height: 20px;
  margin: 2px 0;
}

.kta-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin: 20px 0;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: space-between;
}
</style>
