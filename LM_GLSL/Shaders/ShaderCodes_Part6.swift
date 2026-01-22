//
//  ShaderCodes_Part6.swift
//  LM_GLSL
//
//  Shader codes - Part 6: Parametric Geometric & Abstract Shaders (20 shaders)
//  Each shader has 36 parameters + 24 toggles with Master Opacity
//

import Foundation

// MARK: - Parametric Geometric Shaders

/// Rotating Polygon with adjustable sides and rotation
let rotatingPolygonCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param sides "Sides" range(3.0, 12.0) default(6.0)
// @param rotationSpeed "Rotation Speed" range(0.1, 5.0) default(1.0)
// @param size "Size" range(0.1, 0.8) default(0.4)
// @param glowAmount "Glow Amount" range(0.0, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param edgeSharpness "Edge Sharpness" range(0.001, 0.1) default(0.01)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle showGlow "Show Glow" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
p = rp;

if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + iTime), cos(p.x * 5.0 + iTime)) * distortion * 0.1;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float angle = atan2(p.y, p.x) + timeVal * rotationSpeed;
float r = length(p);
float n = max(3.0, floor(sides));
float a = 6.28318 / n;
float d = cos(floor(0.5 + angle / a) * a - angle) * r;
float polygon = smoothstep(size + edgeSharpness, size - edgeSharpness, d);
float glowEffect = exp(-abs(d - size) * 5.0) * glowAmount;

float3 col = float3(0.0);
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(angle + iTime + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    col = float3(color1Red, color1Green, color1Blue);
}

col = polygon * col + glowEffect * col;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Concentric Rings with customizable spacing
let concentricRingsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(2.0, 20.0) default(8.0)
// @param ringWidth "Ring Width" range(0.01, 0.1) default(0.03)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(1.0)
// @param colorShift "Color Shift" range(0.0, 6.28) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param expandAmount "Expand Amount" range(0.0, 0.2) default(0.05)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle expandContract "Expand Contract" default(true)
// @toggle rainbow "Rainbow" default(true)
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
// @toggle colorShiftToggle "Color Shift Toggle" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float r = length(p);
float3 col = float3(0.02);

