import SwiftUI

@MainActor
class SproutViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Home data
    @Published var missions: [Mission] = []
    
    // Chat data
    @Published var chatMessages: [ChatMessage] = []
    
    // Grocery list
    @Published var groceryItems: [GroceryItem] = []
    
    // Saved recipes
    @Published var savedRecipes: [Recipe] = []
    
    // Scan data
    @Published var scannedIngredients: [IngredientClassification] = []
    @Published var scannedMenu: [MenuDish] = []
    @Published var recentScans: [RecentScan] = []
        
    private let apiClient = APIClient.shared
    
    init() {
        // Initialize with welcome message
        chatMessages = [
            ChatMessage(isUser: false, text: "Hi! What should we cook today?")
        ]
    }
    
    // MARK: - Profile Management
    
    func loadProfile(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            userProfile = try await apiClient.getProfile(userId: userId)
            await loadHomeData()
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
    
    func loadProfile() async {
        // Load profile using stored userId
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            errorMessage = "No user ID found. Please complete onboarding."
            return
        }
        await loadProfile(userId: userId)
    }
    
    func updateProfile(_ profile: UserProfile) async {
        let userId = profile.id
        isLoading = true
        defer { isLoading = false }
        
        do {
            userProfile = try await apiClient.updateProfile(userId: userId, profile: profile)
        } catch {
            // For development: update locally if backend fails
            #if DEBUG
            await MainActor.run {
                userProfile = profile
            }
            #else
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            #endif
        }
    }
    
    // MARK: - Home Data
    
    func loadHomeData() async {
        guard let userId = userProfile?.id else { return }
        do {
            let summary = try await apiClient.getHomeSummary(userId: userId)
            await MainActor.run {
                if let profile = userProfile {
                    userProfile = UserProfile(
                        id: profile.id,
                        userName: profile.userName,
                        eatingStyle: profile.eatingStyle,
                        dietaryRestrictions: profile.dietaryRestrictions,
                        cuisinePreferences: profile.cuisinePreferences,
                        cookingStylePreferences: profile.cookingStylePreferences,
                        sproutName: profile.sproutName,
                        level: summary.level,
                        xp: summary.xp,
                        xpToNextLevel: summary.xpToNextLevel,
                        coins: summary.coins,
                        streakDays: summary.streakDays
                    )
                }
                missions = summary.missions
                // If no missions returned, add sample missions in DEBUG mode
                #if DEBUG
                if missions.isEmpty {
                    missions = getSampleMissions()
                }
                #endif
            }
        } catch {
            #if DEBUG
            // Load sample missions for development
            await MainActor.run {
                missions = getSampleMissions()
            }
            #else
            errorMessage = "Failed to load home data: \(error.localizedDescription)"
            #endif
        }
    }
    
    // MARK: - Sample Data
    
    private func getSampleMissions() -> [Mission] {
        return [
            Mission(
                id: "mission-1",
                title: "Try a new plant-based protein",
                xpReward: 50,
                coinReward: 10,
                isCompleted: false
            ),
            Mission(
                id: "mission-2",
                title: "Scan 3 ingredient lists",
                xpReward: 75,
                coinReward: 15,
                isCompleted: false
            ),
            Mission(
                id: "mission-3",
                title: "Cook a vegan recipe",
                xpReward: 100,
                coinReward: 20,
                isCompleted: false
            ),
            Mission(
                id: "mission-4",
                title: "Add 5 items to grocery list",
                xpReward: 30,
                coinReward: 5,
                isCompleted: false
            ),
            Mission(
                id: "mission-5",
                title: "Complete your daily streak",
                xpReward: 25,
                coinReward: 5,
                isCompleted: false
            )
        ]
    }
    
    func completeMission(_ mission: Mission) async {
        guard let userId = userProfile?.id else { return }
        
        do {
            let updatedProfile = try await apiClient.completeMission(userId: userId, missionId: mission.id)
            userProfile = updatedProfile
            
            // Update mission status locally
            if let index = missions.firstIndex(where: { $0.id == mission.id }) {
                missions[index].isCompleted = true
            }
            
            // Reload home data to get updated missions
            await loadHomeData()
        } catch {
            errorMessage = "Failed to complete mission: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Chat & Recipes
    
    func addUserChat(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        chatMessages.append(ChatMessage(isUser: true, text: text))
    }
    
    func generateRecipe() async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recipe = try await apiClient.generateRecipe(userId: userId)
            let message = ChatMessage(isUser: false, text: "Here's a recipe for you!", recipe: recipe)
            chatMessages.append(message)
        } catch {
            errorMessage = "Failed to generate recipe: \(error.localizedDescription)"
            chatMessages.append(ChatMessage(isUser: false, text: "Sorry, I couldn't generate a recipe right now. Please try again."))
        }
    }
    
    func veganizeRecipe(inputText: String) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recipe = try await apiClient.veganizeRecipe(userId: userId, inputText: inputText)
            let message = ChatMessage(isUser: false, text: "Here's your veganized recipe!", recipe: recipe)
            chatMessages.append(message)
        } catch {
            errorMessage = "Failed to veganize recipe: \(error.localizedDescription)"
            chatMessages.append(ChatMessage(isUser: false, text: "Sorry, I couldn't veganize that recipe. Please try again."))
        }
    }
    
    func sendChatMessage(_ text: String) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.sendChatMessage(
                userId: userId,
                message: text,
                conversationHistory: chatMessages
            )
            let message = ChatMessage(isUser: false, text: response.message)
            chatMessages.append(message)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            chatMessages.append(ChatMessage(isUser: false, text: "Sorry, I'm having trouble right now. Please try again."))
        }
    }
    
    func saveRecipe(_ recipe: Recipe) async {
        guard let userId = userProfile?.id else { return }
        do {
            let saved = try await apiClient.saveRecipe(userId: userId, recipe: recipe)
            if !savedRecipes.contains(where: { $0.id == saved.id }) {
                savedRecipes.append(saved)
            }
        } catch {
            errorMessage = "Failed to save recipe: \(error.localizedDescription)"
        }
    }
    
    func loadSavedRecipes() async {
        guard let userId = userProfile?.id else { return }
        do {
            savedRecipes = try await apiClient.getSavedRecipes(userId: userId)
            // If no recipes returned, add sample recipes in DEBUG mode
            #if DEBUG
            if savedRecipes.isEmpty {
                await MainActor.run {
                    savedRecipes = getSampleRecipes(userId: userId)
                }
            }
            #endif
        } catch {
            #if DEBUG
            // Load sample recipes for development
            await MainActor.run {
                savedRecipes = getSampleRecipes(userId: userId)
            }
            #else
            errorMessage = "Failed to load saved recipes: \(error.localizedDescription)"
            #endif
        }
    }
    
    private func getSampleRecipes(userId: String) -> [Recipe] {
        return [
            Recipe(
                id: "recipe-1",
                userId: userId,
                title: "Creamy Vegan Pasta Primavera",
                tags: ["Italian", "Quick", "Comfort Food"],
                duration: "25 min",
                ingredients: [
                    RecipeIngredient(name: "Penne pasta", amount: "12 oz", unit: nil),
                    RecipeIngredient(name: "Cashews", amount: "1 cup, soaked", unit: nil),
                    RecipeIngredient(name: "Nutritional yeast", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Garlic", amount: "3 cloves", unit: nil),
                    RecipeIngredient(name: "Mixed vegetables", amount: "2 cups", unit: nil),
                    RecipeIngredient(name: "Olive oil", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Lemon juice", amount: "1 tbsp", unit: nil)
                ],
                steps: [
                    "Cook pasta according to package directions. Reserve 1 cup pasta water.",
                    "Sauté vegetables in olive oil until tender, about 5-7 minutes.",
                    "Blend soaked cashews, nutritional yeast, garlic, lemon juice, and 1/2 cup pasta water until smooth.",
                    "Toss pasta with vegetables and cashew cream sauce. Add more pasta water if needed.",
                    "Season with salt and pepper. Serve hot with fresh herbs."
                ],
                previewImageUrl: "",
                originalPrompt: nil,
                type: .veganized,
                substitutionMap: nil
            ),
            Recipe(
                id: "recipe-2",
                userId: userId,
                title: "Vegan Buddha Bowl",
                tags: ["Healthy", "Meal Prep", "Gluten-Free"],
                duration: "30 min",
                ingredients: [
                    RecipeIngredient(name: "Quinoa", amount: "1 cup, cooked", unit: nil),
                    RecipeIngredient(name: "Chickpeas", amount: "1 can, drained", unit: nil),
                    RecipeIngredient(name: "Sweet potato", amount: "1 large, cubed", unit: nil),
                    RecipeIngredient(name: "Kale", amount: "2 cups", unit: nil),
                    RecipeIngredient(name: "Avocado", amount: "1, sliced", unit: nil),
                    RecipeIngredient(name: "Tahini", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Lemon juice", amount: "1 tbsp", unit: nil),
                    RecipeIngredient(name: "Maple syrup", amount: "1 tsp", unit: nil)
                ],
                steps: [
                    "Preheat oven to 400°F. Toss sweet potato cubes with olive oil and roast for 20 minutes.",
                    "Cook quinoa according to package directions. Let cool slightly.",
                    "Drain and rinse chickpeas. Season with salt, pepper, and paprika.",
                    "Massage kale with a bit of olive oil and lemon juice to soften.",
                    "Make tahini dressing by mixing tahini, lemon juice, maple syrup, and water until smooth.",
                    "Assemble bowl: quinoa base, roasted sweet potato, chickpeas, kale, and avocado. Drizzle with dressing."
                ],
                previewImageUrl: "",
                originalPrompt: nil,
                type: .simplified,
                substitutionMap: nil
            ),
            Recipe(
                id: "recipe-3",
                userId: userId,
                title: "Vegan Chocolate Chip Cookies",
                tags: ["Dessert", "Baking", "Comfort Food"],
                duration: "20 min",
                ingredients: [
                    RecipeIngredient(name: "All-purpose flour", amount: "2 cups", unit: nil),
                    RecipeIngredient(name: "Vegan butter", amount: "1/2 cup, softened", unit: nil),
                    RecipeIngredient(name: "Brown sugar", amount: "3/4 cup", unit: nil),
                    RecipeIngredient(name: "White sugar", amount: "1/4 cup", unit: nil),
                    RecipeIngredient(name: "Flax egg", amount: "1 (1 tbsp ground flax + 3 tbsp water)", unit: nil),
                    RecipeIngredient(name: "Vanilla extract", amount: "1 tsp", unit: nil),
                    RecipeIngredient(name: "Baking soda", amount: "1 tsp", unit: nil),
                    RecipeIngredient(name: "Salt", amount: "1/2 tsp", unit: nil),
                    RecipeIngredient(name: "Vegan chocolate chips", amount: "1 cup", unit: nil)
                ],
                steps: [
                    "Preheat oven to 375°F. Line baking sheets with parchment paper.",
                    "Make flax egg by mixing ground flax with water. Let sit 5 minutes.",
                    "Cream vegan butter and both sugars until light and fluffy.",
                    "Add flax egg and vanilla. Mix well.",
                    "In separate bowl, whisk flour, baking soda, and salt.",
                    "Gradually mix dry ingredients into wet ingredients.",
                    "Fold in chocolate chips.",
                    "Drop rounded tablespoons of dough onto baking sheets. Bake 10-12 minutes until edges are golden.",
                    "Cool on baking sheet 5 minutes, then transfer to wire rack."
                ],
                previewImageUrl: "",
                originalPrompt: nil,
                type: .veganized,
                substitutionMap: nil
            ),
            Recipe(
                id: "recipe-4",
                userId: userId,
                title: "Vegan Pad Thai",
                tags: ["Thai", "Noodles", "Quick"],
                duration: "20 min",
                ingredients: [
                    RecipeIngredient(name: "Rice noodles", amount: "8 oz", unit: nil),
                    RecipeIngredient(name: "Tofu", amount: "14 oz, firm, cubed", unit: nil),
                    RecipeIngredient(name: "Bean sprouts", amount: "1 cup", unit: nil),
                    RecipeIngredient(name: "Carrots", amount: "2, julienned", unit: nil),
                    RecipeIngredient(name: "Green onions", amount: "3, chopped", unit: nil),
                    RecipeIngredient(name: "Lime", amount: "2, juiced", unit: nil),
                    RecipeIngredient(name: "Tamarind paste", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Soy sauce", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Brown sugar", amount: "2 tbsp", unit: nil),
                    RecipeIngredient(name: "Peanuts", amount: "1/4 cup, crushed", unit: nil)
                ],
                steps: [
                    "Soak rice noodles in warm water for 10 minutes until pliable. Drain.",
                    "Press and cube tofu. Pan-fry until golden on all sides.",
                    "Make sauce: mix tamarind paste, soy sauce, brown sugar, and lime juice.",
                    "Heat large wok or pan. Add noodles and sauce. Toss to combine.",
                    "Add tofu, carrots, and bean sprouts. Cook 2-3 minutes.",
                    "Garnish with green onions and crushed peanuts. Serve with lime wedges."
                ],
                previewImageUrl: "",
                originalPrompt: nil,
                type: .veganized,
                substitutionMap: nil
            )
        ]
    }
    
    // MARK: - Grocery List
    
    func loadGroceryList() async {
        guard let userId = userProfile?.id else { return }
        do {
            groceryItems = try await apiClient.getGroceryList(userId: userId)
        } catch {
            errorMessage = "Failed to load grocery list: \(error.localizedDescription)"
        }
    }
    
    func addGroceryItem(name: String, category: String? = nil) async {
        guard let userId = userProfile?.id else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // If no category provided, use AI to categorize
        var finalCategory = category ?? GroceryCategory.produce.rawValue
        if category == nil {
            do {
                finalCategory = try await apiClient.categorizeGroceryItem(name: trimmed)
            } catch {
                // If categorization fails, default to produce
                print("Failed to categorize item: \(error)")
                finalCategory = GroceryCategory.produce.rawValue
            }
        }
        
        let item = GroceryItem(
            id: UUID().uuidString,
            name: trimmed,
            category: finalCategory,
            isChecked: false,
            userId: userId
        )
        
        do {
            let added = try await apiClient.addGroceryItem(userId: userId, item: item)
            await MainActor.run {
                groceryItems.append(added)
            }
        } catch {
            // For development: add locally if backend fails
            #if DEBUG
            await MainActor.run {
                groceryItems.append(item)
            }
            #else
            errorMessage = "Failed to add item: \(error.localizedDescription)"
            #endif
        }
    }
    
    func updateGroceryItem(_ item: GroceryItem) async {
        guard let userId = userProfile?.id else { return }
        
        do {
            let updated = try await apiClient.updateGroceryItem(userId: userId, item: item)
            await MainActor.run {
                if let idx = groceryItems.firstIndex(where: { $0.id == item.id }) {
                    groceryItems[idx] = updated
                }
            }
        } catch {
            // For development: update locally if backend fails
            #if DEBUG
            await MainActor.run {
                if let idx = groceryItems.firstIndex(where: { $0.id == item.id }) {
                    groceryItems[idx] = item
                }
            }
            #else
            errorMessage = "Failed to update item: \(error.localizedDescription)"
            #endif
        }
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async {
        guard let userId = userProfile?.id else { return }
        
        do {
            try await apiClient.deleteGroceryItem(userId: userId, itemId: item.id)
            await MainActor.run {
                groceryItems.removeAll { $0.id == item.id }
            }
        } catch {
            // For development: delete locally if backend fails
            #if DEBUG
            await MainActor.run {
                groceryItems.removeAll { $0.id == item.id }
            }
            #else
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
            #endif
        }
    }
    
    func moveGroceryItem(_ item: GroceryItem, toCategory category: String) async {
        var updatedItem = item
        updatedItem.category = category
        await updateGroceryItem(updatedItem)
    }
    
    func toggleGroceryItem(_ item: GroceryItem) {
        guard let idx = groceryItems.firstIndex(where: { $0.id == item.id }) else { return }
        groceryItems[idx].isChecked.toggle()
    }
    
    func scanFridge(image: UIImage) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let items = try await apiClient.scanFridge(image: image, userId: userId)
            groceryItems.append(contentsOf: items)
        } catch {
            errorMessage = "Failed to scan fridge: \(error.localizedDescription)"
        }
    }
    
    func scanReceipt(image: UIImage) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let items = try await apiClient.scanReceipt(image: image, userId: userId)
            groceryItems.append(contentsOf: items)
        } catch {
            errorMessage = "Failed to scan receipt: \(error.localizedDescription)"
        }
    }
    
    func scanIngredients(image: UIImage) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.scanIngredients(image: image, userId: userId)
            scannedIngredients = response.ingredients
        } catch {
            errorMessage = "Failed to scan ingredients: \(error.localizedDescription)"
        }
    }
    
    func scanMenu(image: UIImage) async {
        guard let userId = userProfile?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.scanMenu(image: image, userId: userId)
            scannedMenu = response.dishes
        } catch {
            errorMessage = "Failed to scan menu: \(error.localizedDescription)"
        }
    }
    
    func getAlternativeProduct(productType: String, context: String) async -> [String] {
        guard let userId = userProfile?.id else { return [] }
        do {
            let response = try await apiClient.getAlternativeProduct(
                userId: userId,
                productType: productType,
                context: context
            )
            return response.suggestions
        } catch {
            print("Error fetching alternatives:", error)
            return []
        }
    }
}

extension SproutViewModel {
    var userName: String {
        userProfile?.userName ?? "User"
    }
    
    var sproutName: String {
        userProfile?.sproutName ?? "Bud"
    }
    
    var sproutLevel: Int {
        userProfile?.level ?? 1
    }
    
    var xp: Int {
        userProfile?.xp ?? 0
    }
    
    var xpToNextLevel: Int {
        userProfile?.xpToNextLevel ?? 100
    }
    
    var coins: Int {
        userProfile?.coins ?? 0
    }
    
    var streakDays: Int {
        userProfile?.streakDays ?? 0
    }
}
