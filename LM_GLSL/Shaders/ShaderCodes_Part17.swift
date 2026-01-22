//
//  ShaderCodes_Part17.swift
//  LM_GLSL
//
//  Shader codes - Part 17: Advanced Visual Effects
//

import Foundation

// MARK: - Advanced Visual Category

let hexagonalGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.5)
// @param hexSize "Hexagon Size" range(0.02, 0.3) default(0.08)
// @param lineWidth "Line Width" range(0.001, 0.02) default(0.005)
// @param glowAmount "Glow Amount" range(0.0, 2.0) default(0.5)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param waveSpeed "Wave Speed" range(0.0, 3.0) default(0.8)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.3)
// @param colorSpeed "Color Cycle Speed" range(0.0, 2.0) default(0.3)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.85)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param fillAmount "Fill Amount" range(0.0, 1.0) default(0.0)
// @param innerRadius "Inner Radius" range(0.0, 0.9) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowDepth "Shadow Depth" range(0.0, 1.0) default(0.2)
// @param highlightPower "Highlight Power" range(0.0, 2.0) default(0.5)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.1)
// @param patternMix "Pattern Mix" range(0.0, 1.0) default(0.5)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showGrid "Show Grid Lines" default(true)
// @toggle showFill "Show Fill" default(false)
// @toggle radialWave "Radial Wave" default(true)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal * 2.0), cos(p.x * 10.0 + timeVal * 2.0)) * distortion * 0.05;
}

// Hexagonal grid calculation
float sqrt3 = 1.732050808;
float2 hexSize2D = float2(hexSize * 2.0, hexSize * sqrt3);
float2 halfHex = hexSize2D * 0.5;

float2 p1 = fmod(p, hexSize2D) - halfHex;
float2 p2 = fmod(p - halfHex, hexSize2D) - halfHex;

float2 hexP;
if (length(p1) < length(p2)) {
    hexP = p1;
} else {
    hexP = p2;
}

// Hexagon distance function
float2 hexAbs = abs(hexP);
float hexDist = max(hexAbs.x * 0.866025 + hexAbs.y * 0.5, hexAbs.y) / hexSize;

// Calculate hex cell center for effects
float2 hexCenter = p - hexP;
float cellDist = length(hexCenter - center);

// Radial wave effect
float wave = 1.0;
if (radialWave > 0.5) {
    wave = sin(cellDist * 10.0 - timeVal * waveSpeed * 3.0) * waveAmplitude + 1.0;
}

// Pulse effect
float pulseVal = 1.0;
if (pulse > 0.5) {
    pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed + cellDist * 5.0);
}

// Color based on position and time
float colorAngle = atan2(hexCenter.y, hexCenter.x);
float colorT = colorAngle / 6.28318 + 0.5;
if (colorCycle > 0.5) colorT += timeVal * colorSpeed;
colorT = fmod(colorT, 1.0);

float3 col1 = float3(0.0);
float h1 = fmod(hue1 + hueShift + colorT * patternMix, 1.0) * 6.0;
col1.r = clamp(abs(h1 - 3.0) - 1.0, 0.0, 1.0);
col1.g = clamp(2.0 - abs(h1 - 2.0), 0.0, 1.0);
col1.b = clamp(2.0 - abs(h1 - 4.0), 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = fmod(hue2 + hueShift, 1.0) * 6.0;
col2.r = clamp(abs(h2 - 3.0) - 1.0, 0.0, 1.0);
col2.g = clamp(2.0 - abs(h2 - 2.0), 0.0, 1.0);
col2.b = clamp(2.0 - abs(h2 - 4.0), 0.0, 1.0);

float3 col = float3(0.0);

// Grid lines
if (showGrid > 0.5) {
    float lineMask = 1.0 - smoothstep(1.0 - lineWidth / hexSize, 1.0, hexDist);
    lineMask *= wave * pulseVal;
    col = mix(col, col1, lineMask);
    
    // Glow
    if (glow > 0.5) {
        float glowMask = 1.0 - smoothstep(0.8, 1.0 + glowAmount * 0.3, hexDist);
        col += col1 * glowMask * glowAmount * 0.3 * pulseVal;
    }
}

// Fill hexagons
if (showFill > 0.5) {
    float fillMask = 1.0 - smoothstep(fillAmount - 0.1, fillAmount, hexDist);
    if (innerRadius > 0.0) {
        fillMask *= smoothstep(innerRadius - 0.1, innerRadius, hexDist);
    }
    fillMask *= wave * pulseVal;
    col = mix(col, col2, fillMask * 0.5);
}

// Apply color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.x * 50.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.x * 50.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let voronoiCellsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.3)
// @param cellCount "Cell Count" range(3.0, 30.0) default(12.0)
// @param borderWidth "Border Width" range(0.0, 0.2) default(0.05)
// @param cellMovement "Cell Movement" range(0.0, 1.0) default(0.5)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.7)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.4)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.5)
// @param hue1 "Base Hue" range(0.0, 1.0) default(0.6)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.1)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowDepth "Shadow Depth" range(0.0, 1.0) default(0.3)
// @param highlightPower "Highlight Power" range(0.0, 2.0) default(0.5)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.2)
// @param cellDepth "Cell Depth" range(0.0, 1.0) default(0.4)
// @param wobbleAmount "Wobble Amount" range(0.0, 1.0) default(0.3)
// @param wobbleSpeed "Wobble Speed" range(0.0, 5.0) default(2.0)
// @param gradientMix "Gradient Mix" range(0.0, 1.0) default(0.5)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showBorders "Show Borders" default(true)
// @toggle showCells "Show Cell Colors" default(true)
// @toggle smoothBorders "Smooth Borders" default(true)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

if (distortion > 0.0) {
    p += float2(sin(p.y * 8.0 + timeVal), cos(p.x * 8.0 + timeVal)) * distortion * 0.05;
}

// Voronoi calculation
float2 scaledP = p * cellCount;

float minDist = 10.0;
float secondDist = 10.0;
float2 closestCell = float2(0.0);
float closestCellId = 0.0;

for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 cellBase = floor(scaledP) + neighbor;
        
        // Random point in cell
        float2 randomOffset = float2(
            fract(sin(dot(cellBase, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(cellBase, float2(269.5, 183.3))) * 43758.5453)
        );
        
        // Animate the points
        if (cellMovement > 0.0) {
            float2 wobble = float2(
                sin(timeVal * wobbleSpeed + randomOffset.x * 6.28) * wobbleAmount,
                cos(timeVal * wobbleSpeed * 1.1 + randomOffset.y * 6.28) * wobbleAmount
            );
            randomOffset += wobble * cellMovement * 0.3;
        }
        
        float2 cellPoint = cellBase + randomOffset;
        float dist = length(scaledP - cellPoint);
        
        if (dist < minDist) {
            secondDist = minDist;
            minDist = dist;
            closestCell = cellBase;
            closestCellId = fract(sin(dot(cellBase, float2(12.9898, 78.233))) * 43758.5453);
        } else if (dist < secondDist) {
            secondDist = dist;
        }
    }
}

// Edge detection
float edge = secondDist - minDist;
float borderMask = showBorders > 0.5 ? 
    (smoothBorders > 0.5 ? smoothstep(0.0, borderWidth, edge) : step(borderWidth, edge)) : 1.0;

// Cell coloring
float3 cellColor = float3(0.0);
float cellHue = fmod(closestCellId * colorVariation + hue1 + hueShift, 1.0);
if (colorCycle > 0.5) cellHue = fmod(cellHue + timeVal * 0.1, 1.0);

float h = cellHue * 6.0;
cellColor.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
cellColor.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
cellColor.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);

// Gradient within cell
float cellGradient = 1.0 - minDist * 0.5 * cellDepth;
cellColor *= mix(1.0, cellGradient, gradientMix);

// Border color
float3 borderColor = float3(0.0);
float hB = hue2 * 6.0;
borderColor.r = clamp(abs(hB - 3.0) - 1.0, 0.0, 1.0);
borderColor.g = clamp(2.0 - abs(hB - 2.0), 0.0, 1.0);
borderColor.b = clamp(2.0 - abs(hB - 4.0), 0.0, 1.0);

float3 col = showCells > 0.5 ? cellColor : float3(0.0);
col = mix(borderColor, col, borderMask);

// Pulse
if (pulse > 0.5) {
    float pulseVal = 0.8 + 0.2 * sin(timeVal * pulseSpeed + closestCellId * 6.28);
    col *= pulseVal;
}

// Glow on borders
if (glow > 0.5 && showBorders > 0.5) {
    float glowMask = 1.0 - smoothstep(0.0, borderWidth * 3.0, edge);
    col += borderColor * glowMask * glowIntensity;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.x * 50.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.x * 50.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let sineWaveMatrixCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.5)
// @param waveCountX "Horizontal Waves" range(1.0, 20.0) default(8.0)
// @param waveCountY "Vertical Waves" range(1.0, 20.0) default(6.0)
// @param amplitude "Wave Amplitude" range(0.0, 1.0) default(0.5)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param lineThickness "Line Thickness" range(0.01, 0.2) default(0.05)
// @param glowSpread "Glow Spread" range(0.0, 0.5) default(0.1)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param hue1 "Wave Hue 1" range(0.0, 1.0) default(0.0)
// @param hue2 "Wave Hue 2" range(0.0, 1.0) default(0.5)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveInteraction "Wave Interaction" range(0.0, 1.0) default(0.3)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param freqMod "Frequency Modulation" range(0.0, 2.0) default(0.0)
// @param damping "Damping" range(0.0, 1.0) default(0.0)
// @param phaseSpeed "Phase Speed" range(0.0, 3.0) default(0.5)
// @param mixRatio "Mix Ratio" range(0.0, 1.0) default(0.5)
// @param waveBlend "Wave Blend" range(0.0, 1.0) default(0.5)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @param gridOpacity "Grid Opacity" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showHorizontal "Horizontal Waves" default(true)
// @toggle showVertical "Vertical Waves" default(true)
// @toggle additive "Additive Blend" default(true)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

p += 0.5;

float3 col = float3(0.0);

// Horizontal waves
float waveH = 0.0;
if (showHorizontal > 0.5) {
    for (float i = 0.0; i < 10.0; i++) {
        if (i >= waveCountY) break;
        
        float waveY = i / waveCountY;
        float phase = phaseOffset + i * 0.5 + timeVal * phaseSpeed;
        float wave = sin(p.x * waveCountX * 6.28 + phase) * amplitude * 0.1;
        
        if (freqMod > 0.0) wave *= sin(p.x * freqMod * 10.0 + timeVal);
        if (damping > 0.0) wave *= 1.0 - abs(p.x - 0.5) * damping * 2.0;
        
        float dist = abs(p.y - waveY - wave);
        float lineMask = 1.0 - smoothstep(0.0, lineThickness, dist);
        
        if (glow > 0.5) lineMask += (1.0 - smoothstep(lineThickness, lineThickness + glowSpread, dist)) * 0.5;
        
        waveH = max(waveH, lineMask);
    }
}

// Vertical waves
float waveV = 0.0;
if (showVertical > 0.5) {
    for (float i = 0.0; i < 10.0; i++) {
        if (i >= waveCountX) break;
        
        float waveX = i / waveCountX;
        float phase = phaseOffset + i * 0.5 + timeVal * phaseSpeed * 1.1;
        float wave = sin(p.y * waveCountY * 6.28 + phase) * amplitude * 0.1;
        
        if (freqMod > 0.0) wave *= sin(p.y * freqMod * 10.0 + timeVal * 1.2);
        if (damping > 0.0) wave *= 1.0 - abs(p.y - 0.5) * damping * 2.0;
        
        float dist = abs(p.x - waveX - wave);
        float lineMask = 1.0 - smoothstep(0.0, lineThickness, dist);
        
        if (glow > 0.5) lineMask += (1.0 - smoothstep(lineThickness, lineThickness + glowSpread, dist)) * 0.5;
        
        waveV = max(waveV, lineMask);
    }
}

