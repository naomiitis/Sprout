import express from "express";
import multer from "multer";
import Tesseract from "tesseract.js";
import User from "../models/User.js";
import { isAllowedForUser } from "../utils/llmClient.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

router.post('/', upload.single('image'), async (req, res) => {
    try {
        const userId = req.query.userId || req.body.userId || req.body.userID;

        if (!req.file) {
            return res.status(400).json({ success: false, error: "Image is required" });
        }

        if (!userId) {
            return res.status(400).json({ success: false, error: "userId is required" });
        }

        // Load user preferences
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ success: false, error: "User not found" });

        const userPrefs = {
            dietLevel: user.dietLevel,
            extraForbiddenTags: user.extraForbiddenTags || []
        };

        // OCR
        const ocrResult = await Tesseract.recognize(req.file.path, 'eng');
        let lines = ocrResult.data.lines.map(l => l.text.trim());

        // Clean each line
        lines = lines
            .map(line => line.replace(/[^a-zA-Z ]/g, "").trim())
            .filter(line => line.length > 0);

        // Check each line as a possible dish
        const dishes = [];

        for (const line of lines) {
            const check = await isAllowedForUser(userPrefs, [line]);
            const first = check[0] || { allowed: "Ambiguous", reason: "" };
            
            let status = "suitable";
            if (first.allowed === "NotAllowed") {
                status = "not_suitable";
            } else if (first.allowed === "Ambiguous") {
                status = "modifiable";
            }
            
            dishes.push({
                name: line,
                status: status,
                modificationSuggestion: first.allowed !== "Allowed" ? first.reason || first.reasons?.[0] || "May need modifications" : null
            });
        }

        res.json({ dishes: dishes });

    } catch (err) {
        console.error("Error scanning menu:", err);
        res.status(500).json({ success: false, error: "Internal server error" });
    }
});

export default router;
