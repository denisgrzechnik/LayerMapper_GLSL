//
//  ShaderCodes_Part8.swift
//  LM_GLSL
//
//  Shader codes - Part 8: Retro, Glitch & Digital Art Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Retro & Digital Parametric Shaders

/// VHS Tape Distortion Advanced
let vhsAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.5)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.2)
// @param colorBleed "Color Bleed" range(0.0, 0.05) default(0.02)
// @param trackingError "Tracking Error" range(0.0, 0.1) default(0.03)
// @param flickerSpeed "Flicker Speed" range(0.0, 20.0) default(10.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.6)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle staticNoise "Static Noise" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
float trackError = sin(timeVal * 2.0 + p.y * 20.0) * trackingError * step(0.9, sin(timeVal * 0.5));
p.x += trackError;

float r = sin(p.x * 500.0 + timeVal * flickerSpeed) * 0.5 + 0.5;
float g = sin((p.x + colorBleed) * 500.0 + timeVal * flickerSpeed) * 0.5 + 0.5;
float b = sin((p.x - colorBleed) * 500.0 + timeVal * flickerSpeed) * 0.5 + 0.5;
float3 col = float3(r * color1Red, g * color1Green, b * color1Blue);

if (scanlines > 0.5) {
    float scanline = sin(p.y * 400.0) * 0.5 + 0.5;
    scanline = pow(scanline, 2.0);
    col *= (1.0 - scanlineIntensity * 0.5 + scanlineIntensity * 0.5 * scanline);
}

if (staticNoise > 0.5) {
    float noiseVal = fract(sin(dot(p + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * noiseAmount;
}

if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

float flickerVal = 0.98 + 0.02 * sin(timeVal * flickerSpeed * 3.0);
col *= flickerVal;
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// CRT Monitor Effect
let crtMonitorCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param curvature "Curvature" range(0.0, 0.5) default(0.2)
// @param scanlineWeight "Scanline Weight" range(0.0, 1.0) default(0.5)
// @param phosphorGlow "Phosphor Glow" range(0.0, 1.0) default(0.3)
// @param rgbOffset "RGB Offset" range(0.0, 0.01) default(0.003)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle interlace "Interlace" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv - 0.5;
float2 curved = p * (1.0 + length(p) * curvature);
curved += 0.5;

if (curved.x < 0.0 || curved.x > 1.0 || curved.y < 0.0 || curved.y > 1.0) {
    return float4(0.0, 0.0, 0.0, masterOpacity);
}

float r = sin(curved.x * 100.0 + timeVal) * 0.5 + 0.5;
float g = sin((curved.x + rgbOffset) * 100.0 + timeVal * 1.1) * 0.5 + 0.5;
float b = sin((curved.x - rgbOffset) * 100.0 + timeVal * 0.9) * 0.5 + 0.5;
float3 col = float3(r * color1Red, g * color1Green, b * color1Blue);

if (scanlines > 0.5) {
    float scanline = sin(curved.y * 600.0) * 0.5 + 0.5;
    col *= (1.0 - scanlineWeight * (1.0 - scanline));
}

if (interlace > 0.5) {
    float interlaceLines = fmod(floor(curved.y * 300.0) + floor(timeVal * 30.0), 2.0);
    col *= (0.9 + 0.1 * interlaceLines);
}

float phosphor = exp(-length(curved - 0.5) * 2.0) * phosphorGlow;
col += float3(color2Red * phosphor, color2Green * phosphor, color2Blue * phosphor);
col *= brightness;

float bezel = smoothstep(0.0, 0.05, curved.x) * smoothstep(1.0, 0.95, curved.x);
bezel *= smoothstep(0.0, 0.05, curved.y) * smoothstep(1.0, 0.95, curved.y);
col *= bezel;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Glitch Art
let glitchArtCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param glitchIntensity "Glitch Intensity" range(0.0, 1.0) default(0.5)
// @param blockSize "Block Size" range(0.02, 0.2) default(0.05)
// @param shiftAmount "Shift Amount" range(0.0, 0.2) default(0.1)
// @param colorSplit "Color Split" range(0.0, 0.05) default(0.02)
// @param glitchSpeed "Glitch Speed" range(1.0, 20.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle digitalNoise "Digital Noise" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float time = floor(timeVal * glitchSpeed);
float glitchTrigger = step(0.8, fract(sin(time * 43.758) * 43758.5453));
float blockY = floor(p.y / blockSize) * blockSize;
float blockRand = fract(sin(blockY * 43.758 + time) * 43758.5453);

if (blockRand > (1.0 - glitchIntensity) && glitchTrigger > 0.5) {
    p.x += (blockRand - 0.5) * shiftAmount;
}

float3 col;
float r = sin(p.x * 50.0 + sin(p.y * 30.0 + timeVal)) * 0.5 + 0.5;
float g = sin((p.x + colorSplit) * 50.0 + sin(p.y * 30.0 + timeVal)) * 0.5 + 0.5;
float b = sin((p.x - colorSplit) * 50.0 + sin(p.y * 30.0 + timeVal)) * 0.5 + 0.5;
col = float3(r * color1Red, g * color1Green, b * color1Blue);

if (digitalNoise > 0.5) {
    float noiseVal = fract(sin(dot(floor(p * 100.0) + time, float2(12.9898, 78.233))) * 43758.5453);
    if (noiseVal > 0.98 && glitchTrigger > 0.5) {
        col = float3(1.0);
    }
}

float corruptLine = step(0.995, fract(sin(floor(p.y * 50.0 + time * 0.1) * 43.758) * 43758.5453));
corruptLine *= glitchTrigger * glitchIntensity;
col = mix(col, float3(1.0) - col, corruptLine);
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Pixel Art Style
let pixelArtCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param pixelSize "Pixel Size" range(4.0, 64.0) default(16.0)
// @param colorDepth "Color Depth" range(2.0, 16.0) default(8.0)
// @param dithering "Dithering" range(0.0, 1.0) default(0.3)
// @param palette "Palette" range(0.0, 3.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle showGrid "Show Grid" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(true)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 pixelUV = floor(uv * pixelSize) / pixelSize;
float2 pixelCenter = pixelUV + 0.5 / pixelSize;
float pattern = sin(pixelCenter.x * 20.0 + timeVal) * sin(pixelCenter.y * 20.0 + timeVal * 0.7);
pattern = pattern * 0.5 + 0.5;

float3 col;
if (palette < 1.0) {
    col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0));
} else if (palette < 2.0) {
    col = float3(pattern * color1Red, pattern * color1Green * 0.8, pattern * color1Blue * 0.5);
} else if (palette < 3.0) {
    col = float3(pattern * color2Red * 0.3, pattern * color2Green, pattern * color2Blue * 0.5);
} else {
    col = float3(pattern, pattern * 0.5, pattern);
}
col = pow(col, float3(contrast));

if (dithering > 0.0) {
    float2 ditherPos = fract(uv * pixelSize);
    float ditherPattern = fmod(floor(ditherPos.x * 2.0) + floor(ditherPos.y * 2.0), 2.0);
    col += (ditherPattern - 0.5) * dithering * 0.1;
}
col = floor(col * colorDepth) / colorDepth;

if (showGrid > 0.5) {
    float2 gridPos = fract(uv * pixelSize);
    float grid = step(0.95, max(gridPos.x, gridPos.y));
    col = mix(col, float3(0.0), grid * 0.5);
}
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Arcade Machine
let arcadeMachineCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param screenGlow "Screen Glow" range(0.0, 1.0) default(0.5)
// @param scanlineGap "Scanline Gap" range(100.0, 500.0) default(200.0)
// @param bloomAmount "Bloom Amount" range(0.0, 1.0) default(0.3)
// @param colorBoost "Color Boost" range(1.0, 2.0) default(1.3)
// @param noiseLevel "Noise Level" range(0.0, 0.2) default(0.05)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle cabinetFrame "Cabinet Frame" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 col = float3(0.0);

float game = sin(p.x * 30.0 + timeVal * 2.0) * sin(p.y * 30.0 + timeVal * 1.5);
game = step(0.0, game);
float3 gameColor = game * float3(color1Red, color1Green, color1Blue);

float player = smoothstep(0.05, 0.03, length(p - float2(0.5 + sin(timeVal) * 0.2, 0.3)));
gameColor += player * float3(color2Red, color2Green, color2Blue);

for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 enemyPos = float2(0.2 + fi * 0.15, 0.7 + sin(timeVal + fi) * 0.1);
    float enemy = smoothstep(0.03, 0.02, length(p - enemyPos));
    gameColor += enemy * float3(1.0, 0.0, 0.3);
}
col = gameColor * colorBoost;

