import api from "./api.service";

class RegionService {
  async getProvinces() {
    try {
      const prov = await api.get("/regions/provinces");
      return prov.data;
    } catch (error) {
      throw new Error("Gagal ambil data provinsi!");
    }
  }
  async getCities(provId) {
    try {
      const cities = await api.get(`/regions/cities/${provId}`);
      return cities.data;
    } catch (error) {
      throw new Error("Gagal ambil data kota/kabupaten!");
    }
  }
  async getDistricts(cityId) {
    try {
      const districts = await api.get(`/regions/districts/${cityId}`);
      return districts.data;
    } catch (error) {
      throw new Error("Gagal ambil data kecamatan!");
    }
  }
  async getVillages(districtId) {
    try {
      const villages = await api.get(`/regions/villages/${districtId}`);
      return villages.data;
    } catch (error) {
      throw new Error("Gagal ambil data kelurahan/desa!");
    }
  }
}

export default new RegionService();
