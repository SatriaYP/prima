<script setup>
// eslint-disable-next-line
import { computed, ref, watch } from "vue";

const props = defineProps({
  columns: Array,
  items: Array,
  rowsPerPage: { type: Number, default: 5 },
  loading: { type: Boolean, default: false },
  onDetail: Boolean,
  onEdit: Boolean,
  onDelete: Boolean,
  currentPage: Number,

  // ✅ BARU: Untuk multi-select
  selectable: {
    type: Boolean,
    default: false,
  },
  selectedItems: {
    type: Array,
    default: () => [],
  },
  totalPages: {
    type: Number,
    default: 1,
  },
});
const emit = defineEmits([
  "edit",
  "delete",
  "detail",
  "page-change", // 👈 Baru
  "selection-change", // 👈 Baru
]);

// Status seleksi lokal (hanya untuk halaman saat ini)
const localSelectedIds = ref(new Set(props.selectedItems.map((item) => item.id)));

// Fungsi untuk mengecek apakah item terpilih
const isSelected = (item) => localSelectedIds.value.has(item.id);

// Toggle satu item
const toggleSelect = (item) => {
  if (localSelectedIds.value.has(item.id)) {
    localSelectedIds.value.delete(item.id);
  } else {
    localSelectedIds.value.add(item.id);
  }
  emitSelectionChange();
};

// Toggle semua item di halaman ini
const toggleSelectAll = () => {
  const currentItems = paginatedItems.value;
  if (currentItems.length === 0) return;

  const allSelected = currentItems.every(isSelected);
  if (allSelected) {
    currentItems.forEach((item) => localSelectedIds.value.delete(item.id));
  } else {
    currentItems.forEach((item) => localSelectedIds.value.add(item.id));
  }
  emitSelectionChange();
};

// Emit event ke parent
const emitSelectionChange = () => {
  const selected = props.items.filter((item) =>
    localSelectedIds.value.has(item.id)
  );
  emit("selection-change", selected);
};
// eslint-disable-next-line
const hasActions = props.onDetail || props.onEdit || props.onDelete;
// eslint-disable-next-line
const currentPage = ref(1);

const getRowValue = (obj, path) => {
  return path.split(".").reduce((acc, part) => acc?.[part], obj) ?? "";
};

const paginatedItems = computed(() => props.items);
</script>
<template>
  <div class="table-container">
    <table class="data-table">
      <thead>
        <tr>
          <!-- Checkbox Header -->
          <th v-if="props.selectable" style="width: 40px; text-align: center;">
            <input type="checkbox" :checked="paginatedItems.length > 0 &&
              paginatedItems.every(isSelected) &&
              !paginatedItems.some((item) => !isSelected(item))
              " @change="toggleSelectAll" />
          </th>

          <!-- Kolom Data -->
          <th v-for="col in columns" :key="col.key">
            {{ col.label }}
          </th>

          <!-- Aksi -->
          <th v-if="hasActions">Aksi</th>
        </tr>
      </thead>

      <tbody>
        <!-- Skeleton Loading -->
        <template v-if="loading">
          <tr v-for="n in rowsPerPage" :key="'skeleton-' + n">
            <td v-if="props.selectable">
              <div class="skeleton" style="width: 20px; height: 20px; border-radius: 4px;"></div>
            </td>
            <td v-for="col in columns" :key="col.key">
              <div class="skeleton"></div>
            </td>
            <td v-if="hasActions">
              <div class="skeleton-btn-group">
                <div class="skeleton skeleton-btn"></div>
                <div class="skeleton skeleton-btn"></div>
                <div class="skeleton skeleton-btn"></div>
              </div>
            </td>
          </tr>
        </template>

        <!-- Data Rows -->
        <template v-else>
          <tr v-for="item in paginatedItems" :key="item.id">
            <!-- Checkbox Row -->
            <td v-if="props.selectable" style="text-align: center;">
              <input type="checkbox" :checked="isSelected(item)" @change="toggleSelect(item)" />
            </td>

            <!-- Data Cells -->
            <td v-for="col in columns" :key="col.key">
              <!-- Jika ada prop 'default', gunakan jika nilai null/undefined -->
              {{
                col.default && getRowValue(item, col.key) == ""
                  ? col.default
                  : getRowValue(item, col.key)
              }}
            </td>

            <!-- Aksi -->
            <td v-if="hasActions">
              <button v-if="onDetail" class="btn detail" @click="$emit('detail', item)" title="Detail">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z" />
                  <path d="M9 12l2 2 4-4" />
                </svg>
              </button>

              <button v-if="onEdit" class="btn edit" @click="$emit('edit', item)" title="Edit">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" />
                </svg>
              </button>

              <button v-if="onDelete" class="btn delete" @click="$emit('delete', item)" title="Hapus">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                </svg>
              </button>
            </td>
          </tr>

          <!-- No Data -->
          <tr v-if="!paginatedItems.length">
            <td :colspan="columns.length + (hasActions ? 1 : 0) + (props.selectable ? 1 : 0)">
              <div class="no-data">Data tidak ditemukan.</div>
            </td>
          </tr>
        </template>
      </tbody>
    </table>
    <!-- Pagination Navigation -->
    <div v-if="props.totalPages > 1" class="pagination">
      <button class="pagination-btn" :disabled="props.currentPage <= 1"
        @click="$emit('page-change', props.currentPage - 1)">
        ← Sebelumnya
      </button>

      <span class="pagination-info">
        Halaman {{ props.currentPage }} dari {{ props.totalPages }}
      </span>

      <button class="pagination-btn" :disabled="props.currentPage >= props.totalPages"
        @click="$emit('page-change', props.currentPage + 1)">
        Berikutnya →
      </button>
    </div>
  </div>
