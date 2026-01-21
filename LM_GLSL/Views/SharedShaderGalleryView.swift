//
//  SharedShaderGalleryView.swift
//  LM_GLSL
//
//  Gallery view for browsing and downloading community-shared shaders
//

import SwiftUI
import SwiftData
import CloudKit

struct SharedShaderGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var cloudService = CloudKitShaderService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOption: CloudKitShaderService.SortOption = .newest
    @State private var selectedShader: CloudKitShaderService.SharedShader?
    @State private var showingShaderDetail: Bool = false
    @State private var downloadedCode: String?
    @State private var showingDownloadSuccess: Bool = false
    
    // Callback when shader is imported (now receives ShaderEntity)
    var onImport: ((ShaderEntity) -> Void)?
    
    private let categories = ["All", "Basic", "Abstract", "Geometric", "Nature", "Cosmic", "Retro", "Psychedelic", "Patterns", "Fractals"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filter Bar
                    filterBar
                    
                    // Content
                    if cloudService.isLoading {
                        loadingView
                    } else if cloudService.sharedShaders.isEmpty {
                        emptyView
                    } else {
                        shaderGrid
                    }
                }
            }
            .navigationTitle("Community Shaders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await cloudService.fetchPublicShaders(
                                category: selectedCategory,
                                sortBy: sortOption
                            )
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await cloudService.fetchPublicShaders()
            }
        }
        .sheet(isPresented: $showingShaderDetail) {
            if let shader = selectedShader {
                ShaderDetailSheet(
                    shader: shader,
                    modelContext: modelContext,
                    onImport: { newShader in
                        onImport?(newShader)
                        showingDownloadSuccess = true
                        dismiss()
                    }
                )
            }
        }
        .alert("Shader Imported!", isPresented: $showingDownloadSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The shader has been added to your collection.")
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        VStack(spacing: 8) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search shaders...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .onSubmit {
                        Task {
                            if searchText.isEmpty {
                                await cloudService.fetchPublicShaders(
                                    category: selectedCategory,
                                    sortBy: sortOption
                                )
                            } else {
                                await cloudService.searchShaders(query: searchText)
                            }
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        Task {
                            await cloudService.fetchPublicShaders(
                                category: selectedCategory,
                                sortBy: sortOption
                            )
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(white: 0.15))
            .cornerRadius(10)
            
            // Category and Sort
            HStack {
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                Task {
                                    await cloudService.fetchPublicShaders(
                                        category: category,
                                        sortBy: sortOption
                                    )
                                }
                            }) {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(selectedCategory == category ? .bold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color.blue : Color(white: 0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Sort menu
                Menu {
                    Button(action: { 
                        sortOption = .newest
                        refreshShaders()
                    }) {
                        Label("Newest", systemImage: sortOption == .newest ? "checkmark" : "")
                    }
                    Button(action: { 
                        sortOption = .popular
                        refreshShaders()
                    }) {
                        Label("Most Popular", systemImage: sortOption == .popular ? "checkmark" : "")
                    }
                    Button(action: { 
                        sortOption = .name
                        refreshShaders()
                    }) {
                        Label("Name", systemImage: sortOption == .name ? "checkmark" : "")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOptionText)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    private var sortOptionText: String {
        switch sortOption {
        case .newest: return "Newest"
        case .popular: return "Popular"
        case .name: return "Name"
        }
    }
    
    private func refreshShaders() {
        Task {
            await cloudService.fetchPublicShaders(
                category: selectedCategory,
                sortBy: sortOption
            )
        }
    }
    
    // MARK: - Shader Grid
    
    private var shaderGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(cloudService.sharedShaders) { shader in
                    SharedShaderCard(shader: shader) {
                        selectedShader = shader
                        showingShaderDetail = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading shaders...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No shaders found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Be the first to share a shader!")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let error = cloudService.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shared Shader Card

struct SharedShaderCard: View {
    let shader: CloudKitShaderService.SharedShader
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Color(hex: "#FE144D") ?? .red, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                // Name
                Text(shader.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Author and stats
                HStack {
                    Text(shader.authorName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Label("\(shader.likes)", systemImage: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.pink)
                        
                        Label("\(shader.downloadCount)", systemImage: "arrow.down.circle")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(8)
            .background(Color(white: 0.12))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shader Detail Sheet

struct ShaderDetailSheet: View {
    let shader: CloudKitShaderService.SharedShader
    let modelContext: ModelContext
    let onImport: (ShaderEntity) -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var cloudService = CloudKitShaderService.shared
    @State private var isDownloading: Bool = false
    @State private var hasLiked: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Preview placeholder
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#FE144D") ?? .red, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                        
                        // Title and author
                        VStack(alignment: .leading, spacing: 4) {
                            Text(shader.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("by \(shader.authorName)")
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(shader.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.3))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Description
                        if !shader.shaderDescription.isEmpty {
                            Text(shader.shaderDescription)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Stats
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(shader.likes)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Likes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack {
                                Text("\(shader.downloadCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Downloads")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack {
                                Text(shader.dateCreated, style: .date)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Created")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.1))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 20)
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            // Like button
                            Button(action: {
                                if !hasLiked {
                                    hasLiked = true
                                    Task {
                                        await cloudService.likeShader(shader)
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: hasLiked ? "heart.fill" : "heart")
                                    Text(hasLiked ? "Liked" : "Like")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(hasLiked ? Color.pink : Color(white: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(hasLiked)
                            
                            // Download button
                            Button(action: {
                                isDownloading = true
                                Task {
                                    do {
                                        let newShader = try await cloudService.downloadShaderAsEntity(shader)
                                        await MainActor.run {
                                            modelContext.insert(newShader)
                                            do {
                                                try modelContext.save()
                                                print("✅ Community shader '\(shader.name)' saved successfully to local database")
                                                onImport(newShader)
                                            } catch {
                                                print("❌ Failed to save community shader: \(error)")
                                            }
                                        }
                                    } catch {
                                        print("❌ Failed to download shader: \(error)")
                                    }
                                    isDownloading = false
                                }
                            }) {
                                HStack {
                                    if isDownloading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.down.circle.fill")
                                    }
                                    Text("Import")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isDownloading)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Shader Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SharedShaderGalleryView()
        .modelContainer(for: [ShaderEntity.self], inMemory: true)
}
