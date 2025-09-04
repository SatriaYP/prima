<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  columns: Array,
  items: Array,
  rowsPerPage: { type: Number, default: 5 },
  loading: { type: Boolean, default: false },
  onDetail: Boolean,
  onEdit: Boolean,
  onDelete: Boolean,
});

const hasActions = props.onDetail || props.onEdit || props.onDelete;
const currentPage = ref(1);

const getRowValue = (obj, path) => {
  return path.split(".").reduce((acc, part) => acc?.[part], obj) ?? "";
};

const totalPages = computed(() =>
  Math.ceil(props.items.length / props.rowsPerPage)
);

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * props.rowsPerPage;
  return props.items.slice(start, start + props.rowsPerPage);
});

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++;
}
function prevPage() {
  if (currentPage.value > 1) currentPage.value--;
}

watch(
  () => props.items,
  () => {
    currentPage.value = 1;
  }
);
</script>
<template>
  <div class="table-container">
    <table class="data-table">
      <thead>
        <tr>
          <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
          <th v-if="hasActions">Aksi</th>
        </tr>
      </thead>

      <tbody>
        <!-- Skeleton Loading State -->
        <template v-if="loading">
          <tr v-for="n in rowsPerPage" :key="'skeleton-' + n">
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
            <td v-for="col in columns" :key="col.key">
              {{ getRowValue(item, col.key) }}
            </td>
            <td v-if="hasActions">
              <!-- <button
                v-if="onDetail"
                class="btn detail"
                @click="$emit('detail', item)"
              >
                Detail
              </button> -->
              <button
                v-if="onEdit"
                class="btn edit"
                @click="$emit('edit', item)"
                title="Edit data"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                >
                  <g
                    fill="none"
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                  >
                    <path
                      d="m16.214 4.982l1.402-1.401a1.982 1.982 0 0 1 2.803 2.803l-1.401 1.402m-2.804-2.804l-5.234 5.234c-1.045 1.046-1.568 1.568-1.924 2.205S8.342 14.561 8 16c1.438-.342 2.942-.7 3.579-1.056s1.16-.879 2.205-1.924l5.234-5.234m-2.804-2.804l2.804 2.804"
                    />
                    <path
                      d="M21 12c0 4.243 0 6.364-1.318 7.682S16.242 21 12 21s-6.364 0-7.682-1.318S3 16.242 3 12s0-6.364 1.318-7.682S7.758 3 12 3"
                    />
                  </g>
                </svg>
              </button>
              <button
                v-if="onDelete"
                class="btn delete"
                @click="$emit('delete', item)"
                title="Delete data"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                >
                  <path
                    fill="none"
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="m19.5 5.5l-.62 10.025c-.158 2.561-.237 3.842-.88 4.763a4 4 0 0 1-1.2 1.128c-.957.584-2.24.584-4.806.584c-2.57 0-3.855 0-4.814-.585a4 4 0 0 1-1.2-1.13c-.642-.922-.72-2.205-.874-4.77L4.5 5.5M3 5.5h18m-4.944 0l-.683-1.408c-.453-.936-.68-1.403-1.071-1.695a2 2 0 0 0-.275-.172C13.594 2 13.074 2 12.035 2c-1.066 0-1.599 0-2.04.234a2 2 0 0 0-.278.18c-.395.303-.616.788-1.058 1.757L8.053 5.5m1.447 11v-6m5 6v-6"
                  />
                </svg>
              </button>
            </td>
          </tr>
          <tr v-if="!paginatedItems.length">
            <td :colspan="columns.length + (hasActions ? 1 : 0)">
              <div class="no-data">Data tidak ditemukan.</div>
            </td>
          </tr>
        </template>
      </tbody>
    </table>

    <!-- Pagination -->
    <div class="pagination" v-if="!loading && totalPages > 1">
      <button @click="prevPage" :disabled="currentPage === 1">« Prev</button>
      <span>Halaman {{ currentPage }} dari {{ totalPages }}</span>
      <button @click="nextPage" :disabled="currentPage === totalPages">
        Next »
      </button>
    </div>
  </div>
</template>
<style scoped>
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
