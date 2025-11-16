import SwiftUI


struct ScanView: View {
    @EnvironmentObject var vm: SproutViewModel
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var scanMode: ScanMode = .ingredients
    @State private var showingAlternatives = false
    @State private var selectedIngredient: IngredientClassification?
    @State private var alternatives: [String] = []
    @State private var showingSourceUnavailableAlert = false
    @State private var unavailableSourceMessage = ""
    
    enum ScanMode {
        case ingredients
        case menu
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.sproutBackground, Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Mode selector
                    if selectedImage == nil {
                        Picker("Scan Mode", selection: $scanMode) {
                            Text("Ingredients").tag(ScanMode.ingredients)
                            Text("Menu").tag(ScanMode.menu)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    if let image = selectedImage {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Scanned image
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                
                                if vm.isLoading {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .padding()
                                } else if scanMode == .ingredients && !vm.scannedIngredients.isEmpty {
                                    // Ingredients results
                                    VStack(alignment: .leading, spacing: 20) {
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.title3)
                                                .foregroundColor(.sproutGreen)
                                            Text("Scan Results")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                            Spacer()
                                        }
                                        
                                        VStack(spacing: 16) {
                                            ForEach(vm.scannedIngredients) { ingredient in
                                                IngredientResultRow(
                                                    ingredient: ingredient,
                                                    onRequestAlternative: {
                                                        selectedIngredient = ingredient
                                                        Task {
                                                            alternatives = await vm.getAlternativeProduct(
                                                                productType: ingredient.name,
                                                                context: ingredient.reason
                                                            )
                                                            showingAlternatives = true
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                    }
                                    .padding(24)
                                    .cardStyle()
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 24)
                                } else if scanMode == .menu && !vm.scannedMenu.isEmpty {
                                    // Menu results
                                    VStack(alignment: .leading, spacing: 20) {
                                        HStack {
                                            Image(systemName: "fork.knife")
                                                .font(.title3)
                                                .foregroundColor(.sproutGreen)
                                            Text("Menu Results")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                            Spacer()
                                        }
                                        
                                        VStack(spacing: 16) {
                                            ForEach(vm.scannedMenu) { dish in
                                                MenuDishRow(dish: dish)
                                            }
                                        }
                                    }
                                    .padding(24)
                                    .cardStyle()
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 24)
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 32) {
                                // Recent Scans Carousel
                                if !vm.recentScans.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Recent Scans")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.sproutGreenDark)
                                            .padding(.horizontal, 20)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(vm.recentScans) { scan in
                                                    RecentScanCard(scan: scan) {
                                                        selectedImage = scan.image
                                                        scanMode = scan.scanType == .ingredients ? .ingredients : .menu
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                    .padding(.top, 20)
                                }
                                
                                // Empty state
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        Color.sproutGreen.opacity(0.2),
                                                        Color.sproutGreen.opacity(0.1),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 30,
                                                    endRadius: 100
                                                )
                                            )
                                            .frame(width: 200, height: 200)
                                        
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 80))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color.sproutGreen, Color.sproutGreenDark],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Scan Ingredients")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                        Text("Scan an ingredient list or menu to see if it fits your preferences.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                }
                                
                                // Action buttons
                                VStack(spacing: 16) {
                                    ScanButton(
                                        title: "Take a Photo",
                                        icon: "camera.fill",
                                        color: .sproutGreen
                                    ) {
                                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                            sourceType = .camera
                                            showingImagePicker = true
                                        } else {
                                            unavailableSourceMessage = "Camera is not available on this device."
                                            showingSourceUnavailableAlert = true
                                        }
                                    }
                                    
                                    ScanButton(
                                        title: "Upload Image",
                                        icon: "photo.on.rectangle.angled",
                                        color: .sproutGreenDark
                                    ) {
                                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                            sourceType = .photoLibrary
                                            showingImagePicker = true
                                        } else {
                                            unavailableSourceMessage = "Photo library is not available on this device."
                                            showingSourceUnavailableAlert = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
            .alert("Source Unavailable", isPresented: $showingSourceUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(unavailableSourceMessage)
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    Task {
                        if scanMode == .ingredients {
                            await vm.scanIngredients(image: image)
                        } else {
                            await vm.scanMenu(image: image)
                        }
                        // Add to recent scans
                        if let image = newImage {
                            let recentScan = RecentScan(
                                image: image,
                                scanType: scanMode == .ingredients ? .ingredients : .menu,
                                timestamp: Date()
                            )
                            vm.recentScans.insert(recentScan, at: 0)
                            // Keep only last 10 scans
                            if vm.recentScans.count > 10 {
                                vm.recentScans = Array(vm.recentScans.prefix(10))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAlternatives) {
                if let ingredient = selectedIngredient {
                    AlternativesView(
                        ingredient: ingredient,
                        alternatives: alternatives
                    )
                }
            }
        }
    }
}

struct ScanButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .cardStyle()
        }
    }
}

struct IngredientResultRow: View {
    let ingredient: IngredientClassification
    let onRequestAlternative: () -> Void
    
    private var statusColor: Color {
        switch ingredient.status {
        case .allowed: return .sproutGreen
        case .ambiguous: return .sproutWarning
        case .notAllowed: return .sproutError
        }
    }
    
    private var statusIcon: String {
        switch ingredient.status {
        case .allowed: return "checkmark.circle.fill"
        case .ambiguous: return "exclamationmark.triangle.fill"
        case .notAllowed: return "xmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 18))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(ingredient.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(ingredient.reason)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if ingredient.status == .notAllowed {
                Button {
                    onRequestAlternative()
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                        Text("Suggest an alternative product")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.sproutGreen, Color.sproutGreenDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct MenuDishRow: View {
    let dish: MenuDish
    
    private var statusColor: Color {
        switch dish.status {
        case .suitable: return .sproutGreen
        case .modifiable: return .sproutWarning
        case .notSuitable: return .sproutError
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dish.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(dish.status.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            if let suggestion = dish.modificationSuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if dish.status == .modifiable {
                Button {
                    // Navigate to Cook tab with dish name
                } label: {
                    HStack {
                        Text("Veganize this dish")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.sproutGreen, Color.sproutGreenDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecentScanCard: View {
    let scan: RecentScan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(uiImage: scan.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.sproutGreen.opacity(0.3), lineWidth: 2)
                    )
                
                HStack(spacing: 4) {
                    Image(systemName: scan.scanType == .ingredients ? "list.bullet" : "fork.knife")
                        .font(.caption2)
                    Text(scan.scanType == .ingredients ? "Ingredients" : "Menu")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AlternativesView: View {
    let ingredient: IngredientClassification
    let alternatives: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Alternatives for \(ingredient.name):")
                        .font(.headline)
                        .foregroundColor(.sproutGreenDark)
                    
                    ForEach(alternatives, id: \.self) { alternative in
                        Text(alternative)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Alternatives")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

