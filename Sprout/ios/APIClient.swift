import Foundation
import UIKit

// MARK: - API Client

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    init() {
        // Update with your backend URL - default to localhost:4000
        #if DEBUG
        self.baseURL = "http://localhost:4000"
        #else
        self.baseURL = "https://your-production-url.com"
        #endif
        self.session = URLSession.shared
    }
    
    // MARK: - Helper Methods
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        imageData: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body or image data
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        } else if let imageData = imageData {
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = createMultipartBody(imageData: imageData, boundary: boundary)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // Handle empty responses (e.g., DELETE requests)
        if data.isEmpty {
            // For empty responses, try to decode from empty JSON object
            if let emptyJSON = "{}".data(using: .utf8) {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: emptyJSON)
            }
            // If that fails, throw an error
            throw APIError.decodingError
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // Helper method for DELETE requests that don't return data
    private func deleteRequest(endpoint: String) async throws {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
    
    private func createMultipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    // MARK: - Onboarding
    
    func createProfile(_ profile: UserProfile) async throws -> UserProfile {
        struct Request: Encodable {
            let eatingStyle: String
            let dietaryRestrictions: [String]
            let cuisinePreferences: [String]
            let cookingStylePreferences: [String]
            let sproutName: String
        }
        
        let requestBody = Request(
            eatingStyle: profile.eatingStyle,
            dietaryRestrictions: profile.dietaryRestrictions,
            cuisinePreferences: profile.cuisinePreferences,
            cookingStylePreferences: profile.cookingStylePreferences,
            sproutName: profile.sproutName
        )
        
        return try await request(endpoint: "/onboarding/profile", method: "POST", body: requestBody)
    }
    
    // MARK: - Profile
    
    func getProfile(userId: String) async throws -> UserProfile {
        return try await request(endpoint: "/profile?userId=\(userId)")
    }
    
    func updateProfile(userId: String, profile: UserProfile) async throws -> UserProfile {
        struct Request: Encodable {
            let userId: String
            let userName: String?
            let eatingStyle: String?
            let dietaryRestrictions: [String]?
            let cuisinePreferences: [String]?
            let cookingStylePreferences: [String]?
            let sproutName: String?
        }
        
        let requestBody = Request(
            userId: userId,
            userName: profile.userName,
            eatingStyle: profile.eatingStyle,
            dietaryRestrictions: profile.dietaryRestrictions,
            cuisinePreferences: profile.cuisinePreferences,
            cookingStylePreferences: profile.cookingStylePreferences,
            sproutName: profile.sproutName
        )
        
        return try await request(endpoint: "/profile", method: "PATCH", body: requestBody)
    }
    
    // MARK: - Home
    
    struct HomeSummary: Codable {
        let level: Int
        let xp: Int
        let xpToNextLevel: Int
        let coins: Int
        let streakDays: Int
        let missions: [Mission]
    }
    
    func getHomeSummary(userId: String) async throws -> HomeSummary {
        return try await request(endpoint: "/home/summary?userId=\(userId)")
    }
    
    func completeMission(userId: String, missionId: String) async throws -> UserProfile {
        struct Request: Encodable {
            let userId: String
            let missionId: String
        }
        
        return try await request(
            endpoint: "/progress/complete-mission",
            method: "POST",
            body: Request(userId: userId, missionId: missionId)
        )
    }
    
    // MARK: - Scan
    
    struct ScanIngredientsResponse: Codable {
        let ingredients: [IngredientClassification]
    }
    
    struct IngredientClassificationResponse: Codable {
        let name: String
        let status: String
        let reason: String
        let suggestions: [String]?
    }
    
    func scanIngredients(image: UIImage, userId: String) async throws -> ScanIngredientsResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }
        
        struct Response: Codable {
            let ingredients: [IngredientClassificationResponse]
        }
        
        let response: Response = try await request(
            endpoint: "/scan/ingredients?userId=\(userId)",
            method: "POST",
            imageData: imageData
        )
        
        // Map to iOS format
        return ScanIngredientsResponse(
            ingredients: response.ingredients.map { item in
                let status: IngredientStatus
                switch item.status {
                case "allowed": status = .allowed
                case "not_allowed": status = .notAllowed
                default: status = .ambiguous
                }
                return IngredientClassification(
                    name: item.name,
                    status: status,
                    reason: item.reason,
                    suggestions: item.suggestions
                )
            }
        )
    }
    
    struct ScanMenuResponse: Codable {
        let dishes: [MenuDish]
    }
    
    struct MenuDishResponse: Codable {
        let name: String
        let status: String
        let modificationSuggestion: String?
    }
    
    func scanMenu(image: UIImage, userId: String) async throws -> ScanMenuResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }
        
        struct Response: Codable {
            let dishes: [MenuDishResponse]
        }
        
        let response: Response = try await request(
            endpoint: "/scan/menu?userId=\(userId)",
            method: "POST",
            imageData: imageData
        )
        
        // Map to iOS format
        return ScanMenuResponse(
            dishes: response.dishes.map { dish in
                let status: MenuDish.DishStatus
                switch dish.status {
                case "suitable": status = .suitable
                case "modifiable": status = .modifiable
                default: status = .notSuitable
                }
                return MenuDish(
                    name: dish.name,
                    status: status,
                    modificationSuggestion: dish.modificationSuggestion
                )
            }
        )
    }
    
    struct AlternativeProductResponse: Codable {
        let suggestions: [String]
    }
    
    func getAlternativeProduct(userId: String, productType: String, context: String? = nil) async throws -> AlternativeProductResponse {
        struct Request: Encodable {
            let userId: String
            let productType: String
            let context: String?
        }
        
        return try await request(
            endpoint: "/scan/alternative-product",
            method: "POST",
            body: Request(userId: userId, productType: productType, context: context)
        )
    }
    
    // MARK: - Grocery List
    
    func getGroceryList(userId: String) async throws -> [GroceryItem] {
        return try await request(endpoint: "/grocery-list?userId=\(userId)")
    }
    
    func categorizeGroceryItem(name: String) async throws -> String {
        struct Request: Encodable {
            let itemName: String
        }
        
        struct Response: Codable {
            let category: String
        }
        
        let requestBody = Request(itemName: name)
        let response: Response = try await request(endpoint: "/grocery-list/categorize", method: "POST", body: requestBody)
        return response.category
    }
    
    func addGroceryItem(userId: String, item: GroceryItem) async throws -> GroceryItem {
        struct Request: Encodable {
            let userId: String
            let name: String
            let category: String
        }
        
        let requestBody = Request(userId: userId, name: item.name, category: item.category)
        return try await request(endpoint: "/grocery-list", method: "POST", body: requestBody)
    }
    
    func updateGroceryItem(userId: String, item: GroceryItem) async throws -> GroceryItem {
        struct Request: Encodable {
            let userId: String
            let name: String
            let category: String
        }
        
        let requestBody = Request(userId: userId, name: item.name, category: item.category)
        return try await request(endpoint: "/grocery-list/\(item.id)", method: "PUT", body: requestBody)
    }
    
    func deleteGroceryItem(userId: String, itemId: String) async throws {
        try await deleteRequest(endpoint: "/grocery-list/\(itemId)?userId=\(userId)")
    }
    
    func scanFridge(image: UIImage, userId: String) async throws -> [GroceryItem] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }
        
        return try await request(
            endpoint: "/grocery-list/scan-fridge?userId=\(userId)",
            method: "POST",
            imageData: imageData
        )
    }
    
    func scanReceipt(image: UIImage, userId: String) async throws -> [GroceryItem] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }
        
        return try await request(
            endpoint: "/grocery-list/scan-receipt?userId=\(userId)",
            method: "POST",
            imageData: imageData
        )
    }
    
    // MARK: - Chat
    
    struct ChatResponse: Codable {
        let message: String
        let timestamp: String
    }
    
    func sendChatMessage(userId: String, message: String, conversationHistory: [ChatMessage]) async throws -> ChatResponse {
        struct Request: Encodable {
            let userId: String
            let message: String
            let conversationHistory: [ChatMessageRequest]
        }
        
        struct ChatMessageRequest: Encodable {
            let isUser: Bool
            let text: String
        }
        
        let history = conversationHistory.map { msg in
            ChatMessageRequest(isUser: msg.isUser, text: msg.text)
        }
        
        return try await request(
            endpoint: "/chat",
            method: "POST",
            body: Request(userId: userId, message: message, conversationHistory: history)
        )
    }
    
    // MARK: - Recipes
    
    func generateRecipe(userId: String) async throws -> Recipe {
        struct Request: Encodable {
            let userId: String
        }
        
        return try await request(
            endpoint: "/recipes/generate",
            method: "POST",
            body: Request(userId: userId)
        )
    }
    
    func veganizeRecipe(userId: String, inputText: String) async throws -> Recipe {
        struct Request: Encodable {
            let userId: String
            let inputText: String
        }
        
        return try await request(
            endpoint: "/recipes/veganize",
            method: "POST",
            body: Request(userId: userId, inputText: inputText)
        )
    }
    
    func getSavedRecipes(userId: String) async throws -> [Recipe] {
        return try await request(endpoint: "/recipes/saved?userId=\(userId)")
    }
    
    func saveRecipe(userId: String, recipe: Recipe) async throws -> Recipe {
        struct Request: Encodable {
            let userId: String
            let recipe: Recipe
        }
        
        return try await request(
            endpoint: "/recipes/save",
            method: "POST",
            body: Request(userId: userId, recipe: recipe)
        )
    }
    
    // MARK: - Dietary Restrictions Parsing
    
    struct ParseRestrictionsResponse: Codable {
        let restrictions: [String]
    }
    
    func parseDietaryRestrictions(text: String, userId: String) async throws -> ParseRestrictionsResponse {
        struct Request: Encodable {
            let userId: String
            let text: String
        }
        
        return try await request(
            endpoint: "/profile/parse-restrictions",
            method: "POST",
            body: Request(userId: userId, text: text)
        )
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImage
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidImage:
            return "Invalid image data"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
