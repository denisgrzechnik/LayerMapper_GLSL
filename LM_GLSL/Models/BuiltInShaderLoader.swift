//
//  BuiltInShaderLoader.swift
//  LM_GLSL
//
//  Loads built-in shaders from shader code files into SwiftData
//

import Foundation
import SwiftData

/// Ładuje wbudowane shadery do bazy danych przy pierwszym uruchomieniu
@MainActor
class BuiltInShaderLoader {
    
    private let modelContext: ModelContext
    private let userDefaultsKey = "BuiltInShadersLoaded_v2"
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Sprawdza czy shadery zostały już załadowane
    var areShadersLoaded: Bool {
        UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    /// Ładuje wszystkie wbudowane shadery jeśli nie zostały jeszcze załadowane
    func loadIfNeeded() {
        guard !areShadersLoaded else { return }
        loadAllBuiltInShaders()
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
    
    /// Wymusza przeładowanie wszystkich wbudowanych shaderów
    func forceReload() {
        deleteAllBuiltInShaders()
        loadAllBuiltInShaders()
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
    
    /// Usuwa wszystkie wbudowane shadery
    private func deleteAllBuiltInShaders() {
        let descriptor = FetchDescriptor<ShaderEntity>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        
        do {
            let shaders = try modelContext.fetch(descriptor)
            for shader in shaders {
                modelContext.delete(shader)
            }
            try modelContext.save()
        } catch {
            print("Error deleting built-in shaders: \(error)")
        }
    }
    
    /// Ładuje wszystkie wbudowane shadery
    private func loadAllBuiltInShaders() {
        // Part 1: Basic, Tunnels, Nature, Geometric
        loadBasicShaders()
        loadTunnelShaders()
        loadNatureShaders()
        loadGeometricShaders()
        
        // Part 2: Retro, Psychedelic, Abstract
        loadRetroShaders()
        loadPsychedelicShaders()
        loadAbstractShaders()
        
        // Part 3: Cosmic, Organic, WaterLiquid, FireEnergy
        loadCosmicShaders()
        loadOrganicShaders()
        loadWaterLiquidShaders()
        loadFireEnergyShaders()
        
        // Part 4: Patterns, Fractals, AudioReactive, Gradient
        loadPatternShaders()
        loadFractalShaders()
        loadAudioReactiveShaders()
        loadGradientShaders()
        
        // Part 5: 3DStyle, Particles, Neon, Tech, Motion, Minimal
        loadThreeDShaders()
        loadParticleShaders()
        loadNeonShaders()
        loadTechShaders()
        loadMotionShaders()
        loadMinimalShaders()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving shaders: \(error)")
        }
    }
    
    // MARK: - Part 1 Categories
    
    private func loadBasicShaders() {
        loadShader(name: "Rainbow Gradient", code: rainbowGradientCode, category: .basic)
        loadShader(name: "Plasma", code: plasmaCode, category: .basic)
        loadShader(name: "Noise", code: noiseCode, category: .basic)
    }
    
    private func loadTunnelShaders() {
        loadShader(name: "Warp Tunnel", code: warpTunnelCode, category: .tunnels)
        loadShader(name: "Star Tunnel", code: starTunnelCode, category: .tunnels)
        loadShader(name: "Hypnotic Spiral", code: hypnoticSpiralCode, category: .tunnels)
    }
    
    private func loadNatureShaders() {
        loadShader(name: "Fire", code: fireCode, category: .nature)
        loadShader(name: "Ocean Waves", code: oceanWavesCode, category: .nature)
        loadShader(name: "Aurora", code: auroraCode, category: .nature)
        loadShader(name: "Electric Storm", code: electricStormCode, category: .nature)
    }
    
    private func loadGeometricShaders() {
        loadShader(name: "Kaleidoscope", code: kaleidoscopeCode, category: .geometric)
        loadShader(name: "Hexagon Grid", code: hexagonGridCode, category: .geometric)
        loadShader(name: "Voronoi", code: voronoiCode, category: .geometric)
        loadShader(name: "Fractal Circles", code: fractalCirclesCode, category: .geometric)
        loadShader(name: "Infinite Cubes", code: infiniteCubesCode, category: .geometric)
        loadShader(name: "Rotating Triangles", code: rotatingTrianglesCode, category: .geometric)
        loadShader(name: "Penrose Tiles", code: penroseTilesCode, category: .geometric)
        loadShader(name: "Truchet Pattern", code: truchetPatternCode, category: .geometric)
        loadShader(name: "Sacred Geometry", code: sacredGeometryCode, category: .geometric)
    }
    
    // MARK: - Part 2 Categories
    
    private func loadRetroShaders() {
        loadShader(name: "Matrix Rain", code: matrixRainCode, category: .retro)
        loadShader(name: "CRT TV", code: crtTvCode, category: .retro)
        loadShader(name: "Glitch", code: glitchCode, category: .retro)
        loadShader(name: "Synthwave Grid", code: synthwaveGridCode, category: .retro)
        loadShader(name: "VHS Distortion", code: vhsDistortionCode, category: .retro)
        loadShader(name: "Scanlines", code: scanlinesCode, category: .retro)
        loadShader(name: "Pixel Sort", code: pixelSortCode, category: .retro)
        loadShader(name: "ASCII Art", code: asciiArtCode, category: .retro)
        loadShader(name: "Commodore 64", code: commodore64Code, category: .retro)
    }
    
    private func loadPsychedelicShaders() {
        loadShader(name: "Liquid Metal", code: liquidMetalCode, category: .psychedelic)
        loadShader(name: "Neon Pulse", code: neonPulseCode, category: .psychedelic)
        loadShader(name: "Fractal Warp", code: fractalWarpCode, category: .psychedelic)
        loadShader(name: "Color Explosion", code: colorExplosionCode, category: .psychedelic)
        loadShader(name: "Acid Trip", code: acidTripCode, category: .psychedelic)
        loadShader(name: "Mushroom Vision", code: mushroomVisionCode, category: .psychedelic)
        loadShader(name: "Morphing Shapes", code: morphingShapesCode, category: .psychedelic)
        loadShader(name: "Color Flow", code: colorFlowCode, category: .psychedelic)
        loadShader(name: "Dream Weaver", code: dreamWeaverCode, category: .psychedelic)
    }
    
    private func loadAbstractShaders() {
        loadShader(name: "Metaballs", code: metaballsCode, category: .abstract)
        loadShader(name: "Sine Waves", code: sineWavesCode, category: .abstract)
        loadShader(name: "Moire Pattern", code: moirePatternCode, category: .abstract)
        loadShader(name: "Ink Blot", code: inkBlotCode, category: .abstract)
        loadShader(name: "Rorschach", code: rorschachCode, category: .abstract)
        loadShader(name: "Fabric", code: fabricCode, category: .abstract)
        loadShader(name: "Marble", code: marbleCode, category: .abstract)
        loadShader(name: "Wood Grain", code: woodGrainCode, category: .abstract)
    }
    
    // MARK: - Part 3 Categories
    
    private func loadCosmicShaders() {
        loadShader(name: "Galaxy", code: galaxyCode, category: .cosmic)
        loadShader(name: "Starfield", code: starfieldCode, category: .cosmic)
        loadShader(name: "Nebula", code: nebulaCode, category: .cosmic)
        loadShader(name: "Black Hole", code: blackHoleCode, category: .cosmic)
        loadShader(name: "Cosmic Dust", code: cosmicDustCode, category: .cosmic)
    }
    
    private func loadOrganicShaders() {
        loadShader(name: "Cells", code: cellsCode, category: .organic)
        loadShader(name: "Veins", code: veinsCode, category: .organic)
        loadShader(name: "Bacteria", code: bacteriaCode, category: .organic)
        loadShader(name: "Leaf Veins", code: leafVeinsCode, category: .organic)
        loadShader(name: "Coral", code: coralCode, category: .organic)
    }
    
    private func loadWaterLiquidShaders() {
        loadShader(name: "Raindrops", code: raindropsCode, category: .waterLiquid)
        loadShader(name: "Underwater", code: underwaterCode, category: .waterLiquid)
        loadShader(name: "Bubbles", code: bubbleCode, category: .waterLiquid)
        loadShader(name: "Pond Ripple", code: pondRippleCode, category: .waterLiquid)
        loadShader(name: "Waterfall", code: waterfallCode, category: .waterLiquid)
    }
    
    private func loadFireEnergyShaders() {
        loadShader(name: "Plasma Fire", code: plasmaFireCode, category: .fireEnergy)
        loadShader(name: "Lightning Bolt", code: lightningBoltCode, category: .fireEnergy)
        loadShader(name: "Solar Flare", code: solarFlareCode, category: .fireEnergy)
        loadShader(name: "Energy Orb", code: energyOrbCode, category: .fireEnergy)
        loadShader(name: "Electric Arc", code: electricArcCode, category: .fireEnergy)
    }
    
    // MARK: - Part 4 Categories
    
    private func loadPatternShaders() {
        loadShader(name: "Chevron", code: chevronCode, category: .patterns)
        loadShader(name: "Houndstooth", code: houndstoothCode, category: .patterns)
        loadShader(name: "Herringbone", code: herringboneCode, category: .patterns)
        loadShader(name: "Islamic Pattern", code: islamicPatternCode, category: .patterns)
        loadShader(name: "Celtic Knot", code: celticKnotCode, category: .patterns)
    }
    
    private func loadFractalShaders() {
        loadShader(name: "Mandelbrot", code: mandelbrotCode, category: .fractals)
        loadShader(name: "Julia Set", code: juliaSetCode, category: .fractals)
        loadShader(name: "Sierpinski", code: sierpinskiCode, category: .fractals)
        loadShader(name: "Burning Ship", code: burningShipCode, category: .fractals)
        loadShader(name: "Fractal Tree", code: fractalTreeCode, category: .fractals)
    }
    
    private func loadAudioReactiveShaders() {
        loadShader(name: "Audio Waveform", code: audioWaveformCode, category: .audioReactive)
        loadShader(name: "Spectrum Bars", code: spectrumBarsCode, category: .audioReactive)
        loadShader(name: "Beat Pulse", code: beatPulseCode, category: .audioReactive)
        loadShader(name: "Sound Circles", code: soundCirclesCode, category: .audioReactive)
        loadShader(name: "Frequency Mesh", code: frequencyMeshCode, category: .audioReactive)
    }
    
    private func loadGradientShaders() {
        loadShader(name: "Linear Gradient", code: linearGradientCode, category: .gradient)
        loadShader(name: "Radial Gradient", code: radialGradientCode, category: .gradient)
        loadShader(name: "Conic Gradient", code: conicGradientCode, category: .gradient)
        loadShader(name: "Diamond Gradient", code: diamondGradientCode, category: .gradient)
        loadShader(name: "Spiral Gradient", code: spiralGradientCode, category: .gradient)
    }
    
    // MARK: - Part 5 Categories
    
    private func loadThreeDShaders() {
        loadShader(name: "Raymarching Cube", code: raymarchingCubeCode, category: .threeD)
        loadShader(name: "Sphere Grid", code: sphereGridCode, category: .threeD)
        loadShader(name: "Tunnel", code: tunnelCode, category: .threeD)
        loadShader(name: "Torus", code: torusCode, category: .threeD)
        loadShader(name: "Infinite Grid", code: infiniteGridCode, category: .threeD)
    }
    
    private func loadParticleShaders() {
        loadShader(name: "Particle Field", code: particleFieldCode, category: .particles)
        loadShader(name: "Sparkles", code: sparklesCode, category: .particles)
        loadShader(name: "Snow", code: snowCode, category: .particles)
        loadShader(name: "Fireflies", code: firefliesCode, category: .particles)
        loadShader(name: "Dust Motes", code: dustMotesCode, category: .particles)
    }
    
    private func loadNeonShaders() {
        loadShader(name: "Neon Lines", code: neonLinesCode, category: .neon)
        loadShader(name: "Neon Sign", code: neonSignCode, category: .neon)
        loadShader(name: "Laser Grid", code: laserGridCode, category: .neon)
        loadShader(name: "Glowing Edges", code: glowingEdgesCode, category: .neon)
        loadShader(name: "Cyberpunk City", code: cyberpunkCityCode, category: .neon)
    }
    
    private func loadTechShaders() {
        loadShader(name: "Circuit Board", code: circuitBoardCode, category: .tech)
        loadShader(name: "Data Stream", code: dataStreamCode, category: .tech)
        loadShader(name: "Hologram", code: hologramCode, category: .tech)
        loadShader(name: "Binary Rain", code: binaryRainCode, category: .tech)
        loadShader(name: "Loading Spinner", code: loadingSpinnerCode, category: .tech)
    }
    
    private func loadMotionShaders() {
        loadShader(name: "Flow Field", code: flowFieldCode, category: .motion)
        loadShader(name: "Vortex", code: vortexCode, category: .motion)
        loadShader(name: "Waves", code: wavesCode, category: .motion)
        loadShader(name: "Oscillation", code: oscillationCode, category: .motion)
        loadShader(name: "Pendulum", code: pendulumCode, category: .motion)
    }
    
    private func loadMinimalShaders() {
        loadShader(name: "Single Circle", code: singleCircleCode, category: .minimal)
        loadShader(name: "Crosshair", code: crosshairCode, category: .minimal)
        loadShader(name: "Dot Grid", code: dotGridCode, category: .minimal)
        loadShader(name: "Stripes", code: stripesCode, category: .minimal)
        loadShader(name: "Pulsing Dot", code: pulsingDotCode, category: .minimal)
    }
    
    // MARK: - Helper
    
    private func loadShader(name: String, code: String, category: ShaderCategory) {
        let shader = ShaderEntity(
            name: name,
            fragmentCode: code,
            category: category,
            isBuiltIn: true
        )
        modelContext.insert(shader)
    }
}
