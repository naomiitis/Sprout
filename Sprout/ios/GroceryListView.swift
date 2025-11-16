import SwiftUI

// MARK: - Grocery List View

struct GroceryListView: View {
    @EnvironmentObject var vm: SproutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var newItemName: String = ""
    @State private var selectedCategory: GroceryCategory = .produce
    @State private var showingImagePicker = false
    @State private var receiptImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingSourceUnavailableAlert = false
    @State private var unavailableSourceMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
            .navigationTitle("Grocery List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // open Saved Recipes
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.sproutYellow)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $receiptImage, sourceType: sourceType)
            }
            .alert("Source Unavailable", isPresented: $showingSourceUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(unavailableSourceMessage)
            }
            .onChange(of: receiptImage) { newImage in
                if let image = newImage {
                    Task {
                        await vm.scanReceipt(image: image)
                        receiptImage = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.sproutBackground, Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            inputSection
            Divider()
            groceryListSection
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            addItemInput
            scanButtons
        }
        .padding(20)
        .background(Color(.systemBackground))
    }
    
    private var addItemInput: some View {
        HStack(spacing: 12) {
            TextField("Add an item…", text: $newItemName)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
            
            categoryMenu
            
            addButton
        }
    }
    
    private var categoryMenu: some View {
        Menu {
            Picker("Category", selection: $selectedCategory) {
                ForEach(GroceryCategory.allCases) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.title3)
                .foregroundColor(.sproutGreen)
        }
    }
    
    private var addButton: some View {
        Button {
            addItem()
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.sproutGreen)
        }
        .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private var scanButtons: some View {
        HStack(spacing: 12) {
            scanReceiptButton
            uploadReceiptButton
            Spacer()
        }
    }
    
    private var scanReceiptButton: some View {
        Button {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                sourceType = .camera
                showingImagePicker = true
            } else {
                unavailableSourceMessage = "Camera is not available on this device."
                showingSourceUnavailableAlert = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.caption)
                Text("Scan Receipt")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.sproutGreenDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.sproutGreenDark.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var uploadReceiptButton: some View {
        Button {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                sourceType = .photoLibrary
                showingImagePicker = true
            } else {
                unavailableSourceMessage = "Photo library is not available on this device."
                showingSourceUnavailableAlert = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.caption)
                Text("Upload Receipt")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.sproutGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.sproutGreen.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var groceryListSection: some View {
        List {
            ForEach(GroceryCategory.allCases) { category in
                Section {
                    ForEach(itemsForCategory(category)) { item in
                        GroceryItemRow(
                            item: item,
                            onToggle: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    vm.toggleGroceryItem(item)
                                }
                            },
                            onEdit: { editedItem in
                                Task {
                                    await vm.updateGroceryItem(editedItem)
                                }
                            },
                            onMove: { item, newCategory in
                                Task {
                                    await vm.moveGroceryItem(item, toCategory: newCategory)
                                }
                            },
                            onDelete: { item in
                                Task {
                                    await vm.deleteGroceryItem(item)
                                }
                            }
                        )
                    }
                } header: {
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.sproutGreenDark)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Helper Methods
    
    private func addItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            // Don't pass category - let AI categorize it automatically
            await vm.addGroceryItem(name: trimmedName, category: nil)
            await MainActor.run {
                newItemName = ""
            }
        }
    }
    
    private func itemsForCategory(_ category: GroceryCategory) -> [GroceryItem] {
        vm.groceryItems.filter { $0.category == category.rawValue }
    }
}

// MARK: - Grocery Item Row

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    let onEdit: (GroceryItem) -> Void
    let onMove: (GroceryItem, String) -> Void
    let onDelete: (GroceryItem) -> Void
    
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var showingMoveMenu = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(item.isChecked ? Color.sproutGreen.opacity(0.2) : Color(.secondarySystemBackground))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(item.isChecked ? .sproutGreen : .secondary)
                }
            }
            
            if isEditing {
                TextField("Item name", text: $editedName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, design: .rounded))
                    .onSubmit {
                        saveEdit()
                    }
            } else {
                Text(item.name)
                    .font(.system(size: 16, design: .rounded))
                    .strikethrough(item.isChecked)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
            }
            
            Spacer()
            
            if !isEditing {
                Menu {
                    Button {
                        editedName = item.name
                        isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Menu {
                        ForEach(GroceryCategory.allCases) { category in
                            if category.rawValue != item.category {
                                Button(category.rawValue) {
                                    onMove(item, category.rawValue)
                                }
                            }
                        }
                    } label: {
                        Label("Move to", systemImage: "folder")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.sproutGreen)
                        .font(.system(size: 18))
                }
            } else {
                HStack(spacing: 8) {
                    Button {
                        saveEdit()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.sproutGreen)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Button {
                        cancelEdit()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete(item)
            }
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
        .onAppear {
            editedName = item.name
        }
    }
    
    private func saveEdit() {
        guard !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelEdit()
            return
        }
        
        var updatedItem = item
        updatedItem.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        onEdit(updatedItem)
        isEditing = false
    }
    
    private func cancelEdit() {
        editedName = item.name
        isEditing = false
    }
}

