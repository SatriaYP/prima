<template>
  <li class="unit-node" :style="{marginLeft: level * 24 + 'px'}">
    <div class="unit-card">
      <span class="unit-title">{{ unit.name }}</span>
      <span class="unit-meta">{{ unit.tingkat?.name || '' }} - {{ unit.code }}</span>
      <div class="unit-actions">
        <button class="btn btn-blue" @click="$emit('edit', unit)">Edit</button>
        <button class="btn btn-green" @click="$emit('add-child', null, unit)">Tambah Anak</button>
        <button class="btn btn-red" :disabled="unit.children && unit.children.length" @click="$emit('delete', unit)">Hapus</button>
      </div>
    </div>
    <ul v-if="unit.children && unit.children.length" class="unit-tree">
      <UnitNode v-for="child in unit.children" :key="child.id" :unit="child" :level="level+1" @edit="$emit('edit', child)" @add-child="$emit('add-child', null, child)" @delete="$emit('delete', child)" />
    </ul>
  </li>
</template>

<script>
export default {
  name: 'UnitNode',
  props: {
    unit: Object,
    level: { type: Number, default: 0 }
  }
};
</script>

<style scoped>
.unit-node { margin-bottom: 8px; }
.unit-card { display: flex; align-items: center; background: #f5f6fa; border-radius: 6px; padding: 10px 14px; box-shadow: var(--shadow-xs); }
.unit-title { font-weight: 600; margin-right: 12px; }
.unit-meta { color: #888; font-size: 0.95em; margin-right: auto; }
.unit-actions button { margin-left: 8px; }
.unit-tree { list-style: none; padding-left: 0; }
</style>
