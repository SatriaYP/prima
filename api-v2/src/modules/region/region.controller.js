import RegionService from "./region.service.js";

class RegionController {
  getProvinces = async (_req, res) => {
    try {
      const provinces = await RegionService.getProvinces();
      res.json(provinces);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  getCities = async (req, res) => {
    try {
      const cities = await RegionService.getCities(req.params.provinceId);
      res.json(cities);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  getDistricts = async (req, res) => {
    try {
      const districts = await RegionService.getDistricts(req.params.cityId);
      res.json(districts);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  getVillages = async (req, res) => {
    try {
      const villages = await RegionService.getVillages(req.params.districtId);
      res.json(villages);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
}

export default new RegionController();
