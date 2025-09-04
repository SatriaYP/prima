import { defineStore } from "pinia";
import { ref } from "vue";
import RegionService from "@/services/region.service";

export const useRegionStore = defineStore("region", () => {
  const provinces = ref([]);
  const cities = ref([]);
  const districts = ref([]);
  const villages = ref([]);

  const loading = ref(false);
  const error = ref(null);

  const fetchProvinces = async () => {
    loading.value = true;
    try {
      const prov = await RegionService.getProvinces();
      provinces.value = (Array.isArray(prov) ? prov : []).map((prov) => ({
        code: prov.code,
        name: prov.name,
      }));
      console.log(provinces.value);
      error.value = null;
    } catch (err) {
      error.value = err.message;
      provinces.value = [];
    } finally {
      loading.value = false;
    }
  };

  const fetchCities = async (provId) => {
    loading.value = true;
    try {
      const city = await RegionService.getCities(provId);
      cities.value = (Array.isArray(city) ? city : []).map((city) => ({
        code: city.code,
        name: city.name,
      }));
      error.value = null;
    } catch (err) {
      error.value = err.message;
      cities.value = [];
    } finally {
      loading.value = false;
    }
  };

  const fetchDistricts = async (cityId) => {
    loading.value = true;
    try {
      const dist = await RegionService.getDistricts(cityId);
      districts.value = (Array.isArray(dist) ? dist : []).map((dis) => ({
        code: dis.code,
        name: dis.name,
      }));
      console.log(districts);
      error.value = null;
    } catch (err) {
      error.value = err.message;
      districts.value = [];
    } finally {
      loading.value = false;
    }
  };

  const fetchVillages = async (districtId) => {
    loading.value = true;
    try {
      const desa = await RegionService.getVillages(districtId);
      villages.value = (Array.isArray(desa) ? desa : []).map((village) => ({
        code: village.code,
        name: village.name,
      }));
      console.log(villages.value);
      error.value = null;
    } catch (err) {
      error.value = err.message;
      villages.value = [];
    } finally {
      loading.value = false;
    }
  };

  const resetCities = () => {
    cities.value = [];
    districts.value = [];
    villages.value = [];
  };

  const resetDistricts = () => {
    districts.value = [];
    villages.value = [];
  };

  const resetVillages = () => {
    villages.value = [];
  };

  return {
    provinces,
    cities,
    districts,
    villages,
    loading,
    error,
    fetchProvinces,
    fetchCities,
    fetchDistricts,
    fetchVillages,
    resetCities,
    resetDistricts,
    resetVillages,
  };
});
