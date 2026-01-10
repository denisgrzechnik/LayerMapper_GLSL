//
//  ViewMode.swift
//  LM_GLSL
//
//  Enum for switching between Preview and Grid view modes
//

import Foundation

/// Tryby widoku aplikacji
enum ViewMode: String, CaseIterable, Identifiable {
    case preview = "Preview"
    case grid = "Grid"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .preview: return "rectangle.center.inset.filled"
        case .grid: return "square.grid.3x3.fill"
        }
    }
}
