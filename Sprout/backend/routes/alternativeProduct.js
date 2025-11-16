// routes/alternativeProduct.js
import express from "express";
import User from "../models/User.js";
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const substitutions = JSON.parse(readFileSync(join(__dirname, "../config/substitutions.json"), "utf-8"));

const router = express.Router();

/**
 * POST /scan/alternative-product
 * body: { userId, productType, context? }
 */
router.post("/", async (req, res, next) => {
  try {
    const { userId, productType, context } = req.body;
    
    if (!userId || !productType) {
      return res.status(400).json({ error: "userId and productType are required" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const dietLevel = user.dietLevel?.toLowerCase() || "vegan";
    const key = productType.toUpperCase();
    const suggestions = substitutions[key]?.[dietLevel] || [];

    res.json({ suggestions });
  } catch (err) {
    next(err);
  }
});

export default router;

