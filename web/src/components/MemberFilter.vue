<template>
  <div class="member-filter card">
    <input v-model="search" @input="$emit('update:search', search)" placeholder="Cari anggota..." />
    <select v-model="province" @change="$emit('update:province', province)">
      <option value="">Prosvinsi</option>
    </select>
    <select v-model="city" @change="$emit('update:city', city)">
      <option value="">Kota/Kabupaten</option>
    </select>
    <select v-model="district" @change="$emit('update:district', district)">
      <option value="">Kecamatan</option>
    </select>
    <select v-model="village" @change="$emit('update:village', village)">
      <option value="">Desa/Kelurahan</option>
    </select>
    <button class="btn" @click="$emit('reset')">Reset</button>
  </div>
</template>
<script>
import { ref } from 'vue';
export default {
  name: 'MemberFilter',
  emits: ['update:search', 'update:province', 'update:city', 'update:district', 'update:village', 'reset'],
  setup() {
    const search = ref('');
    const province = ref('');
    const city = ref('');
    const district = ref('');
    const village = ref('');
    return { search, province, city, district, village };
  }
};
</script>
<style scoped>
.member-filter {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
  margin-bottom: 18px;
}

.member-filter input,
.member-filter select {
  min-width: 120px;
  flex: 1 1 130px;
}
</style>
