/**
 * Implementasi cache sederhana untuk API wilayah
 */
class Cache {
  constructor(ttl = 3600000) { // Default TTL: 1 jam
    this.cache = new Map();
    this.ttl = ttl;
  }

  /**
   * Menyimpan data ke cache
   * @param {string} key - Key untuk menyimpan data
   * @param {any} data - Data yang akan disimpan
   */
  set(key, data) {
    const expiry = Date.now() + this.ttl;
    this.cache.set(key, {
      data,
      expiry
    });
    console.log(`Cache: Data disimpan untuk key "${key}"`);
  }

  /**
   * Mengambil data dari cache
   * @param {string} key - Key untuk mengambil data
   * @returns {any|null} Data dari cache atau null jika tidak ditemukan atau expired
   */
  get(key) {
    if (!this.cache.has(key)) {
      return null;
    }

    const cachedItem = this.cache.get(key);
    
    // Cek apakah cache sudah expired
    if (cachedItem.expiry < Date.now()) {
      console.log(`Cache: Data untuk key "${key}" sudah expired`);
      this.cache.delete(key);
      return null;
    }
    
    console.log(`Cache: Data ditemukan untuk key "${key}"`);
    return cachedItem.data;
  }

  /**
   * Menghapus data dari cache
   * @param {string} key - Key untuk menghapus data
   */
  delete(key) {
    this.cache.delete(key);
  }

  /**
   * Membersihkan cache yang sudah expired
   */
  cleanup() {
    const now = Date.now();
    let expiredCount = 0;
    
    for (const [key, item] of this.cache.entries()) {
      if (item.expiry < now) {
        this.cache.delete(key);
        expiredCount++;
      }
    }
    
    if (expiredCount > 0) {
      console.log(`Cache: ${expiredCount} item yang expired telah dihapus`);
    }
  }

  /**
   * Membersihkan semua cache
   */
  clear() {
    this.cache.clear();
    console.log('Cache: Semua cache telah dihapus');
  }

  /**
   * Mendapatkan ukuran cache
   * @returns {number} Jumlah item dalam cache
   */
  size() {
    return this.cache.size;
  }
}

// Buat instance cache dengan TTL 1 jam
const apiCache = new Cache(3600000);

// Jalankan cleanup setiap 30 menit
setInterval(() => {
  apiCache.cleanup();
}, 1800000);

module.exports = apiCache;
