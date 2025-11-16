// routes/chat.js
import express from "express";
import { chatWithAssistant } from "../utils/llmClient.js";
import User from "../models/User.js";

const router = express.Router();

/**
 * POST /chat
 * body: { userId, message, conversationHistory? }
 */
router.post("/", async (req, res, next) => {
  try {
    const { userId, message, conversationHistory } = req.body;

    if (!userId || !message) {
      return res.status(400).json({ error: "userId and message are required" });
    }

    // Load user preferences
    const user = await User.findById(userId).lean();
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const userPrefs = {
      dietLevel: user.dietLevel || "vegan",
      extraForbiddenTags: user.extraForbiddenTags || [],
      preferredCuisines: user.preferredCuisines || []
    };

    // Format conversation history for the LLM
    const formattedHistory = (conversationHistory || []).map(msg => ({
      role: msg.isUser ? "user" : "assistant",
      content: msg.text
    }));

    // Get response from chatbot
    const response = await chatWithAssistant(message, formattedHistory, userPrefs);

    res.json({
      message: response,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    next(err);
  }
});

export default router;

