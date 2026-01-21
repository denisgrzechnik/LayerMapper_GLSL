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
    private let userDefaultsKey = "BuiltInShadersLoaded_v18"
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Sprawdza czy shadery zostały już załadowane w bieżącej wersji
    var areShadersLoaded: Bool {
        // Check if this specific version was already loaded
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    /// Ładuje wszystkie wbudowane shadery jeśli nie zostały jeszcze załadowane
    func loadIfNeeded() {
        guard !areShadersLoaded else {
            print("✅ Built-in shaders v18 already loaded - skipping")
            return
        }
        print("📦 Loading built-in shaders v18...")
        // First delete old built-in shaders to avoid duplicates
        deleteAllBuiltInShaders()
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
        print("🔵 Loading 3D Shaders...")
        loadThreeDShaders()
        print("✅ 3D Shaders loaded")
        
        print("🔵 Loading Particle Shaders...")
        loadParticleShaders()
        print("✅ Particle Shaders loaded")
        
        print("🔵 Loading Neon Shaders...")
        loadNeonShaders()
        print("✅ Neon Shaders loaded")
        
        print("🔵 Loading Tech Shaders...")
        // WYŁĄCZONE TYMCZASOWO - powoduje crash
        // loadTechShaders()
        print("⚠️ Tech Shaders SKIPPED (causing crash)")
        
        print("🔵 Loading Motion Shaders...")
        loadMotionShaders()
        print("✅ Motion Shaders loaded")
        
        print("🔵 Loading Minimal Shaders...")
        loadMinimalShaders()
        print("✅ Minimal Shaders loaded")
        
        // Part 6: Parametric Geometric & Abstract
        print("🔵 Loading Part 6 Parametric Shaders...")
        loadPart6ParametricShaders()
        print("✅ Part 6 Shaders loaded")
        
        // Part 7: Cosmic & Space
        print("🔵 Loading Part 7 Cosmic Shaders...")
        loadPart7CosmicShaders()
        print("✅ Part 7 Shaders loaded")
        
        // Part 8: Retro & Glitch
        print("🔵 Loading Part 8 Retro Shaders...")
        loadPart8RetroShaders()
        print("✅ Part 8 Shaders loaded")
        
        // Part 9: Organic & Nature
        print("🔵 Loading Part 9 Organic Shaders...")
        loadPart9OrganicShaders()
        print("✅ Part 9 Shaders loaded")
        
        // Part 10: Energy & Experimental
        print("🔵 Loading Part 10 Energy Shaders...")
        loadPart10EnergyShaders()
        print("✅ Part 10 Shaders loaded")

        // Part 11: Hypnotic & Optical Illusions
        print("🔵 Loading Part 11 Hypnotic Shaders...")
        loadPart11HypnoticShaders()
        print("✅ Part 11 Shaders loaded")

        // Part 12: Weather & Atmospheric
        print("🔵 Loading Part 12 Weather Shaders...")
        loadPart12WeatherShaders()
        print("✅ Part 12 Shaders loaded")

        // Part 13: Cyberpunk & Sci-Fi
        print("🔵 Loading Part 13 Cyberpunk Shaders...")
        loadPart13CyberpunkShaders()
        print("✅ Part 13 Shaders loaded")

        // Part 14: Mechanical & Industrial
        print("🔵 Loading Part 14 Mechanical Shaders...")
        loadPart14MechanicalShaders()
        print("✅ Part 14 Shaders loaded")

        // Part 15: Surreal & Artistic
        print("🔵 Loading Part 15 Surreal Shaders...")
        loadPart15SurrealShaders()
        print("✅ Part 15 Shaders loaded")

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
        print("  📍 Loading Circuit Board...")
        loadShader(name: "Circuit Board", code: circuitBoardCode, category: .tech)
        print("  📍 Loading Data Stream...")
        loadShader(name: "Data Stream", code: dataStreamCode, category: .tech)
        print("  📍 Loading Hologram...")
        loadShader(name: "Hologram", code: hologramCode, category: .tech)
        print("  📍 Loading Binary Rain...")
        loadShader(name: "Binary Rain", code: binaryRainCode, category: .tech)
        print("  📍 Loading Loading Spinner...")
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
    
    // MARK: - Part 6: Parametric Geometric & Abstract
    
    private func loadPart6ParametricShaders() {
        loadShader(name: "Rotating Polygon", code: rotatingPolygonCode, category: .geometric)
        loadShader(name: "Concentric Rings", code: concentricRingsCode, category: .geometric)
        loadShader(name: "Spiral Galaxy", code: spiralGalaxyCode, category: .cosmic)
        loadShader(name: "Hex Mosaic", code: hexMosaicCode, category: .geometric)
        loadShader(name: "Radial Symmetry", code: radialSymmetryCode, category: .geometric)
        loadShader(name: "Geometric Flower", code: geometricFlowerCode, category: .geometric)
        loadShader(name: "Wave Interference", code: waveInterferenceCode, category: .abstract)
        loadShader(name: "Diamond Lattice", code: diamondLatticeCode, category: .geometric)
        loadShader(name: "Tessellation Grid", code: tessellationGridCode, category: .geometric)
        loadShader(name: "Voronoi Advanced", code: voronoiAdvancedCode, category: .abstract)
        loadShader(name: "Morphing Blobs", code: morphingBlobsCode, category: .abstract)
        loadShader(name: "Liquid Surface", code: liquidSurfaceCode, category: .waterLiquid)
        loadShader(name: "Smoke Effect", code: smokeEffectCode, category: .abstract)
        loadShader(name: "Ink Drop", code: inkDropCode, category: .abstract)
        loadShader(name: "Fabric Weave", code: fabricWeaveCode, category: .patterns)
        loadShader(name: "Marble Texture", code: marbleTextureCode, category: .abstract)
        loadShader(name: "Oil Slick", code: oilSlickCode, category: .abstract)
        loadShader(name: "Crystal Formation", code: crystalFormationCode, category: .abstract)
        loadShader(name: "Caustics", code: causticsCode, category: .waterLiquid)
        loadShader(name: "Lava Lamp", code: lavaLampCode, category: .abstract)
    }
    
    // MARK: - Part 7: Cosmic & Space
    
    private func loadPart7CosmicShaders() {
        loadShader(name: "Supernova", code: supernovaCode, category: .cosmic)
        loadShader(name: "Wormhole", code: wormholeCode, category: .cosmic)
        loadShader(name: "Pulsar Beam", code: pulsarBeamCode, category: .cosmic)
        loadShader(name: "Asteroid Field", code: asteroidFieldCode, category: .cosmic)
        loadShader(name: "Solar Eclipse", code: solarEclipseCode, category: .cosmic)
        loadShader(name: "Cosmic Web", code: cosmicWebCode, category: .cosmic)
        loadShader(name: "Quasar Jet", code: quasarJetCode, category: .cosmic)
        loadShader(name: "Planetary Rings", code: planetaryRingsCode, category: .cosmic)
        loadShader(name: "Space Dust Cloud", code: spaceDustCloudCode, category: .cosmic)
        loadShader(name: "Binary Star", code: binaryStarCode, category: .cosmic)
        loadShader(name: "Aurora Advanced", code: auroraAdvancedCode, category: .cosmic)
        loadShader(name: "Meteor Shower", code: meteorShowerCode, category: .cosmic)
        loadShader(name: "Stargate", code: stargateCode, category: .cosmic)
        loadShader(name: "Galactic Core", code: galacticCoreCode, category: .cosmic)
        loadShader(name: "Comet Trail", code: cometTrailCode, category: .cosmic)
        loadShader(name: "Dark Energy", code: darkEnergyCode, category: .cosmic)
        loadShader(name: "Cosmic String", code: cosmicStringCode, category: .cosmic)
        loadShader(name: "Gravitational Lensing", code: gravitationalLensingCode, category: .cosmic)
        loadShader(name: "Neutron Star", code: neutronStarCode, category: .cosmic)
        loadShader(name: "Event Horizon", code: eventHorizonCode, category: .cosmic)
    }
    
    // MARK: - Part 8: Retro & Glitch
    
    private func loadPart8RetroShaders() {
        loadShader(name: "VHS Advanced", code: vhsAdvancedCode, category: .retro)
        loadShader(name: "CRT Monitor", code: crtMonitorCode, category: .retro)
        loadShader(name: "Glitch Art", code: glitchArtCode, category: .retro)
        loadShader(name: "Pixel Art", code: pixelArtCode, category: .retro)
        loadShader(name: "Arcade Machine", code: arcadeMachineCode, category: .retro)
        loadShader(name: "C64 Style", code: c64StyleCode, category: .retro)
        loadShader(name: "Synthwave Horizon", code: synthwaveHorizonCode, category: .retro)
        loadShader(name: "Neon City", code: neonCityCode, category: .neon)
        loadShader(name: "Digital Rain Advanced", code: digitalRainAdvancedCode, category: .retro)
        loadShader(name: "Demoscene Plasma", code: demoscenePlasmaCode, category: .retro)
        loadShader(name: "Data Corruption", code: dataCorruptionCode, category: .retro)
        loadShader(name: "Signal Interference", code: signalInterferenceCode, category: .retro)
        loadShader(name: "Broken LCD", code: brokenLCDCode, category: .retro)
        loadShader(name: "Hologram Display", code: hologramDisplayCode, category: .tech)
        loadShader(name: "Databending", code: databendingCode, category: .retro)
        loadShader(name: "TV Static", code: tvStaticCode, category: .retro)
        loadShader(name: "ASCII Art Shader", code: asciiArtShaderCode, category: .retro)
        loadShader(name: "Bitcrusher", code: bitcrusherCode, category: .retro)
        loadShader(name: "Oscilloscope", code: oscilloscopeCode, category: .retro)
        loadShader(name: "Gameboy Style", code: gameboyStyleCode, category: .retro)
    }
    
    // MARK: - Part 9: Organic & Nature
    
    private func loadPart9OrganicShaders() {
        loadShader(name: "Living Cells", code: livingCellsCode, category: .organic)
        loadShader(name: "Neural Network", code: neuralNetworkCode, category: .organic)
        loadShader(name: "DNA Helix", code: dnaHelixCode, category: .organic)
        loadShader(name: "Blood Vessels", code: bloodVesselsCode, category: .organic)
        loadShader(name: "Coral Reef", code: coralReefCode, category: .organic)
        loadShader(name: "Mushroom Forest", code: mushroomForestCode, category: .organic)
        loadShader(name: "Butterfly Wings", code: butterflyWingsCode, category: .organic)
        loadShader(name: "Fern Fractal", code: fernFractalCode, category: .organic)
        loadShader(name: "Peacock Feather", code: peacockFeatherCode, category: .organic)
        loadShader(name: "Spider Web", code: spiderWebCode, category: .organic)
        loadShader(name: "Mitosis", code: mitosisCode, category: .organic)
        loadShader(name: "Jellyfish Swarm", code: jellyfishSwarmCode, category: .organic)
        loadShader(name: "Flower Bloom", code: flowerBloomCode, category: .organic)
        loadShader(name: "Lichen Growth", code: lichenGrowthCode, category: .organic)
        loadShader(name: "Heartbeat Monitor", code: heartbeatMonitorCode, category: .organic)
        loadShader(name: "Vine Growth", code: vineGrowthCode, category: .organic)
        loadShader(name: "Seashell Spiral", code: seashellSpiralCode, category: .organic)
        loadShader(name: "Tide Pool", code: tidePoolCode, category: .organic)
    }
    
    // MARK: - Part 10: Energy & Experimental
    
    private func loadPart10EnergyShaders() {
        loadShader(name: "Electric Arc Advanced", code: electricArcAdvancedCode, category: .fireEnergy)
        loadShader(name: "Plasma Ball", code: plasmaBallCode, category: .fireEnergy)
        loadShader(name: "Shockwave", code: shockwaveCode, category: .fireEnergy)
        loadShader(name: "Tornado Vortex", code: tornadoVortexCode, category: .motion)
        loadShader(name: "Magnetic Field", code: magneticFieldCode, category: .fireEnergy)
        loadShader(name: "Energy Beam", code: energyBeamCode, category: .fireEnergy)
        loadShader(name: "Quantum Fluctuation", code: quantumFluctuationCode, category: .abstract)
        loadShader(name: "Fire Whirl", code: fireWhirlCode, category: .fireEnergy)
        loadShader(name: "Cyberpunk Grid", code: cyberpunkGridCode, category: .tech)
        loadShader(name: "Holographic Display", code: holographicDisplayCode, category: .tech)
        loadShader(name: "Dimensional Rift", code: dimensionalRiftCode, category: .abstract)
        loadShader(name: "Neural Synapse", code: neuralSynapseCode, category: .organic)
        loadShader(name: "Data Visualization", code: dataVisualizationCode, category: .tech)
        loadShader(name: "Time Warp", code: timeWarpCode, category: .abstract)
        loadShader(name: "Pixel Sorting", code: pixelSortingCode, category: .retro)
        loadShader(name: "Morphing Geometry", code: morphingGeometryCode, category: .geometric)
        loadShader(name: "Audio Spectrum", code: audioSpectrumCode, category: .audioReactive)
        loadShader(name: "Fractal Tree Advanced", code: fractalTreeAdvancedCode, category: .fractals)
        loadShader(name: "Kaleidoscope Advanced", code: kaleidoscopeAdvancedCode, category: .geometric)
    }
    
    // MARK: - Part 11: Liquid & Fluid
    
    private func loadPart11HypnoticShaders() {
        loadShader(name: "Rotating Illusion", code: rotatingIllusionCode, category: .psychedelic)
        loadShader(name: "Breathing Mandala", code: breathingMandalaCode, category: .psychedelic)
        loadShader(name: "Zoetrope", code: zoetropeCode, category: .motion)
        loadShader(name: "Op Art Waves", code: opArtWavesCode, category: .patterns)
        loadShader(name: "Spirograph", code: spirographCode, category: .geometric)
        loadShader(name: "Moire Circles", code: moireCirclesCode, category: .patterns)
        loadShader(name: "Infinity Mirror", code: infinityMirrorCode, category: .abstract)
        loadShader(name: "Checkerboard Warp", code: checkerboardWarpCode, category: .patterns)
        loadShader(name: "Penrose Impossible", code: penroseImpossibleCode, category: .geometric)
        loadShader(name: "Escher Stairs", code: escherStairsCode, category: .abstract)
        loadShader(name: "Pulsing Hypnosis", code: pulsingHypnosisCode, category: .psychedelic)
        loadShader(name: "Impossible Cube", code: impossibleCubeCode, category: .geometric)
        loadShader(name: "Tunnel Zoom", code: tunnelZoomCode, category: .tunnels)
        loadShader(name: "Necker Cube", code: neckerCubeCode, category: .geometric)
        loadShader(name: "Ames Room", code: amesRoomCode, category: .abstract)
        loadShader(name: "Rubin Vase", code: rubinVaseCode, category: .abstract)
        loadShader(name: "Spinning Discs", code: spinningDiscsCode, category: .motion)
        loadShader(name: "Fraser Spiral", code: fraserSpiralCode, category: .psychedelic)
        loadShader(name: "Droste Effect", code: drosteEffectCode, category: .fractals)
    }
    
    // MARK: - Part 12: Weather & Atmospheric
    
    private func loadPart12WeatherShaders() {
        loadShader(name: "Rain Storm", code: rainStormCode, category: .nature)
        loadShader(name: "Snow Fall", code: snowFallCode, category: .nature)
        loadShader(name: "Fog Mist", code: fogMistCode, category: .nature)
        loadShader(name: "Cloud Formation", code: cloudFormationCode, category: .nature)
        loadShader(name: "Thunderstorm", code: thunderstormCode, category: .fireEnergy)
        loadShader(name: "Sunrise Gradient", code: sunriseGradientCode, category: .gradient)
        loadShader(name: "Northern Lights Advanced", code: northernLightsAdvancedCode, category: .cosmic)
        loadShader(name: "Dust Storm", code: dustStormCode, category: .nature)
        loadShader(name: "Rainbow Arc", code: rainbowArcCode, category: .gradient)
        loadShader(name: "Hail Storm", code: hailStormCode, category: .nature)
        loadShader(name: "Heat Shimmer", code: heatShimmerCode, category: .fireEnergy)
        loadShader(name: "Tornado Funnel", code: tornadoFunnelCode, category: .nature)
        loadShader(name: "Blizzard", code: blizzardCode, category: .nature)
        loadShader(name: "Acid Rain", code: acidRainCode, category: .nature)
        loadShader(name: "Meteor Rain", code: meteorRainCode, category: .cosmic)
        loadShader(name: "Eclipse", code: eclipseCode, category: .cosmic)
        loadShader(name: "Volcanic Ash", code: volcanicAshCode, category: .nature)
        loadShader(name: "Wind Patterns", code: windPatternsCode, category: .nature)
    }
    
    // MARK: - Part 13: Cyberpunk & Sci-Fi
    
    private func loadPart13CyberpunkShaders() {
        loadShader(name: "Neon Grid City", code: neonGridCityCode, category: .neon)
        loadShader(name: "Holographic Interface", code: holographicInterfaceCode, category: .tech)
        loadShader(name: "Data Matrix", code: dataMatrixCode, category: .tech)
        loadShader(name: "Force Field", code: forceFieldCode, category: .fireEnergy)
        loadShader(name: "Warp Drive", code: warpDriveCode, category: .cosmic)
        loadShader(name: "Cyber Brain", code: cyberBrainCode, category: .tech)
        loadShader(name: "Laser Scan", code: laserScanCode, category: .tech)
        loadShader(name: "Tractor Beam", code: tractorBeamCode, category: .cosmic)
        loadShader(name: "Quantum Tunnel", code: quantumTunnelCode, category: .cosmic)
        loadShader(name: "Cyberpunk Rain", code: cyberpunkRainCode, category: .neon)
        loadShader(name: "Android Vision", code: androidVisionCode, category: .tech)
        loadShader(name: "Teleporter", code: teleporterCode, category: .cosmic)
        loadShader(name: "Cyber Lock", code: cyberLockCode, category: .tech)
        loadShader(name: "Energy Core", code: energyCoreCode, category: .fireEnergy)
        loadShader(name: "Mech HUD", code: mechHUDCode, category: .tech)
        loadShader(name: "Particle Accelerator", code: particleAcceleratorCode, category: .cosmic)
        loadShader(name: "Stasis Field", code: stasisFieldCode, category: .cosmic)
        loadShader(name: "Alien Script", code: alienScriptCode, category: .abstract)
    }
    
    // MARK: - Part 14: Mechanical & Industrial
    
    private func loadPart14MechanicalShaders() {
        loadShader(name: "Clockwork Mechanism", code: clockworkMechanismCode, category: .tech)
        loadShader(name: "Steam Pipes", code: steamPipesCode, category: .tech)
        loadShader(name: "Industrial Pistons", code: industrialPistonsCode, category: .tech)
        loadShader(name: "Factory Sparks", code: factorySparksCode, category: .fireEnergy)
        loadShader(name: "Metal Plates", code: metalPlatesCode, category: .tech)
        loadShader(name: "Rotating Fan", code: rotatingFanCode, category: .motion)
        loadShader(name: "Pressure Gauge", code: pressureGaugeCode, category: .tech)
        loadShader(name: "Chain Links", code: chainLinksCode, category: .tech)
        loadShader(name: "Control Panel", code: controlPanelCode, category: .tech)
        loadShader(name: "Mechanical Heart", code: mechanicalHeartCode, category: .organic)
        loadShader(name: "Conveyor Belt", code: conveyorBeltCode, category: .motion)
        loadShader(name: "Warning Lights", code: warningLightsCode, category: .tech)
        loadShader(name: "Hydraulic Press", code: hydraulicPressCode, category: .tech)
        loadShader(name: "Engine Cylinder", code: engineCylinderCode, category: .tech)
        loadShader(name: "Radar Dish", code: radarDishCode, category: .tech)
        loadShader(name: "Steel Mesh", code: steelMeshCode, category: .patterns)
        loadShader(name: "Turbine Blades", code: turbineBladesCode, category: .motion)
        loadShader(name: "Electrical Panel", code: electricalPanelCode, category: .tech)
    }
    
    // MARK: - Part 15: Surreal & Artistic
    
    private func loadPart15SurrealShaders() {
        loadShader(name: "Melting Clock", code: meltingClockCode, category: .abstract)
        loadShader(name: "Impossible Stairs", code: impossibleStairsCode, category: .abstract)
        loadShader(name: "Floating Islands", code: floatingIslandsCode, category: .nature)
        loadShader(name: "Dream Portal", code: dreamPortalCode, category: .psychedelic)
        loadShader(name: "Paper Cutout", code: paperCutoutCode, category: .abstract)
        loadShader(name: "Stained Glass", code: stainedGlassCode, category: .patterns)
        loadShader(name: "Abstract Expressionism", code: abstractExpressionismCode, category: .abstract)
        loadShader(name: "Watercolor Wash", code: watercolorWashCode, category: .abstract)
        loadShader(name: "Pop Art Dots", code: popArtDotsCode, category: .retro)
        loadShader(name: "Neon Sign Art", code: neonSignArtCode, category: .neon)
        loadShader(name: "Ink Blot Art", code: inkBlotArtCode, category: .abstract)
        loadShader(name: "Oil Painting", code: oilPaintingCode, category: .abstract)
        loadShader(name: "Kaleidoscope Dream", code: kaleidoscopeDreamCode, category: .psychedelic)
        loadShader(name: "Cubist Portrait", code: cubistPortraitCode, category: .abstract)
        loadShader(name: "Pointillism", code: pointillismCode, category: .abstract)
        loadShader(name: "Art Nouveau", code: artNouveauCode, category: .patterns)
        loadShader(name: "Graffiti Tag", code: graffitiTagCode, category: .retro)
        loadShader(name: "Zen Garden", code: zenGardenCode, category: .nature)
        loadShader(name: "Mosaic", code: mosaicCode, category: .patterns)
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
