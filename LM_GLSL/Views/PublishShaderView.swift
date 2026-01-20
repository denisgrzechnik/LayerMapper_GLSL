//
//  PublishShaderView.swift
//  LM_GLSL
//
//  View for publishing a shader to the community gallery
//

import SwiftUI

struct PublishShaderView: View {
    let shader: ShaderEntity
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var cloudService = CloudKitShaderService.shared
    
    @State private var authorName: String = ""
    @State private var shaderDescription: String = ""
    @State private var selectedCategory: String = "Basic"
    @State private var isPublishing: Bool = false
    @State private var publishError: String?
    @State private var showingSuccess: Bool = false
    
    private let categories = [
        "Basic", "Abstract", "Geometric", "Nature", "Cosmic", 
        "Retro", "Psychedelic", "Patterns", "Fractals", "Tunnels",
        "Organic", "Tech", "Neon", "Minimal", "Motion"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Shader info
                        shaderInfoSection
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Author info
                        authorSection
                        
                        // Description
                        descriptionSection
                        
                        // Category
                        categorySection
                        
                        // Terms
                        termsSection
                        
                        // Error message
                        if let error = publishError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Publish button
                        publishButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Publish Shader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Pre-fill category from shader
            selectedCategory = shader.category.rawValue
            shaderDescription = shader.shaderDescription
            
            // Load saved author name
            if let savedName = UserDefaults.standard.string(forKey: "publishAuthorName") {
                authorName = savedName
            }
        }
        .alert("Shader Published!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your shader '\(shader.name)' is now available in the community gallery!")
        }
    }
    
    // MARK: - Shader Info Section
    
    private var shaderInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shader")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                // Thumbnail placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 45)
                    .overlay(
                        Image(systemName: "sparkles")
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(shader.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(shader.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Author Section
    
    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Name")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextField("Enter your name or nickname", text: $authorName)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(white: 0.15))
                .foregroundColor(.white)
                .cornerRadius(10)
            
            Text("This will be shown as the shader author")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextEditor(text: $shaderDescription)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(white: 0.15))
                .foregroundColor(.white)
                .cornerRadius(10)
                .scrollContentBackground(.hidden)
            
            Text("Describe what makes this shader unique")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(selectedCategory == category ? .bold : .regular)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color(white: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text("By publishing, you confirm this shader is your original work and you grant other users the right to use it in their projects.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Publish Button
    
    private var publishButton: some View {
        Button(action: publishShader) {
            HStack {
                if isPublishing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "cloud.fill")
                }
                Text(isPublishing ? "Publishing..." : "Publish to Community")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canPublish ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!canPublish || isPublishing)
    }
    
    private var canPublish: Bool {
        !authorName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Publish Action
    
    private func publishShader() {
        let trimmedName = authorName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            publishError = "Please enter your name"
            return
        }
        
        // Save author name for future
        UserDefaults.standard.set(trimmedName, forKey: "publishAuthorName")
        
        isPublishing = true
        publishError = nil
        
        Task {
            do {
                // Generate thumbnail data (optional)
                var thumbnailData: Data? = nil
                if let thumbData = shader.thumbnailData {
                    thumbnailData = thumbData
                }
                
                _ = try await cloudService.publishShader(
                    name: shader.name,
                    fragmentCode: shader.fragmentCode,
                    category: selectedCategory,
                    authorName: trimmedName,
                    description: shaderDescription,
                    thumbnailData: thumbnailData
                )
                
                isPublishing = false
                showingSuccess = true
                
            } catch {
                isPublishing = false
                publishError = error.localizedDescription
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockShader = ShaderEntity(
        name: "Rainbow Wave",
        fragmentCode: "// shader code",
        category: .abstract
    )
    return PublishShaderView(shader: mockShader)
}
