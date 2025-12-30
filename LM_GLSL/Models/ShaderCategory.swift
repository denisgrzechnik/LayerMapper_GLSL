//
//  ShaderCategory.swift
//  LM_GLSL
//
//  Created on 30/12/2024
//  Shader categories for filtering
//

import Foundation
import SwiftUI

/// Kategorie shaderów do filtrowania
enum ShaderCategory: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case basic = "Basic"
    case tunnels = "Tunnels & Warp"
    case nature = "Nature"
    case geometric = "Geometric"
    case retro = "Retro & Digital"
    case psychedelic = "Psychedelic"
    case abstract = "Abstract"
    case cosmic = "Cosmic"
    case organic = "Organic"
    case waterLiquid = "Water & Liquid"
    case fireEnergy = "Fire & Energy"
    case patterns = "Patterns"
    case fractals = "Fractals"
    case audioReactive = "Audio Reactive"
    case gradient = "Gradient"
    case threeD = "3D Style"
    case particles = "Particles"
    case neon = "Neon"
    case tech = "Tech"
    case motion = "Motion"
    case minimal = "Minimal"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .basic: return "circle.fill"
        case .tunnels: return "tornado"
        case .nature: return "leaf.fill"
        case .geometric: return "hexagon.fill"
        case .retro: return "tv.fill"
        case .psychedelic: return "sparkles"
        case .abstract: return "scribble.variable"
        case .cosmic: return "star.fill"
        case .organic: return "allergens"
        case .waterLiquid: return "drop.fill"
        case .fireEnergy: return "flame.fill"
        case .patterns: return "checkerboard.rectangle"
        case .fractals: return "perspective"
        case .audioReactive: return "waveform"
        case .gradient: return "paintbrush.fill"
        case .threeD: return "cube.fill"
        case .particles: return "sparkle"
        case .neon: return "lightbulb.fill"
        case .tech: return "cpu"
        case .motion: return "figure.walk"
        case .minimal: return "minus"
        case .custom: return "pencil"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .basic: return .blue
        case .tunnels: return .purple
        case .nature: return .green
        case .geometric: return .orange
        case .retro: return .pink
        case .psychedelic: return .rainbow
        case .abstract: return .indigo
        case .cosmic: return .purple
        case .organic: return .green
        case .waterLiquid: return .cyan
        case .fireEnergy: return .red
        case .patterns: return .gray
        case .fractals: return .blue
        case .audioReactive: return .green
        case .gradient: return .orange
        case .threeD: return .purple
        case .particles: return .yellow
        case .neon: return .cyan
        case .tech: return .green
        case .motion: return .orange
        case .minimal: return .gray
        case .custom: return .secondary
        }
    }
}
