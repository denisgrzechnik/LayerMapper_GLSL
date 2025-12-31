//
//  ShaderSettingsView.swift
//  LM_GLSL
//
//  Created on 31/12/2024
//  Shader settings, info and code preview view
//

import SwiftUI
import SwiftData

struct ShaderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var shader: ShaderEntity
    
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    @State private var selectedCategory: ShaderCategory = .basic
    @State private var showCodePreview: Bool = false
    @State private var showSaveConfirmation: Bool = false
    @State private var isCopied: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Shader Info Section
                    infoSection
                    
                    // Category Section
                    categorySection
                    
                    // Tags Section
                    tagsSection
                    
                    // Stats Section
                    statsSection
                    
                    // Code Preview Section
                    codeSection
                }
                .padding()
            }
            .background(Color(white: 0.08))
            .navigationTitle("Shader Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            editedName = shader.name
            editedDescription = shader.shaderDescription
            selectedCategory = shader.category
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Information", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.cyan)
            
            VStack(spacing: 12) {
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Shader name", text: $editedName)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(3...6)
                        .padding(10)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                }
                
                // Author
                HStack {
                    Text("Author")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(shader.author)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Category", systemImage: "folder.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(ShaderCategory.allCases.filter { $0 != .all }, id: \.id) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.rawValue)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(selectedCategory == category ? category.color.opacity(0.3) : Color(white: 0.15))
                        .foregroundColor(selectedCategory == category ? category.color : .gray)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selectedCategory == category ? category.color : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Tags", systemImage: "tag.fill")
                .font(.headline)
                .foregroundColor(.green)
            
            if shader.tags.isEmpty {
                Text("No tags")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(shader.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Statistics", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundColor(.purple)
            
            HStack(spacing: 20) {
                StatItem(title: "Views", value: "\(shader.viewCount)", icon: "eye.fill")
                StatItem(title: "Rating", value: String(format: "%.1f", shader.rating), icon: "star.fill")
                StatItem(title: "Created", value: formatDate(shader.dateCreated), icon: "calendar")
            }
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Code Section
    
    private var codeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = shader.fragmentCode
                    withAnimation {
                        isCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copied!" : "Copy")
                    }
                    .font(.caption)
                    .foregroundColor(isCopied ? .green : .yellow)
                }
                
                Button {
                    withAnimation {
                        showCodePreview.toggle()
                    }
                } label: {
                    Image(systemName: showCodePreview ? "chevron.up" : "chevron.down")
                        .foregroundColor(.yellow)
                }
            }
            
            if showCodePreview {
                ScrollView(.horizontal, showsIndicators: true) {
                    Text(shader.fragmentCode)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.green.opacity(0.9))
                        .padding()
                }
                .frame(maxHeight: 300)
                .background(Color.black)
                .cornerRadius(8)
            } else {
                // Code stats
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(.gray)
                        Text("\(shader.fragmentCode.components(separatedBy: "\n").count) lines")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "character")
                            .foregroundColor(.gray)
                        Text("\(shader.fragmentCode.count) chars")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 4)
            }
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func saveChanges() {
        shader.name = editedName
        shader.shaderDescription = editedDescription
        shader.category = selectedCategory
        shader.dateModified = Date()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple.opacity(0.7))
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ShaderSettingsView(
        shader: ShaderEntity(
            name: "Test Shader",
            fragmentCode: """
            // @param speed "Speed" range(0.0, 5.0) default(1.0)
            // @param scale "Scale" range(0.1, 10.0) default(1.0)
            float3 col = float3(uv.x, uv.y, 0.5);
            return float4(col, 1.0);
            """,
            category: .abstract,
            author: "Artist"
        )
    )
}
