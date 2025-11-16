// routes/recipes.js
import express from "express";
import Recipe from "../models/Recipe.js";
import { generateRecipes } from "../utils/llmClient.js";
import Grocery from "../models/grocery.js";
import UserImpact from "../models/UserImpact.js";

const router = express.Router();

/**
 * POST /recipes/generate
 * body: { userId }
 */
router.post("/generate", async (req, res, next) => {
  try {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    // Get user's groceries
    const groceries = await Grocery.find({ userID: userId }).lean();
    const ingredients = groceries.map(g => g.name);

    if (ingredients.length === 0) {
      return res.status(400).json({ error: "No ingredients found. Add items to your grocery list first." });
    }

    // Generate recipes
    const recipes = await generateRecipes(ingredients, 1);
    if (recipes.length === 0) {
      return res.status(500).json({ error: "Failed to generate recipe" });
    }

    const recipeData = recipes[0];
    
    // Save recipe to database
    const savedRecipe = await Recipe.create({
      userID: userId,
      recipe: [JSON.stringify(recipeData)]
    });

    // Award XP
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
    impact.xp += 5;
    await impact.save();

    // Format response for iOS
    res.json({
      id: savedRecipe._id.toString(),
      userId: userId,
      title: recipeData.title || "Generated Recipe",
      tags: recipeData.tags || [],
      duration: recipeData.duration || "30 min",
      ingredients: recipeData.ingredients || [],
      steps: recipeData.steps || [],
      previewImageUrl: recipeData.previewImageUrl || "",
      originalPrompt: null,
      type: "simplified",
      substitutionMap: null
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /recipes/veganize
 * body: { userId, inputText }
 */
router.post("/veganize", async (req, res, next) => {
  try {
    const { userId, inputText } = req.body;
    if (!userId || !inputText) {
      return res.status(400).json({ error: "userId and inputText are required" });
    }

    // Use the veganize route logic
    // This will be handled by the veganize route
    res.status(501).json({ error: "Use /recipes/veganize/analyze and /recipes/veganize/commit" });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /recipes/saved?userId=xxx
 */
router.get("/saved", async (req, res, next) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    const recipes = await Recipe.find({ userID: userId }).lean();
    
    // Parse recipe data
    const formattedRecipes = recipes.map(r => {
      try {
        const recipeData = JSON.parse(r.recipe[0] || "{}");
        return {
          id: r._id.toString(),
          userId: userId,
          title: recipeData.title || "Recipe",
          tags: recipeData.tags || [],
          duration: recipeData.duration || "30 min",
          ingredients: recipeData.ingredients || [],
          steps: recipeData.steps || [],
          previewImageUrl: recipeData.previewImageUrl || "",
          originalPrompt: recipeData.originalPrompt || null,
          type: recipeData.type || "simplified",
          substitutionMap: recipeData.substitutionMap || null
        };
      } catch {
        return {
          id: r._id.toString(),
          userId: userId,
          title: "Recipe",
          tags: [],
          duration: "30 min",
          ingredients: [],
          steps: [],
          previewImageUrl: "",
          originalPrompt: null,
          type: "simplified",
          substitutionMap: null
        };
      }
    });

    res.json(formattedRecipes);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /recipes/save
 * body: { userId, recipe }
 */
router.post("/save", async (req, res, next) => {
  try {
    const { userId, recipe } = req.body;
    if (!userId || !recipe) {
      return res.status(400).json({ error: "userId and recipe are required" });
    }

    const savedRecipe = await Recipe.create({
      userID: userId,
      recipe: [JSON.stringify(recipe)]
    });

    res.json({
      id: savedRecipe._id.toString(),
      userId: userId,
      title: recipe.title || "Recipe",
      tags: recipe.tags || [],
      duration: recipe.duration || "30 min",
      ingredients: recipe.ingredients || [],
      steps: recipe.steps || [],
      previewImageUrl: recipe.previewImageUrl || "",
      originalPrompt: recipe.originalPrompt || null,
      type: recipe.type || "simplified",
      substitutionMap: recipe.substitutionMap || null
    });
  } catch (err) {
    next(err);
  }
});

export default router;

