import { GoogleGenerativeAI } from "@google/generative-ai";
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

//
// Extract ingredients
//
async function extractIngredients(recipeText) {
    const prompt = `
Extract ALL ingredients from the recipe below.
Return only a list with one ingredient per line.
No numbering, no extra text.

Recipe:
"""
${recipeText}
"""
`;

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
        const result = await model.generateContent(prompt);
        const text = result.response.text();

        return text
            .split("\n")
            .map(line => line.trim())
            .filter(Boolean);
    } catch (err) {
        console.error("extractIngredients error:", err);
        return [];
    }
}

//
// Rewrite recipe steps
//
async function rewriteRecipeSteps(subs, originalRecipe) {
    let instructions = "";
    subs.forEach(s => {
        if (s.substitute)
            instructions += `Replace "${s.original}" with "${s.substitute}".\n`;
    });

    const prompt = `
Rewrite the following recipe to incorporate the listed substitutions.

Substitutions:
${instructions}

Original Recipe:
"""
${originalRecipe}
"""

Return ONLY the rewritten recipe text.
`;

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
        const result = await model.generateContent(prompt);
        return result.response.text();
    } catch (err) {
        console.error("rewriteRecipeSteps error:", err);
        return originalRecipe;
    }
}



/**
 * Check if ingredients are allowed for a user
 * @param {Object} userPrefs { dietLevel: string, extraForbiddenTags: [string] }
 * @param {string[]} ingredientTags
 * @returns {Object} { allowed: boolean, reasons: [string] }
 */
async function isAllowedForUser(userPrefs, ingredientTags) {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `
        You are a dietary compliance assistant.
        User dietary preferences:
        Diet Level: ${userPrefs.dietLevel}
        Extra Forbidden Tags: ${userPrefs.extraForbiddenTags?.join(', ') || 'none'}

        For each ingredient tag: ${ingredientTags.join(', ')}
        Decide if it is allowed (true/false) and explain why if not allowed.
        Return JSON array:
        [
        { "ingredient": "name", "allowed": Allowed/NotAllowed/Ambiguous, "reason": "..." }
        ]
`;

    try {
        const result = await model.generateContent(prompt);
        const raw = result.response.text();
        return JSON.parse(raw);
    } catch (err) {
        console.error("❌ Failed to check diet:", err, "\nRaw:", err?.response || "");
        return ingredientTags.map(tag => ({ ingredient: tag, allowed: true, reason: "" }));
    }
}

/**
 * Generate recipes from ingredients
 * @param {string[]} ingredients
 * @param {number} count
 * @returns {Promise<Array>} Array of recipe objects
 */
async function generateRecipes(ingredients, count = 3) {
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
    
    const prompt = `
Generate ${count} vegan recipes using these ingredients: ${ingredients.join(', ')}.

For each recipe, return a JSON object with this structure:
{
  "title": "Recipe Name",
  "tags": ["tag1", "tag2"],
  "duration": "30 min",
  "ingredients": [
    {"name": "ingredient name", "amount": "1", "unit": "cup"}
  ],
  "steps": ["Step 1", "Step 2", ...],
  "previewImageUrl": ""
}

Return a JSON array of ${count} recipes.
`;

    try {
        const result = await model.generateContent(prompt);
        const text = result.response.text();
        // Extract JSON from markdown code blocks if present
        const jsonMatch = text.match(/\[[\s\S]*\]/);
        if (jsonMatch) {
            return JSON.parse(jsonMatch[0]);
        }
        return JSON.parse(text);
    } catch (err) {
        console.error("generateRecipes error:", err);
        return [];
    }
}

/**
 * Chat with the AI assistant
 * @param {string} message - User's message
 * @param {Array} conversationHistory - Previous messages in format [{role: "user"|"assistant", content: "..."}]
 * @param {Object} userPrefs - User preferences { dietLevel, extraForbiddenTags, preferredCuisines }
 * @returns {Promise<string>} Assistant's response
 */
async function chatWithAssistant(message, conversationHistory = [], userPrefs = {}) {
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
    
    // Build system prompt with user preferences
    const systemInstruction = `You are Sprout, a friendly and helpful vegan cooking assistant. 
You help users with:
- Vegan recipe suggestions
- Ingredient substitutions
- Cooking tips and advice
- Dietary compliance questions
- General vegan lifestyle questions

User preferences:
- Diet: ${userPrefs.dietLevel || "vegan"}
- Dietary restrictions: ${userPrefs.extraForbiddenTags?.join(", ") || "none"}
- Preferred cuisines: ${userPrefs.preferredCuisines?.join(", ") || "various"}

Be friendly, encouraging, and helpful. Keep responses concise but informative.`;

    try {
        // Build conversation history for Gemini
        const history = conversationHistory.map(msg => ({
            role: msg.role === "user" ? "user" : "model",
            parts: [{ text: msg.content }]
        }));

        // Start chat with history and system instruction
        const chat = model.startChat({
            history: history,
            systemInstruction: systemInstruction
        });

        // Send current message
        const result = await chat.sendMessage(message);
        return result.response.text();
    } catch (err) {
        console.error("chatWithAssistant error:", err);
        return "I'm sorry, I'm having trouble right now. Please try again!";
    }
}

export {
    extractIngredients,
    rewriteRecipeSteps,
    isAllowedForUser,
    generateRecipes,
    chatWithAssistant
};
