<template>
    <div class="personal-data-form">
        <h3>Data Diri Anggota</h3>

        <!-- NIK -->
        <div class="form-group">
            <label>NIK *</label>
            <input v-model="localNik" @input="validateAndFormatNIK" maxlength="16" placeholder="Masukkan 16 digit NIK"
                required :class="{ 'error-input': !localNik || nikError }" />
            <div v-if="!localNik" class="error-message">NIK wajib diisi</div>
            <div v-if="nikError" class="error-message">{{ nikError }}</div>
            <div v-if="nikStatus" class="status-message"
                :class="{ 'status-success': nikStatus === 'NIK tersedia', 'status-error': nikStatus !== 'NIK tersedia' }">
                {{ nikStatus }}
            </div>
        </div>

        <!-- Nama -->
        <div class="form-group">
            <label>Nama *</label>
            <input v-model="localName" @input="handleUppercaseInput('name', $event)" style="text-transform: uppercase;"
                required />
        </div>

        <!-- Tempat Lahir -->
        <div class="form-group">
            <label>Tempat Lahir *</label>
            <input v-model="localBirthPlace" list="birthplace-list" @input="handleUppercaseInput('birthPlace', $event)"
                placeholder="Kota / Kabupaten" required />
            <datalist id="birthplace-list">
                <option v-for="r in regionOptions" :key="r.id" :value="r.name" />
            </datalist>
        </div>

        <!-- Tanggal Lahir -->
        <div class="form-group">
            <label>Tanggal Lahir *</label>
            <input v-model="dateFormatted" placeholder="DD/MM/YYYY" required type="date" />
        </div>

        <!-- Alamat -->
        <div class="form-group">
            <label>Alamat *</label>
            <input v-model="localAddress" @input="handleUppercaseInput('address', $event)"
                style="text-transform: uppercase;" />
        </div>

        <!-- Jenis Kelamin + Status Perkawinan -->
        <div class="form-row">
            <div class="form-group">
                <label>Jenis Kelamin *</label>
                <select v-model="localGender" required>
                    <option value="">Pilih</option>
                    <option value="Laki-laki">Laki-laki</option>
                    <option value="Perempuan">Perempuan</option>
                </select>
            </div>
            <div class="form-group">
                <label>Status Perkawinan *</label>
                <select v-model="localMaritalStatus" required>
                    <option value="">Pilih</option>
                    <option value="Belum Kawin">Belum Kawin</option>
                    <option value="Kawin">Kawin</option>
                    <option value="Cerai">Cerai</option>
                </select>
            </div>
        </div>

        <!-- Pekerjaan + Minat/Bakat -->
        <div class="form-row">
            <div class="form-group">
                <label>Status Pekerjaan *</label>
                <input v-model="localOccupation" @input="handleUppercaseInput('occupation', $event)"
                    style="text-transform: uppercase;" />
            </div>
            <div class="form-group" v-if="!props.isAdmin">
                <label>Minat/Bakat</label>
                <input v-model="localInterests" @input="handleUppercaseInput('interests', $event)"
                    style="text-transform: uppercase;" />
            </div>
        </div>

        <!-- Email + No HP -->
        <div class="form-row" v-if="!props.isAdmin">
            <div class="form-group">
                <label>Email</label>
                <input v-model="localEmail" />
            </div>
            <div class="form-group">
                <label>No. Hp</label>
                <input v-model="localPhone" />
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, watch } from "vue";
import MemberService from "@/services/member.service";
const props = defineProps({
    form: {
        type: Object,
        required: true,
    },
    provinsiList: {
        type: Array,
        required: true,
    },
    isAdmin: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(["update:form"]);

const nikError = ref("");
const nikStatus = ref("");
const regionOptions = ref(props.provinsiList);

// 👇 COMPUTED PROPERTIES UNTUK SETIAP FIELD
const localNik = computed({
    get() {
        return props.form?.nik || "";
    },
    set(value) {
        emit("update:form", { ...props.form, nik: value });
    },
});

const localName = computed({
    get() {
        return props.form?.name || "";
    },
    set(value) {
        emit("update:form", { ...props.form, name: value });
    },
});

const localBirthPlace = computed({
    get() {
        return props.form?.birthPlace || "";
    },
    set(value) {
        emit("update:form", { ...props.form, birthPlace: value });
    },
});

const localAddress = computed({
    get() {
        return props.form?.address || "";
    },
    set(value) {
        emit("update:form", { ...props.form, address: value });
    },
});

const localGender = computed({
    get() {
        return props.form?.gender || "";
    },
    set(value) {
        emit("update:form", { ...props.form, gender: value });
    },
});

const localMaritalStatus = computed({
    get() {
        return props.form?.maritalStatus || "";
    },
    set(value) {
        emit("update:form", { ...props.form, maritalStatus: value });
    },
});

const localOccupation = computed({
    get() {
        return props.form?.occupation || "";
    },
    set(value) {
        emit("update:form", { ...props.form, occupation: value });
    },
});

const localInterests = computed({
    get() {
        return props.form?.interests || "";
    },
    set(value) {
        emit("update:form", { ...props.form, interests: value });
    },
});

const localEmail = computed({
    get() {
        return props.form?.email || "";
    },
    set(value) {
        emit("update:form", { ...props.form, email: value });
    },
});

const localPhone = computed({
    get() {
        return props.form?.phone || "";
    },
    set(value) {
        emit("update:form", { ...props.form, phone: value });
    },
});

// Fungsi lainnya tetap sama...
function validateAndFormatNIK(event) {
    let value = event.target.value;
    value = value.replace(/\D/g, "");

    if (value.length > 16) {
        value = value.slice(0, 16);
    }

    localNik.value = value; // 👈 UPDATE COMPUTED VALUE

    if (value.length > 0 && value.length !== 16) {
        nikError.value = "NIK harus terdiri dari 16 digit angka.";
    } else {
        nikError.value = "";
        if (value.length === 16) {
            checkNikUniqueness(value);
        }
    }
}

async function checkNikUniqueness(nik) {
    if (!nik || nik.length !== 16) return;

    nikStatus.value = "Memeriksa...";
    nikError.value = "";

    try {
        const result = await MemberService.checkNikUniqueness(nik);

        if (result.exists) {
            nikStatus.value = "NIK sudah terdaftar";
        } else {
            nikStatus.value = "NIK tersedia";
            nikError.value = "";
        }
    } catch (err) {
        console.error("Error checking NIK:", err);
        nikStatus.value = "Gagal memeriksa NIK. Coba lagi.";
        nikError.value =
            err.response?.data?.message ||
            "Gagal memeriksa NIK. Silakan coba lagi.";
    }
}

const dateFormatted = computed({
    get() {
        if (!props.form?.birthDate) return "";
        const [day, month, year] = props.form.birthDate.split("-");
        return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
    },
    set(val) {
        if (!val) return;
        const parts = val.split("-");
        if (parts.length === 3) {
            const [y, m, d] = parts;
            emit("update:form", {
                ...props.form,
                birthDate: `${d}-${m}-${y}`,
            });
        }
    },
});

function handleUppercaseInput(field, event) {
    const value = event.target.value.toUpperCase();
    emit("update:form", {
        ...props.form,
        [field]: value,
    });
}

watch(
    () => props.provinsiList,
    (newList) => {
        regionOptions.value = newList;
    },
    { deep: true }
);
</script>

<style scoped>
.status-message {
    margin-top: 4px;
    font-size: 0.85rem;
    font-weight: 500;
    padding: 4px 8px;
    border-radius: 4px;
    display: inline-block;
}

.status-success {
    color: #16a34a;
    /* Hijau */
    background-color: #dcfce7;
    border: 1px solid #d1fae5;
}

.status-error {
    color: #dc2626;
    /* Merah */
    background-color: #fee2e2;
    border: 1px solid #fecaca;
}

/* --- TETAP SAMA SEPERTI SEBELUMNYA --- */
.personal-data-form h3 {
    color: #3c3c3c;
    margin-bottom: 24px;
    font-size: 1.4rem;
    font-weight: 600;
}

.form-row {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    margin-bottom: 16px;
}

.form-row .form-group {
    flex: 1 1 300px;
    display: flex;
    flex-direction: column;
}

.form-group {
    margin-bottom: 16px;
    display: flex;
    flex-direction: column;
}

.form-group label {
    font-weight: 600;
    margin-bottom: 6px;
    color: #333;
    font-size: 0.95rem;
}

.form-group input,
.form-group select {
    padding: 10px 12px;
    border: 1.5px solid #d0d7e2;
    border-radius: 8px;
    font-size: 1em;
    transition: border-color 0.3s;
}

.form-group input:focus,
.form-group select:focus {
    outline: none;
    border-color: #6c63ff;
    box-shadow: 0 0 0 2px rgba(108, 99, 255, 0.2);
}

.error-input {
    border-color: #e74c3c !important;
}

.error-message {
    color: #e74c3c;
    font-size: 0.85em;
    margin-top: 4px;
}

@media (max-width: 700px) {
    .form-row {
        flex-direction: column;
    }
}
</style>