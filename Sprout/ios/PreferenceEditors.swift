import SwiftUI

// MARK: - Eating Style Editor

struct EatingStyleEditorView: View {
    @EnvironmentObject var vm: SproutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedStyle: EatingStyle?
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.sproutBackground, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("What's your eating style?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .multilineTextAlignment(.center)
                        
                        Text("Choose the option that best describes you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 32)
                    
                    VStack(spacing: 16) {
                        ForEach(EatingStyle.allCases) { style in
                            EatingStyleCard(
                                style: style,
                                isSelected: selectedStyle == style
                            ) {
                                selectedStyle = style
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button {
                        guard let style = selectedStyle, let profile = vm.userProfile else { return }
                        isSaving = true
                        var updatedProfile = profile
                        updatedProfile.eatingStyle = style.rawValue
                        Task {
                            await vm.updateProfile(updatedProfile)
                            await MainActor.run {
                                isSaving = false
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: selectedStyle != nil ? [Color.sproutGreen, Color.sproutGreenDark] : [Color.gray, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: selectedStyle != nil ? Color.sproutGreen.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(selectedStyle == nil || isSaving)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let profile = vm.userProfile,
               let style = EatingStyle.allCases.first(where: { $0.rawValue == profile.eatingStyle }) {
                selectedStyle = style
            }
        }
        .navigationTitle("Eating Style")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Dietary Restrictions Editor

struct DietaryRestrictionsEditorView: View {
    @EnvironmentObject var vm: SproutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedRestrictions: Set<String> = []
    @State private var freeText: String = ""
    @State private var isParsing: Bool = false
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.sproutBackground, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("Any dietary restrictions?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .multilineTextAlignment(.center)
                        
                        Text("Select from common options or describe your restrictions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    
                    // Predefined chips
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Common Restrictions")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(DietaryRestrictionChip.allCases) { chip in
                                DietaryRestrictionChipView(
                                    chip: chip,
                                    isSelected: selectedRestrictions.contains(chip.rawValue)
                                ) {
                                    if selectedRestrictions.contains(chip.rawValue) {
                                        selectedRestrictions.remove(chip.rawValue)
                                    } else {
                                        selectedRestrictions.insert(chip.rawValue)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Free text input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Or describe your restrictions")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            TextField("e.g., allergic to peanuts, avoid palm oil", text: $freeText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            
                            Button {
                                parseFreeText()
                            } label: {
                                if isParsing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.sproutGreen)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.title3)
                                        .foregroundColor(.sproutGreen)
                                }
                            }
                            .disabled(freeText.isEmpty || isParsing)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Button {
                        guard let profile = vm.userProfile else { return }
                        isSaving = true
                        var updatedProfile = profile
                        updatedProfile.dietaryRestrictions = Array(selectedRestrictions)
                        Task {
                            await vm.updateProfile(updatedProfile)
                            await MainActor.run {
                                isSaving = false
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                            }
                        }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.sproutGreen, Color.sproutGreenDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.sproutGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let profile = vm.userProfile {
                selectedRestrictions = Set(profile.dietaryRestrictions)
            }
        }
        .navigationTitle("Dietary Restrictions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func parseFreeText() {
        guard !freeText.isEmpty, let userId = vm.userProfile?.id else { return }
        isParsing = true
        
        Task {
            do {
                let response = try await APIClient.shared.parseDietaryRestrictions(
                    text: freeText,
                    userId: userId
                )
                
                await MainActor.run {
                    for restriction in response.restrictions {
                        selectedRestrictions.insert(restriction)
                    }
                    freeText = ""
                    isParsing = false
                }
            } catch {
                await MainActor.run {
                    isParsing = false
                }
            }
        }
    }
}

// MARK: - Cuisine Preferences Editor

struct CuisinePreferencesEditorView: View {
    @EnvironmentObject var vm: SproutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCuisines: Set<String> = []
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.sproutBackground, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("Favorite cuisines?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .multilineTextAlignment(.center)
                        
                        Text("Select all that you enjoy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                        ForEach(CuisineOption.allCases) { cuisine in
                            CuisineCard(
                                cuisine: cuisine,
                                isSelected: selectedCuisines.contains(cuisine.rawValue)
                            ) {
                                if selectedCuisines.contains(cuisine.rawValue) {
                                    selectedCuisines.remove(cuisine.rawValue)
                                } else {
                                    selectedCuisines.insert(cuisine.rawValue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button {
                        guard let profile = vm.userProfile else { return }
                        isSaving = true
                        var updatedProfile = profile
                        updatedProfile.cuisinePreferences = Array(selectedCuisines)
                        Task {
                            await vm.updateProfile(updatedProfile)
                            await MainActor.run {
                                isSaving = false
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                            }
                        }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.sproutGreen, Color.sproutGreenDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.sproutGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let profile = vm.userProfile {
                selectedCuisines = Set(profile.cuisinePreferences)
            }
        }
        .navigationTitle("Cuisine Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cooking Style Preferences Editor

struct CookingStylePreferencesEditorView: View {
    @EnvironmentObject var vm: SproutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedStyles: Set<String> = []
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.sproutBackground, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("Cooking preferences?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.sproutGreenDark)
                            .multilineTextAlignment(.center)
                        
                        Text("What do you like to cook?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(CookingStyleOption.allCases) { style in
                            CookingStyleCard(
                                style: style,
                                isSelected: selectedStyles.contains(style.rawValue)
                            ) {
                                if selectedStyles.contains(style.rawValue) {
                                    selectedStyles.remove(style.rawValue)
                                } else {
                                    selectedStyles.insert(style.rawValue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button {
                        guard let profile = vm.userProfile else { return }
                        isSaving = true
                        var updatedProfile = profile
                        updatedProfile.cookingStylePreferences = Array(selectedStyles)
                        Task {
                            await vm.updateProfile(updatedProfile)
                            await MainActor.run {
                                isSaving = false
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                            }
                        }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.sproutGreen, Color.sproutGreenDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.sproutGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let profile = vm.userProfile {
                selectedStyles = Set(profile.cookingStylePreferences)
            }
        }
        .navigationTitle("Cooking Style")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views
// Note: Helper views (EatingStyleCard, DietaryRestrictionChipView, CuisineCard, CookingStyleCard) 
// are defined in OnboardingView.swift and reused here since they're in the same module.

