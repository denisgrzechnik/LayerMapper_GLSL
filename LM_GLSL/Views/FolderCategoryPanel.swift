//
//  FolderCategoryPanel.swift
//  LM_GLSL
//
//  Panel with folders and categories tabs for Grid view
//

import SwiftUI
import SwiftData

/// Panel z zakładkami Folder i Category
struct FolderCategoryPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShaderFolder.order) private var folders: [ShaderFolder]
    
    @Binding var selectedFolder: ShaderFolder?
    @Binding var selectedCategory: ShaderCategory?
    @Binding var showingNewShaderSheet: Bool
    @Binding var viewMode: ViewMode
    @Binding var showingParametersView: Bool
    var selectedShader: ShaderEntity?
    
    // Sync service for broadcast button
    @ObservedObject var syncService: ShaderSyncService
    
    @State private var selectedTab: PanelTab = .folder
    @State private var showingNewFolderSheet: Bool = false
    @State private var newFolderName: String = ""
    
    enum PanelTab: String, CaseIterable {
        case folder = "Folder"
        case category = "Category"
        
        var icon: String {
            switch self {
            case .folder: return "folder.fill"
            case .category: return "square.grid.2x2.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("GLSL Shaders")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Function buttons row
            functionButtonsRow
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            
            Divider()
                .background(Color(white: 0.2))
            
            // Tab selector with add button
            HStack(spacing: 0) {
                // Add button (folder or category depending on tab)
                Button(action: {
                    if selectedTab == .folder {
                        showingNewFolderSheet = true
                    } else {
                        // For categories, could show a category creation sheet
                        // For now, categories are predefined
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(white: 0.6))
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.15))
                }
                
                ForEach(PanelTab.allCases, id: \.rawValue) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                            // Clear selections when switching tabs
                            if tab == .folder {
                                selectedCategory = nil
                            } else {
                                selectedFolder = nil
                            }
                        }
                    }) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14))
                            .foregroundColor(selectedTab == tab ? .white : Color(white: 0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color(white: 0.2) : Color.clear)
                    }
                }
            }
            .background(Color(white: 0.1))
            
            Divider()
                .background(Color(white: 0.2))
            
            // Content based on selected tab
            ScrollView {
                VStack(spacing: 4) {
                    if selectedTab == .folder {
                        foldersList
                    } else {
                        categoriesList
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .background(Color(white: 0.05))
        .sheet(isPresented: $showingNewFolderSheet) {
            newFolderSheet
        }
    }
    
    // MARK: - Function Buttons Row
    
    private var functionButtonsRow: some View {
        let slotColumns = [
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6)
        ]
        
        return VStack(spacing: 6) {
            // First row: 2 buttons + 1 slot
            HStack(spacing: 8) {
                // Favorites toggle - show all favorites
                Button(action: {
                    // Could add favorites filter here
                }) {
                    Image(systemName: "heart")
                        .font(.body)
                        .foregroundColor(Color(white: 0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                }
                
                // Add Custom button
                Button(action: { showingNewShaderSheet = true }) {
                    Image(systemName: "plus")
                        .font(.body)
                        .foregroundColor(Color(white: 0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                }
            }
            
            // 6 slots grid
            LazyVGrid(columns: slotColumns, spacing: 6) {
                // Broadcast toggle button
                Button(action: {
                    if syncService.isAdvertising {
                        syncService.stop()
                    } else {
                        syncService.start()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(syncService.isAdvertising ? Color.green.opacity(0.3) : Color(white: 0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(syncService.isAdvertising ? Color.green : Color(white: 0.2), lineWidth: syncService.isAdvertising ? 2 : 1)
                            )
                            .cornerRadius(6)
                        
                        VStack(spacing: 4) {
                            Image(systemName: syncService.isAdvertising ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                                .font(.system(size: 16))
                                .foregroundColor(syncService.isAdvertising ? .green : Color(white: 0.4))
                            
                            if syncService.isConnected && syncService.connectedReceivers.count > 0 {
                                Text("\(syncService.connectedReceivers.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Parameters button for current shader
                Button(action: {
                    if selectedShader != nil {
                        showingParametersView = true
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(selectedShader != nil ? Color(white: 0.1) : Color(white: 0.05))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16))
                            .foregroundColor(selectedShader != nil ? Color(white: 0.6) : Color(white: 0.3))
                    }
                }
                .disabled(selectedShader == nil)
                
                // View mode toggle button (switch back to Preview)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewMode = .preview
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .cornerRadius(6)
                        
                        Image(systemName: "rectangle.center.inset.filled")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
                
                // Empty slots
                ForEach(0..<3, id: \.self) { _ in
                    emptySlotButton
                }
            }
        }
    }
    
    // MARK: - Folders List
    
    private var foldersList: some View {
        VStack(spacing: 4) {
            // "All" option
            FolderRowItem(
                name: "All Shaders",
                icon: "square.grid.2x2.fill",
                color: .gray,
                count: nil,
                isSelected: selectedFolder == nil
            ) {
                selectedFolder = nil
            }
            
            // User folders
            ForEach(folders) { folder in
                FolderRowItem(
                    name: folder.name,
                    icon: folder.iconName,
                    color: Color(hex: folder.colorHex) ?? .gray,
                    count: folder.shaderCount,
                    isSelected: selectedFolder?.id == folder.id
                ) {
                    selectedFolder = folder
                }
                .contextMenu {
                    Button(role: .destructive) {
                        deleteFolder(folder)
                    } label: {
                        Label("Delete Folder", systemImage: "trash")
                    }
                }
            }
            
            if folders.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.title2)
                        .foregroundColor(Color(white: 0.3))
                    Text("No folders yet")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.4))
                    Text("Tap + to create one")
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Categories List
    
    private var categoriesList: some View {
        VStack(spacing: 4) {
            ForEach(ShaderCategory.allCases) { category in
                CategoryRowItem(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    selectedCategory = category
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Empty Slot
    
    private var emptySlotButton: some View {
        Rectangle()
            .fill(Color(white: 0.1))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
            .cornerRadius(6)
    }
    
    // MARK: - New Folder Sheet
    
    private var newFolderSheet: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Enter folder name", text: $newFolderName)
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newFolderName = ""
                        showingNewFolderSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createFolder()
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Actions
    
    private func createFolder() {
        let trimmedName = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let folder = ShaderFolder(
            name: trimmedName,
            order: folders.count
        )
        modelContext.insert(folder)
        try? modelContext.save()
        
        newFolderName = ""
        showingNewFolderSheet = false
    }
    
    private func deleteFolder(_ folder: ShaderFolder) {
        if selectedFolder?.id == folder.id {
            selectedFolder = nil
        }
        modelContext.delete(folder)
        try? modelContext.save()
    }
}

// MARK: - Folder Row Item

struct FolderRowItem: View {
    let name: String
    let icon: String
    let color: Color
    let count: Int?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 18)
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(white: 0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(isSelected ? Color(white: 0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Row Item

struct CategoryRowItem: View {
    let category: ShaderCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(category.color)
                    .frame(width: 18)
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(isSelected ? Color(white: 0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FolderCategoryPanel(
        selectedFolder: .constant(nil),
        selectedCategory: .constant(nil),
        showingNewShaderSheet: .constant(false),
        viewMode: .constant(.grid),
        showingParametersView: .constant(false),
        selectedShader: nil,
        syncService: ShaderSyncService()
    )
    .modelContainer(for: [ShaderFolder.self], inMemory: true)
}
