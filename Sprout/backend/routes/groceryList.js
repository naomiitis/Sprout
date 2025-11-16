// routes/groceryList.js
import express from "express";
import multer from "multer";
import Tesseract from "tesseract.js";
import Grocery from "../models/grocery.js";
import User from "../models/User.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

/**
 * GET /grocery-list?userId=xxx
 */
router.get("/", async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const groceries = await Grocery.find({ userID: userId }).lean();
    
    // Map to iOS format
    const items = groceries.map(g => ({
      id: g._id.toString(),
      name: g.name,
      category: "Produce", // Default category
      isChecked: false,
      userId: userId
    }));

    res.json(items);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /grocery-list
 * body: { userId, name, category }
 */
router.post("/", async (req, res, next) => {
  try {
    const { userId, name, category } = req.body;
    
    if (!userId || !name) {
      return res.status(400).json({ error: "userId and name are required" });
    }

    const grocery = await Grocery.create({
      userID: userId,
      name: name
    });

    res.json({
      id: grocery._id.toString(),
      name: grocery.name,
      category: category || "Produce",
      isChecked: false,
      userId: userId
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /grocery-list/scan-fridge?userId=xxx
 * file: image
 */
router.post("/scan-fridge", upload.single("image"), async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId || !req.file) {
      return res.status(400).json({ error: "userId and image are required" });
    }

    const ocrResult = await Tesseract.recognize(req.file.path, "eng");
    const text = ocrResult.data.text;
    const lines = text.split("\n")
      .map(line => line.trim())
      .filter(line => line.length > 0);

    const items = [];
    for (const line of lines) {
      const grocery = await Grocery.create({
        userID: userId,
        name: line
      });
      items.push({
        id: grocery._id.toString(),
        name: grocery.name,
        category: "Produce",
        isChecked: false,
        userId: userId
      });
    }

    res.json(items);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /grocery-list/scan-receipt?userId=xxx
 * file: image
 */
router.post("/scan-receipt", upload.single("image"), async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId || !req.file) {
      return res.status(400).json({ error: "userId and image are required" });
    }

    const ocrResult = await Tesseract.recognize(req.file.path, "eng");
    const rawText = ocrResult.data.text;
    const cleaned = rawText.replace(/[^a-zA-Z\s]/g, " ");
    const lines = cleaned
      .split("\n")
      .map(l => l.trim())
      .filter(l => l.length > 1);

    const items = [];
    for (const line of lines) {
      const grocery = await Grocery.create({
        userID: userId,
        name: line
      });
      items.push({
        id: grocery._id.toString(),
        name: grocery.name,
        category: "Produce",
        isChecked: false,
        userId: userId
      });
    }

    res.json(items);
  } catch (err) {
    next(err);
  }
});

export default router;