</template>
<style scoped>
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin-top: 20px;
  padding: 12px;
  background-color: #f9f9f9;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
}

.pagination-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  background-color: #f0f0f0;
  color: #333;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.pagination-btn:hover:not(:disabled) {
  background-color: #e0e0e0;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-info {
  font-weight: 500;
  color: #555;
  font-size: 14px;
}

.table-container {
  overflow-x: auto;
  border-radius: 12px;
  background: #fff;
  /* box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05); */
  padding: 1rem;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

.data-table th,
.data-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.data-table th {
  background-color: #f3f4f6;
  color: #333;
  font-weight: 600;
  font-size: 14px;
}

.data-table td {
  font-size: 14px;
  color: #444;
}

.btn {
  padding: 6px 10px;
  font-size: 13px;
  border: none;
  border-radius: 8px;
  margin-right: 6px;
  cursor: pointer;
}

.btn.detail {
  background: #e0e7ff;
  color: #4338ca;
}

.btn.edit {
  padding: 3px;
  background: #fef3c7;
  color: #b45309;
}

.btn.delete {
  padding: 3px;
  background: #fecaca;
  color: #b91c1c;
}

.no-data {
  padding: 16px;
  text-align: center;
  color: #888;
}

.pagination {
  margin-top: 1rem;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  align-items: center;
}

.pagination button {
  background: #eee;
  border: none;
  padding: 6px 12px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
}

.pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Skeleton Styles */
.skeleton {
  height: 14px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e4e4e4 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: pulse 1.5s infinite;
  border-radius: 6px;
}

.skeleton-btn-group {
  display: flex;
  gap: 6px;
}

.skeleton-btn {
  width: 50px;
  height: 20px;
}

@keyframes pulse {
  0% {
    background-position: 200% 0;
  }

  100% {
    background-position: -200% 0;
  }
}
</style>

<!-- <template>
  <div class="table-container">
    <table class="data-table">
      <thead>
        <tr>
          <th v-for="col in columns" :key="col.key">
            {{ col.label }}
          </th>
          <th v-if="hasActions">Aksi</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in items" :key="item.id">
          <td v-for="col in columns" :key="col.key">
            {{ item[col.key] }}
          </td>
          <td v-if="hasActions">
            <button
              v-if="onDetail"
              class="btn detail"
              @click="$emit('detail', item)"
            >
              Detail
            </button>
            <button v-if="onEdit" class="btn edit" @click="$emit('edit', item)">
              Edit
            </button>
            <button
              v-if="onDelete"
              class="btn delete"
              @click="$emit('delete', item)"
            >
              Hapus
            </button>
          </td>
        </tr>
        <tr v-if="!items.length">
          <td :colspan="columns.length + (hasActions ? 1 : 0)">
            <div class="no-data">Data tidak ditemukan.</div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
const props = defineProps({
  columns: Array, // [{ key: 'name', label: 'Nama' }]
  items: Array, // Array of data
  onDetail: Boolean,
  onEdit: Boolean,
  onDelete: Boolean,
});

const hasActions = props.onDetail || props.onEdit || props.onDelete;
</script>

<style scoped>
.table-container {
  overflow-x: auto;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

.data-table th,
.data-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.data-table th {
  background-color: #f3f4f6;
  color: #333;
  font-weight: 600;
  font-size: 14px;
}

.data-table td {
  font-size: 14px;
  color: #444;
}

.btn {
  padding: 6px 10px;
  font-size: 13px;
  border: none;
  border-radius: 8px;
  margin-right: 6px;
  cursor: pointer;
}

.btn.detail {
  background: #e0e7ff;
  color: #4338ca;
}

.btn.edit {
  background: #fef3c7;
  color: #b45309;
}

.btn.delete {
  background: #fecaca;
  color: #b91c1c;
}

.no-data {
  padding: 16px;
  text-align: center;
  color: #888;
}
</style> -->

<!-- <template>
  <div class="table-wrapper">
    <div class="table-scroll">
      <table class="styled-table">
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                :checked="isAllSelected"
                @change="toggleSelectAll"
              />
            </th>
            <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
            <th v-if="hasActions">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in paginatedData" :key="row.id">
            <td>
              <input type="checkbox" :value="row.id" v-model="selectedIds" />
            </td>
            <td v-for="col in columns" :key="col.key">
              <span
                v-if="col.badge"
                :class="'badge ' + badgeClass(row[col.key])"
              >
                {{ row[col.key] }}
              </span>
              <span v-else>
                {{ row[col.key] }}
              </span>
            </td>
            <td v-if="hasActions">
              <button @click="$emit('view', row)">👁</button>
              <button @click="$emit('edit', row)">✏️</button>
              <button @click="$emit('delete', row)">🗑</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination">
      <button :disabled="page === 1" @click="prevPage">Prev</button>
      <span>Showing {{ paginatedData.length }} of {{ data.length }}</span>
      <button :disabled="page === totalPages" @click="nextPage">Next</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from "vue";

const props = defineProps({
  columns: Array,
  data: Array,
  pageSize: { type: Number, default: 8 },
  hasActions: { type: Boolean, default: true },
});

const emit = defineEmits(["view", "edit", "delete", "selection-change"]);

const page = ref(1);
const selectedIds = ref([]);

const paginatedData = computed(() => {
  const start = (page.value - 1) * props.pageSize;
  return props.data.slice(start, start + props.pageSize);
});

const totalPages = computed(() =>
  Math.ceil(props.data.length / props.pageSize)
);

const isAllSelected = computed(() => {
  const idsOnPage = paginatedData.value.map((row) => row.id);
  return (
    idsOnPage.every((id) => selectedIds.value.includes(id)) &&
    idsOnPage.length > 0
  );
});

function toggleSelectAll(e) {
  const idsOnPage = paginatedData.value.map((row) => row.id);
  if (e.target.checked) {
    selectedIds.value = [...new Set([...selectedIds.value, ...idsOnPage])];
  } else {
    selectedIds.value = selectedIds.value.filter(
      (id) => !idsOnPage.includes(id)
    );
  }
}

watch(selectedIds, () => {
  const selectedData = props.data.filter((d) =>
    selectedIds.value.includes(d.id)
  );
  emit("selection-change", selectedData);
});

watch(
  () => props.data,
  () => {
    page.value = 1;
    selectedIds.value = [];
  }
);

function prevPage() {
  if (page.value > 1) page.value--;
}

function nextPage() {
  if (page.value < totalPages.value) page.value++;
}

function badgeClass(value) {
  const val = value.toLowerCase();
  if (val.includes("all")) return "green";
  if (val.includes("uncategorized")) return "gray";
  if (val.includes("legality")) return "purple";
  if (val.includes("subscription")) return "blue";
  return "default";
}
</script>

<style scoped>
.table-wrapper {
  width: 100%;
  overflow-x: auto;
}
.table-scroll {
  width: 100%;
  overflow-x: auto;
}
.styled-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 960px;
  background: white;
}
.styled-table th,
.styled-table td {
  padding: 12px;
  border-bottom: 1px solid #eee;
  text-align: left;
  white-space: nowrap;
}
.styled-table thead {
  background-color: #fff;
  border-bottom: 2px solid #e0e0e0;
}
.styled-table tbody tr:hover {
  background-color: #f9f9f9;
}
.badge {
  padding: 3px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  color: white;
}
.badge.green {
  background-color: #20c997;
}
.badge.gray {
  background-color: #adb5bd;
}
.badge.purple {
  background-color: #d63384;
}
.badge.blue {
  background-color: #0d6efd;
}
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  margin-top: 12px;
}
.pagination button {
  padding: 6px 12px;
  background: #f1f3f5;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
}
.pagination button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}
</style> -->