// Color 1 for horizontal
float3 col1 = float3(0.0);
float h1 = fmod(hue1 + hueShift, 1.0) * 6.0;
col1.r = clamp(abs(h1 - 3.0) - 1.0, 0.0, 1.0);
col1.g = clamp(2.0 - abs(h1 - 2.0), 0.0, 1.0);
col1.b = clamp(2.0 - abs(h1 - 4.0), 0.0, 1.0);

// Color 2 for vertical
float3 col2 = float3(0.0);
float h2 = fmod(hue2 + hueShift, 1.0) * 6.0;
col2.r = clamp(abs(h2 - 3.0) - 1.0, 0.0, 1.0);
col2.g = clamp(2.0 - abs(h2 - 2.0), 0.0, 1.0);
col2.b = clamp(2.0 - abs(h2 - 4.0), 0.0, 1.0);

if (colorCycle > 0.5) {
    float shift = timeVal * 0.2;
    col1 = float3(
        col1.r * cos(shift) + col1.g * sin(shift),
        col1.g * cos(shift) - col1.r * sin(shift),
        col1.b
    );
}

// Combine waves
if (additive > 0.5) {
    col = col1 * waveH + col2 * waveV;
    col += col1 * col2 * waveH * waveV * waveInteraction * 2.0;
} else {
    col = mix(col1 * waveH, col2 * waveV, waveBlend);
}

// Grid intersection highlight
if (gridOpacity > 0.0) {
    float intersection = waveH * waveV;
    col += float3(1.0) * intersection * gridOpacity;
}

