// routes/home.js
import express from "express";
import UserImpact from "../models/UserImpact.js";

const router = express.Router();

/**
 * GET /home/summary?userId=xxx
 */
router.get("/summary", async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const impact = await UserImpact.findOne({ user_id: userId }).lean();
    
    if (!impact) {
      return res.json({
        level: 1,
        xp: 0,
        xpToNextLevel: 100,
        coins: 0,
        streakDays: 0,
        missions: []
      });
    }

    const xp = impact.xp || 0;
    const level = Math.floor(xp / 100) + 1;
    const xpToNextLevel = level * 100 - xp;

    // Mock missions for now
    const missions = [
      {
        id: "1",
        title: "Log your first meal",
        xpReward: 10,
        coinReward: 5,
        isCompleted: false
      },
      {
        id: "2",
        title: "Scan an ingredient list",
        xpReward: 5,
        coinReward: 3,
        isCompleted: false
      },
      {
        id: "3",
        title: "Generate a recipe",
        xpReward: 5,
        coinReward: 3,
        isCompleted: false
      }
    ];

    res.json({
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      coins: 0,
      streakDays: impact.streak_days || 0,
      missions: missions
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /progress/complete-mission
 * body: { userId, missionId }
 */
router.post("/complete-mission", async (req, res, next) => {
  try {
    const { userId, missionId } = req.body;
    if (!userId || !missionId) {
      return res.status(400).json({ error: "userId and missionId are required" });
    }

    // Award XP and coins (mock values)
    let impact = await UserImpact.findOne({ user_id: userId });
    if (!impact) {
      impact = await UserImpact.create({
        user_id: userId,
        xp: 0,
        total_meals_logged: 0,
        streak: 0,
        forest_stage: "SEED",
        last_activity_date: null
      });
    }

    // Award mission rewards (mock)
    impact.xp += 10;
    await impact.save();

    const xp = impact.xp;
    const level = Math.floor(xp / 100) + 1;
    const xpToNextLevel = level * 100 - xp;

    res.json({
      id: userId,
      userName: "User",
      eatingStyle: "vegan",
      dietaryRestrictions: [],
      cuisinePreferences: [],
      cookingStylePreferences: [],
      sproutName: "Bud",
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      coins: 0,
      streakDays: impact.streak_days || 0
    });
  } catch (err) {
    next(err);
  }
});

export default router;

