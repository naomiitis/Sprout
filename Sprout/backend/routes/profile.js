// routes/profile.js
import express from "express";
import User from "../models/User.js";
import UserImpact from "../models/UserImpact.js";

const router = express.Router();

/**
 * GET /profile?userId=xxx
 */
router.get("/", async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const user = await User.findById(userId).lean();
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const impact = await UserImpact.findOne({ user_id: userId }).lean();
    
    // Calculate level from XP
    const xp = impact?.xp || 0;
    const level = Math.floor(xp / 100) + 1;
    const xpToNextLevel = level * 100 - xp;

    res.json({
      id: user._id.toString(),
      userName: user.name || "User",
      eatingStyle: user.dietLevel || "vegan",
      dietaryRestrictions: user.extraForbiddenTags || [],
      cuisinePreferences: user.preferredCuisines || [],
      cookingStylePreferences: [],
      sproutName: "Bud",
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      coins: 0,
      streakDays: impact?.streak_days || 0
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PATCH /profile
 * body: { userId, ...profile fields }
 */
router.patch("/", async (req, res, next) => {
  try {
    const { userId, ...updates } = req.body;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (updates.eatingStyle) user.dietLevel = updates.eatingStyle;
    if (updates.dietaryRestrictions) user.extraForbiddenTags = updates.dietaryRestrictions;
    if (updates.cuisinePreferences) user.preferredCuisines = updates.cuisinePreferences;
    if (updates.userName) user.name = updates.userName;

    await user.save();

    const impact = await UserImpact.findOne({ user_id: userId }).lean();
    const xp = impact?.xp || 0;
    const level = Math.floor(xp / 100) + 1;
    const xpToNextLevel = level * 100 - xp;

    res.json({
      id: user._id.toString(),
      userName: user.name || "User",
      eatingStyle: user.dietLevel || "vegan",
      dietaryRestrictions: user.extraForbiddenTags || [],
      cuisinePreferences: user.preferredCuisines || [],
      cookingStylePreferences: [],
      sproutName: updates.sproutName || "Bud",
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      coins: 0,
      streakDays: impact?.streak_days || 0
    });
  } catch (err) {
    next(err);
  }
});

export default router;

