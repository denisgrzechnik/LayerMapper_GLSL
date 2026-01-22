//
//  ShaderCodes_Part11.swift
//  LM_GLSL
//
//  Shader codes - Part 11: Hypnotic & Optical Illusions (20 shaders)
//

import Foundation

// MARK: - Hypnotic & Optical Illusions

/// Rotating Illusion
let rotatingIllusionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(3, 15) default(8)
// @param ringSpacing "Ring Spacing" range(0.03, 0.15) default(0.08)
// @param thickness "Thickness" range(0.02, 0.15) default(0.05)
// @param waveAmount "Wave Amount" range(0.0, 0.3) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle alternateDirection "Alternate Direction" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5 - center * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float a = atan2(p.y, p.x);
    a = fmod(a + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(a), sin(a)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float r = length(p);
float a = atan2(p.y, p.x);
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = float3(0.02, 0.02, 0.05);

for (int i = 0; i < 15; i++) {
    if (i >= int(ringCount)) break;
    float fi = float(i);
    float ringR = (0.1 + fi * ringSpacing) * pulseAmt;
    float dir = (alternateDirection > 0.5 && (i % 2) == 1) ? -1.0 : 1.0;
    float wave = sin(a * 6.0 + timeVal * 2.0) * waveAmount;
    float ringAngle = a + timeVal * dir + fi * 0.5;
    float pattern = sin(ringAngle * 8.0) * 0.5 + 0.5;
    float ring = smoothstep(thickness, 0.0, abs(r - ringR - wave));
    if (smooth > 0.5) ring = smoothstep(0.0, 1.0, ring);
    
    float3 ringColor;
    if (rainbow > 0.5) {
        ringColor = 0.5 + 0.5 * cos(fi * 0.8 + timeVal + float3(0.0, 2.094, 4.188));
    } else if (gradient > 0.5) {
        ringColor = mix(col1, col2, fi / float(ringCount));
    } else {
        ringColor = col1;
    }
    
    if (neon > 0.5) ringColor = pow(ringColor, float3(0.5));
    if (pastel > 0.5) ringColor = mix(ringColor, float3(1.0), 0.4);
    
    col += ring * ringColor * pattern;
    
    if (showEdges > 0.5) {
        float edge = smoothstep(0.01, 0.0, abs(ring - 0.5));
        col += edge * float3(1.0) * 0.3;
    }
}

if (radial > 0.5) col *= 1.0 - r * 0.3;

if (glow > 0.5) {
    float glowAmt = exp(-r * 2.0) * glowIntensity;
    col += glowAmt * mix(col1, col2, 0.5);
}

if (outline > 0.5) {
    float edge = abs(fract(r * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Breathing Mandala
let breathingMandalaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param petalCount "Petal Count" range(4, 16) default(8)
// @param layers "Layers" range(2, 8) default(5)
// @param breathAmount "Breath Amount" range(0.0, 0.5) default(0.2)
// @param complexity "Complexity" range(1.0, 5.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle innerGlow "Inner Glow" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5 - center * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float r = length(p);
float a = atan2(p.y, p.x);
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;
float breath = sin(timeVal) * breathAmount + 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = float3(0.02, 0.02, 0.05);

for (int layer = 0; layer < 8; layer++) {
    if (layer >= int(layers)) break;
    float fl = float(layer);
    float layerR = (0.15 + fl * 0.12) * breath * pulseAmt;
    float layerPetals = float(petalCount) + fl * 2.0;
    float petal = cos(a * layerPetals + timeVal * (fl * 0.2 + 0.5)) * 0.5 + 0.5;
    petal = pow(petal, complexity);
    float mask = smoothstep(layerR + 0.05, layerR, r) * smoothstep(layerR - 0.08, layerR - 0.03, r);
    if (smooth > 0.5) mask = smoothstep(0.0, 1.0, mask);
    
    float3 layerColor;
    if (rainbow > 0.5) {
        layerColor = 0.5 + 0.5 * cos(fl * 0.8 + timeVal + float3(0.0, 2.094, 4.188));
    } else if (gradient > 0.5) {
        layerColor = mix(col1, col2, fl / float(layers));
    } else {
        layerColor = col1;
    }
    
    if (neon > 0.5) layerColor = pow(layerColor, float3(0.5));
    if (pastel > 0.5) layerColor = mix(layerColor, float3(1.0), 0.4);
    
    col += mask * petal * layerColor * 0.7;
    
    if (showEdges > 0.5) {
        float edge = smoothstep(0.01, 0.0, abs(mask - 0.5));
        col += edge * float3(1.0) * 0.3;
    }
}

if (innerGlow > 0.5 || glow > 0.5) {
    float glowAmt = exp(-r * 3.0 / breath) * glowIntensity;
    col += glowAmt * mix(col1, col2, 0.5);
}

if (radial > 0.5) col *= 1.0 - r * 0.3;

if (outline > 0.5) {
    float edge = abs(fract(r * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Zoetrope Animation
let zoetropeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param frameCount "Frame Count" range(4, 16) default(8)
// @param slitWidth "Slit Width" range(0.02, 0.1) default(0.05)
// @param figureSize "Figure Size" range(0.1, 0.3) default(0.15)
// @param animationPhase "Animation Phase" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle showSlits "Show Slits" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5 - center * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float r = length(p);
float a = atan2(p.y, p.x);
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = mix(col2, float3(0.1, 0.08, 0.06), 0.5);

float spinAngle = timeVal * 2.0;
float slitAngle = 6.28318 / float(frameCount);
float currentSlit = floor((a + 3.14159 + spinAngle) / slitAngle);
float slitPos = fmod(a + 3.14159 + spinAngle, slitAngle) - slitAngle * 0.5;
float slit = smoothstep(slitWidth, slitWidth * 0.5, abs(slitPos));

if (showSlits > 0.5) {
    float slitMark = smoothstep(0.005, 0.0, abs(slitPos));
    col += slitMark * float3(0.2) * step(0.7, r) * step(r, 0.9);
}

float framePhase = currentSlit / float(frameCount) + animationPhase;
float figureY = sin(framePhase * 6.28318) * 0.1;
float figureX = cos(framePhase * 6.28318 * 2.0) * 0.05;
float2 figureCenter = float2(0.0, 0.5 + figureY);
float2 rotP = float2(
    p.x * cos(-spinAngle) - p.y * sin(-spinAngle),
    p.x * sin(-spinAngle) + p.y * cos(-spinAngle)
);
float figSz = figureSize * pulseAmt;
float figure = smoothstep(figSz, figSz - 0.02, length(rotP - figureCenter - float2(figureX, 0.0)));
if (smooth > 0.5) figure = smoothstep(0.0, 1.0, figure);

float3 figureColor;
if (rainbow > 0.5) {
    figureColor = 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.094, 4.188));
} else if (gradient > 0.5) {
    figureColor = mix(col1, col2, figureY + 0.5);
} else {
    figureColor = col1;
}

if (neon > 0.5) figureColor = pow(figureColor, float3(0.5));
if (pastel > 0.5) figureColor = mix(figureColor, float3(1.0), 0.4);

col = mix(col, figureColor, figure * slit * step(0.3, r) * step(r, 0.85));

float rim = smoothstep(0.02, 0.0, abs(r - 0.9));
col += rim * col2 * 0.5;

if (showEdges > 0.5) {
    float edge = smoothstep(0.01, 0.0, abs(figure - 0.5));
    col += edge * float3(1.0) * 0.3;
}

if (glow > 0.5) {
    float glowAmt = exp(-r * 2.0) * glowIntensity;
    col += glowAmt * col1 * 0.3;
}

if (radial > 0.5) col *= 1.0 - r * 0.3;

if (outline > 0.5) {
    col = mix(col, float3(1.0), rim * 0.5);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Op Art Waves
let opArtWavesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveCount "Wave Count" range(5, 30) default(15)
// @param amplitude "Amplitude" range(0.0, 0.5) default(0.1)
// @param perspective "Perspective" range(0.0, 1.0) default(0.5)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle colorMode "Color Mode" default(false)
// @toggle rainbow "Rainbow" default(false)
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

float2 center = float2(centerX, centerY);
float2 p = uv - 0.5 - center * 0.5;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
p += 0.5;
if (distortion > 0.0) {
    float rd = length(p - 0.5);
    p = 0.5 + (p - 0.5) * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float ak = atan2(kp.y, kp.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float py = pow(p.y, 1.0 + perspective);
float wave = sin(py * float(waveCount) * 6.28 - timeVal * waveFrequency);
wave *= amplitude * pulseAmt * (1.0 - py * perspective);
float stripe = sin((p.x + wave) * float(waveCount) * 3.14159);
stripe = stripe * 0.5 + 0.5;
if (smooth > 0.5) stripe = smoothstep(0.2, 0.8, stripe);

float3 col;
if (rainbow > 0.5) {
    float3 rc1 = 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.094, 4.188));
    float3 rc2 = 0.5 + 0.5 * cos(timeVal + 3.14 + float3(0.0, 2.094, 4.188));
    col = mix(rc1, rc2, stripe);
} else if (colorMode > 0.5 || gradient > 0.5) {
    col = mix(col1, col2, stripe);
} else {
    col = float3(stripe);
}

if (neon > 0.5) col = pow(col, float3(0.5));
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);

if (showEdges > 0.5) {
    float edge = abs(stripe - 0.5);
    col += smoothstep(0.1, 0.0, edge) * 0.3;
}

if (glow > 0.5) {
    col += col * glowIntensity * stripe;
}

if (radial > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

if (outline > 0.5) {
    float edge = abs(fract(stripe * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Spirograph Pattern
let spirographCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param outerRadius "Outer Radius" range(0.5, 1.0) default(0.8)
// @param innerRadius "Inner Radius" range(0.1, 0.5) default(0.3)
// @param penOffset "Pen Offset" range(0.1, 0.5) default(0.25)
// @param lineThickness "Line Thickness" range(0.005, 0.03) default(0.01)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle multiColor "Multi Color" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5 - center * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = float3(0.02, 0.02, 0.05);

float R = outerRadius * pulseAmt;
float r = innerRadius;
float d = penOffset;
float totalAngle = timeVal * 5.0 + 10.0;

float minDist = 10.0;
float closestT = 0.0;
for (int i = 0; i < 500; i++) {
    float t = float(i) * 0.05;
    if (t > totalAngle) break;
    float x = (R - r) * cos(t) + d * cos((R - r) / r * t);
    float y = (R - r) * sin(t) - d * sin((R - r) / r * t);
    float dist = length(p - float2(x, y));
    if (dist < minDist) {
        minDist = dist;
        closestT = t;
    }
}

float line = smoothstep(lineThickness, 0.0, minDist);
if (smooth > 0.5) line = smoothstep(0.0, 1.0, line);

float3 lineColor;
if (rainbow > 0.5) {
    lineColor = 0.5 + 0.5 * cos(closestT * 0.5 + timeVal + float3(0.0, 2.094, 4.188));
} else if (multiColor > 0.5 || gradient > 0.5) {
    lineColor = mix(col1, col2, sin(closestT * 0.5) * 0.5 + 0.5);
} else {
    lineColor = col1;
}

if (neon > 0.5) lineColor = pow(lineColor, float3(0.5));
if (pastel > 0.5) lineColor = mix(lineColor, float3(1.0), 0.4);

col += line * lineColor;

if (glow > 0.5) {
    float glowAmt = exp(-minDist * 20.0) * glowIntensity;
    col += glowAmt * lineColor;
}

if (showEdges > 0.5) {
    float edge = smoothstep(lineThickness * 1.5, lineThickness, minDist);
    col += edge * float3(1.0) * 0.3;
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    col = mix(col, float3(1.0), line * 0.2);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Moiré Circles
let moireCirclesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param circleSpacing "Circle Spacing" range(0.02, 0.1) default(0.04)
// @param offsetAmount "Offset Amount" range(0.0, 0.5) default(0.15)
// @param lineWidth "Line Width" range(0.3, 0.7) default(0.5)
// @param centerCount "Center Count" range(1, 4) default(2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorMode "Color Mode" default(false)
// @toggle rainbow "Rainbow" default(false)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float offset = sin(timeVal) * offsetAmount * pulseAmt;
float pattern = 0.0;
for (int c = 0; c < 4; c++) {
    if (c >= int(centerCount)) break;
    float2 circleCenter;
    if (c == 0) circleCenter = float2(-offset, 0.0);
    else if (c == 1) circleCenter = float2(offset, 0.0);
    else if (c == 2) circleCenter = float2(0.0, -offset);
    else circleCenter = float2(0.0, offset);
    float r = length(p - circleCenter);
    float circles = sin(r / circleSpacing * 6.28318);
    circles = step(lineWidth - 0.5, circles * 0.5 + 0.5);
    if (smooth > 0.5) circles = smoothstep(0.0, 1.0, circles);
    pattern += circles;
}
pattern = fract(pattern * 0.5);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(pattern * 6.28 + timeVal + float3(0.0, 2.094, 4.188));
} else if (colorMode > 0.5 || gradient > 0.5) {
    col = mix(col2, col1, pattern);
} else {
    col = float3(pattern);
}

if (neon > 0.5) col = pow(col, float3(0.5));
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);

if (showEdges > 0.5) {
    float edge = abs(pattern - 0.5);
    col += smoothstep(0.1, 0.0, edge) * 0.3;
}

if (glow > 0.5) {
    col += col * glowIntensity * pattern;
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    float edge = abs(fract(pattern * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Infinity Mirror
let infinityMirrorCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param tunnelDepth "Tunnel Depth" range(3, 15) default(8)
// @param shrinkRate "Shrink Rate" range(0.6, 0.9) default(0.75)
// @param rotationPerLevel "Rotation Per Level" range(0.0, 0.5) default(0.1)
// @param colorFade "Color Fade" range(0.5, 1.0) default(0.85)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle neonFrame "Neon Frame" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? 0.7 + 0.3 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = float3(0.02, 0.02, 0.05);

float scale = 1.0;
float rot = 0.0;
for (int i = 0; i < 15; i++) {
    if (i >= int(tunnelDepth)) break;
    float fi = float(i);
    float c = cos(rot);
    float s = sin(rot);
    float2 rp = float2(p.x * c - p.y * s, p.x * s + p.y * c) / scale;
    float frameSize = 0.8;
    float frame = max(abs(rp.x), abs(rp.y));
    float frameMask = smoothstep(frameSize + 0.02, frameSize, frame) - smoothstep(frameSize - 0.02, frameSize - 0.04, frame);
    if (smooth > 0.5) frameMask = smoothstep(0.0, 1.0, frameMask);
    float pls = 0.7 + 0.3 * sin(timeVal - fi * 0.5);
    float fade = pow(colorFade, fi);
    
    float3 frameColor;
    if (rainbow > 0.5) {
        frameColor = 0.5 + 0.5 * cos(fi * 0.8 + timeVal + float3(0.0, 2.094, 4.188));
    } else if (neonFrame > 0.5 || gradient > 0.5) {
        frameColor = mix(col1, col2, fi / float(tunnelDepth));
    } else {
        frameColor = col1;
    }
    
    if (neon > 0.5) frameColor = pow(frameColor, float3(0.5));
    if (pastel > 0.5) frameColor = mix(frameColor, float3(1.0), 0.4);
    
    col += frameMask * frameColor * fade * pls * pulseAmt;
    
    if (showEdges > 0.5) {
        float edge = smoothstep(0.01, 0.0, abs(frameMask - 0.5));
        col += edge * float3(1.0) * 0.2;
    }
    
    scale *= shrinkRate;
    rot += rotationPerLevel;
}

if (glow > 0.5) {
    float glowAmt = exp(-length(p) * 2.0) * glowIntensity;
    col += glowAmt * mix(col1, col2, 0.5);
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    float edge = abs(fract(length(p) * 3.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.2);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Checkerboard Warp
let checkerboardWarpCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param checkSize "Check Size" range(2.0, 20.0) default(8.0)
// @param warpStrength "Warp Strength" range(0.0, 1.0) default(0.3)
// @param warpFrequency "Warp Frequency" range(1.0, 5.0) default(2.0)
// @param edgeSoftness "Edge Softness" range(0.0, 0.5) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(false)
// @toggle rainbow "Rainbow" default(false)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float2 warp = float2(
    sin(p.y * warpFrequency * 3.14 + timeVal),
    sin(p.x * warpFrequency * 3.14 + timeVal * 1.3)
) * warpStrength * pulseAmt;
float2 wp = p + warp;
float2 checkP = floor(wp * checkSize);
float checker = fmod(checkP.x + checkP.y, 2.0);
float2 cellP = fract(wp * checkSize);
float edge = min(min(cellP.x, 1.0 - cellP.x), min(cellP.y, 1.0 - cellP.y));
float softChecker = checker;
if (smooth > 0.5) {
    softChecker = mix(checker, 1.0 - checker, smoothstep(edgeSoftness, 0.0, edge));
}

float3 col;
if (rainbow > 0.5) {
    float3 rc1 = 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.094, 4.188));
    float3 rc2 = 0.5 + 0.5 * cos(timeVal + 3.14 + float3(0.0, 2.094, 4.188));
    col = mix(rc1, rc2, softChecker);
} else if (colorful > 0.5 || gradient > 0.5) {
    col = mix(col2, col1, softChecker);
} else {
    col = float3(softChecker);
}

if (neon > 0.5) col = pow(col, float3(0.5));
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);

if (showEdges > 0.5) {
    float edgeMask = smoothstep(0.1, 0.0, edge);
    col = mix(col, float3(1.0, 0.5, 0.0), edgeMask * 0.5);
}

if (glow > 0.5) {
    col += col * glowIntensity * (1.0 - edge);
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    float outlineEdge = smoothstep(0.05, 0.0, edge);
    col = mix(col, float3(1.0), outlineEdge * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Penrose Impossible
let penroseImpossibleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.3)
// @param triSize "Triangle Size" range(0.3, 0.8) default(0.5)
// @param barWidth "Bar Width" range(0.05, 0.15) default(0.08)
// @param shadingDepth "Shading Depth" range(0.0, 0.5) default(0.3)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle impossible "Impossible" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float angle = rotation + timeVal;
float c = cos(angle);
float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = float3(0.1, 0.1, 0.12);

float ts = triSize * pulseAmt;
float2 v1 = float2(0.0, ts);
float2 v2 = float2(-ts * 0.866, -ts * 0.5);
float2 v3 = float2(ts * 0.866, -ts * 0.5);

float bar1 = 10.0, bar2 = 10.0, bar3 = 10.0;
float2 d1 = v2 - v1;
float t1 = clamp(dot(p - v1, d1) / dot(d1, d1), 0.0, 1.0);
bar1 = length(p - v1 - d1 * t1);
float2 d2 = v3 - v2;
float t2 = clamp(dot(p - v2, d2) / dot(d2, d2), 0.0, 1.0);
bar2 = length(p - v2 - d2 * t2);
float2 d3 = v1 - v3;
float t3 = clamp(dot(p - v3, d3) / dot(d3, d3), 0.0, 1.0);
bar3 = length(p - v3 - d3 * t3);

float3 barColor1, barColor2, barColor3;
if (rainbow > 0.5) {
    barColor1 = 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.094, 4.188));
    barColor2 = 0.5 + 0.5 * cos(timeVal + 2.0 + float3(0.0, 2.094, 4.188));
    barColor3 = 0.5 + 0.5 * cos(timeVal + 4.0 + float3(0.0, 2.094, 4.188));
} else if (gradient > 0.5) {
    barColor1 = col1 * (1.0 - t1 * shadingDepth);
    barColor2 = mix(col1, col2, 0.5) * (1.0 - t2 * shadingDepth);
    barColor3 = col2 * (1.0 - t3 * shadingDepth);
} else {
    barColor1 = col1 * (1.0 - t1 * shadingDepth);
    barColor2 = col1 * (1.0 - t2 * shadingDepth);
    barColor3 = col1 * (1.0 - t3 * shadingDepth);
}

if (neon > 0.5) {
    barColor1 = pow(barColor1, float3(0.5));
    barColor2 = pow(barColor2, float3(0.5));
    barColor3 = pow(barColor3, float3(0.5));
}
if (pastel > 0.5) {
    barColor1 = mix(barColor1, float3(1.0), 0.4);
    barColor2 = mix(barColor2, float3(1.0), 0.4);
    barColor3 = mix(barColor3, float3(1.0), 0.4);
}

float mask1 = smoothstep(barWidth, barWidth - 0.02, bar1);
float mask2 = smoothstep(barWidth, barWidth - 0.02, bar2);
float mask3 = smoothstep(barWidth, barWidth - 0.02, bar3);
if (smooth > 0.5) {
    mask1 = smoothstep(0.0, 1.0, mask1);
    mask2 = smoothstep(0.0, 1.0, mask2);
    mask3 = smoothstep(0.0, 1.0, mask3);
}

col = mix(col, barColor1, mask1);
if (impossible > 0.5) {
    col = mix(col, barColor2, mask2 * step(t2, 0.7));
    col = mix(col, barColor3, mask3 * step(0.3, t3));
    col = mix(col, barColor2, mask2 * step(0.7, t2));
} else {
    col = mix(col, barColor2, mask2);
    col = mix(col, barColor3, mask3);
}

if (showEdges > 0.5) {
    float edge = min(min(mask1, mask2), mask3);
    col += smoothstep(0.1, 0.0, abs(edge - 0.5)) * float3(1.0) * 0.3;
}

if (glow > 0.5 && glowAmount > 0.0) {
    float glw = exp(-min(min(bar1, bar2), bar3) * 10.0) * glowAmount * glowIntensity;
    col += glw * mix(col1, col2, 0.5);
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    float minBar = min(min(bar1, bar2), bar3);
    col = mix(col, float3(1.0), smoothstep(barWidth + 0.01, barWidth, minBar) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Escher Stairs
let escherStairsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param stairCount "Stair Count" range(3, 12) default(6)
// @param perspectiveAngle "Perspective Angle" range(0.0, 1.0) default(0.5)
// @param shadowDepth "Shadow Depth" range(0.0, 0.5) default(0.3)
// @param stairWidth "Stair Width" range(0.2, 0.6) default(0.4)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.3)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.7)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.68)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.65)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.88)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.85)
// @toggle animated "Animated" default(true)
// @toggle infinite "Infinite Loop" default(true)
// @toggle rainbow "Rainbow" default(false)
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

float2 ctr = float2(centerX, centerY);
float2 p = uv - ctr * 0.5;
p = (p - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = p - 0.5;
p = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs) + 0.5;
if (distortion > 0.0) {
    float rd = length(p - 0.5);
    p = 0.5 + (p - 0.5) * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float ak = atan2(kp.y, kp.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = col2;

float stairHeight = 1.0 / float(stairCount);
float stairPhase = infinite > 0.5 ? fract(p.y + timeVal) : p.y;
float stairIndex = floor(stairPhase / stairHeight);
float localY = fract(stairPhase / stairHeight);
float stairX = fract(stairIndex * 0.3 + perspectiveAngle * 0.5);
float tread = step(stairX, p.x) * step(p.x, stairX + stairWidth * pulseAmt);
float riser = step(0.0, localY) * step(localY, 0.3);
if (smooth > 0.5) {
    tread = smoothstep(0.0, 1.0, tread);
    riser = smoothstep(0.0, 1.0, riser);
}

float3 treadColor, riserColor;
if (rainbow > 0.5) {
    treadColor = 0.5 + 0.5 * cos(stairIndex * 0.5 + timeVal + float3(0.0, 2.094, 4.188));
    riserColor = treadColor * (1.0 - shadowDepth);
} else if (gradient > 0.5) {
    treadColor = mix(col1, col2, stairIndex / float(stairCount));
    riserColor = treadColor * (1.0 - shadowDepth);
} else {
    treadColor = col1;
    riserColor = treadColor * (1.0 - shadowDepth);
}

if (neon > 0.5) {
    treadColor = pow(treadColor, float3(0.5));
    riserColor = pow(riserColor, float3(0.5));
}
if (pastel > 0.5) {
    treadColor = mix(treadColor, float3(1.0), 0.4);
    riserColor = mix(riserColor, float3(1.0), 0.4);
}

col = mix(col, treadColor, tread * (1.0 - riser));
col = mix(col, riserColor, tread * riser);

float shadow = smoothstep(stairX + stairWidth, stairX + stairWidth + 0.05, p.x) * tread;
col *= (1.0 - shadow * shadowIntensity);

if (showEdges > 0.5) {
    float edge = abs(localY - 0.3);
    col = mix(col, float3(0.2), smoothstep(0.02, 0.0, edge) * tread * 0.5);
}

if (glow > 0.5) {
    col += col * glowIntensity * tread * 0.3;
}

if (radial > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

if (outline > 0.5) {
    float stairEdge = abs(p.x - stairX) + abs(p.x - stairX - stairWidth);
    col = mix(col, float3(0.0), smoothstep(0.02, 0.0, min(abs(p.x - stairX), abs(p.x - stairX - stairWidth))) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Pulsing Hypnosis
let pulsingHypnosisCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(5, 30) default(15)
// @param pulseSpeed "Pulse Speed" range(0.5, 4.0) default(2.0)
// @param wavePhase "Wave Phase" range(0.0, 6.28) default(0.0)
// @param spiralTwist "Spiral Twist" range(0.0, 3.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle invertRings "Invert Rings" default(false)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float r = length(p) * pulseAmt;
float a = atan2(p.y, p.x);
float spiral = a * spiralTwist / 6.28;
float rings = sin((r + spiral) * float(ringCount) * 3.14159 - timeVal * pulseSpeed + wavePhase);
rings = rings * 0.5 + 0.5;
if (smooth > 0.5) rings = smoothstep(0.2, 0.8, rings);
if (invertRings > 0.5) rings = 1.0 - rings;

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(r * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
    col = mix(col1, col, rings);
} else if (gradient > 0.5) {
    col = mix(col1, col2, rings);
} else {
    col = float3(rings);
}

if (neon > 0.5) col = pow(col, float3(0.5));
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);

if (showEdges > 0.5) {
    float edge = abs(rings - 0.5);
    col += smoothstep(0.1, 0.0, edge) * 0.3;
}

if (glow > 0.5) {
    float glowAmt = exp(-r * 2.0) * glowIntensity;
    col += glowAmt * col2;
}

if (radial > 0.5) col *= 1.0 - r * 0.3;

if (outline > 0.5) {
    float edge = abs(fract(rings * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Impossible Cube
let impossibleCubeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param cubeSize "Cube Size" range(0.2, 0.5) default(0.35)
// @param lineWidth "Line Width" range(0.01, 0.05) default(0.02)
// @param rotationX "Rotation X" range(0.0, 6.28) default(0.5)
// @param rotationY "Rotation Y" range(0.0, 6.28) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.95)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.95)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.98)
// @toggle animated "Animated" default(true)
// @toggle autoRotate "Auto Rotate" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = col2;

float rx = rotationX + (autoRotate > 0.5 ? timeVal : 0.0);
float ry = rotationY + (autoRotate > 0.5 ? timeVal * 0.7 : 0.0);
float sz = cubeSize * pulseAmt;

float crx = cos(rx); float srx = sin(rx);
float cry = cos(ry); float sry = sin(ry);

float minDist = 10.0;
float closestDepth = 0.0;

for (int edge = 0; edge < 12; edge++) {
    int v1idx = 0; int v2idx = 0;
    if (edge == 0) { v1idx = 0; v2idx = 1; }
    else if (edge == 1) { v1idx = 1; v2idx = 3; }
    else if (edge == 2) { v1idx = 3; v2idx = 2; }
    else if (edge == 3) { v1idx = 2; v2idx = 0; }
    else if (edge == 4) { v1idx = 4; v2idx = 5; }
    else if (edge == 5) { v1idx = 5; v2idx = 7; }
    else if (edge == 6) { v1idx = 7; v2idx = 6; }
    else if (edge == 7) { v1idx = 6; v2idx = 4; }
    else if (edge == 8) { v1idx = 0; v2idx = 4; }
    else if (edge == 9) { v1idx = 1; v2idx = 5; }
    else if (edge == 10) { v1idx = 2; v2idx = 6; }
    else { v1idx = 3; v2idx = 7; }
    
    float3 vert1 = float3((v1idx & 1) != 0 ? sz : -sz, (v1idx & 2) != 0 ? sz : -sz, (v1idx & 4) != 0 ? sz : -sz);
    float3 vert2 = float3((v2idx & 1) != 0 ? sz : -sz, (v2idx & 2) != 0 ? sz : -sz, (v2idx & 4) != 0 ? sz : -sz);
    
    float t1 = vert1.y * crx - vert1.z * srx;
    vert1.z = vert1.y * srx + vert1.z * crx;
    vert1.y = t1;
    float t2 = vert1.x * cry - vert1.z * sry;
    vert1.z = vert1.x * sry + vert1.z * cry;
    vert1.x = t2;
    
    t1 = vert2.y * crx - vert2.z * srx;
    vert2.z = vert2.y * srx + vert2.z * crx;
    vert2.y = t1;
    t2 = vert2.x * cry - vert2.z * sry;
    vert2.z = vert2.x * sry + vert2.z * cry;
    vert2.x = t2;
    
    float2 v1xy = vert1.xy;
    float2 v2xy = vert2.xy;
    float2 d = v2xy - v1xy;
    float len = length(d);
    if (len > 0.001) {
        d = d / len;
        float2 toP = p - v1xy;
        float t = clamp(dot(toP, d), 0.0, len);
        float dist = length(toP - d * t);
        if (dist < minDist) {
            minDist = dist;
            closestDepth = mix(vert1.z, vert2.z, t / len);
        }
    }
}

float line = smoothstep(lineWidth, lineWidth * 0.5, minDist);
if (smooth > 0.5) line = smoothstep(0.0, 1.0, line);

float3 lineColor;
if (rainbow > 0.5) {
    lineColor = 0.5 + 0.5 * cos(closestDepth * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else if (gradient > 0.5) {
    lineColor = mix(col1, col1 * 1.5, 0.5 + closestDepth);
} else {
    lineColor = col1;
}

if (neon > 0.5) lineColor = pow(lineColor, float3(0.5));
if (pastel > 0.5) lineColor = mix(lineColor, float3(1.0), 0.4);

col = mix(col, lineColor, line);

if (showEdges > 0.5) {
    col = mix(col, lineColor * 1.2, line * smoothstep(lineWidth * 2.0, lineWidth, minDist));
}

if (glow > 0.5) {
    float glowAmt = exp(-minDist * 15.0) * glowIntensity;
    col += glowAmt * col1;
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    col = mix(col, float3(1.0), line * 0.2);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Tunnel Zoom
let tunnelZoomCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param zoomSpeed "Zoom Speed" range(0.5, 5.0) default(2.0)
// @param tunnelSegments "Tunnel Segments" range(4, 16) default(8)
// @param twistAmount "Twist Amount" range(0.0, 2.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 3.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle psychedelic "Psychedelic" default(false)
// @toggle rainbow "Rainbow" default(false)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.2 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float zm = fract(log(r + 0.001) * 0.5 - timeVal * zoomSpeed * 0.1);
float twist = a + zm * twistAmount * 6.28 * pulseAmt;
float segment = floor(twist / (6.28 / float(tunnelSegments)));
float segmentLocal = fract(twist / (6.28 / float(tunnelSegments)));
float pattern = step(0.5, segmentLocal);
if (smooth > 0.5) pattern = smoothstep(0.4, 0.6, segmentLocal);

float3 col;
if (rainbow > 0.5 || psychedelic > 0.5) {
    col = 0.5 + 0.5 * cos(zm * 10.0 + segment + timeVal * colorSpeed + float3(0.0, 2.094, 4.188));
    col *= pattern * 0.5 + 0.5;
} else if (gradient > 0.5) {
    col = mix(col1, col2, pattern);
    col *= (1.0 - zm * 0.5);
} else {
    float bw = mix(0.2, 0.9, pattern);
    bw *= (1.0 - zm * 0.5);
    col = float3(bw);
}

if (neon > 0.5) col = pow(col, float3(0.5));
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);

col *= smoothstep(0.0, 0.1, r);

if (showEdges > 0.5) {
    float edge = abs(segmentLocal - 0.5);
    col += smoothstep(0.1, 0.0, edge) * 0.3;
}

if (glow > 0.5) {
    float glowAmt = exp(-r * 3.0) * glowIntensity;
    col += glowAmt * col2;
}

if (radial > 0.5) col *= 1.0 - r * 0.3;

if (outline > 0.5) {
    float edge = abs(fract(zm * 5.0) - 0.5);
    col = mix(col, float3(1.0), smoothstep(0.1, 0.0, edge) * 0.3);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Necker Cube
let neckerCubeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param cubeSize "Cube Size" range(0.2, 0.5) default(0.3)
// @param lineThickness "Line Thickness" range(0.005, 0.02) default(0.008)
// @param perspective "Perspective" range(0.0, 0.5) default(0.2)
// @param flipAmount "Flip Amount" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.95)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.95)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.98)
// @toggle animated "Animated" default(true)
// @toggle showVertices "Show Vertices" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);
float3 col = col2;

float flip = sin(timeVal) * 0.5 + 0.5;
float frontZ = mix(-1.0, 1.0, flip * flipAmount);
float s = cubeSize * pulseAmt;
float pers = perspective;

float frontScale = 1.0 + frontZ * pers;
float backScale = 1.0 - frontZ * pers;

float minDist = 10.0;
int hitType = 0;

for (int i = 0; i < 4; i++) {
    float x1 = (i == 1 || i == 2) ? s : -s;
    float y1 = (i >= 2) ? s : -s;
    int next = (i + 1) - 4 * int(step(3.5, float(i + 1)));
    float x2 = (next == 1 || next == 2) ? s : -s;
    float y2 = (next >= 2) ? s : -s;
    
    float2 v1 = float2(x1, y1) * frontScale;
    float2 v2 = float2(x2, y2) * frontScale;
    float2 d = v2 - v1;
    float t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    float dist = length(p - v1 - d * t);
    if (dist < minDist) { minDist = dist; hitType = 0; }
    
    v1 = float2(x1, y1) * backScale;
    v2 = float2(x2, y2) * backScale;
    d = v2 - v1;
    t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    dist = length(p - v1 - d * t);
    if (dist < minDist) { minDist = dist; hitType = 1; }
    
    v1 = float2(x1, y1) * frontScale;
    v2 = float2(x1, y1) * backScale;
    d = v2 - v1;
    t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    dist = length(p - v1 - d * t);
    if (dist < minDist) { minDist = dist; hitType = 2; }
}

float line = smoothstep(lineThickness, 0.0, minDist);
if (smooth > 0.5) line = smoothstep(0.0, 1.0, line);

float3 lineColor;
if (rainbow > 0.5) {
    lineColor = 0.5 + 0.5 * cos(float(hitType) + timeVal + float3(0.0, 2.094, 4.188));
} else if (gradient > 0.5) {
    float depth = float(hitType) / 2.0;
    lineColor = mix(col1, col1 * 0.5, depth);
} else {
    lineColor = col1;
}

if (neon > 0.5) lineColor = pow(lineColor, float3(0.5));
if (pastel > 0.5) lineColor = mix(lineColor, float3(1.0), 0.4);

col = mix(col, lineColor, line);

if (showVertices > 0.5) {
    for (int i = 0; i < 4; i++) {
        float x = (i == 1 || i == 2) ? s : -s;
        float y = (i >= 2) ? s : -s;
        float d1 = length(p - float2(x, y) * frontScale);
        float d2 = length(p - float2(x, y) * backScale);
        col = mix(col, float3(0.9, 0.3, 0.3), smoothstep(0.02, 0.01, d1));
        col = mix(col, float3(0.3, 0.3, 0.9), smoothstep(0.02, 0.01, d2));
    }
}

if (showEdges > 0.5) {
    col = mix(col, lineColor * 1.2, line * smoothstep(lineThickness * 2.0, lineThickness, minDist));
}

if (glow > 0.5) {
    float glowAmt = exp(-minDist * 20.0) * glowIntensity;
    col += glowAmt * col1;
}

if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    col = mix(col, float3(1.0), line * 0.2);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Ames Room
let amesRoomCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param roomDistortion "Room Distortion" range(0.0, 1.0) default(0.5)
// @param floorTiles "Floor Tiles" range(3.0, 15.0) default(8.0)
// @param wallPattern "Wall Pattern" range(1.0, 5.0) default(2.0)
// @param figureSize "Figure Size" range(0.05, 0.2) default(0.1)
// @param figurePosX "Figure Position X" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.25)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.85)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.82)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.75)
// @toggle animated "Animated" default(true)
// @toggle showFigures "Show Figures" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = uv - 0.5 - ctr * 0.5;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
p += 0.5;
if (distortion > 0.0) {
    float2 c = p - 0.5;
    float rd = length(c);
    c *= 1.0 + distortion * rd * rd;
    p = c + 0.5;
}
if (mirror > 0.5) p.x = 0.5 - abs(p.x - 0.5);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float2 c = p - 0.5;
    float ak = atan2(c.y, c.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(c) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 col1 = float3(color1R, color1G, color1B);
float3 col2 = float3(color2R, color2G, color2B);

float dist = mix(1.0, 0.5 + p.x * 0.5, roomDistortion);
float2 dp = float2(p.x, (p.y - 0.5) * dist + 0.5);

float3 col = float3(0.9, 0.88, 0.85);
float floorY = 0.3;

if (dp.y < floorY) {
    float2 floorP = float2(dp.x, (floorY - dp.y) * 3.0 / dist);
    float2 tile = floor(floorP * floorTiles);
    float checker = fmod(tile.x + tile.y, 2.0);
    if (rainbow > 0.5) {
        float3 rainCol = 0.5 + 0.5 * cos(timeVal + tile.x * 0.5 + float3(0.0, 2.094, 4.188));
        col = mix(rainCol * 0.5, rainCol, checker);
    } else {
        col = mix(col1, col2 * 0.9, checker);
    }
    if (gradient > 0.5) {
        col *= 1.0 - dp.y * 0.3;
    }
} else {
    float wallX = dp.x * wallPattern;
    float wallY = (dp.y - floorY) * wallPattern / dist;
    float pattern = sin(wallX * 6.28) * sin(wallY * 6.28) * 0.1;
    col = col2 + pattern;
    if (showEdges > 0.5) {
        col *= 1.0 + sin(wallX * 12.56) * 0.05;
    }
}

if (showFigures > 0.5) {
    float figX = animated > 0.5 ? fract(timeVal * 0.2 + figurePosX) : figurePosX;
    float figScale = mix(1.0, 0.4, figX * roomDistortion) * pulseAmt;
    float2 figPos = float2(figX, floorY);
    float2 toFig = p - figPos;
    float figD = length(toFig * float2(1.0, 2.0)) / (figureSize * figScale);
    float figure = smoothstep(1.0, 0.8, figD);
    float3 figCol = float3(0.2, 0.3, 0.5);
    if (neon > 0.5) figCol = float3(0.0, 0.8, 1.0);
    col = mix(col, figCol, figure);
    if (glow > 0.5) {
        col += exp(-figD * 3.0) * glowIntensity * figCol;
    }
}

col += shadowIntensity * (-0.2) * (1.0 - dp.y);
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

if (outline > 0.5) {
    float edge = abs(dp.y - floorY);
    col = mix(col, float3(0.0), smoothstep(0.02, 0.01, edge));
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Rubin Vase
let rubinVaseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param vaseWidth "Vase Width" range(0.1, 0.4) default(0.25)
// @param neckWidth "Neck Width" range(0.05, 0.2) default(0.1)
// @param edgeSoftness "Edge Softness" range(0.0, 0.1) default(0.02)
// @param profileCurve "Profile Curve" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.15)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.95)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.85)
// @toggle animated "Animated" default(true)
// @toggle showFaceDetails "Show Face Details" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 vaseColor = float3(color1R, color1G, color1B);
float3 faceColor = float3(color2R, color2G, color2B);

if (neon > 0.5) {
    vaseColor = float3(0.0, 0.0, 0.2);
    faceColor = float3(0.0, 0.9, 1.0);
}

float profile = vaseWidth * pulseAmt;
float y = p.y;
if (y > 0.3) {
    profile = mix(vaseWidth, neckWidth, (y - 0.3) / 0.4) * pulseAmt;
} else if (y < -0.3) {
    profile = mix(vaseWidth, vaseWidth * 1.2, (-0.3 - y) / 0.3) * pulseAmt;
}
profile += sin(y * 5.0) * profileCurve;

float edg = smooth > 0.5 ? edgeSoftness : edgeSoftness * 0.5;
float vase = smoothstep(profile + edg, profile - edg, abs(p.x));

float transition = sin(timeVal) * 0.5 + 0.5;

if (rainbow > 0.5) {
    vaseColor = 0.5 + 0.5 * cos(timeVal * 0.5 + float3(0.0, 2.094, 4.188));
}

float3 col = mix(faceColor, vaseColor, vase);

if (showFaceDetails > 0.5) {
    float leftEye = smoothstep(0.03, 0.02, length(p - float2(-0.5, 0.1)));
    float rightEye = smoothstep(0.03, 0.02, length(p - float2(0.5, 0.1)));
    float leftNose = smoothstep(0.02, 0.01, abs(p.x + 0.35 + p.y * 0.1)) * step(-0.1, p.y) * step(p.y, 0.1);
    float rightNose = smoothstep(0.02, 0.01, abs(p.x - 0.35 - p.y * 0.1)) * step(-0.1, p.y) * step(p.y, 0.1);
    float faceDetail = max(max(leftEye, rightEye), max(leftNose, rightNose));
    faceDetail *= (1.0 - vase);
    col = mix(col, vaseColor, faceDetail * transition);
}

if (showEdges > 0.5) {
    float edge = smoothstep(edg * 2.0, 0.0, abs(abs(p.x) - profile));
    col = mix(col, float3(1.0), edge * 0.3);
}

if (glow > 0.5) {
    float edgeDist = abs(abs(p.x) - profile);
    col += exp(-edgeDist * 30.0) * glowIntensity * mix(vaseColor, faceColor, 0.5);
}

if (gradient > 0.5) col *= 1.0 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p) * 0.2;

if (outline > 0.5) {
    float edge = smoothstep(edg, 0.0, abs(abs(p.x) - profile));
    col = mix(col, float3(0.0), edge);
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Spinning Discs
let spinningDiscsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param discCount "Disc Count" range(2.0, 8.0) default(4.0)
// @param discSize "Disc Size" range(0.1, 0.3) default(0.2)
// @param patternDensity "Pattern Density" range(4.0, 16.0) default(8.0)
// @param colorCycle "Color Cycle" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.92)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.1)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.1)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle alternateDirection "Alternate Direction" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgCol = float3(color1R, color1G, color1B);
float3 darkCol = float3(color2R, color2G, color2B);
float3 col = bgCol;

int numDiscs = int(discCount);
for (int i = 0; i < 8; i++) {
    if (i >= numDiscs) break;
    float fi = float(i);
    float angle = fi * 6.28318 / discCount;
    float2 center = float2(cos(angle), sin(angle)) * 0.4;
    float2 toDisc = p - center;
    float r = length(toDisc);
    float a = atan2(toDisc.y, toDisc.x);
    float dir = (alternateDirection > 0.5 && i % 2 == 1) ? -1.0 : 1.0;
    a += timeVal * dir;
    float pattern = sin(a * patternDensity) * 0.5 + 0.5;
    float disc = smoothstep(discSize * pulseAmt, discSize * pulseAmt - 0.02, r);
    
    float3 discColor;
    if (rainbow > 0.5) {
        discColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
    } else {
        discColor = 0.5 + 0.5 * cos(fi * colorCycle + float3(0.0, 2.0, 4.0));
    }
    
    if (neon > 0.5) discColor = pow(discColor, float3(0.5)) * 1.5;
    if (pastel > 0.5) discColor = mix(discColor, float3(1.0), 0.4);
    
    float3 patternColor = mix(darkCol, discColor, pattern);
    col = mix(col, patternColor, disc);
    
    if (glow > 0.5) {
        col += exp(-r * 8.0) * glowIntensity * discColor * disc;
    }
    
    if (showEdges > 0.5) {
        float edge = smoothstep(discSize * pulseAmt, discSize * pulseAmt - 0.01, r);
        edge -= smoothstep(discSize * pulseAmt - 0.01, discSize * pulseAmt - 0.02, r);
        col = mix(col, float3(1.0), edge);
    }
}

if (gradient > 0.5) col *= 1.0 - length(p) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

if (outline > 0.5) {
    for (int i = 0; i < 8; i++) {
        if (i >= numDiscs) break;
        float fi = float(i);
        float angle = fi * 6.28318 / discCount;
        float2 center = float2(cos(angle), sin(angle)) * 0.4;
        float r = length(p - center);
        float edge = smoothstep(0.02, 0.0, abs(r - discSize * pulseAmt));
        col = mix(col, float3(0.0), edge);
    }
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle2 = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle2) + cross(k, col) * sin(angle2) + k * dot(k, col) * (1.0 - cos(angle2));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Fraser Spiral
let fraserSpiralCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param spiralTurns "Spiral Turns" range(2.0, 10.0) default(5.0)
// @param tileCount "Tile Count" range(8.0, 32.0) default(16.0)
// @param tiltAmount "Tilt Amount" range(0.0, 0.5) default(0.2)
// @param patternContrast "Pattern Contrast" range(0.5, 1.0) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.1)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle showSpiral "Show Spiral" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 darkCol = float3(color1R, color1G, color1B);
float3 lightCol = float3(color2R, color2G, color2B);

float r = length(p) * pulseAmt;
float a = atan2(p.y, p.x);

float spiral = r * spiralTurns - a / 6.28318 + timeVal;
float ring = floor(spiral);
float ringLocal = fract(spiral);

float tileAngle = a + ring * tiltAmount;
float tile = floor(tileAngle / (6.28318 / tileCount));

float checker = fmod(tile + ring, 2.0);
float pattern = mix(0.1, 0.9, checker) * patternContrast + (1.0 - patternContrast) * 0.5;

float3 col;
if (rainbow > 0.5) {
    float3 rainCol = 0.5 + 0.5 * cos(ring * 0.5 + timeVal + float3(0.0, 2.094, 4.188));
    col = mix(darkCol, rainCol, pattern);
} else {
    col = mix(darkCol, lightCol, pattern);
}

if (neon > 0.5) col = pow(col, float3(0.5)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.35);

if (showSpiral > 0.5) {
    float spiralLine = smoothstep(0.02, 0.01, abs(ringLocal - 0.5));
    col = mix(col, float3(1.0, 0.0, 0.0), spiralLine * 0.5);
}

if (showEdges > 0.5) {
    float tileLocal = fract(tileAngle / (6.28318 / tileCount));
    float edge = smoothstep(0.05, 0.0, min(tileLocal, 1.0 - tileLocal));
    col = mix(col, float3(0.5), edge * 0.3);
}

if (glow > 0.5) {
    col += exp(-r * 3.0) * glowIntensity * lightCol;
}

if (gradient > 0.5) col *= 1.0 + r * 0.2;
if (radial > 0.5) col *= smoothstep(1.0, 0.9, r);

if (outline > 0.5) {
    float spiralLine = smoothstep(0.02, 0.01, abs(ringLocal - 0.5));
    col = mix(col, float3(0.0), spiralLine);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle2 = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle2) + cross(k, col) * sin(angle2) + k * dot(k, col) * (1.0 - cos(angle2));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

/// Droste Effect
let drosteEffectCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.2)
// @param zoomFactor "Zoom Factor" range(1.5, 4.0) default(2.5)
// @param spiralAmount "Spiral Amount" range(0.0, 2.0) default(0.5)
// @param iterations "Iterations" range(1.0, 5.0) default(3.0)
// @param frameWidth "Frame Width" range(0.02, 0.1) default(0.05)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 32.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.25)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.88)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.85)
// @toggle animated "Animated" default(true)
// @toggle colorTint "Color Tint" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = (uv - 0.5 - ctr * 0.5) * 2.0;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (pixelate > 0.5) p = floor(p * pixelSize) / pixelSize;
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 frameCol = float3(color1R, color1G, color1B);
float3 bgCol = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);

float logR = log(r + 0.001);
float spiral = spiralAmount * a / 6.28318;
float zoomVal = fract(logR / log(zoomFactor) + spiral - timeVal);

float3 col = bgCol;

int iters = int(iterations);
for (int i = 0; i < 5; i++) {
    if (i >= iters) break;
    float fi = float(i);
    float scale = pow(zoomFactor, zoomVal + fi) * pulseAmt;
    float2 sp = p / scale;
    float frame = max(abs(sp.x), abs(sp.y));
    float frameMask = smoothstep(0.8 + frameWidth, 0.8, frame) - smoothstep(0.8 - frameWidth, 0.8 - frameWidth * 2.0, frame);
    
    float3 thisFrameCol;
    if (rainbow > 0.5) {
        thisFrameCol = 0.5 + 0.5 * cos(fi * 1.5 + timeVal + float3(0.0, 2.094, 4.188));
    } else if (colorTint > 0.5) {
        float3 tint = 0.5 + 0.5 * cos(fi * 1.5 + float3(0.0, 2.0, 4.0));
        thisFrameCol = mix(frameCol, tint, 0.3);
    } else {
        thisFrameCol = frameCol;
    }
    
    if (neon > 0.5) thisFrameCol = pow(thisFrameCol, float3(0.5)) * 1.5;
    if (pastel > 0.5) thisFrameCol = mix(thisFrameCol, float3(1.0), 0.35);
    
    col = mix(col, thisFrameCol, frameMask);
    
    if (showEdges > 0.5) {
        float edge = smoothstep(0.02, 0.0, abs(frame - 0.8));
        col = mix(col, float3(1.0), edge * 0.5);
    }
    
    if (glow > 0.5) {
        float glowMask = exp(-abs(frame - 0.8) * 30.0) * glowIntensity;
        col += glowMask * thisFrameCol;
    }
    
    float inner = smoothstep(0.8 - frameWidth * 2.0, 0.7, frame);
    col = mix(col, col * 0.95, inner);
}

if (gradient > 0.5) col *= 1.0 - r * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

if (outline > 0.5) {
    float frame0 = max(abs(p.x), abs(p.y));
    float edge = smoothstep(0.02, 0.0, abs(frame0 - 0.8));
    col = mix(col, float3(0.0), edge);
}

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}
if (chromatic > 0.5) {
    float shift = chromaticAmount * 0.01;
    col.r = col.r + shift;
    col.b = col.b - shift;
}
if (scanlines > 0.5) {
    float scan = sin(uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * scan * 0.3;
}
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) {
    col.rgb = col.gbr;
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle2 = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle2) + cross(k, col) * sin(angle2) + k * dot(k, col) * (1.0 - cos(angle2));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.0, 1.0, col);
}

return float4(col, masterOpacity);
"""