// Pulse
if (pulse > 0.5) {
    float pulseVal = 0.8 + 0.2 * sin(timeVal * pulseSpeed);
    col *= pulseVal;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.x * 50.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.x * 50.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let cosmicSpiralArmCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Rotation Speed" range(0.0, 2.0) default(0.2)
// @param armCount "Spiral Arms" range(2.0, 8.0) default(4.0)
// @param armTightness "Arm Tightness" range(0.5, 5.0) default(2.0)
// @param armWidth "Arm Width" range(0.1, 1.0) default(0.4)
// @param coreSize "Core Size" range(0.05, 0.4) default(0.15)
// @param coreGlow "Core Glow" range(0.0, 2.0) default(1.0)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.6)
// @param starBrightness "Star Brightness" range(0.0, 2.0) default(0.8)
// @param dustAmount "Dust Amount" range(0.0, 1.0) default(0.3)
// @param hue1 "Core Hue" range(0.0, 1.0) default(0.1)
// @param hue2 "Arm Hue" range(0.0, 1.0) default(0.6)
// @param saturation "Saturation" range(0.0, 1.5) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param tilt "Tilt Angle" range(0.0, 1.0) default(0.3)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.05)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param warpAmount "Warp Amount" range(0.0, 1.0) default(0.0)
// @param nebulaIntensity "Nebula Intensity" range(0.0, 1.0) default(0.4)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(5.0)
// @param starSize "Star Size" range(0.5, 3.0) default(1.0)
// @param dustColor "Dust Color" range(0.0, 1.0) default(0.0)
// @param rotationOffset "Rotation Offset" range(0.0, 6.28) default(0.0)
// @param fadeDistance "Fade Distance" range(0.5, 2.0) default(1.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Rotation" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showArms "Show Arms" default(true)
// @toggle showStars "Show Stars" default(true)
// @toggle showDust "Show Dust" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Star Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

// Tilt effect (elliptical distortion)
p.y *= 1.0 + tilt * 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = armCount;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

// Polar coordinates
float r = length(p);
float a = atan2(p.y, p.x) + rotationOffset;

// Spiral function
float spiral = a + r * armTightness * 3.0 - timeVal * 2.0;
float armPattern = sin(spiral * armCount) * 0.5 + 0.5;
armPattern = pow(armPattern, 1.0 / armWidth);

// Fade with distance
float distFade = 1.0 - smoothstep(0.0, fadeDistance * 0.5, r);

float3 col = float3(0.0);

// Galaxy core
if (showCore > 0.5) {
    float coreMask = 1.0 - smoothstep(0.0, coreSize, r);
    coreMask = pow(coreMask, 0.5);
    
    float3 coreCol = float3(0.0);
    float hC = fmod(hue1 + hueShift, 1.0) * 6.0;
    coreCol.r = clamp(abs(hC - 3.0) - 1.0, 0.0, 1.0);
    coreCol.g = clamp(2.0 - abs(hC - 2.0), 0.0, 1.0);
    coreCol.b = clamp(2.0 - abs(hC - 4.0), 0.0, 1.0);
    coreCol = mix(float3(1.0), coreCol, 0.5);
    
    col += coreCol * coreMask * coreGlow;
}

// Spiral arms
if (showArms > 0.5) {
    float armMask = armPattern * distFade;
    armMask *= smoothstep(coreSize * 0.5, coreSize * 1.5, r);
    
    float3 armCol = float3(0.0);
    float hA = fmod(hue2 + hueShift + r * 0.2, 1.0) * 6.0;
    armCol.r = clamp(abs(hA - 3.0) - 1.0, 0.0, 1.0);
    armCol.g = clamp(2.0 - abs(hA - 2.0), 0.0, 1.0);
    armCol.b = clamp(2.0 - abs(hA - 4.0), 0.0, 1.0);
    
    col += armCol * armMask * 0.6;
}

// Stars
if (showStars > 0.5) {
    float2 starGrid = floor(p * 50.0);
    float starRand = fract(sin(dot(starGrid, float2(12.9898, 78.233))) * 43758.5453);
    
    if (starRand > 1.0 - starDensity * 0.1) {
        float2 starPos = fract(p * 50.0);
        float2 starCenter = float2(
            fract(sin(dot(starGrid, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(starGrid, float2(269.5, 183.3))) * 43758.5453)
        );
        float starDist = length(starPos - starCenter);
        float starMask = 1.0 - smoothstep(0.0, 0.05 * starSize, starDist);
        
        // Flicker
        float starFlicker = 1.0;
        if (flicker > 0.5) {
            starFlicker = 0.7 + 0.3 * sin(timeVal * flickerRate + starRand * 100.0);
        }
        
        col += float3(1.0, 0.95, 0.9) * starMask * starBrightness * starFlicker * (0.5 + armPattern * 0.5);
    }
}

// Dust lanes
if (showDust > 0.5) {
    float dustPattern = sin(spiral * armCount + 1.57) * 0.5 + 0.5;
    dustPattern = pow(dustPattern, 2.0) * dustAmount;
    
    float3 dustCol = float3(0.0);
    float hD = dustColor * 6.0;
    dustCol.r = clamp(abs(hD - 3.0) - 1.0, 0.0, 1.0);
    dustCol.g = clamp(2.0 - abs(hD - 2.0), 0.0, 1.0);
    dustCol.b = clamp(2.0 - abs(hD - 4.0), 0.0, 1.0);
    dustCol = mix(float3(0.1, 0.05, 0.02), dustCol, 0.3);
    
    col = mix(col, dustCol, dustPattern * distFade * 0.5);
}

// Nebula glow
if (glow > 0.5 && nebulaIntensity > 0.0) {
    float nebula = armPattern * distFade * nebulaIntensity;
    col += float3(0.2, 0.1, 0.3) * nebula * 0.3;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(timeVal * 2.0);
if (noise > 0.5) col += (fract(sin(dot(p * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.05, 0.95, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(a * 3.0);
    col.b *= 1.0 - chromaticAmount * sin(a * 3.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - r * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let lightningBoltAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 5.0) default(2.0)
// @param arcCount "Arc Count" range(1.0, 10.0) default(3.0)
// @param thickness "Arc Thickness" range(0.005, 0.1) default(0.02)
// @param jaggedness "Jaggedness" range(0.0, 1.0) default(0.6)
// @param branchCount "Branch Count" range(0.0, 5.0) default(2.0)
// @param glowRadius "Glow Radius" range(0.0, 0.2) default(0.05)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(1.0)
// @param pulseSpeed "Pulse Speed" range(0.0, 10.0) default(3.0)
// @param hue1 "Core Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Glow Hue" range(0.0, 1.0) default(0.6)
// @param saturation "Saturation" range(0.0, 1.5) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param arcLength "Arc Length" range(0.2, 1.0) default(0.8)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.1)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.6)
// @param flickerSpeed "Flicker Speed" range(0.0, 30.0) default(15.0)
// @param startX "Start X" range(0.0, 1.0) default(0.2)
// @param endX "End X" range(0.0, 1.0) default(0.8)
// @param arcY "Arc Y Position" range(0.0, 1.0) default(0.5)
// @param noiseScale "Noise Scale" range(1.0, 20.0) default(8.0)
// @param branchLength "Branch Length" range(0.0, 0.3) default(0.1)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle showBranches "Show Branches" default(true)
// @toggle horizontal "Horizontal Arc" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.y = abs(p.y);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 4.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

p += 0.5;

float3 col = float3(0.0);

// Generate noise for arc displacement
float arcNoise = 0.0;
for (float i = 1.0; i < 5.0; i++) {
    arcNoise += sin(p.x * noiseScale * i + timeVal * (3.0 + i)) / i;
    arcNoise += cos(p.x * noiseScale * i * 1.3 + timeVal * (2.5 + i * 0.7)) / (i * 1.5);
}
arcNoise *= jaggedness * 0.1;

// Main arc
for (float arc = 0.0; arc < 10.0; arc++) {
    if (arc >= arcCount) break;
    
    float arcOffset = (arc - arcCount * 0.5) * 0.05;
    float arcPhase = arc * 1.234;
    
    float arcDisp = arcNoise + sin(p.x * 5.0 + timeVal * 2.0 + arcPhase) * jaggedness * 0.05;
    
    float targetY = arcY + arcOffset + arcDisp;
    float dist = abs(p.y - targetY);
    
    // Only draw within arc bounds
    float arcMask = smoothstep(startX - 0.02, startX + 0.02, p.x) * 
                    (1.0 - smoothstep(endX - 0.02, endX + 0.02, p.x));
    
    // Core
    if (showCore > 0.5) {
        float coreMask = 1.0 - smoothstep(0.0, thickness, dist);
        coreMask *= arcMask;
        
        float3 coreCol = float3(1.0);
        col += coreCol * coreMask;
    }
    
    // Glow
    if (showGlow > 0.5 && glow > 0.5) {
        float glowMask = 1.0 - smoothstep(thickness, thickness + glowRadius, dist);
        glowMask *= arcMask;
        
        float3 glowCol = float3(0.0);
        float hG = fmod(hue1 + hueShift, 1.0) * 6.0;
        glowCol.r = clamp(abs(hG - 3.0) - 1.0, 0.0, 1.0);
        glowCol.g = clamp(2.0 - abs(hG - 2.0), 0.0, 1.0);
        glowCol.b = clamp(2.0 - abs(hG - 4.0), 0.0, 1.0);
        
        col += glowCol * glowMask * glowIntensity;
    }
    
    // Branches
    if (showBranches > 0.5 && branchCount > 0.0) {
        for (float b = 0.0; b < 5.0; b++) {
            if (b >= branchCount) break;
            
            float branchX = startX + (endX - startX) * fract(sin(arc * 12.9898 + b * 78.233) * 43758.5453);
            float branchDir = fract(sin(arc * 78.233 + b * 12.9898) * 43758.5453) > 0.5 ? 1.0 : -1.0;
            
            float branchNoise = sin(branchX * 20.0 + timeVal * 5.0 + b) * 0.02 * jaggedness;
            float branchDist = length(float2(p.x - branchX, p.y - targetY - branchDir * branchLength * 0.5));
            
            float branchMask = 1.0 - smoothstep(0.0, thickness * 0.7, branchDist);
            branchMask *= step(0.0, branchDir * (p.y - targetY));
            branchMask *= 1.0 - smoothstep(0.0, branchLength, abs(p.y - targetY));
            
            col += float3(0.7, 0.8, 1.0) * branchMask * 0.5;
        }
    }
}

// Flicker
if (flicker > 0.5) {
    float flickerVal = 0.7 + 0.3 * sin(timeVal * flickerSpeed) * sin(timeVal * flickerSpeed * 0.7);
    col *= flickerVal;
}

// Pulse
if (pulse > 0.5) {
    float pulseVal = 0.8 + 0.2 * sin(timeVal * pulseSpeed);
    col *= pulseVal;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.y * 30.0 + timeVal * 10.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.y * 30.0 + timeVal * 10.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let circularRingsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.5)
// @param ringCount "Ring Count" range(2.0, 20.0) default(8.0)
// @param ringWidth "Ring Width" range(0.01, 0.1) default(0.03)
// @param ringSpacing "Ring Spacing" range(0.02, 0.15) default(0.05)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.4)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.5)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.1) default(0.02)
// @param waveCount "Wave Count" range(0.0, 20.0) default(6.0)
// @param hue1 "Inner Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "Outer Hue" range(0.0, 1.0) default(0.7)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param expandSpeed "Expand Speed" range(0.0, 2.0) default(0.3)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.2)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param innerRadius "Inner Radius" range(0.0, 0.3) default(0.05)
// @param colorGradient "Color Gradient" range(0.0, 1.0) default(0.5)
// @param waveSpeed "Wave Speed" range(0.0, 5.0) default(2.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showRings "Show Rings" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle expandOutward "Expand Outward" default(true)
// @toggle waveDeform "Wave Deform" default(false)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation over time
float dynamicRot = rotation + (animated > 0.5 ? iTime * rotationSpeed : 0.0);
float cosR = cos(dynamicRot); float sinR = sin(dynamicRot);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float rad = length(p);
    p = float2(cos(angle), sin(angle)) * rad;
}

float r = length(p);
float a = atan2(p.y, p.x);

// Wave deformation
if (waveDeform > 0.5) {
    r += sin(a * waveCount + timeVal * waveSpeed + phaseOffset) * waveAmplitude;
}

// Expanding animation offset
float expandOffset = 0.0;
if (expandOutward > 0.5) {
    expandOffset = fmod(timeVal * expandSpeed, ringSpacing);
}

float3 col = float3(0.0);

// Draw rings
for (float i = 0.0; i < 20.0; i++) {
    if (i >= ringCount) break;
    
    float ringRadius = innerRadius + i * ringSpacing + expandOffset;
    
    // Skip if outside view
    if (ringRadius > 1.0) continue;
    
    float dist = abs(r - ringRadius);
    float ringMask = 1.0 - smoothstep(0.0, ringWidth, dist);
    
    // Pulse per ring
    float ringPulse = 1.0;
    if (pulse > 0.5) {
        ringPulse = 0.7 + 0.3 * sin(timeVal * pulseSpeed + i * 0.5);
    }
    
    // Color interpolation based on ring index
    float t = i / ringCount;
    if (colorCycle > 0.5) t = fmod(t + timeVal * 0.1, 1.0);
    
    float hue = mix(hue1, hue2, t * colorGradient) + hueShift;
    hue = fmod(hue, 1.0);
    
    float3 ringCol = float3(0.0);
    float h = hue * 6.0;
    ringCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    ringCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    ringCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    col += ringCol * ringMask * ringPulse;
    
    // Glow
    if (showGlow > 0.5 && glow > 0.5) {
        float glowMask = 1.0 - smoothstep(ringWidth, ringWidth + ringWidth * 2.0, dist);
        col += ringCol * glowMask * glowAmount * 0.3 * ringPulse;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(a * 5.0);
    col.b *= 1.0 - chromaticAmount * sin(a * 5.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - r * vignetteSize * 2.0;

return float4(col * masterOpacity, masterOpacity);
"""

let floatingDotsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Particle Speed" range(0.0, 2.0) default(0.5)
// @param particleCount "Particle Density" range(5.0, 50.0) default(20.0)
// @param particleSize "Particle Size" range(0.005, 0.05) default(0.015)
// @param trailLength "Trail Length" range(0.0, 0.3) default(0.1)
// @param flowStrength "Flow Strength" range(0.0, 2.0) default(0.5)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.3)
// @param glowRadius "Glow Radius" range(0.0, 0.05) default(0.02)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.8)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.6)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.9)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param flowAngle "Flow Angle" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.01)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param depthLayers "Depth Layers" range(1.0, 5.0) default(3.0)
// @param layerSpeed "Layer Speed Diff" range(0.0, 1.0) default(0.3)
// @param flickerSpeed "Flicker Speed" range(0.0, 20.0) default(5.0)
// @param fadeEdge "Edge Fade" range(0.0, 0.5) default(0.1)
// @param sizeVariation "Size Variation" range(0.0, 1.0) default(0.5)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.4)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showTrails "Show Trails" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle radialFlow "Radial Flow" default(false)
// @toggle spiralFlow "Spiral Flow" default(false)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float rad = length(p);
    p = float2(cos(angle), sin(angle)) * rad;
}

p += 0.5;

float3 col = float3(0.0);

// Flow direction
float2 flowDir = float2(cos(flowAngle), sin(flowAngle));
if (radialFlow > 0.5) flowDir = normalize(p - 0.5);
if (spiralFlow > 0.5) {
    float2 toCenter = p - 0.5;
    flowDir = normalize(float2(-toCenter.y, toCenter.x) + toCenter * 0.3);
}

// Multiple depth layers
for (float layer = 0.0; layer < 5.0; layer++) {
    if (layer >= depthLayers) break;
    
    float layerDepth = 1.0 - layer / depthLayers;
    float layerSpeedMult = 1.0 - layer * layerSpeed;
    float layerSize = particleSize * (0.5 + layerDepth * 0.5);
    float layerParticles = particleCount * layerDepth;
    
    // Particle grid for this layer
    float gridSize = 1.0 / layerParticles;
    float2 gridPos = floor(p / gridSize);
    
    // Check neighboring cells
    for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
            float2 cellPos = gridPos + float2(float(dx), float(dy));
            
            // Random position within cell
            float2 randSeed = cellPos + layer * 100.0;
            float2 particleOffset = float2(
                fract(sin(dot(randSeed, float2(127.1, 311.7))) * 43758.5453),
                fract(sin(dot(randSeed, float2(269.5, 183.3))) * 43758.5453)
            );
            
            // Particle movement
            float2 movement = flowDir * timeVal * layerSpeedMult;
            
            // Add turbulence
            if (turbulence > 0.0) {
                float turbX = sin(cellPos.y * 5.0 + timeVal * 2.0) * turbulence * 0.1;
                float turbY = cos(cellPos.x * 5.0 + timeVal * 1.7) * turbulence * 0.1;
                movement += float2(turbX, turbY);
            }
            
            float2 particlePos = (cellPos + particleOffset) * gridSize;
            particlePos = fract(particlePos + movement);
            
            // Size variation
            float sizeMult = 1.0 - sizeVariation * fract(sin(dot(randSeed, float2(12.9898, 78.233))) * 43758.5453) * 0.5;
            float pSize = layerSize * sizeMult;
            
            float dist = length(p - particlePos);
            
            // Particle core
            float coreMask = 1.0 - smoothstep(0.0, pSize, dist);
            
            // Trail
            if (showTrails > 0.5 && trailLength > 0.0) {
                float2 trailDir = normalize(flowDir);
                float trailDist = dot(p - particlePos, -trailDir);
                float trailWidth = 1.0 - smoothstep(0.0, pSize * 0.5, abs(dot(p - particlePos, float2(-trailDir.y, trailDir.x))));
                float trailMask = step(0.0, trailDist) * (1.0 - smoothstep(0.0, trailLength, trailDist)) * trailWidth;
                coreMask = max(coreMask, trailMask * 0.5);
            }
            
            // Glow
            float glowMask = 0.0;
            if (showGlow > 0.5 && glow > 0.5) {
                glowMask = 1.0 - smoothstep(pSize, pSize + glowRadius, dist);
            }
            
            // Color
            float particleHue = mix(hue1, hue2, fract(sin(dot(randSeed, float2(45.678, 98.765))) * 43758.5453) * colorVariation);
            if (colorCycle > 0.5) particleHue = fmod(particleHue + timeVal * 0.1, 1.0);
            particleHue = fmod(particleHue + hueShift, 1.0);
            
            float3 pCol = float3(0.0);
            float h = particleHue * 6.0;
            pCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
            pCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
            pCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
            
            // Flicker
            float flickerVal = 1.0;
            if (flicker > 0.5) {
                flickerVal = 0.7 + 0.3 * sin(timeVal * flickerSpeed + dot(randSeed, float2(12.9898, 78.233)) * 100.0);
            }
            
            col += pCol * (coreMask + glowMask * glowIntensity * 0.5) * layerDepth * flickerVal;
        }
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(timeVal * 3.0);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.x * 30.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.x * 30.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let liquidBlobCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Morph Speed" range(0.0, 2.0) default(0.4)
// @param blobCount "Blob Count" range(2.0, 8.0) default(4.0)
// @param blobSize "Blob Size" range(0.1, 0.5) default(0.25)
// @param smoothness "Smoothness" range(0.01, 0.2) default(0.05)
// @param wobbleAmount "Wobble Amount" range(0.0, 0.3) default(0.15)
// @param wobbleSpeed "Wobble Speed" range(0.0, 5.0) default(2.0)
// @param glowRadius "Glow Radius" range(0.0, 0.2) default(0.08)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.7)
// @param hue1 "Blob Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Glow Hue" range(0.0, 1.0) default(0.65)
// @param saturation "Saturation" range(0.0, 1.5) default(0.9)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param orbitRadius "Orbit Radius" range(0.0, 0.4) default(0.2)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param metaballPower "Metaball Power" range(0.5, 3.0) default(1.5)
// @param threshold "Surface Threshold" range(0.3, 0.9) default(0.6)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param innerBrightness "Inner Brightness" range(0.0, 2.0) default(1.2)
// @param edgeSharpness "Edge Sharpness" range(0.01, 0.1) default(0.03)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle orbiting "Orbiting Blobs" default(true)
// @toggle merging "Merging Effect" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float rad = length(p);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Metaball calculation
float metaball = 0.0;

for (float i = 0.0; i < 8.0; i++) {
    if (i >= blobCount) break;
    
    // Blob position
    float2 blobPos = float2(0.0);
    
    if (orbiting > 0.5) {
        float orbitAngle = i * 6.28318 / blobCount + timeVal * 0.5;
        blobPos = float2(cos(orbitAngle), sin(orbitAngle)) * orbitRadius;
    }
    
    // Wobble
    float wobblePhase = i * 1.234 + timeVal * wobbleSpeed;
    blobPos.x += sin(wobblePhase) * wobbleAmount;
    blobPos.y += cos(wobblePhase * 1.3) * wobbleAmount;
    
    // Distance to blob
    float dist = length(p - blobPos);
    
    // Metaball contribution
    float contribution = blobSize / (dist + 0.01);
    contribution = pow(contribution, metaballPower);
    metaball += contribution;
}

// Surface detection
float surface = smoothstep(threshold - edgeSharpness, threshold + edgeSharpness, metaball);

// Inner gradient
float innerGrad = smoothstep(threshold, threshold + 0.5, metaball);

// Colors
float3 blobCol = float3(0.0);
float h1 = fmod(hue1 + hueShift, 1.0) * 6.0;
blobCol.r = clamp(abs(h1 - 3.0) - 1.0, 0.0, 1.0);
blobCol.g = clamp(2.0 - abs(h1 - 2.0), 0.0, 1.0);
blobCol.b = clamp(2.0 - abs(h1 - 4.0), 0.0, 1.0);

float3 glowCol = float3(0.0);
float h2 = fmod(hue2 + hueShift, 1.0) * 6.0;
glowCol.r = clamp(abs(h2 - 3.0) - 1.0, 0.0, 1.0);
glowCol.g = clamp(2.0 - abs(h2 - 2.0), 0.0, 1.0);
glowCol.b = clamp(2.0 - abs(h2 - 4.0), 0.0, 1.0);

if (colorCycle > 0.5) {
    float shift = timeVal * 0.3;
    blobCol = float3(
        blobCol.r * cos(shift) + blobCol.g * sin(shift),
        blobCol.g * cos(shift) - blobCol.r * sin(shift),
        blobCol.b
    );
}

float3 col = float3(0.0);

// Core
if (showCore > 0.5) {
    float3 coreColor = mix(blobCol, float3(1.0), innerGrad * 0.3);
    coreColor *= innerBrightness;
    col = coreColor * surface;
}

// Glow
if (showGlow > 0.5 && glow > 0.5) {
    float glowMask = smoothstep(threshold - glowRadius, threshold, metaball);
    glowMask *= 1.0 - surface;
    col += glowCol * glowMask * glowIntensity;
}

// Pulse
if (pulse > 0.5) {
    float pulseVal = 0.85 + 0.15 * sin(timeVal * 3.0);
    col *= pulseVal;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * (metaball - threshold) * 5.0;
    col.b *= 1.0 - chromaticAmount * (metaball - threshold) * 5.0;
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let geometricTunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Travel Speed" range(0.0, 3.0) default(0.8)
// @param sides "Polygon Sides" range(3.0, 12.0) default(6.0)
// @param ringCount "Ring Count" range(3.0, 20.0) default(10.0)
// @param ringWidth "Ring Width" range(0.01, 0.1) default(0.03)
// @param tunnelDepth "Tunnel Depth" range(0.5, 5.0) default(2.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.4)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param hue1 "Near Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "Far Hue" range(0.0, 1.0) default(0.7)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param twistAmount "Twist Amount" range(0.0, 3.0) default(0.5)
// @param perspective "Perspective" range(0.1, 2.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param fogDensity "Fog Density" range(0.0, 1.0) default(0.3)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param innerScale "Inner Scale" range(0.1, 0.8) default(0.3)
// @param colorGradient "Color Gradient" range(0.0, 1.0) default(0.7)
// @param edgeGlow "Edge Glow" range(0.0, 1.0) default(0.3)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showRings "Show Rings" default(true)
// @toggle showEdges "Show Edges" default(true)
// @toggle twist "Twist Effect" default(true)
// @toggle colorCycle "Color Cycle" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

// Polar coordinates
float r = length(p);
float a = atan2(p.y, p.x);

// Add rotation over time
float rotTime = animated > 0.5 ? iTime * rotationSpeed : 0.0;
a += rotTime;

// Twist based on depth
if (twist > 0.5) {
    a += r * twistAmount;
}

// Tunnel depth calculation (fake 3D)
float depth = 1.0 / (r + 0.1) * perspective;
float depthZ = fmod(depth + timeVal * 0.5, tunnelDepth);
float normalizedDepth = depthZ / tunnelDepth;

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float segments = sides;
    a = fmod(a + 3.14159, 6.28318 / segments);
    a = abs(a - 3.14159 / segments);
}

// Polygon SDF
float polygonAngle = 6.28318 / sides;
float sectorAngle = fmod(a + polygonAngle * 0.5, polygonAngle) - polygonAngle * 0.5;
float polyDist = cos(sectorAngle);

float3 col = float3(0.0);

// Ring pattern
float ringPhase = fmod(normalizedDepth * ringCount, 1.0);
float ringMask = 0.0;

if (showRings > 0.5) {
    ringMask = 1.0 - smoothstep(0.0, ringWidth, abs(ringPhase - 0.5) * 2.0);
    
    // Pulse per ring
    float ringPulse = 1.0;
    if (pulse > 0.5) {
        ringPulse = 0.7 + 0.3 * sin(timeVal * pulseSpeed + normalizedDepth * 10.0);
    }
    ringMask *= ringPulse;
}

// Edge pattern (polygon edges)
float edgeMask = 0.0;
if (showEdges > 0.5) {
    float edgeDist = abs(sectorAngle) / (polygonAngle * 0.5);
    edgeMask = 1.0 - smoothstep(0.9, 1.0, edgeDist);
    edgeMask *= 1.0 - smoothstep(innerScale, 1.0, r);
}

// Depth-based color
float hue = mix(hue1, hue2, normalizedDepth * colorGradient);
if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
hue = fmod(hue + hueShift, 1.0);

float3 ringCol = float3(0.0);
float h = hue * 6.0;
ringCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
ringCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
ringCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);

// Combine
col = ringCol * (ringMask + edgeMask * edgeGlow);

// Glow
if (glow > 0.5) {
    float glowMask = (ringMask + edgeMask) * glowAmount;
    col += ringCol * glowMask * 0.5;
}

// Fog (fade with depth)
if (fogDensity > 0.0) {
    col *= 1.0 - normalizedDepth * fogDensity;
}

// Center fade
col *= smoothstep(0.0, innerScale, r);

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(p + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(a * 3.0 + timeVal);
    col.b *= 1.0 - chromaticAmount * sin(a * 3.0 + timeVal);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - r * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let neonLetterCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Flicker Speed" range(0.0, 10.0) default(2.0)
// @param letterShape "Letter Shape" range(0.0, 5.0) default(0.0)
// @param strokeWidth "Stroke Width" range(0.02, 0.15) default(0.05)
// @param glowRadius "Glow Radius" range(0.0, 0.3) default(0.15)
// @param glowIntensity "Glow Intensity" range(0.0, 3.0) default(1.5)
// @param flickerAmount "Flicker Amount" range(0.0, 1.0) default(0.3)
// @param flickerSpeed "Flicker Rate" range(0.0, 30.0) default(8.0)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param hue1 "Main Hue" range(0.0, 1.0) default(0.95)
// @param hue2 "Glow Hue" range(0.0, 1.0) default(0.0)
// @param saturation "Saturation" range(0.0, 1.5) default(0.9)
// @param brightness "Brightness" range(0.0, 3.0) default(1.5)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param letterScale "Letter Scale" range(0.2, 1.0) default(0.6)
// @param gamma "Gamma" range(0.5, 2.0) default(0.8)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.02)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.4)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.03)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.8)
// @param buzzAmount "Buzz Amount" range(0.0, 0.02) default(0.005)
// @param haloSize "Halo Size" range(0.0, 0.5) default(0.2)
// @param innerGlow "Inner Glow" range(0.0, 1.0) default(0.5)
// @param reflectionY "Reflection Y" range(0.0, 0.5) default(0.1)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @param aspectRatio "Aspect Ratio" range(0.5, 2.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle showReflection "Show Reflection" default(true)
// @toggle showHalo "Show Halo" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
p.x *= aspectRatio;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Buzz/vibration effect
if (buzzAmount > 0.0) {
    p += float2(
        sin(timeVal * 50.0) * buzzAmount,
        cos(timeVal * 47.0) * buzzAmount
    );
}

// Scale
p /= letterScale;

// Simple geometric letter shapes (based on letterShape parameter)
float d = 10.0;
int shape = int(fmod(letterShape, 6.0));

// Shape 0: "O" ring
if (shape == 0) {
    d = abs(length(p) - 0.4) - strokeWidth;
}
// Shape 1: "X" cross
else if (shape == 1) {
    float d1 = abs(p.x + p.y) / 1.414 - strokeWidth;
    float d2 = abs(p.x - p.y) / 1.414 - strokeWidth;
    d = min(d1, d2);
}
// Shape 2: "+" plus
else if (shape == 2) {
    float d1 = max(abs(p.x) - strokeWidth, abs(p.y) - 0.4);
    float d2 = max(abs(p.y) - strokeWidth, abs(p.x) - 0.4);
    d = min(d1, d2);
}
// Shape 3: Triangle
else if (shape == 3) {
    float2 q = abs(p);
    d = max(q.x * 0.866 + p.y * 0.5, -p.y) - 0.3;
    d = abs(d) - strokeWidth;
}
// Shape 4: Square
else if (shape == 4) {
    float2 q = abs(p) - 0.35;
    float outer = max(q.x, q.y);
    float2 q2 = abs(p) - 0.35 + strokeWidth * 2.0;
    float inner = max(q2.x, q2.y);
    d = max(outer, -inner);
}
// Shape 5: Heart
else {
    float2 q = p;
    q.x = abs(q.x);
    q.y -= 0.1;
    float heart = length(q - float2(0.25, 0.0) * clamp(dot(q, float2(0.25, 0.0)), 0.0, 0.25 / 0.0625)) - 0.25;
    d = abs(heart) - strokeWidth * 0.5;
}

// Neon colors
float3 coreCol = float3(1.0);
float3 glowCol = float3(0.0);
float hG = fmod(hue1 + hueShift, 1.0) * 6.0;
glowCol.r = clamp(abs(hG - 3.0) - 1.0, 0.0, 1.0);
glowCol.g = clamp(2.0 - abs(hG - 2.0), 0.0, 1.0);
glowCol.b = clamp(2.0 - abs(hG - 4.0), 0.0, 1.0);

if (colorCycle > 0.5) {
    float shift = timeVal * 0.2;
    glowCol = float3(
        glowCol.r * cos(shift) + glowCol.g * sin(shift),
        glowCol.g * cos(shift) - glowCol.r * sin(shift),
        glowCol.b
    );
}

float3 col = float3(0.0);

// Flicker calculation
float flickerVal = 1.0;
if (flicker > 0.5) {
    float f1 = sin(timeVal * flickerSpeed) * 0.5 + 0.5;
    float f2 = sin(timeVal * flickerSpeed * 1.7 + 1.0) * 0.5 + 0.5;
    float f3 = fract(sin(floor(timeVal * 3.0) * 12.9898) * 43758.5453);
    flickerVal = 1.0 - flickerAmount * (1.0 - f1 * f2) * step(0.95, f3);
}

// Core (brightest part)
if (showCore > 0.5) {
    float coreMask = 1.0 - smoothstep(-strokeWidth * 0.3, 0.0, d);
    col += coreCol * coreMask * flickerVal;
}

// Inner glow
float innerGlowMask = 1.0 - smoothstep(0.0, strokeWidth, d);
col += glowCol * innerGlowMask * innerGlow * flickerVal;

// Outer glow
if (showGlow > 0.5 && glow > 0.5) {
    float glowMask = 1.0 - smoothstep(0.0, glowRadius, d);
    col += glowCol * glowMask * glowIntensity * 0.5 * flickerVal;
}

// Halo
if (showHalo > 0.5) {
    float haloMask = 1.0 - smoothstep(glowRadius, glowRadius + haloSize, d);
    haloMask *= 1.0 - smoothstep(0.0, glowRadius, d);
    col += glowCol * haloMask * 0.2 * flickerVal;
}

// Reflection
if (showReflection > 0.5 && uv.y < centerY - reflectionY) {
    float reflectY = centerY - reflectionY - (uv.y - (centerY - reflectionY));
    float2 reflectP = float2(uv.x, reflectY);
    float reflectFade = 1.0 - smoothstep(centerY - reflectionY - 0.2, centerY - reflectionY, uv.y);
    col += col * reflectFade * 0.3;
}

// Pulse
if (pulse > 0.5) {
    float pulseVal = 0.9 + 0.1 * sin(timeVal * pulseSpeed);
    col *= pulseVal;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.6;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(d * 20.0);
    col.b *= 1.0 - chromaticAmount * sin(d * 20.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.5;

return float4(col * masterOpacity, masterOpacity);
"""

let rotatingMandalaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param petalCount "Petal Count" range(4.0, 24.0) default(12.0)
// @param layerCount "Layer Count" range(1.0, 8.0) default(5.0)
// @param petalWidth "Petal Width" range(0.1, 0.9) default(0.5)
// @param layerSpacing "Layer Spacing" range(0.05, 0.2) default(0.08)
// @param centerSize "Center Size" range(0.05, 0.3) default(0.1)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.4)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param hue1 "Inner Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "Outer Hue" range(0.0, 1.0) default(0.3)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Initial Rotation" range(0.0, 6.28) default(0.0)
// @param symmetryOffset "Symmetry Offset" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param layerRotationOffset "Layer Rotation" range(0.0, 0.5) default(0.1)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param edgeSoftness "Edge Softness" range(0.01, 0.1) default(0.02)
// @param innerDetail "Inner Detail" range(0.0, 1.0) default(0.5)
// @param colorGradient "Color Gradient" range(0.0, 1.0) default(0.6)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showPetals "Show Petals" default(true)
// @toggle showCenter "Show Center" default(true)
// @toggle alternateRotation "Alternate Rotation" default(true)
// @toggle colorByLayer "Color By Layer" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x) + rotation;

if (kaleidoscope > 0.5) {
    float segments = petalCount;
    a = fmod(a + 3.14159, 6.28318 / segments);
    a = abs(a - 3.14159 / segments);
}

float3 col = float3(0.0);

// Center ornament
if (showCenter > 0.5) {
    float centerMask = 1.0 - smoothstep(centerSize - edgeSoftness, centerSize, r);
    float centerPattern = sin(a * petalCount * 0.5 + timeVal * 2.0) * 0.5 + 0.5;
    centerPattern *= innerDetail;
    
    float3 centerCol = float3(1.0, 0.9, 0.7);
    col += centerCol * centerMask * (0.8 + centerPattern * 0.2);
}

// Petal layers
if (showPetals > 0.5) {
    for (float layer = 0.0; layer < 8.0; layer++) {
        if (layer >= layerCount) break;
        
        float layerRadius = centerSize + layer * layerSpacing;
        float layerRot = timeVal + (alternateRotation > 0.5 ? layer * layerRotationOffset * (fmod(layer, 2.0) > 0.5 ? 1.0 : -1.0) : layer * layerRotationOffset);
        layerRot += symmetryOffset * layer;
        
        float petalAngle = 6.28318 / petalCount;
        float localA = fmod(a + layerRot + petalAngle * 0.5, petalAngle) - petalAngle * 0.5;
        
        // Petal shape
        float petalShape = cos(localA * (1.0 / petalWidth)) * 0.5 + 0.5;
        petalShape = pow(petalShape, 2.0);
        
        // Layer mask
        float innerEdge = layerRadius;
        float outerEdge = layerRadius + layerSpacing;
        float layerMask = smoothstep(innerEdge - edgeSoftness, innerEdge, r) * 
                          (1.0 - smoothstep(outerEdge - edgeSoftness, outerEdge, r));
        
        // Pulse per layer
        float layerPulse = 1.0;
        if (pulse > 0.5) {
            layerPulse = 0.7 + 0.3 * sin(timeVal * pulseSpeed + layer * 0.5);
        }
        
        // Color by layer
        float hue = hue1;
        if (colorByLayer > 0.5) {
            hue = mix(hue1, hue2, layer / layerCount * colorGradient);
        }
        if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
        hue = fmod(hue + hueShift, 1.0);
        
        float3 layerCol = float3(0.0);
        float h = hue * 6.0;
        layerCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
        layerCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
        layerCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
        
        col += layerCol * petalShape * layerMask * layerPulse;
        
        // Glow
        if (glow > 0.5) {
            col += layerCol * petalShape * layerMask * glowAmount * 0.3 * layerPulse;
        }
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(a * 5.0);
    col.b *= 1.0 - chromaticAmount * sin(a * 5.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - r * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let radialBurstCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Burst Speed" range(0.0, 3.0) default(1.0)
// @param rayCount "Ray Count" range(4.0, 64.0) default(24.0)
// @param rayLength "Ray Length" range(0.3, 1.0) default(0.8)
// @param rayWidth "Ray Width" range(0.01, 0.3) default(0.1)
// @param burstFrequency "Burst Frequency" range(0.5, 5.0) default(2.0)
// @param burstDecay "Burst Decay" range(0.1, 0.9) default(0.5)
// @param coreSize "Core Size" range(0.05, 0.3) default(0.1)
// @param coreGlow "Core Glow" range(0.0, 1.0) default(0.6)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.08)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.05)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param spiralAmount "Spiral Amount" range(0.0, 2.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param intensityVariation "Intensity Variation" range(0.0, 1.0) default(0.3)
// @param edgeSharpness "Edge Sharpness" range(0.01, 0.2) default(0.05)
// @param pulsePhase "Pulse Phase" range(0.0, 6.28) default(0.0)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showRays "Show Rays" default(true)
// @toggle pulseBurst "Pulse Burst" default(true)
// @toggle rotateRays "Rotate Rays" default(true)
// @toggle spiral "Spiral Rays" default(false)
// @toggle alternateColors "Alternate Colors" default(true)
// @toggle gradient "Gradient Rays" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float r = length(p);
float a = atan2(p.y, p.x) + rotation;

if (spiral > 0.5) {
    a += r * spiralAmount * 5.0;
}

if (rotateRays > 0.5) {
    a += timeVal * 0.5;
}

float3 col = float3(0.0);

// Burst animation
float burstPhase = fmod(timeVal * burstFrequency + pulsePhase, 1.0);
float burstWave = 0.0;
if (pulseBurst > 0.5) {
    burstWave = burstPhase;
} else {
    burstWave = 0.5;
}

// Rays
if (showRays > 0.5) {
    float rayAngle = 6.28318 / rayCount;
    float localA = fmod(a + rayAngle * 0.5 + 6.28318, rayAngle) - rayAngle * 0.5;
    
    float rayMask = 1.0 - smoothstep(rayWidth - edgeSharpness, rayWidth, abs(localA));
    
    // Ray length with burst
    float currentRayLength = rayLength;
    if (pulseBurst > 0.5) {
        currentRayLength = rayLength * (0.3 + burstPhase * 0.7);
    }
    
    float lengthMask = smoothstep(coreSize, coreSize + 0.05, r) * 
                       (1.0 - smoothstep(currentRayLength * (1.0 - burstDecay), currentRayLength, r));
    
    // Gradient along ray
    float rayGradient = 1.0;
    if (gradient > 0.5) {
        rayGradient = 1.0 - (r - coreSize) / currentRayLength;
        rayGradient = clamp(rayGradient, 0.0, 1.0);
    }
    
    // Color
    float hue = hue1;
    if (alternateColors > 0.5) {
        float rayIndex = floor((a + 3.14159) / rayAngle);
        if (fmod(rayIndex, 2.0) > 0.5) hue = hue2;
    }
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 rayCol = float3(0.0);
    float h = hue * 6.0;
    rayCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    rayCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    rayCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    // Intensity variation
    float variation = 1.0;
    if (intensityVariation > 0.0) {
        float rayIdx = floor((a + 3.14159) / rayAngle);
        variation = 0.5 + 0.5 * sin(rayIdx * 1.618 + timeVal);
        variation = mix(1.0, variation, intensityVariation);
    }
    
    col += rayCol * rayMask * lengthMask * rayGradient * variation;
}

// Core
if (showCore > 0.5) {
    float coreMask = 1.0 - smoothstep(coreSize - 0.02, coreSize, r);
    float3 coreCol = float3(1.0, 0.95, 0.9);
    col += coreCol * coreMask;
    
    // Core glow
    float glowMask = 1.0 - smoothstep(0.0, coreSize * 3.0, r);
    col += coreCol * glowMask * coreGlow * 0.5;
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(a * 8.0);
    col.b *= 1.0 - chromaticAmount * sin(a * 8.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - r * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let rippleInterferenceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.5)
// @param waveCount "Wave Sources" range(2.0, 8.0) default(4.0)
// @param frequency "Wave Frequency" range(5.0, 50.0) default(20.0)
// @param amplitude "Wave Amplitude" range(0.1, 1.0) default(0.5)
// @param wavelength "Wavelength" range(0.02, 0.2) default(0.05)
// @param decay "Wave Decay" range(0.0, 2.0) default(0.5)
// @param sourceRadius "Source Radius" range(0.2, 0.8) default(0.4)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param hue1 "Color 1 Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Color 2 Hue" range(0.0, 1.0) default(0.95)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param edgeWidth "Edge Width" range(0.01, 0.1) default(0.03)
// @param colorBalance "Color Balance" range(0.0, 1.0) default(0.5)
// @param waveSharpness "Wave Sharpness" range(0.1, 1.0) default(0.5)
// @param sourceSpread "Source Spread" range(0.0, 1.0) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle showSources "Show Sources" default(false)
// @toggle rotateSources "Rotate Sources" default(true)
// @toggle colorByAmplitude "Color By Amplitude" default(true)
// @toggle rings "Ring Mode" default(false)
// @toggle additive "Additive Blend" default(true)
// @toggle antiAlias "Anti-Alias" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p = abs(p);

float3 col = float3(0.0);
float totalWave = 0.0;

// Calculate wave interference
float sourceAngle = 6.28318 / waveCount;
float sourceRot = rotateSources > 0.5 ? timeVal * 0.3 : 0.0;

for (float i = 0.0; i < 8.0; i++) {
    if (i >= waveCount) break;
    
    float angle = i * sourceAngle + sourceRot + sourceSpread * sin(i * 1.618);
    float2 sourcePos = float2(cos(angle), sin(angle)) * sourceRadius;
    
    float dist = length(p - sourcePos);
    
    // Wave equation
    float phase = dist / wavelength - timeVal * frequency + phaseOffset + i * 0.5;
    float wave = sin(phase * 6.28318);
    
    // Apply decay
    float decayFactor = exp(-dist * decay);
    wave *= decayFactor * amplitude;
    
    if (additive > 0.5) {
        totalWave += wave;
    } else {
        totalWave = max(totalWave, wave);
    }
    
    // Show source points
    if (showSources > 0.5) {
        float sourceDot = 1.0 - smoothstep(0.02, 0.03, dist);
        col += float3(1.0) * sourceDot;
    }
}

// Normalize
totalWave = totalWave / waveCount * 2.0;

// Apply sharpness
if (waveSharpness < 1.0) {
    totalWave = sign(totalWave) * pow(abs(totalWave), waveSharpness);
}

// Ring mode
if (rings > 0.5) {
    totalWave = abs(totalWave);
}

// Color mapping
float3 waveCol;
if (colorByAmplitude > 0.5) {
    float t = totalWave * 0.5 + 0.5;
    float hue = mix(hue1, hue2, t);
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.05, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float h = hue * 6.0;
    waveCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    waveCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    waveCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    waveCol *= abs(totalWave) + 0.2;
} else {
    waveCol = float3(totalWave * 0.5 + 0.5);
}

col += waveCol;

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(totalWave * 10.0);
    col.b *= 1.0 - chromaticAmount * sin(totalWave * 10.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.5;

return float4(col * masterOpacity, masterOpacity);
"""

let checkerboardMotionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.5)
// @param gridSizeX "Grid Size X" range(2.0, 20.0) default(8.0)
// @param gridSizeY "Grid Size Y" range(2.0, 20.0) default(8.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.1)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param rotationAmount "Rotation Amount" range(0.0, 1.0) default(0.2)
// @param scaleAmount "Scale Amount" range(0.0, 0.5) default(0.1)
// @param cornerRadius "Corner Radius" range(0.0, 0.5) default(0.1)
// @param gapSize "Gap Size" range(0.0, 0.3) default(0.05)
// @param hue1 "Color 1 Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "Color 2 Hue" range(0.0, 1.0) default(0.5)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param depthAmount "Depth Amount" range(0.0, 1.0) default(0.3)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(0.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle waveMotion "Wave Motion" default(true)
// @toggle rotateSquares "Rotate Squares" default(true)
// @toggle scaleSquares "Scale Squares" default(true)
// @toggle roundedCorners "Rounded Corners" default(true)
// @toggle checkerColors "Checker Colors" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle showGap "Show Gap" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Grid coordinates
float2 gridPos = p * float2(gridSizeX, gridSizeY);

// Wave motion
if (waveMotion > 0.5) {
    float wave = sin(gridPos.x * 0.5 + timeVal * waveFrequency + phaseOffset) * waveAmplitude;
    gridPos.y += wave * gridSizeY;
    wave = sin(gridPos.y * 0.5 + timeVal * waveFrequency * 0.7) * waveAmplitude;
    gridPos.x += wave * gridSizeX;
}

// Cell coordinates
float2 cellId = floor(gridPos);
float2 cellUv = fract(gridPos) - 0.5;

// Checker pattern
float checker = fmod(cellId.x + cellId.y, 2.0);

// Per-cell animation
float cellPhase = (cellId.x * 0.3 + cellId.y * 0.7) * 1.618;

// Rotate cell
if (rotateSquares > 0.5) {
    float cellRot = sin(timeVal + cellPhase) * rotationAmount * 3.14159;
    float c = cos(cellRot);
    float s = sin(cellRot);
    cellUv = float2(cellUv.x * c - cellUv.y * s, cellUv.x * s + cellUv.y * c);
}

// Scale cell
float cellScale = 1.0;
if (scaleSquares > 0.5) {
    cellScale = 1.0 + sin(timeVal * 2.0 + cellPhase) * scaleAmount;
}
cellUv *= cellScale;

// Square shape with optional rounded corners
float gap = showGap > 0.5 ? gapSize : 0.0;
float halfSize = 0.5 - gap;

float squareDist;
if (roundedCorners > 0.5 && cornerRadius > 0.0) {
    float2 d = abs(cellUv) - (halfSize - cornerRadius);
    squareDist = length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0) - cornerRadius;
} else {
    float2 d = abs(cellUv) - halfSize;
    squareDist = max(d.x, d.y);
}

float squareMask = 1.0 - smoothstep(-0.02, 0.0, squareDist);

// Color
float3 col = float3(0.0);
float hue = hue1;
if (checkerColors > 0.5 && checker > 0.5) {
    hue = hue2;
}
if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
if (colorVariation > 0.0) {
    hue = fmod(hue + fract(sin(cellId.x * 12.9898 + cellId.y * 78.233) * 43758.5453) * colorVariation, 1.0);
}
hue = fmod(hue + hueShift, 1.0);

float h = hue * 6.0;
col.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
col.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
col.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);

// Depth shading
if (depthAmount > 0.0) {
    float depth = 1.0 - length(cellUv) * depthAmount;
    col *= depth;
}

col *= squareMask;

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (flicker > 0.5) col *= 0.9 + 0.1 * sin(timeVal * flickerRate + cellPhase);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(cellId.x * 3.0);
    col.b *= 1.0 - chromaticAmount * sin(cellId.x * 3.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.5;

return float4(col * masterOpacity, masterOpacity);
"""

let concentricSquaresCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.5)
// @param squareCount "Square Count" range(3.0, 20.0) default(10.0)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.03)
// @param spacing "Spacing" range(0.02, 0.15) default(0.05)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param rotationOffset "Rotation Offset" range(0.0, 0.5) default(0.1)
// @param pulseAmount "Pulse Amount" range(0.0, 0.3) default(0.1)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(2.0)
// @param cornerSharpness "Corner Sharpness" range(0.0, 1.0) default(1.0)
// @param hue1 "Inner Hue" range(0.0, 1.0) default(0.6)
// @param hue2 "Outer Hue" range(0.0, 1.0) default(0.0)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Base Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.3)
// @param fadeStart "Fade Start" range(0.0, 1.0) default(0.0)
// @param fadeEnd "Fade End" range(0.0, 1.0) default(1.0)
// @param waveAmount "Wave Amount" range(0.0, 0.2) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle rotateSquares "Rotate Squares" default(true)
// @toggle alternateRotation "Alternate Rotation" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle colorGradient "Color Gradient" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle showGlow "Show Glow" default(true)
// @toggle fadeOpacity "Fade Opacity" default(false)
// @toggle waveDistort "Wave Distort" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply base rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Wave distortion
if (waveDistort > 0.5) {
    p.x += sin(p.y * 10.0 + timeVal * 3.0) * waveAmount;
    p.y += sin(p.x * 10.0 + timeVal * 2.0) * waveAmount;
}

float3 col = float3(0.0);

// Draw concentric squares
for (float i = 0.0; i < 20.0; i++) {
    if (i >= squareCount) break;
    
    float t = i / squareCount;
    float size = (i + 1.0) * spacing;
    
    // Pulse
    float currentSize = size;
    if (pulse > 0.5) {
        currentSize += sin(timeVal * pulseSpeed + i * 0.5) * pulseAmount * spacing;
    }
    
    // Per-square rotation
    float2 rotP = p;
    if (rotateSquares > 0.5) {
        float sqRot = timeVal * rotationSpeed;
        if (alternateRotation > 0.5) {
            sqRot *= (fmod(i, 2.0) > 0.5 ? 1.0 : -1.0);
        }
        sqRot += i * rotationOffset;
        float c = cos(sqRot);
        float s = sin(sqRot);
        rotP = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    }
    
    // Square SDF with adjustable corner
    float2 d = abs(rotP);
    float squareDist;
    if (cornerSharpness >= 1.0) {
        squareDist = max(d.x, d.y);
    } else {
        float blend = cornerSharpness;
        squareDist = mix(length(d), max(d.x, d.y), blend);
    }
    
    // Line mask
    float lineMask = 1.0 - smoothstep(lineWidth * 0.5, lineWidth, abs(squareDist - currentSize));
    
    // Fade
    float opacity = 1.0;
    if (fadeOpacity > 0.5) {
        opacity = smoothstep(fadeStart, fadeEnd, t);
    }
    
    // Color
    float hue = hue1;
    if (colorGradient > 0.5) {
        hue = mix(hue1, hue2, t);
    }
    if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 squareCol = float3(0.0);
    float h = hue * 6.0;
    squareCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    squareCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    squareCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    col += squareCol * lineMask * opacity;
    
    // Glow
    if (showGlow > 0.5) {
        float glowMask = 1.0 / (1.0 + abs(squareDist - currentSize) * 50.0);
        col += squareCol * glowMask * glowAmount * 0.3 * opacity;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    float dist = max(abs(p.x), abs(p.y));
    col.r *= 1.0 + chromaticAmount * sin(dist * 20.0);
    col.b *= 1.0 - chromaticAmount * sin(dist * 20.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.5;

return float4(col * masterOpacity, masterOpacity);
"""

let diamondPatternCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.5)
// @param gridSize "Grid Size" range(2.0, 15.0) default(6.0)
// @param diamondSize "Diamond Size" range(0.3, 0.9) default(0.7)
// @param lineWidth "Line Width" range(0.01, 0.15) default(0.05)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.2)
// @param pulseAmount "Pulse Amount" range(0.0, 0.3) default(0.1)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(2.0)
// @param innerDiamondSize "Inner Diamond" range(0.0, 0.5) default(0.3)
// @param bevelAmount "Bevel Amount" range(0.0, 1.0) default(0.4)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.75)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.3)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.2)
// @param waveAmount "Wave Amount" range(0.0, 0.3) default(0.0)
// @param depthShading "Depth Shading" range(0.0, 1.0) default(0.3)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle rotateDiamonds "Rotate Diamonds" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle showInner "Show Inner Diamond" default(true)
// @toggle fillDiamond "Fill Diamond" default(false)
// @toggle showBevel "Show Bevel" default(true)
// @toggle colorByPosition "Color By Position" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle showGlow "Show Glow" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Wave distortion
if (waveAmount > 0.0) {
    p.x += sin(p.y * 8.0 + timeVal * 2.0) * waveAmount;
    p.y += sin(p.x * 8.0 + timeVal * 1.5) * waveAmount;
}

// Diamond grid (45 degree rotated square grid)
float2 diamondP = float2(p.x + p.y, p.x - p.y) * 0.7071 * gridSize;
float2 cellId = floor(diamondP);
float2 cellUv = fract(diamondP) - 0.5;

// Per-cell rotation
if (rotateDiamonds > 0.5) {
    float cellRot = timeVal * rotationSpeed + (cellId.x + cellId.y) * 0.3;
    float c = cos(cellRot);
    float s = sin(cellRot);
    cellUv = float2(cellUv.x * c - cellUv.y * s, cellUv.x * s + cellUv.y * c);
}

// Diamond SDF (rotated square)
float diamondDist = abs(cellUv.x) + abs(cellUv.y);

// Pulse
float currentSize = diamondSize * 0.5;
if (pulse > 0.5) {
    float pulsePhase = sin(timeVal * pulseSpeed + (cellId.x - cellId.y) * 0.5);
    currentSize += pulsePhase * pulseAmount * 0.5;
}

float3 col = float3(0.0);

// Color
float hue = hue1;
if (colorByPosition > 0.5) {
    float posFactor = fract((cellId.x + cellId.y) * 0.1);
    hue = mix(hue1, hue2, posFactor);
}
if (colorVariation > 0.0) {
    hue = fmod(hue + fract(sin(cellId.x * 12.9898 + cellId.y * 78.233) * 43758.5453) * colorVariation, 1.0);
}
if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
hue = fmod(hue + hueShift, 1.0);

float3 diamondCol = float3(0.0);
float h = hue * 6.0;
diamondCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
diamondCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
diamondCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);

// Diamond outline or fill
if (fillDiamond > 0.5) {
    float fillMask = 1.0 - smoothstep(currentSize - 0.02, currentSize, diamondDist);
    
    // Bevel/depth effect
    if (showBevel > 0.5) {
        float bevel = 1.0 - diamondDist / currentSize;
        bevel = pow(clamp(bevel, 0.0, 1.0), bevelAmount);
        fillMask *= bevel;
    }
    
    col += diamondCol * fillMask;
} else {
    float outlineMask = 1.0 - smoothstep(lineWidth * 0.5, lineWidth, abs(diamondDist - currentSize));
    col += diamondCol * outlineMask;
}

// Inner diamond
if (showInner > 0.5) {
    float innerSize = currentSize * innerDiamondSize;
    float innerMask = 1.0 - smoothstep(lineWidth * 0.4, lineWidth * 0.8, abs(diamondDist - innerSize));
    col += diamondCol * innerMask * 0.6;
}

// Glow
if (showGlow > 0.5) {
    float glowMask = 1.0 / (1.0 + abs(diamondDist - currentSize) * 30.0);
    col += diamondCol * glowMask * glowAmount * 0.4;
}

// Depth shading
if (depthShading > 0.0) {
    float depth = 1.0 - length(cellUv) * depthShading;
    col *= max(depth, 0.5);
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(diamondDist * 20.0);
    col.b *= 1.0 - chromaticAmount * sin(diamondDist * 20.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.5;

return float4(col * masterOpacity, masterOpacity);
"""

let starFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Flight Speed" range(0.0, 3.0) default(1.0)
// @param starCount "Star Density" range(10.0, 100.0) default(50.0)
// @param starSize "Star Size" range(0.005, 0.05) default(0.015)
// @param starBrightness "Star Brightness" range(0.5, 2.0) default(1.0)
// @param layerCount "Layer Count" range(1.0, 5.0) default(3.0)
// @param layerDepth "Layer Depth" range(0.1, 1.0) default(0.5)
// @param twinkleSpeed "Twinkle Speed" range(0.0, 10.0) default(3.0)
// @param twinkleAmount "Twinkle Amount" range(0.0, 0.5) default(0.2)
// @param streakLength "Streak Length" range(0.0, 0.2) default(0.0)
// @param hue1 "Star Hue 1" range(0.0, 1.0) default(0.6)
// @param hue2 "Star Hue 2" range(0.0, 1.0) default(0.0)
// @param saturation "Saturation" range(0.0, 1.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param glowSize "Glow Size" range(1.0, 5.0) default(2.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 0.5) default(0.0)
// @param nebulaAmount "Nebula Amount" range(0.0, 1.0) default(0.0)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.3)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle flyThrough "Fly Through" default(true)
// @toggle twinkle "Twinkle" default(true)
// @toggle showStreaks "Show Streaks" default(false)
// @toggle colorStars "Color Stars" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle showNebula "Show Nebula" default(false)
// @toggle rotate "Rotate Field" default(false)
// @toggle depthFade "Depth Fade" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
if (rotate > 0.5) {
    float rotAngle = timeVal * rotationSpeed;
    float cosR = cos(rotAngle);
    float sinR = sin(rotAngle);
    p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
}

float3 col = float3(0.0);

// Background nebula
if (showNebula > 0.5 && nebulaAmount > 0.0) {
    float nebula = 0.0;
    for (float i = 0.0; i < 3.0; i++) {
        float2 np = p * (3.0 + i * 2.0);
        float n = sin(np.x * 1.5 + timeVal * 0.1) * sin(np.y * 1.5 - timeVal * 0.1);
        n += sin(np.x * 0.7 - np.y * 0.9 + timeVal * 0.05) * 0.5;
        nebula += n * 0.3;
    }
    nebula = nebula * 0.5 + 0.5;
    
    float3 nebulaCol = float3(0.1, 0.0, 0.2) + float3(0.1, 0.05, 0.0) * nebula;
    col += nebulaCol * nebulaAmount * 0.3;
}

// Star layers
for (float layer = 0.0; layer < 5.0; layer++) {
    if (layer >= layerCount) break;
    
    float layerScale = 1.0 + layer * layerDepth;
    float layerTime = timeVal * (1.0 + layer * 0.3);
    
    // Fly through effect
    float2 layerP = p * layerScale;
    if (flyThrough > 0.5) {
        layerP += float2(0.0, fmod(layerTime * 0.2, 10.0));
    }
    
    // Grid for star placement
    float cellSize = 1.0 / starCount;
    float2 cellId = floor(layerP / cellSize);
    float2 cellUv = fract(layerP / cellSize);
    
    // Random star position within cell
    float2 randSeed = cellId + layer * 100.0;
    float2 starPos = float2(
        fract(sin(dot(randSeed, float2(12.9898, 78.233))) * 43758.5453),
        fract(sin(dot(randSeed + 1.0, float2(12.9898, 78.233))) * 43758.5453)
    );
    
    float2 starUv = cellUv - starPos;
    float starDist = length(starUv) * starCount;
    
    // Star size with depth
    float currentStarSize = starSize * starCount;
    if (depthFade > 0.5) {
        currentStarSize *= (1.0 - layer * 0.2);
    }
    
    // Twinkle
    float starIntensity = 1.0;
    if (twinkle > 0.5) {
        float twinklePhase = fract(sin(dot(randSeed, float2(45.233, 89.012))) * 12345.67);
        starIntensity = 0.5 + 0.5 * sin(timeVal * twinkleSpeed + twinklePhase * 6.28);
        starIntensity = mix(1.0, starIntensity, twinkleAmount);
    }
    
    // Star mask
    float starMask = 1.0 - smoothstep(currentStarSize * 0.5, currentStarSize, starDist);
    starMask *= starIntensity * starBrightness;
    
    // Depth fade
    if (depthFade > 0.5) {
        starMask *= (1.0 - layer * 0.25);
    }
    
    // Star color
    float3 starCol = float3(1.0);
    if (colorStars > 0.5) {
        float hue = mix(hue1, hue2, fract(sin(dot(randSeed, float2(23.456, 67.89))) * 43758.5453));
        hue = fmod(hue + fract(sin(dot(randSeed, float2(34.567, 78.901))) * 43758.5453) * colorVariation, 1.0);
        if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.05, 1.0);
        hue = fmod(hue + hueShift, 1.0);
        
        float h = hue * 6.0;
        starCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
        starCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
        starCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
        starCol = mix(float3(1.0), starCol, 0.5);
    }
    
    col += starCol * starMask;
    
    // Glow
    if (showGlow > 0.5) {
        float glowMask = 1.0 / (1.0 + starDist * starDist * glowSize * 10.0);
        col += starCol * glowMask * 0.2 * starIntensity;
    }
    
    // Streaks
    if (showStreaks > 0.5 && streakLength > 0.0) {
        float streakMask = 1.0 - smoothstep(0.0, streakLength, abs(starUv.y) * starCount);
        streakMask *= 1.0 - smoothstep(0.0, currentStarSize * 2.0, abs(starUv.x) * starCount);
        col += starCol * streakMask * 0.3 * starIntensity;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.8)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.0, 0.8, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(length(p) * 20.0);
    col.b *= 1.0 - chromaticAmount * sin(length(p) * 20.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let laserBeamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param beamCount "Beam Count" range(1.0, 8.0) default(3.0)
// @param beamWidth "Beam Width" range(0.01, 0.15) default(0.03)
// @param beamLength "Beam Length" range(0.3, 1.5) default(1.0)
// @param sweepSpeed "Sweep Speed" range(0.0, 3.0) default(0.5)
// @param sweepRange "Sweep Range" range(0.0, 1.5) default(0.5)
// @param coreIntensity "Core Intensity" range(0.5, 2.0) default(1.0)
// @param glowSize "Glow Size" range(1.0, 10.0) default(3.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param hue1 "Beam Hue 1" range(0.0, 1.0) default(0.0)
// @param hue2 "Beam Hue 2" range(0.0, 1.0) default(0.33)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.6)
// @param flickerRate "Flicker Rate" range(0.0, 30.0) default(0.0)
// @param pulseSpeed "Pulse Speed" range(0.0, 10.0) default(0.0)
// @param fadeStart "Fade Start" range(0.0, 1.0) default(0.7)
// @param beamSpread "Beam Spread" range(0.0, 1.0) default(0.3)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle sweep "Sweep Motion" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle multiColor "Multi Color" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle fade "Fade End" default(true)
// @toggle symmetric "Symmetric" default(true)
// @toggle rotate "Rotate Beams" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply base rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float3 col = float3(0.0);

// Draw beams
for (float i = 0.0; i < 8.0; i++) {
    if (i >= beamCount) break;
    
    float beamIndex = i - (beamCount - 1.0) * 0.5;
    
    // Sweep motion
    float sweepAngle = 0.0;
    if (sweep > 0.5) {
        sweepAngle = sin(timeVal * sweepSpeed + i * 0.5) * sweepRange;
    }
    
    // Beam spread
    float spreadAngle = beamIndex * beamSpread;
    float totalAngle = sweepAngle + spreadAngle;
    
    // Rotate beam
    if (rotate > 0.5) {
        totalAngle += timeVal * 0.3;
    }
    
    // Transform to beam space
    float cosA = cos(totalAngle);
    float sinA = sin(totalAngle);
    float2 beamP = float2(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);
    
    // Only draw in positive Y direction (beam going up from center)
    if (beamP.y < 0.0) {
        if (symmetric > 0.5) {
            beamP.y = -beamP.y;
        } else {
            continue;
        }
    }
    
    // Beam distance
    float beamDist = abs(beamP.x);
    float alongBeam = beamP.y;
    
    // Core mask
    float coreMask = 1.0 - smoothstep(beamWidth * 0.3, beamWidth, beamDist);
    
    // Length mask
    float lengthMask = 1.0;
    if (fade > 0.5) {
        lengthMask = 1.0 - smoothstep(beamLength * fadeStart, beamLength, alongBeam);
    } else {
        lengthMask = step(alongBeam, beamLength);
    }
    
    // Pulse
    float pulseVal = 1.0;
    if (pulse > 0.5) {
        pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed + i * 1.5);
    }
    
    // Flicker
    float flickerVal = 1.0;
    if (flicker > 0.5) {
        flickerVal = 0.8 + 0.2 * sin(timeVal * flickerRate + i * 2.0);
    }
    
    // Color
    float hue = hue1;
    if (multiColor > 0.5) {
        hue = mix(hue1, hue2, i / max(beamCount - 1.0, 1.0));
    }
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 beamCol = float3(0.0);
    float h = hue * 6.0;
    beamCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    beamCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    beamCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    // Core
    col += beamCol * coreMask * lengthMask * coreIntensity * pulseVal * flickerVal;
    
    // Glow
    if (showGlow > 0.5) {
        float glowMask = 1.0 / (1.0 + beamDist * beamDist * glowSize * 100.0);
        glowMask *= lengthMask;
        col += beamCol * glowMask * glowIntensity * pulseVal * flickerVal;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.6;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.0, 0.8, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(p.y * 10.0);
    col.b *= 1.0 - chromaticAmount * sin(p.y * 10.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.3;

return float4(col * masterOpacity, masterOpacity);
"""

let audioVisualizerCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param barCount "Bar Count" range(8.0, 64.0) default(32.0)
// @param barWidth "Bar Width" range(0.3, 0.95) default(0.8)
// @param barHeight "Max Bar Height" range(0.2, 0.9) default(0.6)
// @param reactivity "Reactivity" range(0.5, 3.0) default(1.5)
// @param smoothing "Smoothing" range(0.0, 0.9) default(0.3)
// @param baseHeight "Base Height" range(0.0, 0.2) default(0.05)
// @param cornerRadius "Corner Radius" range(0.0, 0.5) default(0.2)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.4)
// @param hue1 "Low Freq Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "High Freq Hue" range(0.0, 1.0) default(0.7)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param peakDecay "Peak Decay" range(0.9, 0.999) default(0.98)
// @param peakHeight "Peak Height" range(0.01, 0.05) default(0.02)
// @param gapSize "Gap Size" range(0.0, 0.3) default(0.1)
// @param waveInfluence "Wave Influence" range(0.0, 1.0) default(0.5)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle showPeaks "Show Peaks" default(true)
// @toggle colorByHeight "Color By Height" default(true)
// @toggle colorByFreq "Color By Frequency" default(true)
// @toggle roundedBars "Rounded Bars" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle circular "Circular Mode" default(false)
// @toggle gradient "Gradient Fill" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv - center;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(0.0);

if (circular > 0.5) {
    // Circular visualizer
    float r = length(p) * zoom * 2.0;
    float a = atan2(p.y, p.x);
    
    // Bar index from angle
    float barAngle = 6.28318 / barCount;
    float barIndex = floor((a + 3.14159) / barAngle);
    float localA = fmod(a + 3.14159 + barAngle * 0.5, barAngle) - barAngle * 0.5;
    
    // Simulated audio value
    float freq = barIndex / barCount;
    float audioVal = 0.0;
    audioVal += sin(timeVal * 3.0 + freq * 10.0) * 0.3;
    audioVal += sin(timeVal * 5.0 + freq * 15.0) * 0.2;
    audioVal += sin(timeVal * 7.0 + freq * 8.0) * 0.15;
    audioVal += sin(timeVal * 2.0 + freq * 20.0) * 0.1;
    audioVal = (audioVal + 0.75) * reactivity * waveInfluence;
    audioVal = clamp(audioVal, 0.0, 1.0);
    audioVal = mix(baseHeight, barHeight, audioVal);
    
    // Bar mask
    float innerRadius = 0.15;
    float outerRadius = innerRadius + audioVal * 0.3;
    
    float barWidthAngle = barAngle * barWidth * 0.5;
    float barMask = smoothstep(barWidthAngle, barWidthAngle - 0.02, abs(localA));
    barMask *= smoothstep(innerRadius - 0.01, innerRadius, r);
    barMask *= 1.0 - smoothstep(outerRadius - 0.01, outerRadius, r);
    
    // Color
    float hue = colorByFreq > 0.5 ? mix(hue1, hue2, freq) : hue1;
    if (colorByHeight > 0.5) hue = mix(hue, hue2, (r - innerRadius) / (outerRadius - innerRadius));
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 barCol = float3(0.0);
    float h = hue * 6.0;
    barCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    barCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    barCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    col += barCol * barMask;
    
    if (showGlow > 0.5) {
        float glowMask = 1.0 / (1.0 + abs(r - outerRadius) * 50.0) * barMask;
        col += barCol * glowMask * glowAmount;
    }
} else {
    // Linear visualizer
    p *= zoom;
    
    float barPixelWidth = 1.0 / barCount;
    float xPos = p.x + 0.5;
    if (mirror > 0.5) xPos = abs(p.x) * 2.0;
    
    float barIndex = floor(xPos / barPixelWidth);
    float localX = fmod(xPos, barPixelWidth) / barPixelWidth - 0.5;
    
    // Simulated audio value
    float freq = barIndex / barCount;
    float audioVal = 0.0;
    audioVal += sin(timeVal * 3.0 + freq * 10.0 + barIndex * 0.3) * 0.3;
    audioVal += sin(timeVal * 5.0 + freq * 15.0 + barIndex * 0.5) * 0.2;
    audioVal += sin(timeVal * 7.0 + freq * 8.0) * 0.15;
    audioVal += sin(timeVal * 2.0 + freq * 20.0) * 0.1;
    audioVal = (audioVal + 0.75) * reactivity * waveInfluence;
    audioVal = clamp(audioVal, 0.0, 1.0);
    audioVal = mix(baseHeight, barHeight, audioVal);
    
    // Bar shape
    float barHalfWidth = barWidth * 0.5 * (1.0 - gapSize);
    float yPos = p.y + 0.5;
    
    float barMask = 0.0;
    if (roundedBars > 0.5 && cornerRadius > 0.0) {
        float2 d = float2(abs(localX) - barHalfWidth + cornerRadius * barPixelWidth, 
                          abs(yPos - audioVal * 0.5) - audioVal * 0.5 + cornerRadius * audioVal);
        float roundDist = length(max(d, float2(0.0))) - cornerRadius * min(barPixelWidth, audioVal);
        barMask = 1.0 - smoothstep(-0.01, 0.01, roundDist);
    } else {
        barMask = step(abs(localX), barHalfWidth) * step(0.0, yPos) * step(yPos, audioVal);
    }
    
    // Color
    float hue = hue1;
    if (colorByFreq > 0.5) hue = mix(hue1, hue2, freq);
    if (colorByHeight > 0.5) hue = mix(hue, hue2, yPos / audioVal);
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 barCol = float3(0.0);
    float h = hue * 6.0;
    barCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    barCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    barCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    // Gradient fill
    float gradientVal = 1.0;
    if (gradient > 0.5) {
        gradientVal = 0.5 + 0.5 * (yPos / audioVal);
    }
    
    col += barCol * barMask * gradientVal;
    
    // Peak indicator
    if (showPeaks > 0.5) {
        float peakY = audioVal + peakHeight * 0.5;
        float peakMask = 1.0 - smoothstep(peakHeight * 0.4, peakHeight, abs(yPos - peakY));
        peakMask *= step(abs(localX), barHalfWidth);
        col += float3(1.0) * peakMask * 0.8;
    }
    
    // Glow
    if (showGlow > 0.5) {
        float glowDist = abs(yPos - audioVal * 0.5) - audioVal * 0.5;
        float glowMask = 1.0 / (1.0 + max(glowDist, 0.0) * 50.0);
        glowMask *= step(abs(localX), barHalfWidth * 1.5);
        col += barCol * glowMask * glowAmount * 0.3;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(uv.x * 30.0);
    col.b *= 1.0 - chromaticAmount * sin(uv.x * 30.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize;

return float4(col * masterOpacity, masterOpacity);
"""

let polygonMorphCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Morph Speed" range(0.0, 2.0) default(0.5)
// @param shapeCount "Shape Count" range(3.0, 8.0) default(4.0)
// @param shapeSize "Shape Size" range(0.1, 0.5) default(0.25)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.03)
// @param morphAmount "Morph Amount" range(0.0, 1.0) default(0.5)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param scaleSpeed "Scale Speed" range(0.0, 3.0) default(0.5)
// @param scaleAmount "Scale Amount" range(0.0, 0.3) default(0.1)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.4)
// @param hue1 "Shape 1 Hue" range(0.0, 1.0) default(0.0)
// @param hue2 "Shape 2 Hue" range(0.0, 1.0) default(0.33)
// @param saturation "Saturation" range(0.0, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param edgeSoftness "Edge Softness" range(0.01, 0.1) default(0.02)
// @param cornerRounding "Corner Rounding" range(0.0, 0.5) default(0.0)
// @param sideCount "Side Count" range(3.0, 12.0) default(6.0)
// @param starAmount "Star Amount" range(0.0, 0.5) default(0.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(3.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle rotate "Rotate" default(true)
// @toggle scale "Scale Pulse" default(true)
// @toggle morph "Morph" default(true)
// @toggle fillShape "Fill Shape" default(false)
// @toggle showGlow "Show Glow" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle multiShape "Multi Shape" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Apply base rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p = abs(p);

float3 col = float3(0.0);

// Polygon SDF function inline
// Calculate distance to regular polygon
float polyDist(float2 pos, float sides, float size, float starAmt) {
    float a = atan2(pos.x, pos.y) + 3.14159;
    float r = length(pos);
    float segAngle = 6.28318 / sides;
    
    // Star inset
    float inset = 1.0;
    if (starAmt > 0.0) {
        inset = 1.0 - starAmt * (1.0 - cos(fmod(a, segAngle) - segAngle * 0.5));
    }
    
    return r / inset - size * cos(3.14159 / sides) / cos(fmod(a, segAngle) - segAngle * 0.5);
}

// Draw shapes
float shapeSpacing = multiShape > 0.5 ? 0.4 : 0.0;

for (float i = 0.0; i < 8.0; i++) {
    if (i >= shapeCount) break;
    
    float2 shapePos = p;
    
    if (multiShape > 0.5) {
        float angle = i / shapeCount * 6.28318 + timeVal * 0.2;
        shapePos -= float2(cos(angle), sin(angle)) * shapeSpacing;
    }
    
    // Rotate shape
    if (rotate > 0.5) {
        float rotAngle = timeVal * rotationSpeed + i * 0.5;
        float c = cos(rotAngle);
        float s = sin(rotAngle);
        shapePos = float2(shapePos.x * c - shapePos.y * s, shapePos.x * s + shapePos.y * c);
    }
    
    // Scale pulse
    float currentSize = shapeSize;
    if (scale > 0.5) {
        currentSize *= 1.0 + sin(timeVal * scaleSpeed + i * 0.7) * scaleAmount;
    }
    
    // Morphing sides
    float sides = sideCount;
    if (morph > 0.5) {
        sides = 3.0 + fmod(timeVal * 0.5 + i * 0.3, 9.0);
        sides = floor(sides) + smoothstep(0.7, 1.0, fract(sides)) * (1.0 - smoothstep(0.0, 0.3, fract(sides)));
    }
    
    // Shape distance
    float d = polyDist(shapePos, sides, currentSize, starAmount);
    
    // Apply corner rounding
    if (cornerRounding > 0.0) {
        d -= cornerRounding * currentSize * 0.3;
    }
    
    // Shape mask
    float shapeMask;
    if (fillShape > 0.5) {
        shapeMask = 1.0 - smoothstep(-edgeSoftness, edgeSoftness, d);
    } else {
        shapeMask = 1.0 - smoothstep(lineWidth * 0.5, lineWidth, abs(d));
    }
    
    // Color
    float hue = mix(hue1, hue2, i / max(shapeCount - 1.0, 1.0));
    if (colorCycle > 0.5) hue = fmod(hue + timeVal * 0.15, 1.0);
    if (colorShift > 0.5) hue = fmod(hue + timeVal * 0.1 + i * 0.1, 1.0);
    hue = fmod(hue + hueShift, 1.0);
    
    float3 shapeCol = float3(0.0);
    float h = hue * 6.0;
    shapeCol.r = clamp(abs(h - 3.0) - 1.0, 0.0, 1.0);
    shapeCol.g = clamp(2.0 - abs(h - 2.0), 0.0, 1.0);
    shapeCol.b = clamp(2.0 - abs(h - 4.0), 0.0, 1.0);
    
    col += shapeCol * shapeMask;
    
    // Glow
    if (showGlow > 0.5) {
        float glowMask = 1.0 / (1.0 + abs(d) * 30.0);
        col += shapeCol * glowMask * glowAmount * 0.3;
    }
}

// Color adjustments
col *= brightness;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Effects
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * sin(length(p) * 15.0);
    col.b *= 1.0 - chromaticAmount * sin(length(p) * 15.0);
}

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 200.0 / scanlineGap);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= 1.0 - length(p) * vignetteSize * 0.5;

return float4(col * masterOpacity, masterOpacity);
"""