<!-- <script setup>
import { ref, computed, watch } from "vue";

const props = defineProps({
  columns: { type: Array, required: true },
  data: { type: Array, required: true },
  pageSize: { type: Number, default: 5 },
  hasActions: { type: Boolean, default: true },
});

const emit = defineEmits(["view", "edit", "delete", "selection-change"]);

const page = ref(1);
const selectedIds = ref([]);

const paginatedData = computed(() => {
  const start = (page.value - 1) * props.pageSize;
  return props.data.slice(start, start + props.pageSize);
});

const totalPages = computed(() =>
  Math.ceil(props.data.length / props.pageSize)
);

const isAllSelected = computed(() => {
  const idsOnPage = paginatedData.value.map((row) => row.id);
  return (
    idsOnPage.every((id) => selectedIds.value.includes(id)) &&
    idsOnPage.length > 0
  );
});

function toggleSelectAll(e) {
  const idsOnPage = paginatedData.value.map((row) => row.id);
  if (e.target.checked) {
    selectedIds.value = [...new Set([...selectedIds.value, ...idsOnPage])];
  } else {
    selectedIds.value = selectedIds.value.filter(
      (id) => !idsOnPage.includes(id)
    );
  }
}

function nextPage() {
  if (page.value < totalPages.value) page.value++;
}
function prevPage() {
  if (page.value > 1) page.value--;
}

