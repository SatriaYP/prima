<template>
  <div class="kepengurusan-container">
    <h1>Manajemen Kepengurusan</h1>
    <div class="tabs">
      <button :class="{active: tab==='tree'}" @click="tab='tree'">
        Struktur Organisasi
      </button>
      <button :class="{active: tab==='tingkat'}" @click="tab='tingkat'">
        Tingkat Kepengurusan
      </button>
    </div>
    <div class="tab-content">
      <StrukturOrganisasi v-if="tab==='tree'" />
      <TingkatKepengurusan v-else />
    </div>
  </div>
</template>

<script>
import StrukturOrganisasi from '../components/StrukturOrganisasi.vue';
import TingkatKepengurusan from '../components/TingkatKepengurusan.vue';

export default {
  name: 'KepengurusanView',
  components: { StrukturOrganisasi, TingkatKepengurusan },
  data() {
    return {
      tab: 'tree'
    };
  }
};
</script>

<style scoped>
.kepengurusan-container { max-width: 980px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: var(--shadow); padding: 24px 28px; }
h1 { margin-bottom: 18px; }
.tabs { display: flex; gap: 8px; margin-bottom: 18px; }
.tabs button { padding: 8px 20px; border: none; border-radius: 8px 8px 0 0; background: #f5f6fa; font-weight: 600; cursor: pointer; color: #333; }
.tabs button.active { background: var(--primary); color: #fff; }
.tab-content { min-height: 480px; }
</style>
