<template>
  <table class="member-table">
    <thead>
      <tr>
        <th>
          <input type="checkbox" v-model="selectAll" @change="toggleAll" />
        </th>
        <th>Nama</th>
        <th>Provinsi</th>
        <th>Kota</th>
        <th>Kecamatan</th>
        <th>Aksi</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="member in members" :key="member.id">
        <td><input type="checkbox" v-model="selected" :value="member.id" /></td>
        <td>{{ member.name }}</td>
        <td>{{ member.province }}</td>
        <td>{{ member.city }}</td>
        <td>{{ member.district }}</td>
        <td>
          <button @click="$emit('view', member)">👁️</button>
          <button @click="$emit('edit', member)">✏️</button>
          <button @click="$emit('delete', member)">🗑️</button>
        </td>
      </tr>
    </tbody>
  </table>
  <button
    class="mass-delete"
    v-if="selected.length"
    @click="$emit('massDelete', selected)"
  >
    🗑️ Hapus Terpilih
  </button>
</template>

<script setup>
import { ref, watch } from "vue";
const props = defineProps(["members"]);

defineEmits(["view", "edit", "delete", "massDelete"]);

const selected = ref([]);
const selectAll = ref(false);

function toggleAll() {
  selected.value = selectAll.value
    ? [...props.members.value.map((m) => m.id)]
    : [];
}

watch(
  () => selected.value,
  (val) => {
    selectAll.value = val.length === props.members.value.length;
  }
);
</script>

<style scoped>
.member-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 12px;
}

.member-table th,
.member-table td {
  padding: 10px;
  border-bottom: 1px solid #ddd;
  text-align: left;
}

.mass-delete {
  background-color: #dc2626;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
}

.mass-delete:hover {
  background-color: #b91c1c;
}
</style>