if (scanlines > 0.5) {
    float scanline = sin(p.y * scanlineGap) * 0.5 + 0.5;
    col *= (0.9 + 0.1 * scanline);
}
col += col * bloomAmount * 0.3;

float noiseVal = fract(sin(dot(p + timeVal, float2(12.9898, 78.233))) * 43758.5453);
col += (noiseVal - 0.5) * noiseLevel;

float glowVal = exp(-length(p - 0.5) * 2.0) * screenGlow;
col += float3(0.0, glowVal * 0.2, glowVal * 0.1);

if (cabinetFrame > 0.5) {
    float frame = step(0.05, p.x) * step(p.x, 0.95) * step(0.05, p.y) * step(p.y, 0.95);
    col *= frame;
    float bezel = (1.0 - frame) * 0.1;
    col += bezel * float3(0.1, 0.1, 0.1);
}
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Commodore 64 Style
let c64StyleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param charScale "Char Scale" range(8.0, 32.0) default(16.0)
// @param borderSize "Border Size" range(0.0, 0.15) default(0.08)
// @param scrollSpeed "Scroll Speed" range(0.0, 3.0) default(1.0)
// @param colorCycle "Color Cycle" range(0.0, 2.0) default(0.5)
// @param scanlineAmount "Scanline Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle flashCursor "Flash Cursor" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 c64Blue = float3(color1Red, color1Green, color1Blue);
float3 c64LightBlue = float3(color2Red, color2Green, color2Blue);
float3 col = c64Blue;

float2 borderMin = float2(borderSize);
float2 borderMax = float2(1.0 - borderSize);
if (p.x > borderMin.x && p.x < borderMax.x && p.y > borderMin.y && p.y < borderMax.y) {
    float2 screenP = (p - borderMin) / (borderMax - borderMin);
    screenP.x += timeVal * scrollSpeed * 0.1;
    float2 charPos = floor(screenP * charScale);
    float charRand = fract(sin(dot(charPos, float2(12.9898, 78.233))) * 43758.5453);
    float charVal = step(0.3, charRand) * step(charRand, 0.7);
    float2 inChar = fract(screenP * charScale);
    float charPixel = step(0.2, inChar.x) * step(inChar.x, 0.8);
    charPixel *= step(0.2, inChar.y) * step(inChar.y, 0.8);
    charPixel *= charVal;
    float3 textColor = 0.5 + 0.5 * cos(charPos.x * 0.1 + timeVal * colorCycle + float3(0.0, 2.0, 4.0));
    col = mix(float3(0.1, 0.1, 0.3), textColor, charPixel);
    if (flashCursor > 0.5) {
        float cursorX = fmod(floor(timeVal * 2.0), charScale);
        float cursorY = charScale - 1.0;
        float cursor = step(cursorX - 0.5, charPos.x) * step(charPos.x, cursorX + 0.5);
        cursor *= step(cursorY - 0.5, charPos.y) * step(charPos.y, cursorY + 0.5);
        cursor *= step(0.5, sin(timeVal * 5.0));
        col += cursor * c64LightBlue;
    }
}

