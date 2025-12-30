# LM GLSL - LayerMapper GLSL Shader Library

iOS/iPadOS application for browsing, editing, and creating GLSL fragment shaders with real-time preview.

## Features

- 📚 **100+ Built-in Shaders** organized in 21 categories
- 🎨 **Real-time Preview** using Metal rendering
- ✏️ **Code Editor** with syntax highlighting
- 🎛️ **Parameter Sliders** for shader customization
- 💾 **SwiftData Storage** - scalable to 30,000+ shaders
- ⭐ **Favorites & Search** functionality
- 📱 **iPad Optimized** - 80% preview, 20% shader list layout

## Categories

- Basic, Tunnels, Nature, Geometric
- Retro, Psychedelic, Abstract, Cosmic
- Organic, Water & Liquid, Fire & Energy
- Patterns, Fractals, Audio Reactive
- Gradient, 3D Style, Particles
- Neon, Tech, Motion, Minimal

## Technical Stack

- **SwiftUI** - Modern declarative UI
- **SwiftData** - Persistent storage with lazy loading
- **Metal** - GPU-accelerated shader rendering
- **iOS 17.0+** - Latest Swift features

## Architecture

```
LM_GLSL/
├── Models/
│   ├── ShaderEntity.swift           # SwiftData model
│   ├── ShaderCategory.swift         # Category enum
│   ├── ShaderDataManager.swift      # CRUD operations
│   └── BuiltInShaderLoader.swift    # Load built-in shaders
├── Views/
│   ├── ContentView.swift            # Main layout
│   ├── ShaderPreviewView.swift      # Metal renderer
│   ├── ShaderListView.swift         # Shader browser
│   ├── ShaderCustomizeView.swift    # Parameter controls
│   ├── ShaderCodeEditorView.swift   # Code editor
│   └── NewShaderView.swift          # Create new shader
├── Shaders/
│   ├── ShaderCodes_Part1.swift      # Basic, Tunnels, Nature, Geometric
│   ├── ShaderCodes_Part2.swift      # Retro, Psychedelic, Abstract
│   ├── ShaderCodes_Part3.swift      # Cosmic, Organic, Water, Fire
│   ├── ShaderCodes_Part4.swift      # Patterns, Fractals, Audio, Gradient
│   └── ShaderCodes_Part5.swift      # 3D, Particles, Neon, Tech, Motion, Minimal
└── Extensions/
    └── Color+Hex.swift              # Hex color support
```

## Shader Code Format

All shaders use GLSL fragment shader syntax with these built-in uniforms:

```glsl
float2 uv       // Normalized UV coordinates (0.0 - 1.0)
float iTime     // Time in seconds
float2 iResolution // Screen resolution in pixels
```

Example shader:
```glsl
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float3 col = 0.5 + 0.5 * cos(iTime + r * 6.28 + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
```

## TODO / UI Improvements

- [ ] Improve shader list UI (thumbnails, better layout)
- [ ] Add shader export/import functionality
- [ ] Implement shader sharing between devices
- [ ] Add performance metrics (FPS counter)
- [ ] Create custom parameter UI for each shader
- [ ] Add shader categories filtering UI
- [ ] Implement favorites section
- [ ] Add search with autocomplete
- [ ] Create onboarding tutorial
- [ ] Add dark/light mode support

## Development

Built with Xcode 15.0+
Target: iOS 17.0+, iPadOS 17.0+

## License

[Add your license here]

## Author

Denis Grzechnik - LayerMapper Project
