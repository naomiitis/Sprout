// routes/onboarding.js
import express from "express";
import User from "../models/User.js";
import UserImpact from "../models/UserImpact.js";

const router = express.Router();

/**
 * POST /onboarding/profile
 * body: { eatingStyle, dietaryRestrictions, cuisinePreferences, cookingStylePreferences, sproutName }
 */
router.post("/profile", async (req, res, next) => {
  try {
    const { eatingStyle, dietaryRestrictions, cuisinePreferences, cookingStylePreferences, sproutName } = req.body;

    // Create new user
    const user = await User.create({
      name: "User",
      dietLevel: eatingStyle || "vegan",
      extraForbiddenTags: dietaryRestrictions || [],
      preferredCuisines: cuisinePreferences || []
    });

    // Create user impact
    await UserImpact.create({
      user_id: user._id,
      xp: 0,
      total_meals_logged: 0,
      streak: 0,
      forest_stage: "SEED",
      last_activity_date: null
    });

    res.json({
      id: user._id.toString(),
      userName: "User",
      eatingStyle: user.dietLevel,
      dietaryRestrictions: user.extraForbiddenTags,
      cuisinePreferences: user.preferredCuisines,
      cookingStylePreferences: cookingStylePreferences || [],
      sproutName: sproutName || "Bud",
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
      coins: 0,
      streakDays: 0
    });
  } catch (err) {
    next(err);
  }
});

export default router;