if (scanlines > 0.5) {
    float scanline = sin(p.y * 500.0) * 0.5 + 0.5;
    col *= (1.0 - scanlineAmount * 0.3 + scanlineAmount * 0.3 * scanline);
}
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Synthwave Horizon
let synthwaveHorizonCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param gridSpeed "Grid Speed" range(0.5, 5.0) default(2.0)
// @param sunSize "Sun Size" range(0.1, 0.4) default(0.25)
// @param horizonLine "Horizon Line" range(0.3, 0.7) default(0.5)
// @param gridDensity "Grid Density" range(5.0, 20.0) default(10.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.1)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle mountains "Mountains" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 col = float3(0.0);
float3 gridColor = float3(color1Red, color1Green, color1Blue);
float3 skyDark = float3(color2Red, color2Green, color2Blue);

float sky = smoothstep(horizonLine + 0.3, horizonLine, p.y);
float3 skyColor = mix(skyDark, float3(0.5, 0.0, 0.3), sky);
col = skyColor;

float2 sunCenter = float2(0.5, horizonLine + 0.1);
float sunDist = length(p - sunCenter);
float sun = smoothstep(sunSize + 0.02, sunSize, sunDist);
float sunStripes = step(0.5, sin(p.y * 50.0));
sun *= sunStripes + (1.0 - step(horizonLine, p.y));
float3 sunColor = mix(float3(1.0, 0.8, 0.0), float3(1.0, 0.3, 0.5), (sunCenter.y - p.y) / sunSize + 0.5);
col = mix(col, sunColor, sun);

if (p.y < horizonLine) {
    float groundY = (horizonLine - p.y) / horizonLine;
    float z = 1.0 / (groundY + 0.01);
    float x = (p.x - 0.5) * z;
    x += timeVal * gridSpeed;
    z += timeVal * gridSpeed * 3.0;
    float gridX = smoothstep(0.1, 0.0, abs(fract(x / gridDensity) - 0.5));
    float gridZ = smoothstep(0.1, 0.0, abs(fract(z / gridDensity) - 0.5));
    float grid = max(gridX, gridZ);
    col = mix(float3(0.05, 0.0, 0.1), gridColor, grid);
    col *= (1.0 - groundY * 0.5);
}

if (mountains > 0.5 && p.y < horizonLine + 0.1 && p.y > horizonLine - 0.15) {
    float mountain = sin(p.x * 20.0) * 0.05 + sin(p.x * 7.0) * 0.03;
    float mountainShape = step(p.y, horizonLine + mountain);
    col = mix(col, float3(0.1, 0.0, 0.15), mountainShape);
}

if (glow > 0.5) {
    float glowVal = exp(-sunDist * 3.0) * glowIntensity;
    col += glowVal * float3(1.0, 0.5, 0.3);
}

col *= brightness;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Neon City
let neonCityCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param buildingDensity "Building Density" range(10.0, 40.0) default(20.0)
// @param neonBrightness "Neon Brightness" range(0.5, 2.0) default(1.0)
// @param rainAmount "Rain Amount" range(0.0, 1.0) default(0.3)
// @param reflectionStrength "Reflection Strength" range(0.0, 1.0) default(0.5)
// @param fogDensity "Fog Density" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle animatedSigns "Animated Signs" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 col = float3(0.02, 0.01, 0.05);
float3 neonColor1 = float3(color1Red, color1Green, color1Blue);
float3 neonColor2 = float3(color2Red, color2Green, color2Blue);
float horizon = 0.4;

if (p.y > horizon) {
    float skyGrad = (p.y - horizon) / (1.0 - horizon);
    col = mix(float3(0.1, 0.02, 0.15), float3(0.02, 0.01, 0.05), skyGrad);
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float bx = fract(sin(fi * 127.1) * 43758.5453);
        float bh = fract(sin(fi * 311.7) * 43758.5453) * 0.5 + 0.2;
        float bw = 0.02 + fract(sin(fi * 78.233) * 43758.5453) * 0.03;
        float building = step(abs(p.x - bx), bw);
        building *= step(horizon, p.y) * step(p.y, horizon + bh);
        float depth = fi / 30.0;
        float3 buildingColor = float3(0.05, 0.03, 0.08) * (1.0 - depth * 0.5);
        col = mix(col, buildingColor, building);
        if (animatedSigns > 0.5) {
            float signY = horizon + bh * 0.7;
            float sign = step(abs(p.x - bx), bw * 0.8) * step(abs(p.y - signY), 0.01);
            float signFlicker = flicker > 0.5 ? step(0.3, sin(timeVal * 5.0 + fi)) : 1.0;
            float3 signColor = rainbow > 0.5 ? 0.5 + 0.5 * cos(fi + float3(0.0, 2.0, 4.0)) : mix(neonColor1, neonColor2, sin(fi));
            col += sign * signColor * neonBrightness * signFlicker;
        }
        float windowChance = fract(sin(dot(float2(floor(p.x * 100.0), floor(p.y * 50.0)), float2(12.9898, 78.233)) + fi) * 43758.5453);
        float window = step(0.7, windowChance) * building;
        float3 windowColor = float3(1.0, 0.9, 0.6);
        col += window * windowColor * 0.3;
    }
}

