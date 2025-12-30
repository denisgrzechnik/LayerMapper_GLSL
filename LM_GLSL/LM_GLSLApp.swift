//
//  LM_GLSLApp.swift
//  LM_GLSL
//
//  Main application entry point with SwiftData
//

import SwiftUI
import SwiftData

@main
struct LM_GLSLApp: App {
    
    // MARK: - SwiftData Container
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ShaderEntity.self,
            ShaderParameterEntity.self,
            TagEntity.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    loadBuiltInShadersIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Initial Setup
    
    @MainActor
    private func loadBuiltInShadersIfNeeded() {
        let context = sharedModelContainer.mainContext
        let loader = BuiltInShaderLoader(modelContext: context)
        loader.loadIfNeeded()
    }
}
