class BaseController {
  constructor(service) {
    this.service = service;
  }

  getAll = async (_req, res) => {
    try {
      const result = await this.service.getAll();
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  getById = async (req, res) => {
    try {
      const result = await this.service.getById(req.params.id);
      if (!result) return res.status(404).json({ message: "Not found" });
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  create = async (req, res) => {
    try {
      const result = await this.service.create(req.body);
      res.status(201).json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  update = async (req, res) => {
    try {
      const result = await this.service.update(req.params.id, req.body);
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  remove = async (req, res) => {
    try {
      await this.service.delete(req.params.id);
      res.status(204).send();
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
}

export default BaseController;