if (rainAmount > 0.0) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float rx = fract(sin(fi * 43.758) * 43758.5453);
        float ry = fract(sin(fi * 78.233) * 43758.5453 - timeVal * 0.5);
        float rain = smoothstep(0.01, 0.0, abs(p.x - rx)) * smoothstep(0.03, 0.0, abs(fract(p.y + ry) - 0.5));
        col += rain * rainAmount * 0.3;
    }
}

if (p.y < horizon && reflectionStrength > 0.0) {
    float2 reflP = float2(p.x, horizon - (horizon - p.y));
    float refl = sin(reflP.x * buildingDensity + timeVal) * 0.5 + 0.5;
    col += refl * neonColor1 * 0.5 * reflectionStrength * (horizon - p.y) / horizon;
}

col = mix(col, float3(0.05, 0.02, 0.1), fogDensity * (1.0 - p.y));
col *= brightness;

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Digital Rain Advanced
let digitalRainAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param columnCount "Column Count" range(10, 50) default(30)
// @param fallSpeed "Fall Speed" range(0.5, 3.0) default(1.0)
// @param trailLength "Trail Length" range(5, 20) default(10)
// @param colorHue "Color Hue" range(0.0, 1.0) default(0.33)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle highlightHead "Highlight Head" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 col = float3(0.0);
float3 mainColor = rainbow > 0.5 
    ? 0.5 + 0.5 * cos(colorHue * 6.28 + timeVal + float3(0.0, 2.0, 4.0))
    : float3(color1Red, color1Green, color1Blue);
float3 headColor = float3(color2Red, color2Green, color2Blue);

for (int i = 0; i < 50; i++) {
    if (float(i) >= float(columnCount)) break;
    float fi = float(i);
    float x = (fi + 0.5) / float(columnCount);
    float speed = 0.5 + fract(sin(fi * 127.1) * 43758.5453) * 0.5;
    float offset = fract(sin(fi * 311.7) * 43758.5453);
    float headY = fract(timeVal * fallSpeed * speed + offset);
    float colDist = abs(p.x - x) * float(columnCount);
    if (colDist < 0.5) {
        for (int j = 0; j < 20; j++) {
            if (j >= int(trailLength)) break;
            float fj = float(j);
            float charY = headY - fj * 0.03;
            if (charY < 0.0) charY += 1.0;
            float charDist = abs(p.y - charY);
            if (charDist < 0.015) {
                float fade = gradient > 0.5 ? 1.0 - fj / float(trailLength) : 1.0;
                float charRand = fract(sin(fi * 43.758 + fj * 12.345 + floor(timeVal * 10.0)) * 43758.5453);
                float charPattern = step(0.3, charRand);
                float3 charColor = mainColor * fade * brightness * charPattern;
                if (highlightHead > 0.5 && j == 0) {
                    charColor = headColor * brightness * charPattern;
                }
                col += charColor * (1.0 - colDist * 2.0);
            }
        }
    }
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (scanlines > 0.5) col *= 0.8 + 0.2 * sin(p.y * 500.0);
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Demoscene Plasma
let demoscenePlasmaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param scale "Scale" range(1.0, 10.0) default(4.0)
// @param colorRotation "Color Rotation" range(0.0, 2.0) default(0.5)
// @param distortion "Distortion" range(0.0, 1.0) default(0.3)
// @param bands "Bands" range(1.0, 5.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle copper "Copper Effect" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv * scale;

float plasma = 0.0;
plasma += sin(p.x + timeVal);
plasma += sin(p.y + timeVal * 0.5);
plasma += sin((p.x + p.y + timeVal) * 0.5);
float cx = p.x + sin(timeVal / 3.0) * distortion * 3.0;
float cy = p.y + cos(timeVal / 2.0) * distortion * 3.0;
plasma += sin(sqrt(cx * cx + cy * cy + 1.0) + timeVal);
plasma = plasma * bands * 0.5;

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(plasma + timeVal * colorRotation + float3(0.0, 2.0, 4.0));
} else {
    float3 baseColor = float3(color1Red, color1Green, color1Blue);
    float3 accentColor = float3(color2Red, color2Green, color2Blue);
    col = mix(baseColor, accentColor, sin(plasma) * 0.5 + 0.5);
}