int maxRings = int(min(ringCount, 20.0));
for (int i = 0; i < 20; i++) {
    if (i >= maxRings) break;
    float fi = float(i);
    float baseRadius = (fi + 1.0) / ringCount * 0.9;
    float radius = baseRadius;
    if (expandContract > 0.5) {
        radius += sin(timeVal * pulseSpeed + fi * 0.5) * expandAmount;
    }
    float ring = smoothstep(ringWidth, 0.0, abs(r - radius));
    float3 ringCol = 0.5 + 0.5 * cos(fi * 0.5 + colorShift + timeVal * 0.5 + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
    col += ring * ringCol;
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Spiral Galaxy with adjustable arms
let spiralGalaxyCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param arms "Arms" range(1.0, 8.0) default(3.0)
// @param twist "Twist" range(1.0, 10.0) default(5.0)
// @param rotationSpeed "Rotation Speed" range(0.1, 3.0) default(0.5)
// @param galaxyBrightness "Galaxy Brightness" range(0.5, 2.0) default(1.0)
// @param coreSize "Core Size" range(0.05, 0.3) default(0.1)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle addStars "Add Stars" default(true)
// @toggle showCore "Show Core" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float r = length(p);
float a = atan2(p.y, p.x);

float spiral = sin(a * arms + r * twist - timeVal * rotationSpeed);
spiral = pow(spiral * 0.5 + 0.5, 2.0);
float falloff = exp(-r * 2.0);

float3 spiralCol = float3(color1Red, color1Green, color1Blue);
float3 col = spiral * falloff * spiralCol * galaxyBrightness;

if (showCore > 0.5) {
    float core = exp(-r / coreSize);
    float3 coreCol = float3(color2Red, color2Green, color2Blue);
    col += core * coreCol;
}

if (addStars > 0.5) {
    float2 starP = uv * 50.0;
    float star = step(0.98 - starDensity * 0.1, fract(sin(dot(floor(starP), float2(12.9898, 78.233))) * 43758.5453));
    col += star * (1.0 - r) * 0.5;
}

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

/// Hexagonal Mosaic
let hexMosaicCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param scale "Scale" range(2.0, 20.0) default(8.0)
// @param colorSpeed "Color Speed" range(0.0, 3.0) default(0.5)
// @param edgeWidth "Edge Width" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param hexSize "Hex Size" range(0.3, 0.5) default(0.4)
// @param colorVariety "Color Variety" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle showEdges "Show Edges" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle outline "Outline" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv * scale;

float2 r = float2(1.0, 1.732);
float2 h = r * 0.5;
float2 a = fmod(p, r) - h;
float2 b = fmod(p - h, r) - h;
float2 g = length(a) < length(b) ? a : b;
float2 id = p - g;

float d = max(abs(g.x), abs(g.y) * 0.577 + abs(g.x) * 0.5);
float edge = smoothstep(hexSize, hexSize - edgeWidth, d);

float3 col = 0.5 + 0.5 * cos(dot(id, float2(0.1, 0.1)) * colorVariety + timeVal * colorSpeed + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
col *= edge * brightness;

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

/// Radial Symmetry Pattern
let radialSymmetryCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param segments "Segments" range(2.0, 16.0) default(8.0)
// @param layers "Layers" range(1.0, 5.0) default(3.0)
// @param complexity "Complexity" range(1.0, 10.0) default(4.0)
// @param colorVariety "Color Variety" range(0.5, 3.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param patternScale "Pattern Scale" range(1.0, 20.0) default(10.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle mirrorY "Mirror Y" default(false)
// @toggle rainbow "Rainbow" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float a = atan2(p.y, p.x);
float r = length(p);

float segAngle = 6.28318 / max(2.0, segments);
a = abs(fmod(a + segAngle * 0.5, segAngle) - segAngle * 0.5);
if (mirrorY > 0.5) {
    a = abs(a);
}

float3 col = float3(0.02);
int maxLayers = int(min(layers, 5.0));
for (int i = 0; i < 5; i++) {
    if (i >= maxLayers) break;
    float fi = float(i);
    float layerR = (fi + 1.0) * 0.2;
    float pattern = sin(a * complexity + r * patternScale - timeVal + fi);
    pattern = smoothstep(0.0, 0.1, pattern);
    float mask = smoothstep(layerR + 0.15, layerR, r) * smoothstep(layerR - 0.1, layerR, r);
    float3 layerCol = 0.5 + 0.5 * cos(fi * colorVariety + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
    col += pattern * mask * layerCol;
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Geometric Flower
let geometricFlowerCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param petals "Petals" range(3.0, 12.0) default(6.0)
// @param petalLength "Petal Length" range(0.2, 0.8) default(0.5)
// @param petalWidth "Petal Width" range(0.1, 0.5) default(0.25)
// @param rotationSpeed "Rotation Speed" range(0.0, 3.0) default(0.5)
// @param pulseAmount "Pulse Amount" range(0.0, 0.2) default(0.05)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle centerGlow "Center Glow" default(true)
// @toggle rainbow "Rainbow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float angle = atan2(p.y, p.x) + timeVal * rotationSpeed;
float r = length(p);

float petalAngle = 6.28318 / max(3.0, petals);
float a = fmod(angle + petalAngle * 0.5, petalAngle) - petalAngle * 0.5;

float pulseVal = pulse > 0.5 ? sin(iTime * 3.0) * pulseAmount : 0.0;
float petalShape = cos(a / petalWidth) * (petalLength + pulseVal);
float petal = smoothstep(0.01, 0.0, r - petalShape);
petal *= smoothstep(petalWidth, 0.0, abs(a));

float3 col = petal * (0.5 + 0.5 * cos(angle + hueShift * 6.28 + float3(0.0, 2.0, 4.0)));

if (centerGlow > 0.5) {
    float centerEffect = exp(-r * 8.0);
    float3 centerCol = float3(color2Red, color2Green, color2Blue);
    col += centerEffect * centerCol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Wave Interference Pattern
let waveInterferenceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.5, 5.0) default(2.0)
// @param sources "Sources" range(2.0, 8.0) default(4.0)
// @param waveLength "Wave Length" range(5.0, 30.0) default(15.0)
// @param waveContrast "Wave Contrast" range(0.5, 2.0) default(1.0)
// @param colorMode "Color Mode" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param sourceRadius "Source Radius" range(0.2, 0.8) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle animateSources "Animate Sources" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float wave = 0.0;

int maxSources = int(min(sources, 8.0));
for (int i = 0; i < 8; i++) {
    if (i >= maxSources) break;
    float fi = float(i);
    float angle = fi * 6.28318 / sources;
    float2 source = float2(cos(angle), sin(angle)) * sourceRadius;
    if (animateSources > 0.5) {
        source *= 0.5 + 0.3 * sin(iTime + fi);
    }
    float d = length(p - source);
    wave += sin(d * waveLength - timeVal);
}

wave = wave / sources;
wave = pow(wave * 0.5 + 0.5, waveContrast);

float3 col;
if (colorMode < 1.0) {
    col = float3(wave);
} else if (colorMode < 2.0) {
    col = 0.5 + 0.5 * cos(wave * 6.28 + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    float3 col1 = float3(color1Red, color1Green, color1Blue);
    float3 col2 = float3(color2Red, color2Green, color2Blue);
    col = mix(col1, col2, wave);
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Diamond Lattice
let diamondLatticeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(2.0, 15.0) default(6.0)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.03)
// @param waveAmount "Wave Amount" range(0.0, 0.5) default(0.1)
// @param latticeBrightness "Lattice Brightness" range(0.5, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param lineSharpness "Line Sharpness" range(0.0, 1.0) default(0.5)
// @param waveSpeed "Wave Speed" range(0.0, 3.0) default(1.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle dualColor "Dual Color" default(true)
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

float2 p = uv * scale;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float wave = sin(timeVal * waveSpeed) * waveAmount;

float d1 = abs(sin(p.x + p.y + wave));
float d2 = abs(sin(p.x - p.y + wave));
float line1 = smoothstep(lineWidth, 0.0, d1);
float line2 = smoothstep(lineWidth, 0.0, d2);

float3 col = float3(0.02);
if (dualColor > 0.5) {
    float3 col1 = float3(color1Red, color1Green, color1Blue);
    float3 col2 = float3(color2Red, color2Green, color2Blue);
    col += line1 * col1 * latticeBrightness;
    col += line2 * col2 * latticeBrightness;
} else {
    col += (line1 + line2) * float3(0.5, 0.8, 1.0) * latticeBrightness;
}

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

/// Tessellation Grid
let tessellationGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param tileSize "Tile Size" range(2.0, 10.0) default(5.0)
// @param tileRotation "Tile Rotation" range(0.0, 1.57) default(0.0)
// @param bevelSize "Bevel Size" range(0.0, 0.2) default(0.05)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param pattern "Pattern" range(0.0, 3.0) default(0.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle alternate "Alternate" default(true)
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
float2 p = uv * tileSize;

float c = cos(tileRotation);
float s = sin(tileRotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float2 id = floor(p);
float2 f = fract(p) - 0.5;
float d = max(abs(f.x), abs(f.y));
float tile = smoothstep(0.5, 0.5 - bevelSize, d);

float checker = 0.0;
if (alternate > 0.5) {
    checker = fmod(id.x + id.y, 2.0);
}

float3 col = 0.5 + 0.5 * cos(id.x * 0.5 + id.y * 0.3 + timeVal * colorSpeed + checker * 3.14 + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
col *= tile * brightness;

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

/// Voronoi Cells Advanced
let voronoiAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param cellCount "Cell Count" range(2.0, 10.0) default(5.0)
// @param borderWidth "Border Width" range(0.0, 0.1) default(0.02)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param colorIntensity "Color Intensity" range(0.5, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param cellVariation "Cell Variation" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle showCenters "Show Centers" default(false)
// @toggle rainbow "Rainbow" default(true)
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
float2 p = uv * cellCount;
p += sin(p.yx * 3.0 + timeVal) * distortAmount;

float2 n = floor(p);
float2 f = fract(p);
float md = 8.0;
float2 mg = float2(0.0);

for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
        float2 g = float2(float(i), float(j));
        float2 o = float2(fract(sin(dot(n + g, float2(127.1, 311.7))) * 43758.5453),
                         fract(sin(dot(n + g, float2(269.5, 183.3))) * 43758.5453));
        o = 0.5 + 0.5 * sin(timeVal + 6.2831 * o);
        float2 r = g + o - f;
        float d = dot(r, r);
        if (d < md) {
            md = d;
            mg = g;
        }
    }
}

float3 col = 0.5 + 0.5 * cos(dot(mg, float2(1.0, 0.5)) * colorIntensity + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
float border = smoothstep(borderWidth, borderWidth + 0.01, sqrt(md));
col *= border * brightness;

if (showCenters > 0.5) {
    col += (1.0 - smoothstep(0.0, 0.05, sqrt(md))) * float3(1.0);
}

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

// MARK: - Abstract Parametric Shaders

/// Morphing Blobs
let morphingBlobsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param blobCount "Blob Count" range(2.0, 8.0) default(4.0)
// @param blobSize "Blob Size" range(0.1, 0.4) default(0.2)
// @param morphSpeed "Morph Speed" range(0.1, 3.0) default(1.0)
// @param smoothness "Smoothness" range(0.01, 0.1) default(0.03)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle metallic "Metallic" default(false)
// @toggle rainbow "Rainbow" default(true)
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

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p = p * 2.0 - 1.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float d = 0.0;

int maxBlobs = int(min(blobCount, 8.0));
for (int i = 0; i < 8; i++) {
    if (i >= maxBlobs) break;
    float fi = float(i);
    float angle = fi * 6.28318 / blobCount + timeVal * 0.3;
    float2 blobPos = float2(cos(angle + sin(timeVal * morphSpeed + fi)), 
                            sin(angle + cos(timeVal * morphSpeed + fi * 1.3))) * 0.4;
    d += blobSize / length(p - blobPos);
}

float blob = smoothstep(1.0 - smoothness, 1.0 + smoothness, d);
float3 col = 0.5 + 0.5 * cos(d * 2.0 + timeVal * colorSpeed + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
col *= blob * brightness;

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

/// Liquid Surface
let liquidSurfaceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param waveScale "Wave Scale" range(2.0, 15.0) default(8.0)
// @param waveHeight "Wave Height" range(0.1, 1.0) default(0.5)
// @param reflectivity "Reflectivity" range(0.0, 1.0) default(0.5)
// @param depth "Depth" range(0.1, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param rippleStrength "Ripple Strength" range(0.0, 0.3) default(0.1)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle ripples "Ripples" default(true)
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
float2 p = uv * waveScale;

float wave1 = sin(p.x + timeVal) * sin(p.y * 1.3 + timeVal * 0.8);
float wave2 = sin(p.x * 1.5 - timeVal * 0.6) * sin(p.y + timeVal * 1.2);
float wave = (wave1 + wave2) * waveHeight * 0.5;

if (ripples > 0.5) {
    wave += sin(length(p - waveScale * 0.5) * 3.0 - timeVal * 3.0) * rippleStrength;
}

float3 baseColor = float3(color1Red, color1Green, color1Blue);
float3 highlightColor = float3(color2Red, color2Green, color2Blue);
float3 col = mix(baseColor, highlightColor, wave * 0.5 + 0.5);

float fresnel = pow(1.0 - abs(wave), 3.0) * reflectivity;
col += fresnel * float3(1.0, 1.0, 1.0);
col *= depth + (1.0 - depth) * (1.0 - uv.y);
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

/// Smoke Effect
let smokeEffectCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param density "Density" range(0.5, 3.0) default(1.5)
// @param turbulence "Turbulence" range(1.0, 5.0) default(2.5)
// @param riseSpeed "Rise Speed" range(0.1, 2.0) default(0.5)
// @param spreadAmount "Spread Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorTemp "Color Temperature" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.25)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.25)
// @toggle animated "Animated" default(true)
// @toggle glow "Glow" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
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
p.y -= timeVal * riseSpeed;
p.x += sin(p.y * 3.0 + timeVal) * spreadAmount;

float smoke = 0.0;
float amp = 1.0;
float2 freq = float2(3.0, 3.0);
for (int i = 0; i < 5; i++) {
    float n = sin(p.x * freq.x + timeVal) * sin(p.y * freq.y);
    smoke += n * amp;
    freq *= turbulence;
    amp *= 0.5;
}
smoke = smoke * 0.5 + 0.5;
smoke *= pow(1.0 - abs(uv.x - 0.5) * 2.0, 0.5);
smoke *= pow(uv.y, 0.3);
smoke *= density;

float3 warmColor = float3(color1Red, color1Green, color1Blue);
float3 coolColor = float3(color2Red, color2Green, color2Blue);
float3 col = mix(coolColor, warmColor, colorTemp);
col *= smoke * brightness;

if (glow > 0.5) col += exp(-uv.y * 3.0) * float3(1.0, 0.5, 0.2) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

/// Ink Drop
let inkDropCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param dropSize "Drop Size" range(0.1, 0.5) default(0.3)
// @param spreadSpeed "Spread Speed" range(0.1, 2.0) default(0.5)
// @param tentacles "Tentacles" range(0.0, 10.0) default(5.0)
// @param turbulence "Turbulence" range(0.0, 0.5) default(0.15)
// @param inkDensity "Ink Density" range(0.5, 2.0) default(1.0)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.05)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.02)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.1)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.1)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.05)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.15)
// @toggle animated "Animated" default(true)
// @toggle multiColor "Multi Color" default(false)
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
float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;

float time = timeVal * spreadSpeed;
float r = length(p);
float a = atan2(p.y, p.x);

float tentacle = sin(a * tentacles + time * 2.0) * turbulence;
float drop = smoothstep(dropSize + tentacle + fract(time) * 0.5, dropSize + tentacle, r);
drop *= smoothstep(1.0, dropSize, r);

float3 col;
if (multiColor > 0.5) {
    col = 0.5 + 0.5 * cos(a + time + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    col = float3(color1Red, color1Green, color1Blue);
}
col *= drop * inkDensity * brightness;

float edge = smoothstep(0.01, 0.0, abs(r - dropSize - tentacle - fract(time) * 0.5));
col += edge * float3(color2Red, color2Green, color2Blue);

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

/// Fabric Weave
let fabricWeaveCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param weaveScale "Weave Scale" range(5.0, 30.0) default(15.0)
// @param threadWidth "Thread Width" range(0.3, 0.8) default(0.5)
// @param depth "Depth" range(0.0, 0.5) default(0.2)
// @param warpHue "Warp Hue" range(0.0, 1.0) default(0.0)
// @param weftHue "Weft Hue" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(false)
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
float2 center = float2(centerX, centerY);
float2 p = ((uv - center) * zoom + center) * weaveScale;
p += timeVal * 0.5;

float2 id = floor(p);
float2 f = fract(p);

float warp = smoothstep(threadWidth, threadWidth + 0.1, abs(f.y - 0.5));
float weft = smoothstep(threadWidth, threadWidth + 0.1, abs(f.x - 0.5));
float over = fmod(id.x + id.y, 2.0);

float3 warpCol = 0.5 + 0.5 * cos(warpHue * 6.28 + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
float3 weftCol = 0.5 + 0.5 * cos(weftHue * 6.28 + hueShift * 6.28 + float3(0.0, 2.0, 4.0));

float3 col;
if (over > 0.5) {
    col = mix(warpCol * (1.0 - depth), weftCol, weft);
} else {
    col = mix(weftCol * (1.0 - depth), warpCol, warp);
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

/// Marble Texture
let marbleTextureCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param scale "Scale" range(1.0, 10.0) default(3.0)
// @param veins "Vein Count" range(1.0, 8.0) default(4.0)
// @param veinSharpness "Vein Sharpness" range(1.0, 10.0) default(3.0)
// @param turbulence "Turbulence" range(0.0, 2.0) default(0.5)
// @param baseValue "Base Value" range(0.0, 1.0) default(0.9)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.88)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.85)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.15)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(false)
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

float timeVal = animated > 0.5 ? iTime * speed * 0.2 : 0.0;
float2 center = float2(centerX, centerY);
float2 p = ((uv - center) * zoom + center) * scale;

float turbNoise = sin(p.x * 2.0 + timeVal) * sin(p.y * 2.0 + timeVal) * turbulence;
float vein = sin((p.x + p.y) * veins + turbNoise * 5.0 + 
                 sin(p.x * 3.0 + timeVal) * turbulence * 2.0);
vein = pow(abs(vein), 1.0 / veinSharpness);

float3 marbleBase = float3(color1Red, color1Green, color1Blue);
float3 veinColor = float3(color2Red, color2Green, color2Blue);
float3 col = mix(veinColor, marbleBase, vein) * brightness;

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

/// Oil Slick
let oilSlickCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param thickness "Film Thickness" range(1.0, 5.0) default(2.0)
// @param flowSpeed "Flow Speed" range(0.0, 2.0) default(0.5)
// @param iridescence "Iridescence" range(0.5, 3.0) default(1.5)
// @param swirl "Swirl" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param darkAmount "Dark Amount" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.05)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.03)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.08)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle darkBase "Dark Base" default(true)
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
float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;
p += sin(p.yx * 5.0 + timeVal * flowSpeed) * swirl * 0.1;

float n = sin(p.x * 10.0 * thickness + timeVal * flowSpeed) + 
          sin(p.y * 8.0 * thickness + timeVal * flowSpeed * 0.8);
n = n * 0.5 + 0.5;

float3 col = 0.5 + 0.5 * cos(n * 6.28 * iridescence + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
col = pow(max(col, float3(0.0)), float3(contrast)) * brightness;

if (darkBase > 0.5) {
    float3 dark = float3(color1Red, color1Green, color1Blue);
    col = mix(dark, col, (1.0 - darkAmount) + darkAmount * sin(n * 3.14));
}

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

/// Crystal Formation
let crystalFormationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param crystalCount "Crystal Count" range(2.0, 8.0) default(5.0)
// @param crystalSize "Crystal Size" range(0.1, 0.4) default(0.2)
// @param facets "Facets" range(4.0, 12.0) default(6.0)
// @param refraction "Refraction" range(0.0, 0.3) default(0.1)
// @param clarity "Clarity" range(0.3, 1.0) default(0.7)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.5)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.02)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.03)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.05)
// @toggle animated "Animated" default(true)
// @toggle glow "Inner Glow" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
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
float2 center = float2(centerX, centerY);
float2 p = ((uv - center) * zoom + center) * 2.0 - 1.0;
float3 col = float3(color2Red, color2Green, color2Blue);

int maxCrystals = int(min(crystalCount, 8.0));
for (int i = 0; i < 8; i++) {
    if (i >= maxCrystals) break;
    float fi = float(i);
    float2 ctr = float2(sin(fi * 1.7), cos(fi * 2.3)) * 0.4;
    float2 cp = p - ctr;
    cp += sin(cp.yx * 10.0) * refraction;
    float r = length(cp);
    float a = atan2(cp.y, cp.x) + timeVal * 0.2;
    float crystal = cos(a * facets) * crystalSize;
    float d = smoothstep(crystal + 0.02, crystal, r);
    float3 crystalCol = 0.5 + 0.5 * cos(fi + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
    crystalCol *= clarity;
    if (glow > 0.5) {
        crystalCol += exp(-r / crystalSize * 3.0) * float3(color1Red, color1Green, color1Blue) * glowIntensity;
    }
    col += d * crystalCol;
}
col *= brightness;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

/// Caustics
let causticsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(0.5)
// @param scale "Scale" range(2.0, 10.0) default(5.0)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
// @param complexity "Complexity" range(1.0, 5.0) default(3.0)
// @param waterHue "Water Hue" range(0.0, 1.0) default(0.6)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param sunStrength "Sun Strength" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.95)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle sunlight "Sunlight" default(true)
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
float2 center = float2(centerX, centerY);
float2 p = ((uv - center) * zoom + center) * scale;

float caustic = 0.0;
float amp = 1.0;
int maxComplexity = int(min(complexity, 5.0));
for (int i = 0; i < 5; i++) {
    if (i >= maxComplexity) break;
    float fi = float(i);
    float2 offset = float2(sin(timeVal + fi), cos(timeVal * 0.7 + fi)) * 0.5;
    caustic += sin(p.x * (fi + 1.0) + offset.x + timeVal) * 
               sin(p.y * (fi + 1.0) + offset.y + timeVal * 0.8) * amp;
    amp *= 0.5;
}
caustic = caustic * 0.5 + 0.5;
caustic = pow(caustic, 1.5) * intensity;

float3 water = 0.5 + 0.5 * cos(waterHue * 6.28 + hueShift * 6.28 + float3(2.0, 3.0, 4.0));
water *= 0.3;
float3 col = water + caustic * float3(color1Red, color1Green, color1Blue);

if (sunlight > 0.5) {
    float sun = pow(caustic, 3.0);
    col += sun * float3(color2Red, color2Green, color2Blue) * sunStrength;
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

/// Lava Lamp
let lavaLampCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param blobCount "Blob Count" range(2.0, 6.0) default(3.0)
// @param blobSpeed "Blob Speed" range(0.1, 1.0) default(0.3)
// @param blobSize "Blob Size" range(0.1, 0.3) default(0.2)
// @param heat "Heat" range(0.0, 1.0) default(0.5)
// @param glassEffect "Glass Effect" range(0.0, 0.3) default(0.1)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle retro "Retro Colors" default(true)
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
float2 center = float2(centerX, centerY);
float2 p = ((uv - center) * zoom + center) * 2.0 - 1.0;
float3 col = float3(0.0);
float d = 0.0;

int maxBlobs = int(min(blobCount, 6.0));
for (int i = 0; i < 6; i++) {
    if (i >= maxBlobs) break;
    float fi = float(i);
    float phase = fi * 1.5;
    float2 blobPos = float2(
        sin(timeVal * blobSpeed + phase) * 0.3,
        sin(timeVal * blobSpeed * 0.7 + phase + 1.0) * 0.7
    );
    d += blobSize / length(p - blobPos);
}
float blob = smoothstep(0.9, 1.1, d);

float3 blobColor;
if (retro > 0.5) {
    blobColor = mix(float3(color1Red, color1Green, color1Blue), 
                    float3(color2Red, color2Green, color2Blue), heat);
} else {
    blobColor = 0.5 + 0.5 * cos(d + timeVal + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
}
float3 bgColor = float3(0.1, 0.02, 0.05);
col = mix(bgColor, blobColor, blob) * brightness;

float glass = abs(uv.x - 0.5) * 2.0;
glass = pow(glass, 3.0) * glassEffect;
col += float3(1.0) * glass;

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

