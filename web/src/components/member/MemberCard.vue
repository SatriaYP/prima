<template>
  <div class="card">
    <div class="card-left">
      <div class="avatar">{{ member.name.charAt(0) }}</div>
      <div class="info">
        <div class="name">{{ member.name }}</div>
        <div class="details">{{ member.gender }} • {{ wilayah }}</div>
      </div>
    </div>
    <div class="actions">
      <button class="btn detail" @click="$emit('detail', member)">
        Detail
      </button>
      <button class="btn edit" @click="$emit('edit', member)">Edit</button>
      <button class="btn delete" @click="$emit('delete', member)">Hapus</button>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
  member: Object,
});

const wilayah = computed(() => {
  return [props.member.provinsi, props.member.kota, props.member.kecamatan]
    .filter(Boolean)
    .join(", ");
});
</script>

<style scoped>
.card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
}

.card-left {
  display: flex;
  align-items: center;
}

.avatar {
  width: 48px;
  height: 48px;
  background: #fdf3c0;
  color: #d4a800;
  font-weight: bold;
  font-size: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  margin-right: 12px;
}

.info .name {
  font-weight: 600;
  font-size: 16px;
  color: #333;
}

.info .details {
  font-size: 13px;
  color: #888;
}

.actions {
  display: flex;
  gap: 8px;
}

.btn {
  border: none;
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}

.btn.detail {
  background: #eae7fd;
  color: #5a4fcf;
}

.btn.edit {
  background: #fff3c4;
  color: #b08300;
}

.btn.delete {
  background: #f87171;
  color: white;
}
</style>