if (copper > 0.5) {
    float copperBar = sin(uv.y * 50.0 + timeVal * 10.0) * 0.5 + 0.5;
    float3 copperColor = 0.5 + 0.5 * cos(uv.y * 20.0 + timeVal * 3.0 + float3(0.0, 1.0, 2.0));
    col = mix(col, copperColor, copperBar * 0.3);
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Glitch & Corruption Effects

/// Data Corruption
let dataCorruptionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param corruptionLevel "Corruption Level" range(0.0, 1.0) default(0.4)
// @param blockScale "Block Scale" range(0.02, 0.2) default(0.05)
// @param shiftRange "Shift Range" range(0.0, 0.3) default(0.1)
// @param colorCorruption "Color Corruption" range(0.0, 1.0) default(0.3)
// @param updateSpeed "Update Speed" range(1.0, 30.0) default(10.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle rgbShift "RGB Shift" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? floor(iTime * updateSpeed * speed) : 0.0;
float2 p = uv;
float3 colorA = float3(color1Red, color1Green, color1Blue);
float3 colorB = float3(color2Red, color2Green, color2Blue);

float2 blockId = floor(p / blockScale);
float blockRand = fract(sin(dot(blockId, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
if (blockRand < corruptionLevel) {
    float shiftX = (fract(sin(blockId.x * 43.758 + timeVal) * 43758.5453) - 0.5) * shiftRange;
    float shiftY = (fract(sin(blockId.y * 78.233 + timeVal) * 43758.5453) - 0.5) * shiftRange * 0.5;
    p += float2(shiftX, shiftY);
}

float3 col;
float pattern = sin(p.x * 50.0 + iTime * speed) * sin(p.y * 50.0 + iTime * speed * 0.7);
pattern = pattern * 0.5 + 0.5;
col = rainbow > 0.5 
    ? 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0))
    : mix(colorA, colorB, pattern);

if (rgbShift > 0.5 && blockRand < corruptionLevel) {
    float rShift = fract(sin(blockId.x * 127.1 + timeVal) * 43758.5453) * 0.02;
    float bShift = fract(sin(blockId.y * 311.7 + timeVal) * 43758.5453) * 0.02;
    col.r = sin((p.x + rShift) * 50.0 + iTime * speed) * 0.5 + 0.5;
    col.b = sin((p.x - bShift) * 50.0 + iTime * speed) * 0.5 + 0.5;
}

if (colorCorruption > 0.0 && fract(sin(dot(blockId * 2.0, float2(127.1, 311.7)) + timeVal) * 43758.5453) < colorCorruption * 0.3) {
    col = float3(1.0) - col;
}

col *= brightness;
if (flicker > 0.5) col *= 0.8 + 0.2 * sin(iTime * 15.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Signal Interference
let signalInterferenceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param interferenceStrength "Interference Strength" range(0.0, 1.0) default(0.5)
// @param waveCount "Wave Count" range(1, 10) default(5)
// @param noiseFrequency "Noise Frequency" range(10.0, 100.0) default(50.0)
// @param rollSpeed "Roll Speed" range(0.0, 5.0) default(1.0)
// @param chromaticShift "Chromatic Shift" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle verticalHold "Vertical Hold" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;

if (verticalHold > 0.5) {
    float rollOffset = sin(timeVal * rollSpeed) * 0.1 * interferenceStrength;
    p.y = fract(p.y + rollOffset);
}

float interference = 0.0;
for (int i = 0; i < 10; i++) {
    if (float(i) >= float(waveCount)) break;
    float fi = float(i);
    float freq = 10.0 + fi * 5.0;
    float phase = timeVal * (1.0 + fi * 0.3);
    interference += sin(p.y * freq + phase) / (fi + 1.0);
}
interference *= interferenceStrength;
p.x += interference * 0.05;

float noiseVal = fract(sin(dot(p * noiseFrequency + timeVal, float2(12.9898, 78.233))) * 43758.5453);

float3 col;
float signal = sin(p.x * 30.0 + p.y * 20.0 + timeVal) * 0.5 + 0.5;

if (chromatic > 0.5) {
    col.r = sin((p.x + chromaticShift) * 30.0 + p.y * 20.0 + timeVal) * 0.5 + 0.5;
    col.g = signal;
    col.b = sin((p.x - chromaticShift) * 30.0 + p.y * 20.0 + timeVal) * 0.5 + 0.5;
} else {
    col = float3(signal);
}

if (rainbow > 0.5) col = 0.5 + 0.5 * cos(signal * 6.28 + timeVal + float3(0.0, 2.0, 4.0));

if (noise > 0.5) col += (noiseVal - 0.5) * interferenceStrength * 0.3;

float staticBurst = step(0.95, fract(sin(floor(timeVal * 10.0) * 43.758) * 43758.5453));
if (flicker > 0.5) col += staticBurst * (noiseVal - 0.5) * 0.5;

col *= brightness;
if (scanlines > 0.5) col *= 0.8 + 0.2 * sin(p.y * 300.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Broken LCD
let brokenLCDCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param deadPixelDensity "Dead Pixel Density" range(0.0, 0.1) default(0.02)
// @param lineDefects "Line Defects" range(0, 5) default(2)
// @param pressurePoint "Pressure Point" range(0.0, 1.0) default(0.0)
// @param colorBleed "Color Bleed" range(0.0, 0.5) default(0.1)
// @param flickerAmount "Flicker Amount" range(0.0, 0.3) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle backlight "Backlight" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 col = float3(0.0);
float3 colorA = float3(color1Red, color1Green, color1Blue);
float3 colorB = float3(color2Red, color2Green, color2Blue);

float content = sin(p.x * 20.0 + timeVal) * sin(p.y * 15.0 + timeVal * 0.7);
content = content * 0.5 + 0.5;
col = rainbow > 0.5 
    ? 0.5 + 0.5 * cos(content * 3.14 + float3(0.0, 2.0, 4.0))
    : mix(colorA, colorB, content);

float2 pixelPos = floor(p * 200.0);
float deadPixel = fract(sin(dot(pixelPos, float2(12.9898, 78.233))) * 43758.5453);
if (deadPixel < deadPixelDensity) {
    col = float3(0.0);
}

for (int i = 0; i < 5; i++) {
    if (float(i) >= float(lineDefects)) break;
    float fi = float(i);
    float lineY = fract(sin(fi * 127.1) * 43758.5453);
    float lineType = fract(sin(fi * 311.7) * 43758.5453);
    if (abs(p.y - lineY) < 0.003) {
        if (lineType < 0.5) {
            col = float3(0.0);
        } else {
            col = float3(1.0);
        }
    }
}

if (pressurePoint > 0.0) {
    float2 pressCenter = float2(0.3, 0.6);
    float pressDist = length(p - pressCenter);
    float pressure = smoothstep(pressurePoint * 0.3, 0.0, pressDist);
    float3 pressColor = 0.5 + 0.5 * cos(pressDist * 30.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, pressColor, pressure * pressurePoint);
}

if (chromatic > 0.5) {
    col.r = mix(col.r, sin((p.x + colorBleed) * 20.0 + timeVal) * 0.5 + 0.5, colorBleed);
    col.b = mix(col.b, sin((p.x - colorBleed) * 20.0 + timeVal) * 0.5 + 0.5, colorBleed);
}

if (flicker > 0.5) {
    float flickVal = 1.0 - flickerAmount * 0.5 + flickerAmount * 0.5 * sin(timeVal * 120.0);
    col *= flickVal;
}

if (backlight > 0.5) {
    float bl = 0.9 + 0.1 * sin(p.y * 3.0);
    col *= bl;
    col += float3(0.02, 0.02, 0.03);
}

col *= brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Hologram Display
let hologramDisplayCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param scanlineSpacing "Scanline Spacing" range(50.0, 200.0) default(100.0)
// @param flickerIntensity "Flicker Intensity" range(0.0, 0.5) default(0.2)
// @param noiseLevel "Noise Level" range(0.0, 0.3) default(0.1)
// @param rgbSeparation "RGB Separation" range(0.0, 0.02) default(0.005)
// @param distortionWave "Distortion Wave" range(0.0, 0.1) default(0.03)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle tripleImage "Triple Image" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
p.x += sin(p.y * 10.0 + timeVal * 5.0) * distortionWave;
float3 col = float3(0.0);
float3 holoColor = float3(color1Red, color1Green, color1Blue);
float3 ghostColor = float3(color2Red, color2Green, color2Blue);

float shape = smoothstep(0.3, 0.28, length(p - 0.5));
shape += smoothstep(0.32, 0.3, length(p - 0.5)) * 0.3;

if (tripleImage > 0.5) {
    float shape1 = smoothstep(0.3, 0.28, length(p - float2(0.48, 0.5)));
    float shape2 = smoothstep(0.3, 0.28, length(p - float2(0.52, 0.5)));
    col += shape1 * float3(1.0, 0.0, 0.0) * 0.3;
    col += shape2 * ghostColor * 0.3;
}
col += shape * holoColor;

if (scanlines > 0.5) {
    float scanline = sin(p.y * scanlineSpacing) * 0.5 + 0.5;
    col *= (0.8 + 0.2 * scanline);
}

if (flicker > 0.5) {
    float flickVal = 1.0 - flickerIntensity * (fract(sin(timeVal * 50.0) * 43758.5453));
    col *= flickVal;
}

if (noise > 0.5) {
    float noiseVal = fract(sin(dot(p + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * noiseLevel;
}

if (chromatic > 0.5) {
    col.r = mix(col.r, col.g, p.x * rgbSeparation * 10.0);
    col.b = mix(col.b, col.g, (1.0 - p.x) * rgbSeparation * 10.0);
}

if (showEdges > 0.5) {
    float edge = smoothstep(0.0, 0.1, p.x) * smoothstep(1.0, 0.9, p.x);
    edge *= smoothstep(0.0, 0.1, p.y) * smoothstep(1.0, 0.9, p.y);
    col *= edge;
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Databending
let databendingCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param bendIntensity "Bend Intensity" range(0.0, 1.0) default(0.5)
// @param chunkSize "Chunk Size" range(0.01, 0.1) default(0.03)
// @param sortAmount "Sort Amount" range(0.0, 1.0) default(0.3)
// @param repeatGlitch "Repeat Glitch" range(0.0, 0.5) default(0.1)
// @param colorShiftAmount "Color Shift Amount" range(0.0, 1.0) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle invertRandom "Invert Random" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? floor(iTime * 5.0 * speed) : 0.0;
float2 p = uv;
float3 colorA = float3(color1Red, color1Green, color1Blue);
float3 colorB = float3(color2Red, color2Green, color2Blue);

float chunkY = floor(p.y / chunkSize) * chunkSize;
float chunkRand = fract(sin(chunkY * 43.758 + timeVal) * 43758.5453);
if (chunkRand < bendIntensity) {
    float bendAmount = (chunkRand - 0.5) * 0.5;
    p.x = fract(p.x + bendAmount);
    if (sortAmount > 0.0) {
        p.x = mix(p.x, chunkRand, sortAmount);
    }
}
if (repeatGlitch > 0.0 && fract(sin(chunkY * 78.233 + timeVal) * 43758.5453) < repeatGlitch) {
    p.x = fract(p.x * 3.0);
}

float3 col;
float pattern = sin(p.x * 30.0 + iTime * speed) * sin(p.y * 20.0);
pattern = pattern * 0.5 + 0.5;
col = rainbow > 0.5 
    ? 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0))
    : mix(colorA, colorB, pattern);

if (colorShiftAmount > 0.0 && chunkRand < bendIntensity) {
    float shift = colorShiftAmount * chunkRand;
    col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(shift, 2.0 + shift, 4.0 - shift));
}
if (invertRandom > 0.5 && fract(sin(chunkY * 127.1 + timeVal) * 43758.5453) < bendIntensity * 0.3) {
    col = float3(1.0) - col;
}

col *= brightness;
if (flicker > 0.5) col *= 0.8 + 0.2 * sin(iTime * 15.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// TV Static
let tvStaticCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param staticIntensity "Static Intensity" range(0.0, 1.0) default(0.7)
// @param scanlineBlend "Scanline Blend" range(0.0, 1.0) default(0.3)
// @param colorStatic "Color Static" range(0.0, 1.0) default(0.0)
// @param signalStrength "Signal Strength" range(0.0, 1.0) default(0.2)
// @param rollSpeed "Roll Speed" range(0.0, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle ghostImage "Ghost Image" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float roll = fract(p.y + timeVal * rollSpeed);
p.y = roll;
float3 signalColor = float3(color2Red, color2Green, color2Blue);

float3 col = float3(0.0);
float noiseVal = fract(sin(dot(floor(p * 500.0) + timeVal * 100.0, float2(12.9898, 78.233))) * 43758.5453);

if (colorStatic > 0.0) {
    col.r = fract(sin(dot(floor(p * 500.0) + timeVal * 100.0, float2(127.1, 311.7))) * 43758.5453);
    col.g = fract(sin(dot(floor(p * 500.0) + timeVal * 100.0, float2(269.5, 183.3))) * 43758.5453);
    col.b = noiseVal;
    col = mix(float3(noiseVal), col, colorStatic);
} else {
    col = float3(noiseVal);
}
col *= staticIntensity;

if (signalStrength > 0.0) {
    float signal = sin(p.x * 50.0 + timeVal * 2.0) * sin(p.y * 40.0);
    signal = signal * 0.5 + 0.5;
    float3 sigColor = rainbow > 0.5 
        ? 0.5 + 0.5 * cos(signal * 3.14 + float3(0.0, 2.0, 4.0))
        : signalColor * signal;
    float signalMask = step(0.5, sin(timeVal * 3.0 + p.y * 10.0));
    col = mix(col, sigColor, signalStrength * signalMask);
}

if (ghostImage > 0.5) {
    float2 ghostP = p + float2(0.05, 0.0);
    float ghost = sin(ghostP.x * 50.0 + timeVal * 2.0) * sin(ghostP.y * 40.0) * 0.5 + 0.5;
    col += float3(ghost) * 0.2 * signalStrength;
}

if (scanlines > 0.5) {
    float scanline = sin(p.y * 300.0) * 0.5 + 0.5;
    col *= (1.0 - scanlineBlend * (1.0 - scanline));
}

col *= brightness;
if (flicker > 0.5) col *= 0.8 + 0.2 * sin(iTime * 20.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// ASCII Art Shader
let asciiArtShaderCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param charSize "Char Size" range(8.0, 32.0) default(16.0)
// @param charSet "Char Set" range(0.0, 2.0) default(0.0)
// @param colorMode "Color Mode" range(0.0, 2.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle inverted "Inverted" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 matrixColor = float3(color1Red, color1Green, color1Blue);
float3 accentColor = float3(color2Red, color2Green, color2Blue);

float2 charCell = floor(p * charSize);
float2 cellCenter = (charCell + 0.5) / charSize;
float value = sin(cellCenter.x * 20.0 + timeVal) * sin(cellCenter.y * 15.0 + timeVal * 0.7);
value = value * 0.5 + 0.5;
value = pow(value, 1.0 / contrast) * brightness;
if (inverted > 0.5) {
    value = 1.0 - value;
}

float2 inCell = fract(p * charSize);
float charPattern = 0.0;
int charIndex = int(value * 10.0);
if (charSet < 1.0) {
    if (charIndex > 8) charPattern = step(0.2, inCell.x) * step(inCell.x, 0.8) * step(0.2, inCell.y) * step(inCell.y, 0.8);
    else if (charIndex > 6) charPattern = step(0.3, inCell.x) * step(inCell.x, 0.7);
    else if (charIndex > 4) charPattern = step(0.4, inCell.y) * step(inCell.y, 0.6);
    else if (charIndex > 2) charPattern = step(0.5, abs(inCell.x - 0.5) + abs(inCell.y - 0.5));
    else charPattern = 0.0;
} else {
    float hash = fract(sin(dot(charCell, float2(12.9898, 78.233)) + float(charIndex)) * 43758.5453);
    charPattern = step(1.0 - value, hash);
}

float3 col;
if (colorMode < 1.0) {
    col = float3(charPattern);
} else if (colorMode < 2.0) {
    col = charPattern * matrixColor;
} else {
    col = charPattern * (rainbow > 0.5 
        ? 0.5 + 0.5 * cos(cellCenter.x * 10.0 + timeVal + float3(0.0, 2.0, 4.0))
        : mix(matrixColor, accentColor, cellCenter.y));
}

if (scanlines > 0.5) col *= 0.8 + 0.2 * sin(p.y * 300.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Bitcrusher Visual
let bitcrusherCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param bitDepth "Bit Depth" range(1.0, 8.0) default(3.0)
// @param sampleRate "Sample Rate" range(10.0, 100.0) default(30.0)
// @param noiseFloor "Noise Floor" range(0.0, 0.3) default(0.05)
// @param waveformMix "Waveform Mix" range(0.0, 1.0) default(0.5)
// @param colorDepth "Color Depth" range(2.0, 16.0) default(4.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle dithering "Dithering" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(true)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 colorA = float3(color1Red, color1Green, color1Blue);
float3 colorB = float3(color2Red, color2Green, color2Blue);

float2 crushedP = floor(p * sampleRate) / sampleRate;
float wave1 = sin(crushedP.x * 30.0 + timeVal * 2.0);
float wave2 = sin(crushedP.y * 20.0 + timeVal * 1.5);
float wave = mix(wave1, wave2, waveformMix);
float levels = pow(2.0, bitDepth);
wave = floor(wave * levels) / levels;

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(wave * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    col = mix(colorA, colorB, wave * 0.5 + 0.5);
}
col = floor(col * colorDepth) / colorDepth;

if (dithering > 0.5) {
    float2 ditherPos = fract(p * sampleRate);
    float dither = fmod(floor(ditherPos.x * 2.0) + floor(ditherPos.y * 2.0), 2.0);
    col += (dither - 0.5) / colorDepth;
}

if (noise > 0.5) {
    float noiseVal = fract(sin(dot(crushedP + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * noiseFloor;
}

col = clamp(col, 0.0, 1.0);
col *= brightness;

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Oscilloscope Display
let oscilloscopeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param waveAmplitude "Wave Amplitude" range(0.1, 0.5) default(0.3)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param lineThickness "Line Thickness" range(0.005, 0.03) default(0.01)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param waveType "Wave Type" range(0.0, 3.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle lissajous "Lissajous Mode" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv * 2.0 - 1.0;
float3 waveColor = float3(color1Red, color1Green, color1Blue);
float3 bgColor = float3(color2Red, color2Green, color2Blue);
float3 col = bgColor * 0.5;

float gridX = smoothstep(0.02, 0.0, abs(fract(p.x * 5.0) - 0.5));
float gridY = smoothstep(0.02, 0.0, abs(fract(p.y * 5.0) - 0.5));
col += (gridX + gridY) * 0.05;

float wave;
if (lissajous > 0.5) {
    float lx = sin(timeVal * waveFrequency) * waveAmplitude * 2.0;
    float ly = sin(timeVal * waveFrequency * 1.5 + 1.57) * waveAmplitude * 2.0;
    float d = length(p - float2(lx, ly));
    wave = smoothstep(lineThickness * 2.0, 0.0, d);
    for (int i = 1; i < 20; i++) {
        float fi = float(i);
        float t = timeVal - fi * 0.02;
        float tx = sin(t * waveFrequency) * waveAmplitude * 2.0;
        float ty = sin(t * waveFrequency * 1.5 + 1.57) * waveAmplitude * 2.0;
        float td = length(p - float2(tx, ty));
        wave += smoothstep(lineThickness, 0.0, td) * (1.0 - fi / 20.0) * 0.3;
    }
} else {
    float waveY;
    if (waveType < 1.0) {
        waveY = sin(p.x * waveFrequency * 6.28 + timeVal * 5.0) * waveAmplitude;
    } else if (waveType < 2.0) {
        waveY = (fract(p.x * waveFrequency + timeVal) * 2.0 - 1.0) * waveAmplitude;
    } else if (waveType < 3.0) {
        waveY = sign(sin(p.x * waveFrequency * 6.28 + timeVal * 5.0)) * waveAmplitude;
    } else {
        waveY = abs(fract(p.x * waveFrequency + timeVal) * 2.0 - 1.0) * 2.0 * waveAmplitude - waveAmplitude;
    }
    wave = smoothstep(lineThickness, 0.0, abs(p.y - waveY));
    if (glow > 0.5) {
        float glowVal = smoothstep(lineThickness * 10.0, 0.0, abs(p.y - waveY)) * glowAmount;
        wave += glowVal * 0.5;
    }
}

float3 lineColor = rainbow > 0.5 
    ? 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.0, 4.0))
    : waveColor;
col += wave * lineColor;

col *= brightness;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Gameboy Style
let gameboyStyleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param pixelGridSize "Pixel Grid Size" range(4.0, 20.0) default(8.0)
// @param scanlineAmount "Scanline Amount" range(0.0, 0.5) default(0.2)
// @param patternSpeed "Pattern Speed" range(0.0, 2.0) default(0.5)
// @param ditherAmount "Dither Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.06)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.22)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.06)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.61)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.73)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.06)
// @toggle animated "Animated" default(true)
// @toggle originalGreen "Original Green" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(true)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;
float3 darkest = float3(color1Red, color1Green, color1Blue);
float3 lightest = float3(color2Red, color2Green, color2Blue);

// Pixelate
float2 pixelUV = pixelate > 0.5 
    ? floor(p * pixelGridSize * 10.0) / (pixelGridSize * 10.0)
    : p;

// Create pattern
float pattern = sin(pixelUV.x * 20.0 + timeVal * patternSpeed) * 
                sin(pixelUV.y * 15.0 + timeVal * patternSpeed * 0.7);
pattern += sin(length(pixelUV - 0.5) * 30.0 - timeVal * 2.0) * 0.5;
pattern = pattern * 0.5 + 0.5;
pattern = pow(pattern, 1.0 / contrast);

// Dithering
float2 ditherCoord = floor(p * pixelGridSize * 10.0);
float dither = fract(sin(dot(ditherCoord, float2(12.9898, 78.233))) * 43758.5453);
pattern += (dither - 0.5) * ditherAmount * 0.2;

// Quantize to 4 shades
float shade = floor(pattern * 4.0) / 3.0;
shade = clamp(shade, 0.0, 1.0);

// Color palette
float3 col;
if (originalGreen > 0.5) {
    // Original DMG green palette
    float3 dark = mix(darkest, lightest, 0.33);
    float3 light = mix(darkest, lightest, 0.66);
    if (shade < 0.33) {
        col = mix(darkest, dark, shade * 3.0);
    } else if (shade < 0.66) {
        col = mix(dark, light, (shade - 0.33) * 3.0);
    } else {
        col = mix(light, lightest, (shade - 0.66) * 3.0);
    }
} else {
    // Rainbow or grayscale
    col = rainbow > 0.5 
        ? 0.5 + 0.5 * cos(shade * 6.28 + timeVal + float3(0.0, 2.0, 4.0))
        : float3(shade);
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = sin(p.y * pixelGridSize * 10.0 * 3.14159) * 0.5 + 0.5;
    col *= 1.0 - scanline * scanlineAmount;
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) {
    float vig = smoothstep(0.5, 0.3, max(abs(p.x - 0.5), abs(p.y - 0.5)));
    col *= 0.8 + vig * 0.2;
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