watch(selectedIds, () => {
  const selectedData = props.data.filter((item) =>
    selectedIds.value.includes(item.id)
  );
  emit("selection-change", selectedData);
});

watch(
  () => props.data,
  () => {
    page.value = 1;
    selectedIds.value = [];
  }
);
</script>

<template>
  <div class="table-wrapper">
    <div class="table-container">
      <table class="custom-table">
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                :checked="isAllSelected"
                @change="toggleSelectAll"
              />
            </th>
            <th v-for="col in columns" :key="col.key">
              {{ col.label }}
            </th>
            <th v-if="hasActions">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in paginatedData" :key="row.id">
            <td>
              <input type="checkbox" :value="row.id" v-model="selectedIds" />
            </td>
            <td v-for="col in columns" :key="col.key">
              {{ row[col.key] }}
            </td>
            <td v-if="hasActions">
              <button @click="$emit('view', row)">👁</button>
              <button @click="$emit('edit', row)">✏️</button>
              <button @click="$emit('delete', row)">🗑</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

   
    <div class="pagination">
      <button :disabled="page === 1" @click="prevPage">Prev</button>
      <span>Page {{ page }} of {{ totalPages }}</span>
      <button :disabled="page === totalPages" @click="nextPage">Next</button>
    </div>
  </div>
</template>

<style scoped>
.table-wrapper {
  width: 100%;
  overflow-x: auto;
}
.table-container {
  min-width: 900px;
}
.custom-table {
  width: 100%;
  border-collapse: collapse;
}
.custom-table th,
.custom-table td {
  padding: 8px;
  border: 1px solid #ccc;
  white-space: nowrap;
  text-align: left;
}
.custom-table th {
  background-color: #f4f4f4;
}
.pagination {
  margin-top: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> -->
