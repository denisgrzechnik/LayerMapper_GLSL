//
//  ShaderDataManager.swift
//  LM_GLSL
//
//  Manager for SwiftData operations
//

import Foundation
import SwiftData
import SwiftUI

/// Zarządza operacjami na bazie danych shaderów
@MainActor
class ShaderDataManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedShader: ShaderEntity?
    @Published var selectedCategory: ShaderCategory = .all
    @Published var searchText: String = ""
    @Published var sortOrder: SortOrder = .nameAscending
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var modelContext: ModelContext
    
    // MARK: - Sort Order
    
    enum SortOrder: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
        case mostViewed = "Most Viewed"
        case highestRated = "Highest Rated"
        case favorites = "Favorites First"
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    /// Pobiera wszystkie shadery z filtrami
    func fetchShaders(
        category: ShaderCategory? = nil,
        searchText: String = "",
        sortOrder: SortOrder = .nameAscending,
        limit: Int? = nil
    ) -> [ShaderEntity] {
        var descriptor = FetchDescriptor<ShaderEntity>()
        
        // Budowanie predykatu
        var predicates: [Predicate<ShaderEntity>] = []
        
        // Filtr kategorii
        if let category = category, category != .all {
            let categoryRaw = category.rawValue
            predicates.append(#Predicate<ShaderEntity> { shader in
                shader.categoryRawValue == categoryRaw
            })
        }
        
        // Filtr wyszukiwania
        if !searchText.isEmpty {
            predicates.append(#Predicate<ShaderEntity> { shader in
                shader.name.localizedStandardContains(searchText) ||
                shader.shaderDescription.localizedStandardContains(searchText) ||
                shader.author.localizedStandardContains(searchText)
            })
        }
        
        // Łączenie predykatów
        if !predicates.isEmpty {
            if predicates.count == 1 {
                descriptor.predicate = predicates[0]
            } else {
                // Dla wielu predykatów używamy AND
                let categoryRaw = category?.rawValue ?? ""
                let search = searchText
                
                if category != nil && category != .all && !searchText.isEmpty {
                    descriptor.predicate = #Predicate<ShaderEntity> { shader in
                        shader.categoryRawValue == categoryRaw &&
                        (shader.name.localizedStandardContains(search) ||
                         shader.shaderDescription.localizedStandardContains(search))
                    }
                } else if category != nil && category != .all {
                    descriptor.predicate = #Predicate<ShaderEntity> { shader in
                        shader.categoryRawValue == categoryRaw
                    }
                } else if !searchText.isEmpty {
                    descriptor.predicate = #Predicate<ShaderEntity> { shader in
                        shader.name.localizedStandardContains(search) ||
                        shader.shaderDescription.localizedStandardContains(search)
                    }
                }
            }
        }
        
        // Sortowanie
        switch sortOrder {
        case .nameAscending:
            descriptor.sortBy = [SortDescriptor(\.name)]
        case .nameDescending:
            descriptor.sortBy = [SortDescriptor(\.name, order: .reverse)]
        case .dateNewest:
            descriptor.sortBy = [SortDescriptor(\.dateCreated, order: .reverse)]
        case .dateOldest:
            descriptor.sortBy = [SortDescriptor(\.dateCreated)]
        case .mostViewed:
            descriptor.sortBy = [SortDescriptor(\.viewCount, order: .reverse)]
        case .highestRated:
            descriptor.sortBy = [SortDescriptor(\.rating, order: .reverse)]
        case .favorites:
            descriptor.sortBy = [SortDescriptor(\.name)]
        }
        
        // Limit
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch shaders: \(error.localizedDescription)"
            return []
        }
    }
    
    /// Pobiera shader po ID
    func fetchShader(by id: UUID) -> ShaderEntity? {
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            errorMessage = "Failed to fetch shader: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// Pobiera ulubione shadery
    func fetchFavorites() -> [ShaderEntity] {
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch favorites: \(error.localizedDescription)"
            return []
        }
    }
    
    /// Pobiera ostatnio używane shadery
    func fetchRecentlyViewed(limit: Int = 10) -> [ShaderEntity] {
        var descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.viewCount > 0 },
            sortBy: [SortDescriptor(\.dateModified, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch recent shaders: \(error.localizedDescription)"
            return []
        }
    }
    
    /// Dodaje nowy shader
    func addShader(_ shader: ShaderEntity) {
        modelContext.insert(shader)
        save()
    }
    
    /// Tworzy i dodaje nowy shader
    func createShader(
        name: String,
        fragmentCode: String,
        category: ShaderCategory,
        author: String = "User",
        description: String = ""
    ) -> ShaderEntity {
        let shader = ShaderEntity(
            name: name,
            fragmentCode: fragmentCode,
            category: category,
            author: author,
            isBuiltIn: false,
            shaderDescription: description
        )
        
        addShader(shader)
        return shader
    }
    
    /// Aktualizuje shader
    func updateShader(_ shader: ShaderEntity) {
        shader.updateModifiedDate()
        save()
    }
    
    /// Usuwa shader
    func deleteShader(_ shader: ShaderEntity) {
        // Nie pozwól usuwać wbudowanych shaderów
        guard !shader.isBuiltIn else {
            errorMessage = "Cannot delete built-in shaders"
            return
        }
        
        modelContext.delete(shader)
        save()
        
        if selectedShader?.id == shader.id {
            selectedShader = nil
        }
    }
    
    /// Duplikuje shader
    func duplicateShader(_ shader: ShaderEntity) -> ShaderEntity {
        let duplicate = ShaderEntity(
            name: "\(shader.name) Copy",
            fragmentCode: shader.fragmentCode,
            vertexCode: shader.vertexCode,
            category: shader.category,
            tags: shader.tags,
            author: "User",
            isBuiltIn: false,
            shaderDescription: shader.shaderDescription,
            thumbnailColorHex: shader.thumbnailColorHex
        )
        
        // Kopiuj parametry
        if let originalParams = shader.parameters {
            for param in originalParams {
                let newParam = ShaderParameterEntity(
                    name: param.name,
                    displayName: param.displayName,
                    parameterType: param.parameterType,
                    floatValue: param.floatValue,
                    minValue: param.minValue,
                    maxValue: param.maxValue,
                    defaultValue: param.defaultValue,
                    step: param.step
                )
                newParam.shader = duplicate
            }
        }
        
        addShader(duplicate)
        return duplicate
    }
    
    /// Przełącza ulubione
    func toggleFavorite(_ shader: ShaderEntity) {
        shader.isFavorite.toggle()
        save()
    }
    
    /// Zapisuje zmiany
    func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Statistics
    
    /// Liczba shaderów
    func shaderCount() -> Int {
        let descriptor = FetchDescriptor<ShaderEntity>()
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }
    
    /// Liczba shaderów w kategorii
    func shaderCount(in category: ShaderCategory) -> Int {
        let categoryRaw = category.rawValue
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.categoryRawValue == categoryRaw }
        )
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }
    
    /// Liczba ulubionych
    func favoritesCount() -> Int {
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.isFavorite == true }
        )
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }
    
    /// Liczba shaderów użytkownika
    func userShadersCount() -> Int {
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.isBuiltIn == false }
        )
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }
    
    // MARK: - Import/Export
    
    /// Eksportuje shader do JSON
    func exportShader(_ shader: ShaderEntity) -> Data? {
        let exportData = ShaderExportData(
            name: shader.name,
            fragmentCode: shader.fragmentCode,
            vertexCode: shader.vertexCode,
            category: shader.category.rawValue,
            tags: shader.tags,
            author: shader.author,
            version: shader.version,
            description: shader.shaderDescription
        )
        
        return try? JSONEncoder().encode(exportData)
    }
    
    /// Importuje shader z JSON
    func importShader(from data: Data) -> ShaderEntity? {
        guard let importData = try? JSONDecoder().decode(ShaderExportData.self, from: data) else {
            errorMessage = "Invalid shader data format"
            return nil
        }
        
        let shader = ShaderEntity(
            name: importData.name,
            fragmentCode: importData.fragmentCode,
            vertexCode: importData.vertexCode,
            category: ShaderCategory(rawValue: importData.category) ?? .custom,
            tags: importData.tags,
            author: importData.author,
            version: importData.version,
            isBuiltIn: false,
            shaderDescription: importData.description
        )
        
        addShader(shader)
        return shader
    }
    
    /// Importuje wiele shaderów
    func importShaders(from data: Data) -> Int {
        guard let shaders = try? JSONDecoder().decode([ShaderExportData].self, from: data) else {
            errorMessage = "Invalid shaders data format"
            return 0
        }
        
        var count = 0
        for shaderData in shaders {
            let shader = ShaderEntity(
                name: shaderData.name,
                fragmentCode: shaderData.fragmentCode,
                vertexCode: shaderData.vertexCode,
                category: ShaderCategory(rawValue: shaderData.category) ?? .custom,
                tags: shaderData.tags,
                author: shaderData.author,
                version: shaderData.version,
                isBuiltIn: false,
                shaderDescription: shaderData.description
            )
            modelContext.insert(shader)
            count += 1
        }
        
        save()
        return count
    }
}

// MARK: - Export Data Structure

struct ShaderExportData: Codable {
    let name: String
    let fragmentCode: String
    let vertexCode: String?
    let category: String
    let tags: [String]
    let author: String
    let version: String
    let description: String
}
