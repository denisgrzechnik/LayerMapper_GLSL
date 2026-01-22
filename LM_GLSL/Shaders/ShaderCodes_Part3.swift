//
//  ShaderCodes_Part3.swift
//  LM_GLSL
//
//  Shader codes - Part 3: Cosmic, Organic, WaterLiquid, FireEnergy
//

import Foundation

// MARK: - Cosmic Category

let galaxyCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param spiralArms "Spiral Arms" range(1.0, 8.0) default(3.0)
// @param spiralTightness "Spiral Tightness" range(5.0, 20.0) default(10.0)
// @param starDensity "Star Density" range(100.0, 400.0) default(200.0)
// @param starThreshold "Star Threshold" range(0.95, 0.99) default(0.98)
// @param coreSize "Core Size" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param nebulaIntensity "Nebula Intensity" range(0.0, 1.0) default(0.5)
// @param dustAmount "Dust Amount" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.5)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.2)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.8)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showStars "Show Stars" default(true)
// @toggle showNebula "Show Nebula" default(true)
// @toggle showCore "Show Core" default(true)
// @toggle radial "Radial" default(true)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle twinkle "Twinkle" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.1;
}

float r = length(p);
float a = atan2(p.y, p.x);

// Spiral pattern
float spiral = sin(a * spiralArms + r * spiralTightness - timeVal);

// Stars
float3 col = float3(0.0);
if (showStars > 0.5) {
    float starField = fract(sin(dot(floor(uv * starDensity), float2(12.9898, 78.233))) * 43758.5453);
    float stars = step(starThreshold, starField);
    
    // Twinkle effect
    if (twinkle > 0.5) {
        float twinkleVal = 0.5 + 0.5 * sin(timeVal * 5.0 + starField * 100.0);
        stars *= twinkleVal;
    }
    col += stars * float3(1.0);
}

// Nebula/spiral
if (showNebula > 0.5) {
    float3 nebulaCol = spiral * float3(redAmount, greenAmount, blueAmount) * (1.0 - r * 0.5);
    nebulaCol *= nebulaIntensity;
    col += nebulaCol;
}

// Core glow
if (showCore > 0.5) {
    float core = smoothstep(coreSize, 0.0, r);
    col += core * float3(1.0, 0.9, 0.7) * 0.5;
}

// Dust lanes
if (dustAmount > 0.0) {
    float dust = fract(sin(dot(p * 10.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col *= 1.0 - dust * dustAmount * 0.3;
}

// Background color
col += float3(0.1, 0.0, 0.2) * (1.0 - r * 0.5);

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.5 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let starfieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param starLayers "Star Layers" range(1.0, 5.0) default(3.0)
// @param baseDensity "Base Density" range(20.0, 100.0) default(50.0)
// @param starThreshold "Star Threshold" range(0.95, 0.99) default(0.98)
// @param twinkleSpeed "Twinkle Speed" range(1.0, 10.0) default(5.0)
// @param depthEffect "Depth Effect" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.5)
// @param nebulaAmount "Nebula Amount" range(0.0, 1.0) default(0.0)
// @param shootingStars "Shooting Stars" range(0.0, 1.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle parallax "Parallax" default(true)
// @toggle twinkle "Twinkle" default(true)
// @toggle coloredStars "Colored Stars" default(false)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle nebula "Nebula" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
p += center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.05;
}

float3 col = float3(0.0);

// Multi-layer starfield
int layers = int(starLayers);
for (int i = 0; i < 5; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float layerDensity = baseDensity + fi * baseDensity;
    
    float2 sp = p * layerDensity;
    
    // Parallax motion
    if (parallax > 0.5) {
        sp += float2(timeVal * (1.0 + fi * 0.5 * morphSpeed), timeVal * 0.3 * morphSpeed);
    }
    
    float starVal = fract(sin(dot(floor(sp), float2(12.9898, 78.233))) * 43758.5453);
    float star = step(starThreshold, starVal);
    
    // Twinkle
    float twinkleVal = 1.0;
    if (twinkle > 0.5) {
        twinkleVal = 0.5 + 0.5 * sin(timeVal * twinkleSpeed + fi * 2.0 + starVal * 10.0);
    }
    
    // Depth fade
    float depthFade = 1.0 - fi * 0.2 * depthEffect;
    
    // Star color
    float3 starColor = float3(1.0);
    if (coloredStars > 0.5) {
        starColor = 0.7 + 0.3 * cos(float3(0.0, 2.0, 4.0) + starVal * 6.28 + hueShift * 6.28);
    }
    
    col += star * twinkleVal * depthFade * starColor;
}

col *= float3(redAmount, greenAmount, blueAmount);

// Nebula background
if (nebula > 0.5 && nebulaAmount > 0.0) {
    float n = sin(p.x * 5.0 + timeVal * 0.2) * sin(p.y * 5.0 + timeVal * 0.3);
    col += n * nebulaAmount * 0.2 * float3(0.2, 0.1, 0.3);
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.5);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.05;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let nebulaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param cloudScale "Cloud Scale" range(1.0, 5.0) default(3.0)
// @param cloudLayers "Cloud Layers" range(2.0, 8.0) default(5.0)
// @param starDensity "Star Density" range(100.0, 500.0) default(300.0)
// @param starThreshold "Star Threshold" range(0.98, 0.999) default(0.99)
// @param turbulence "Turbulence" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(0.8)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param dustOpacity "Dust Opacity" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showStars "Show Stars" default(true)
// @toggle showClouds "Show Clouds" default(true)
// @toggle showDust "Show Dust" default(true)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle twinkle "Twinkle" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * cloudScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.2;
}

float3 col = float3(0.0);

// Nebula clouds
if (showClouds > 0.5) {
    float n = 0.0;
    int layers = int(cloudLayers);
    for (int i = 0; i < 8; i++) {
        if (i >= layers) break;
        float fi = float(i);
        float2 q = p + float2(sin(timeVal * 0.1 * morphSpeed + fi), cos(timeVal * 0.15 * morphSpeed + fi));
        float wave = sin(q.x * 2.0 * turbulence + q.y * 2.0 * turbulence + timeVal * 0.5 + fi);
        n += wave * (1.0 / (fi + 1.0));
    }
    
    col = 0.5 + 0.5 * cos(n + float3(0.0, 2.0, 4.0) + hueShift * 6.28);
    col *= 0.8 * colorMix;
}

col *= float3(redAmount, greenAmount, blueAmount);

// Dust lanes
if (showDust > 0.5 && dustOpacity > 0.0) {
    float dust = fract(sin(dot(p * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col *= 1.0 - dust * dustOpacity * 0.3;
}

// Stars
if (showStars > 0.5) {
    float starVal = fract(sin(dot(floor(uv * starDensity), float2(12.9898, 78.233))) * 43758.5453);
    float stars = step(starThreshold, starVal);
    
    if (twinkle > 0.5) {
        stars *= 0.5 + 0.5 * sin(timeVal * 5.0 + starVal * 100.0);
    }
    col += stars;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let blackHoleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param eventHorizon "Event Horizon" range(0.1, 0.4) default(0.2)
// @param accretionInner "Accretion Inner" range(0.2, 0.5) default(0.3)
// @param accretionOuter "Accretion Outer" range(0.5, 1.0) default(0.8)
// @param diskSpeed "Disk Speed" range(1.0, 10.0) default(5.0)
// @param gravityDistort "Gravity Distort" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param diskBands "Disk Bands" range(5.0, 20.0) default(10.0)
// @param glowFalloff "Glow Falloff" range(0.1, 0.5) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.02)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.5)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.2)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showDisk "Show Disk" default(true)
// @toggle showHorizon "Show Horizon" default(true)
// @toggle showJets "Show Jets" default(false)
// @toggle radial "Radial" default(true)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle lensing "Lensing" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

float r = length(p);
float a = atan2(p.y, p.x);

// Gravitational lensing distortion
if (lensing > 0.5) {
    float distortAmount = 1.0 / (r + 0.1) * gravityDistort;
    a += distortAmount * 0.5 + timeVal;
}

float3 col = float3(0.0);

// Accretion disk
if (showDisk > 0.5) {
    float disk = smoothstep(accretionInner, accretionInner + 0.1, r) * smoothstep(accretionOuter, accretionOuter - 0.3, r);
    float diskPattern = 0.5 + 0.5 * sin(a * diskBands - timeVal * diskSpeed);
    disk *= diskPattern;
    
    // Disk color gradient
    float3 diskColor = mix(float3(1.0, 1.0, 0.5), float3(redAmount, greenAmount, blueAmount), r);
    col += disk * diskColor;
}

// Event horizon (black center)
if (showHorizon > 0.5) {
    float horizon = 1.0 - smoothstep(0.0, eventHorizon, r);
    col *= 1.0 - horizon;
    
    // Glow around horizon
    float horizonGlow = smoothstep(eventHorizon + glowFalloff, eventHorizon, r) * (1.0 - horizon);
    col += horizonGlow * glowIntensity * 0.5;
}

// Relativistic jets
if (showJets > 0.5) {
    float jetWidth = 0.1;
    float jet1 = smoothstep(jetWidth, 0.0, abs(p.x)) * step(p.y, 0.0) * smoothstep(-1.0, -0.2, p.y);
    float jet2 = smoothstep(jetWidth, 0.0, abs(p.x)) * step(0.0, p.y) * smoothstep(1.0, 0.2, p.y);
    col += (jet1 + jet2) * float3(0.5, 0.7, 1.0) * 0.5;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.5 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * (1.0 - r);
    col.b *= 1.0 - chromaticAmount * 5.0 * (1.0 - r);
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let cosmicDustCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param dustScale "Dust Scale" range(2.0, 8.0) default(4.0)
// @param dustLayers "Dust Layers" range(2.0, 6.0) default(4.0)
// @param dustDensity "Dust Density" range(0.3, 0.8) default(0.5)
// @param starDensity "Star Density" range(200.0, 600.0) default(400.0)
// @param starThreshold "Star Threshold" range(0.99, 0.999) default(0.995)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param dustOpacity "Dust Opacity" range(0.1, 0.5) default(0.2)
// @param driftSpeed "Drift Speed" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showDust "Show Dust" default(true)
// @toggle showStars "Show Stars" default(true)
// @toggle coloredDust "Colored Dust" default(true)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle twinkle "Twinkle" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * dustScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.2;
}

float3 col = float3(0.0);

// Cosmic dust layers
if (showDust > 0.5) {
    int layers = int(dustLayers);
    for (int i = 0; i < 6; i++) {
        if (i >= layers) break;
        float fi = float(i);
        
        float2 q = p + float2(sin(timeVal * driftSpeed * 0.2 + fi * 2.0), cos(timeVal * driftSpeed * 0.3 + fi * 1.5));
        float dust = fract(sin(dot(floor(q * noiseScale), float2(12.9898, 78.233))) * 43758.5453);
        dust = smoothstep(dustDensity, 1.0, dust);
        
        float3 dustColor = float3(dustOpacity);
        if (coloredDust > 0.5) {
            dustColor = dustOpacity * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + hueShift * 6.28));
        }
        
        col += dust * dustColor;
    }
}

col *= float3(redAmount, greenAmount, blueAmount);

// Stars
if (showStars > 0.5) {
    float starVal = fract(sin(dot(floor(uv * starDensity), float2(12.9898, 78.233))) * 43758.5453);
    float stars = step(starThreshold, starVal);
    
    if (twinkle > 0.5) {
        stars *= 0.5 + 0.5 * sin(timeVal * 5.0 + starVal * 100.0);
    }
    col += stars;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

// MARK: - Organic Category

let cellsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param cellScale "Cell Scale" range(4.0, 16.0) default(8.0)
// @param cellCount "Cell Count" range(10.0, 40.0) default(20.0)
// @param cellMovement "Cell Movement" range(0.0, 1.0) default(0.3)
// @param wallThickness "Wall Thickness" range(0.0, 0.3) default(0.1)
// @param nucleusSize "Nucleus Size" range(0.0, 0.3) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.5)
// @param membraneGlow "Membrane Glow" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showWalls "Show Walls" default(true)
// @toggle showNucleus "Show Nucleus" default(true)
// @toggle coloredCells "Colored Cells" default(true)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle mitosis "Mitosis" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * cellScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 10.0 / pxSize) * pxSize / 10.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 2.0 + timeVal), cos(p.x * 2.0 + timeVal)) * distortion * 0.5;
}

float3 col = float3(0.0);
float minDist = 10.0;
float secondMinDist = 10.0;
int closestCell = 0;

// Voronoi cells
int cells = int(cellCount);
for (int i = 0; i < 40; i++) {
    if (i >= cells) break;
    float fi = float(i);
    
    // Cell center
    float2 cellCenter = float2(
        fract(sin(fi * 12.9898) * 43758.5453) * cellScale,
        fract(sin(fi * 78.233) * 43758.5453) * cellScale
    );
    
    // Cell movement
    cellCenter += float2(sin(timeVal * morphSpeed + fi), cos(timeVal * morphSpeed * 0.7 + fi)) * cellMovement;
    
    float d = length(p - cellCenter);
    if (d < minDist) {
        secondMinDist = minDist;
        minDist = d;
        closestCell = i;
    } else if (d < secondMinDist) {
        secondMinDist = d;
    }
}

// Cell walls
float wall = secondMinDist - minDist;
float wallLine = smoothstep(wallThickness, 0.0, wall) * 0.5;

if (showWalls > 0.5) {
    col += wallLine * membraneGlow;
}

// Cell interior color
float3 cellColor = 0.5 + 0.5 * cos(minDist * 2.0 + float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28);
if (coloredCells > 0.5) {
    cellColor *= colorVariation + (1.0 - colorVariation) * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + float(closestCell)));
}

col += cellColor * smoothstep(0.0, wallThickness + 0.2, wall);

// Nucleus
if (showNucleus > 0.5) {
    float nucleus = smoothstep(nucleusSize, nucleusSize * 0.5, minDist);
    col = mix(col, float3(0.8, 0.6, 0.9), nucleus);
}

col *= float3(redAmount, greenAmount, blueAmount);

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let veinsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param veinScale "Vein Scale" range(2.0, 10.0) default(5.0)
// @param veinLayers "Vein Layers" range(2.0, 8.0) default(5.0)
// @param veinThickness "Vein Thickness" range(0.1, 0.5) default(0.3)
// @param veinIntensity "Vein Intensity" range(0.0, 1.0) default(0.7)
// @param bloodFlow "Blood Flow" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param tissueOpacity "Tissue Opacity" range(0.0, 0.5) default(0.1)
// @param pulseRate "Pulse Rate" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.8)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.1)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.1)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showFlow "Show Flow" default(true)
// @toggle showTissue "Show Tissue" default(true)
// @toggle arterial "Arterial" default(true)
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
// @toggle branching "Branching" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * veinScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 10.0 / pxSize) * pxSize / 10.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 3.0 + timeVal), cos(p.x * 3.0 + timeVal)) * distortion * 0.3;
}

// Vein pattern
float n = 0.0;
float amp = 1.0;
int layers = int(veinLayers);
for (int i = 0; i < 8; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float2 q = p * (fi + 1.0);
    float wave = abs(sin(q.x + sin(q.y + timeVal * morphSpeed)));
    
    if (branching > 0.5) {
        wave *= abs(sin(q.y * 0.5 + q.x * 0.3));
    }
    
    n += amp * wave;
    amp *= 0.5;
}

// Vein visibility
float vein = smoothstep(veinThickness, 0.0, abs(n - 0.5)) * veinIntensity;

// Blood flow animation
if (showFlow > 0.5) {
    float flow = sin(n * 10.0 + timeVal * pulseRate * 5.0) * 0.5 + 0.5;
    vein *= 0.7 + 0.3 * flow * bloodFlow;
}

// Base tissue color
float3 tissueColor = float3(0.2, 0.0, 0.0);
if (showTissue > 0.5) {
    tissueColor += tissueOpacity * float3(0.5, 0.0, 0.0);
}

// Vein color
float3 veinColor = float3(redAmount, greenAmount, blueAmount);
if (arterial > 0.5) {
    veinColor = float3(0.8, 0.1, 0.1);
} else {
    veinColor = float3(0.3, 0.1, 0.4); // Venous (blue)
}

float3 col = mix(tissueColor, veinColor, vein);

// Pulse effect
if (pulse > 0.5) {
    float heartbeat = pow(sin(timeVal * pulseRate * 3.14159) * 0.5 + 0.5, 4.0);
    col *= 0.8 + 0.2 * heartbeat;
}

// Glow
if (glow > 0.5) {
    col += vein * glowIntensity * 0.3 * veinColor;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float noiseVal = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * 0.1;
}

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let bacteriaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param petriScale "Petri Scale" range(5.0, 20.0) default(10.0)
// @param bacteriaCount "Bacteria Count" range(5.0, 30.0) default(15.0)
// @param bacteriaSize "Bacteria Size" range(0.2, 0.6) default(0.4)
// @param movementSpeed "Movement Speed" range(0.0, 1.0) default(0.5)
// @param colorVariety "Color Variety" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param agarOpacity "Agar Opacity" range(0.0, 0.3) default(0.1)
// @param colonyGlow "Colony Glow" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showAgar "Show Agar" default(true)
// @toggle coloredColonies "Colored Colonies" default(true)
// @toggle dividing "Dividing" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle flagella "Flagella" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * petriScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 10.0 / pxSize) * pxSize / 10.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 2.0 + timeVal), cos(p.x * 2.0 + timeVal)) * distortion * 0.5;
}

// Agar background
float3 col = float3(0.1, 0.15, 0.1);
if (showAgar > 0.5) {
    col += agarOpacity * float3(0.0, 0.1, 0.05);
}

// Bacteria colonies
int bacteria = int(bacteriaCount);
for (int i = 0; i < 30; i++) {
    if (i >= bacteria) break;
    float fi = float(i);
    
    // Colony position
    float2 colonyCenter = float2(
        fract(sin(fi * 12.9898) * 43758.5453) * petriScale,
        fract(sin(fi * 78.233) * 43758.5453) * petriScale
    );
    
    // Movement
    colonyCenter += float2(
        sin(timeVal * movementSpeed * 0.5 + fi * 2.0),
        cos(timeVal * movementSpeed * 0.3 + fi * 3.0)
    ) * 0.5;
    
    float d = length(p - colonyCenter);
    float bacteriaShape = smoothstep(bacteriaSize, bacteriaSize - 0.1, d);
    
    // Colony color
    float3 bcol = float3(0.5, 0.7, 0.5);
    if (coloredColonies > 0.5) {
        bcol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * colorVariety + hueShift * 6.28);
    }
    
    col += bacteriaShape * bcol * colonyGlow;
    
    // Flagella
    if (flagella > 0.5) {
        float2 toCenter = normalize(p - colonyCenter);
        float flagellaWave = sin(d * 20.0 - timeVal * 5.0 + fi) * 0.02;
        float flagellaLine = smoothstep(0.02, 0.0, abs(dot(toCenter, float2(1.0, 0.0)) - flagellaWave));
        flagellaLine *= step(bacteriaSize, d) * step(d, bacteriaSize + 0.3);
        col += flagellaLine * 0.3;
    }
}

col *= float3(redAmount, greenAmount, blueAmount);

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let leafVeinsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param leafScale "Leaf Scale" range(1.0, 3.0) default(2.0)
// @param mainVeinWidth "Main Vein Width" range(0.01, 0.05) default(0.02)
// @param branchCount "Branch Count" range(3.0, 10.0) default(5.0)
// @param branchSpacing "Branch Spacing" range(0.1, 0.3) default(0.15)
// @param branchAngle "Branch Angle" range(0.3, 0.8) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param leafGreen "Leaf Green" range(0.3, 0.8) default(0.5)
// @param veinGreen "Vein Green" range(0.0, 0.5) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.2)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.5)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.2)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle showBranches "Show Branches" default(true)
// @toggle showMainVein "Show Main Vein" default(true)
// @toggle autumnColors "Autumn Colors" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
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
// @toggle secondaryVeins "Secondary Veins" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * leafScale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.1;
}

// Base leaf color
float3 col = float3(redAmount, leafGreen, blueAmount);
if (autumnColors > 0.5) {
    col = mix(float3(0.8, 0.4, 0.1), float3(0.6, 0.2, 0.0), p.y + 0.5);
}

// Main vein
float mainVein = 0.0;
if (showMainVein > 0.5) {
    mainVein = smoothstep(mainVeinWidth, 0.0, abs(p.x));
    col += mainVein * float3(0.0, veinGreen, 0.0);
}

// Branch veins
if (showBranches > 0.5) {
    int branches = int(branchCount);
    for (int i = 1; i <= 10; i++) {
        if (i > branches) break;
        float fi = float(i);
        float y = fi * branchSpacing - 0.3;
        
        // Right branch
        float branchR = smoothstep(0.015, 0.0, abs(p.y - y - p.x * branchAngle));
        branchR *= step(0.0, p.x) * step(p.x, 0.5);
        col += branchR * float3(0.0, veinGreen * 0.8, 0.0);
        
        // Left branch (mirrored)
        if (mirror > 0.5) {
            float branchL = smoothstep(0.015, 0.0, abs(p.y - y + p.x * branchAngle));
            branchL *= step(p.x, 0.0) * step(-0.5, p.x);
            col += branchL * float3(0.0, veinGreen * 0.8, 0.0);
        }
        
        // Secondary veins
        if (secondaryVeins > 0.5) {
            for (int j = 1; j <= 3; j++) {
                float fj = float(j);
                float subY = y + fj * 0.03;
                float subBranch = smoothstep(0.008, 0.0, abs(p.y - subY - p.x * branchAngle * 0.7));
                subBranch *= step(0.0, p.x) * step(p.x, 0.3);
                col += subBranch * float3(0.0, veinGreen * 0.5, 0.0) * 0.5;
            }
        }
    }
}

// Pulse (breathing leaf)
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * morphSpeed);
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let coralCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.1)
// @param coralScale "Coral Scale" range(2.0, 6.0) default(4.0)
// @param branchIterations "Branch Iterations" range(4.0, 12.0) default(8.0)
// @param branchSpread "Branch Spread" range(0.3, 1.0) default(0.7)
// @param branchThickness "Branch Thickness" range(0.05, 0.2) default(0.1)
// @param growthRate "Growth Rate" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param waterColor "Water Color" range(0.0, 1.0) default(0.4)
// @param coralGlow "Coral Glow" range(0.0, 0.5) default(0.1)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.5)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.7)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle coloredBranches "Colored Branches" default(true)
// @toggle showWater "Show Water" default(true)
// @toggle bioluminescent "Bioluminescent" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle polyps "Polyps" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * coralScale - (coralScale * 0.5 - 1.0);

// Rotation
float baseRotation = rotation;
float cosR = cos(baseRotation); float sinR = sin(baseRotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 3.0 + timeVal), cos(p.x * 3.0 + timeVal)) * distortion * 0.2;
}

// Water background
float3 col = float3(0.1, 0.2, waterColor);
if (showWater > 0.5) {
    float caustics = sin(p.x * 10.0 + timeVal) * sin(p.y * 10.0 + timeVal * 1.3) * 0.1;
    col += caustics * float3(0.1, 0.2, 0.3);
}

// Fractal coral branches
int iterations = int(branchIterations);
for (int i = 0; i < 12; i++) {
    if (i >= iterations) break;
    float fi = float(i);
    
    p = abs(p) - branchSpread;
    
    float a = timeVal * growthRate * morphSpeed + fi * 0.5;
    float c = cos(a); float s = sin(a);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    
    float branch = smoothstep(branchThickness, 0.0, min(abs(p.x), abs(p.y)));
    
    float3 branchColor = float3(redAmount, greenAmount, blueAmount);
    if (coloredBranches > 0.5) {
        branchColor = 0.5 + 0.5 * cos(float3(0.0, 1.0, 2.0) + fi + hueShift * 6.28);
    }
    
    col += branch * coralGlow * branchColor;
    
    // Bioluminescence
    if (bioluminescent > 0.5) {
        float glow = branch * (0.5 + 0.5 * sin(timeVal * 3.0 + fi));
        col += glow * 0.2 * float3(0.2, 0.8, 1.0);
    }
}

// Polyps
if (polyps > 0.5) {
    float polyp = sin(p.x * 30.0) * sin(p.y * 30.0) * 0.05;
    col += polyp * float3(1.0, 0.5, 0.5);
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

// MARK: - WaterLiquid Category

let raindropsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param dropCount "Drop Count" range(5.0, 20.0) default(10.0)
// @param rippleFrequency "Ripple Frequency" range(20.0, 80.0) default(50.0)
// @param rippleSpeed "Ripple Speed" range(2.0, 10.0) default(5.0)
// @param rippleDecay "Ripple Decay" range(5.0, 20.0) default(10.0)
// @param fallSpeed "Fall Speed" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param waterDepth "Water Depth" range(0.0, 1.0) default(0.5)
// @param rippleIntensity "Ripple Intensity" range(0.1, 0.5) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.1)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.2)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.3)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showRipples "Show Ripples" default(true)
// @toggle showReflections "Show Reflections" default(false)
// @toggle randomDrops "Random Drops" default(true)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle splash "Splash" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.02;
}

// Water base color
float3 col = float3(redAmount, greenAmount, blueAmount) * waterDepth;

// Raindrops and ripples
if (showRipples > 0.5) {
    int drops = int(dropCount);
    for (int i = 0; i < 20; i++) {
        if (i >= drops) break;
        float fi = float(i);
        
        // Drop position
        float2 dropPos = float2(
            fract(sin(fi * 12.9898) * 43758.5453),
            fract(fract(sin(fi * 78.233) * 43758.5453) + timeVal * fallSpeed * (0.5 + fi * 0.05))
        );
        
        if (randomDrops > 0.5) {
            dropPos.x = fract(dropPos.x + sin(fi * 3.0) * 0.3);
        }
        
        float d = length(p - dropPos);
        
        // Ripple wave
        float ripple = sin(d * rippleFrequency - timeVal * rippleSpeed);
        ripple *= exp(-d * rippleDecay);
        
        col += ripple * rippleIntensity * float3(0.3, 0.5, 0.8);
        
        // Splash effect
        if (splash > 0.5) {
            float splashTime = fract(timeVal * fallSpeed + fi * 0.1);
            float splashRing = smoothstep(0.02, 0.0, abs(d - splashTime * 0.3));
            splashRing *= 1.0 - splashTime;
            col += splashRing * 0.3;
        }
    }
}

// Reflections
if (showReflections > 0.5) {
    float reflection = 0.5 + 0.5 * sin(p.y * 20.0 + timeVal);
    col += reflection * 0.1 * float3(0.8, 0.9, 1.0);
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let underwaterCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(5.0, 20.0) default(10.0)
// @param waveAmplitude "Wave Amplitude" range(0.01, 0.05) default(0.02)
// @param causticScale "Caustic Scale" range(10.0, 40.0) default(20.0)
// @param causticSpeed "Caustic Speed" range(0.5, 2.0) default(1.3)
// @param causticIntensity "Caustic Intensity" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @param turbidity "Turbidity" range(0.0, 0.5) default(0.1)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.3)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.5)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCaustics "Show Caustics" default(true)
// @toggle showWaves "Show Waves" default(true)
// @toggle showParticles "Show Particles" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle bubbles "Bubbles" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Water distortion waves
if (showWaves > 0.5) {
    p.x += sin(p.y * waveFrequency + timeVal) * waveAmplitude;
    p.y += cos(p.x * waveFrequency + timeVal) * waveAmplitude;
}

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Base underwater color with depth gradient
float3 col = float3(redAmount, greenAmount, blueAmount);
col *= depthFade + (1.0 - depthFade) * (1.0 - p.y);

// Caustics
if (showCaustics > 0.5) {
    float caustic = sin(p.x * causticScale + timeVal) * sin(p.y * causticScale + timeVal * causticSpeed);
    caustic = pow(abs(caustic), 0.5);
    col += caustic * causticIntensity * float3(0.2, 0.4, 0.3);
}

// Floating particles
if (showParticles > 0.5) {
    for (int i = 0; i < 10; i++) {
        float fi = float(i);
        float2 particlePos = float2(
            fract(sin(fi * 12.9898) * 43758.5453),
            fract(sin(fi * 78.233) * 43758.5453 + timeVal * 0.1)
        );
        float d = length(p - particlePos);
        float particle = smoothstep(0.01, 0.005, d);
        col += particle * 0.3;
    }
}

// Bubbles
if (bubbles > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float2 bubblePos = float2(
            fract(sin(fi * 45.233) * 43758.5453),
            fract(timeVal * 0.3 + fi * 0.2)
        );
        float d = length(p - bubblePos);
        float bubble = smoothstep(0.03, 0.02, d);
        float highlight = smoothstep(0.015, 0.01, length(p - bubblePos - 0.005));
        col += bubble * float3(0.2, 0.3, 0.4) + highlight * 0.3;
    }
}

// Turbidity (murkiness)
if (turbidity > 0.0) {
    float turb = fract(sin(dot(p * 10.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col = mix(col, col + turb * 0.2, turbidity);
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let bubbleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param bubbleCount "Bubble Count" range(3.0, 15.0) default(8.0)
// @param bubbleSize "Bubble Size" range(0.05, 0.2) default(0.1)
// @param bubbleSizeVariation "Size Variation" range(0.0, 0.1) default(0.05)
// @param riseSpeed "Rise Speed" range(0.1, 0.5) default(0.2)
// @param swayAmount "Sway Amount" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param highlightSize "Highlight Size" range(0.3, 0.8) default(0.5)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightOffset "Highlight Offset" range(0.0, 0.1) default(0.02)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.1)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.2)
// @param bgBlue "BG Blue" range(0.0, 1.0) default(0.4)
// @param bubbleRed "Bubble Red" range(0.0, 1.0) default(0.2)
// @param bubbleGreen "Bubble Green" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showHighlights "Show Highlights" default(true)
// @toggle showReflections "Show Reflections" default(true)
// @toggle showRim "Show Rim" default(true)
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
// @toggle wobble "Wobble" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Convert to centered coordinates
float2 pc = p * 2.0 - 1.0;

// Background
float3 col = float3(bgRed, bgGreen, bgBlue);
float3 bubbleColor = float3(bubbleRed, bubbleGreen, 0.4);

// Bubbles
int numBubbles = int(bubbleCount);
for (int i = 0; i < 15; i++) {
    if (i >= numBubbles) break;
    float fi = float(i);
    
    // Bubble position with sway and rise
    float2 bubbleCenter = float2(
        sin(fi * 2.3 + timeVal) * swayAmount,
        fract(fi * 0.3 - timeVal * riseSpeed) * 2.0 - 1.0
    );
    
    // Wobble effect
    if (wobble > 0.5) {
        bubbleCenter.x += sin(timeVal * 3.0 + fi) * 0.02;
    }
    
    float r = bubbleSize + bubbleSizeVariation * sin(fi);
    float d = length(pc - bubbleCenter);
    
    // Main bubble
    float bubble = smoothstep(r, r - 0.02, d);
    col += bubble * bubbleColor;
    
    // Rim/edge
    if (showRim > 0.5) {
        float rim = smoothstep(r - 0.01, r - 0.02, d) - smoothstep(r, r - 0.01, d);
        col += rim * 0.3;
    }
    
    // Highlight
    if (showHighlights > 0.5) {
        float2 highlightPos = bubbleCenter + float2(highlightOffset, highlightOffset);
        float highlight = smoothstep(r * highlightSize, r * (highlightSize - 0.2), length(pc - highlightPos));
        col += highlight * bubble * highlightIntensity;
    }
    
    // Reflection
    if (showReflections > 0.5) {
        float2 reflectPos = bubbleCenter - float2(highlightOffset * 0.5, highlightOffset * 0.5);
        float reflection = smoothstep(r * 0.3, r * 0.2, length(pc - reflectPos));
        col += reflection * bubble * 0.2;
    }
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let pondRippleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(3.0)
// @param rippleCount "Ripple Count" range(1.0, 8.0) default(3.0)
// @param rippleFrequency "Ripple Frequency" range(10.0, 50.0) default(30.0)
// @param rippleDecay "Ripple Decay" range(1.0, 5.0) default(3.0)
// @param rippleIntensity "Ripple Intensity" range(0.0, 0.5) default(0.15)
// @param centerSpread "Center Spread" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param waveSpeed "Wave Speed" range(0.0, 2.0) default(1.0)
// @param reflection "Reflection" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param waterRed "Water Red" range(0.0, 0.5) default(0.1)
// @param waterGreen "Water Green" range(0.0, 0.5) default(0.3)
// @param waterBlue "Water Blue" range(0.0, 1.0) default(0.4)
// @param rippleRed "Ripple Red" range(0.0, 1.0) default(0.3)
// @param rippleGreen "Ripple Green" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showRipples "Show Ripples" default(true)
// @toggle showReflection "Show Reflection" default(true)
// @toggle showLeaves "Show Leaves" default(false)
// @toggle radial "Radial" default(true)
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
// @toggle rain "Rain" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Convert to centered coordinates
float2 pc = p * 2.0 - 1.0;

// Water base color
float3 col = float3(waterRed, waterGreen, waterBlue);
float3 rippleColor = float3(rippleRed, rippleGreen, 0.6);

// Ripples
if (showRipples > 0.5) {
    int numRipples = int(rippleCount);
    for (int i = 0; i < 8; i++) {
        if (i >= numRipples) break;
        float fi = float(i);
        float2 rippleCenter = float2(sin(fi * 2.0) * centerSpread, cos(fi * 3.0) * centerSpread);
        float d = length(pc - rippleCenter);
        float ripple = sin(d * rippleFrequency - timeVal * waveSpeed - fi * 2.0);
        ripple *= exp(-d * rippleDecay);
        col += ripple * rippleIntensity * rippleColor;
    }
}

// Rain drops creating new ripples
if (rain > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float dropTime = fract(timeVal * 0.3 + fi * 0.2);
        float2 dropPos = float2(
            fract(sin(fi * 12.9898 + floor(timeVal * 0.3)) * 43758.5453) * 2.0 - 1.0,
            fract(sin(fi * 78.233 + floor(timeVal * 0.3)) * 43758.5453) * 2.0 - 1.0
        );
        float d = length(pc - dropPos);
        float ripple = sin(d * 40.0 - dropTime * 20.0);
        ripple *= exp(-d * 5.0) * (1.0 - dropTime);
        col += ripple * 0.1 * rippleColor;
    }
}

// Reflection
if (showReflection > 0.5) {
    float refl = 0.5 + 0.5 * sin(pc.x * 10.0 + timeVal * 0.5);
    col += refl * reflection * 0.1;
}

// Floating leaves
if (showLeaves > 0.5) {
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float2 leafPos = float2(
            sin(fi * 2.5 + timeVal * 0.2) * 0.5,
            cos(fi * 1.8 + timeVal * 0.15) * 0.5
        );
        float d = length(pc - leafPos);
        float leaf = smoothstep(0.05, 0.03, d);
        col = mix(col, float3(0.2, 0.4, 0.1), leaf);
    }
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let waterfallCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param flowRate "Flow Rate" range(1.0, 10.0) default(5.0)
// @param flowIntensity "Flow Intensity" range(0.0, 1.0) default(0.5)
// @param mistAmount "Mist Amount" range(0.0, 1.0) default(0.3)
// @param mistHeight "Mist Height" range(0.5, 1.0) default(0.7)
// @param noiseDetail "Noise Detail" range(10.0, 100.0) default(50.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param splashIntensity "Splash Intensity" range(0.0, 1.0) default(0.5)
// @param rockAmount "Rock Amount" range(0.0, 1.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.2)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 1.0) default(0.2)
// @param greenAmount "Green Amount" range(0.0, 1.0) default(0.4)
// @param blueAmount "Blue Amount" range(0.0, 1.0) default(0.6)
// @param foamWidth "Foam Width" range(0.0, 0.5) default(0.2)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.1) default(0.03)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showMist "Show Mist" default(true)
// @toggle showFoam "Show Foam" default(true)
// @toggle showRocks "Show Rocks" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle sparkle "Sparkle" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Water base color
float3 col = float3(redAmount, greenAmount, blueAmount);

// Flowing water effect
float flow = fract(p.y * flowRate - timeVal);
flow = pow(flow, 0.5) * flowIntensity;

// Water noise texture
float waterNoise = fract(sin(dot(floor(p * float2(noiseDetail, noiseDetail * 2.0) + timeVal * 10.0), float2(12.9898, 78.233))) * 43758.5453);
col += flow * waterNoise * float3(0.3, 0.4, 0.5);

// Wave motion across waterfall
float wave = sin(p.x * 20.0 + timeVal) * waveAmplitude;
col *= 0.7 + 0.3 * (sin(p.x * 20.0 + timeVal) + 1.0) * 0.5;

// Foam streaks
if (showFoam > 0.5) {
    float foam = fract(sin(dot(floor(p * float2(noiseDetail * 0.5, noiseDetail * 2.0) - timeVal * 5.0), float2(12.9898, 78.233))) * 43758.5453);
    foam = step(1.0 - foamWidth, foam);
    col += foam * float3(0.4, 0.45, 0.5);
}

// Mist at bottom
if (showMist > 0.5) {
    float mist = smoothstep(1.0, mistHeight, p.y) * mistAmount;
    col += mist * float3(1.0, 1.0, 1.0);
}

// Rocks
if (showRocks > 0.5) {
    float rock = step(0.8, fract(sin(dot(floor(p * 10.0), float2(12.9898, 78.233))) * 43758.5453));
    col = mix(col, float3(0.2, 0.15, 0.1), rock * rockAmount);
}

// Splash at bottom
if (splashIntensity > 0.0) {
    float splash = smoothstep(1.0, 0.9, p.y);
    splash *= fract(sin(dot(p * 50.0 + timeVal * 5.0, float2(12.9898, 78.233))) * 43758.5453);
    col += splash * splashIntensity * 0.5;
}

// Sparkles
if (sparkle > 0.5) {
    float sparkle = fract(sin(dot(floor(p * 80.0 * noiseScale), float2(12.9898, 78.233)) + timeVal * 2.0) * 43758.5453);
    sparkle = step(0.97, sparkle);
    col += sparkle * 0.4;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.05;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

// MARK: - FireEnergy Category

let plasmaFireCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param scale "Scale" range(1.0, 5.0) default(3.0)
// @param iterations "Iterations" range(1.0, 10.0) default(5.0)
// @param fireHeight "Fire Height" range(0.0, 1.0) default(0.5)
// @param plasmaIntensity "Plasma Intensity" range(0.0, 1.0) default(0.5)
// @param coreIntensity "Core Intensity" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param flameSpread "Flame Spread" range(0.1, 1.0) default(0.5)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param innerRed "Inner Red" range(0.0, 1.0) default(1.0)
// @param innerGreen "Inner Green" range(0.0, 1.0) default(1.0)
// @param innerBlue "Inner Blue" range(0.0, 1.0) default(0.0)
// @param outerRed "Outer Red" range(0.0, 1.0) default(1.0)
// @param outerGreen "Outer Green" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showPlasma "Show Plasma" default(true)
// @toggle showSparks "Show Sparks" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smoke "Smoke" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Plasma calculation
float2 pp = p * scale;
float n = 0.0;
int iters = int(iterations);
for (int i = 0; i < 10; i++) {
    if (i >= iters) break;
    float fi = float(i);
    n += sin(pp.x * (fi + 1.0) + timeVal * 2.0) * sin(pp.y * (fi + 1.0) - timeVal);
    if (turbulence > 0.0) {
        n += sin(pp.x * pp.y * 0.1 + timeVal * turbulence) * turbulence;
    }
}
n = n * 0.2 * plasmaIntensity + 0.5;

// Fire effect from bottom
float fire = pow(max(0.0, 1.0 - uv.y), 2.0 - fireHeight) * n * flameSpread * 2.0;

// Core
float3 innerColor = float3(innerRed, innerGreen, innerBlue);
float3 outerColor = float3(outerRed, outerGreen, 0.0);
float3 col = mix(outerColor, innerColor, fire);

if (showCore > 0.5) {
    col *= fire * coreIntensity * 2.0;
}

// Plasma waves
if (showPlasma > 0.5) {
    col += n * 0.2 * float3(1.0, 0.5, 0.1);
}

// Sparks
if (showSparks > 0.5) {
    float spark = fract(sin(dot(floor(p * 30.0 * noiseScale), float2(12.9898, 78.233)) + timeVal * 3.0) * 43758.5453);
    spark = step(0.98, spark) * (1.0 - uv.y);
    col += spark * float3(1.0, 0.8, 0.3);
}

// Smoke above fire
if (smoke > 0.5) {
    float smokeVal = smoothstep(0.3, 0.0, uv.y);
    float smokeNoise = fract(sin(dot(p * 10.0 + timeVal * 0.5, float2(12.9898, 78.233))) * 43758.5453);
    col += smokeVal * smokeNoise * 0.1;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float noise = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 5.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.85 + 0.15 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let lightningBoltCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param boltCount "Bolt Count" range(1.0, 10.0) default(3.0)
// @param boltWidth "Bolt Width" range(0.005, 0.05) default(0.02)
// @param boltSegments "Bolt Segments" range(5.0, 30.0) default(20.0)
// @param jitter "Jitter" range(0.0, 0.2) default(0.1)
// @param flashRate "Flash Rate" range(5.0, 30.0) default(10.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param glowRadius "Glow Radius" range(0.0, 0.1) default(0.03)
// @param branchChance "Branch Chance" range(0.0, 0.5) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param coreRed "Core Red" range(0.0, 1.0) default(0.8)
// @param coreGreen "Core Green" range(0.0, 1.0) default(0.9)
// @param coreBlue "Core Blue" range(0.0, 1.0) default(1.0)
// @param glowRed "Glow Red" range(0.0, 1.0) default(0.5)
// @param glowGreen "Glow Green" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle showCore "Show Core" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle showBranches "Show Branches" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle thunder "Thunder" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Background
float3 col = float3(0.02, 0.02, 0.05);

// Thunder flash
if (thunder > 0.5) {
    float flash = step(0.95, fract(sin(floor(timeVal * 2.0) * 43.758) * 43758.5453));
    col += flash * 0.3;
}

// Lightning bolts
float bolt = 0.0;
int numBolts = int(boltCount);
int segments = int(boltSegments);

for (int b = 0; b < 10; b++) {
    if (b >= numBolts) break;
    float fb = float(b);
    float x = 0.0;
    
    for (int i = 0; i < 30; i++) {
        if (i >= segments) break;
        float fi = float(i);
        float y = fi / boltSegments;
        x += (fract(sin(fi * 43.758 + floor(timeVal * flashRate) + fb * 100.0) * 43758.5453) - 0.5) * jitter;
        float d = abs(p.y - y) + abs(p.x - abs(x));
        bolt += smoothstep(boltWidth, 0.0, d);
        
        // Branches
        if (showBranches > 0.5 && fract(sin(fi * 123.456 + fb) * 43758.5453) < branchChance) {
            float bx = x;
            for (int j = 0; j < 5; j++) {
                float fj = float(j);
                bx += (fract(sin(fj * 78.233 + fi + fb) * 43758.5453) - 0.5) * jitter * 0.5;
                float by = y + fj * 0.02;
                float bd = abs(p.y - by) + abs(p.x - abs(bx));
                bolt += smoothstep(boltWidth * 0.5, 0.0, bd) * 0.5;
            }
        }
    }
}

// Core color
float3 coreColor = float3(coreRed, coreGreen, coreBlue);
float3 glowColor = float3(glowRed, glowGreen, 1.0);

if (showCore > 0.5) {
    col += bolt * coreColor;
}

// Glow around bolt
if (showGlow > 0.5) {
    col += bolt * bolt * glowColor * glowIntensity;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.7 + 0.3 * fract(sin(floor(timeVal * flashRate) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let solarFlareCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param sunSize "Sun Size" range(0.1, 0.5) default(0.3)
// @param coronaSize "Corona Size" range(0.3, 0.8) default(0.6)
// @param flareCount "Flare Count" range(3.0, 12.0) default(8.0)
// @param flareIntensity "Flare Intensity" range(0.0, 1.0) default(0.5)
// @param flarePower "Flare Power" range(1.0, 5.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param coronaGlow "Corona Glow" range(0.0, 1.0) default(0.5)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.4)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param sunRed "Sun Red" range(0.0, 1.0) default(1.0)
// @param sunGreen "Sun Green" range(0.0, 1.0) default(0.8)
// @param sunBlue "Sun Blue" range(0.0, 1.0) default(0.3)
// @param flareRed "Flare Red" range(0.0, 1.0) default(1.0)
// @param flareGreen "Flare Green" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showSun "Show Sun" default(true)
// @toggle showCorona "Show Corona" default(true)
// @toggle showFlares "Show Flares" default(true)
// @toggle radial "Radial" default(true)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle prominences "Prominences" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Convert to polar coordinates
float2 pc = p * 2.0 - 1.0;
float r = length(pc);
float a = atan2(pc.y, pc.x);

float3 col = float3(0.0);

// Sun core
float3 sunColor = float3(sunRed, sunGreen, sunBlue);
if (showSun > 0.5) {
    float sun = smoothstep(sunSize, sunSize - 0.02, r);
    col += sun * sunColor;
    
    // Surface turbulence
    if (turbulence > 0.0) {
        float turb = sin(a * 10.0 + r * 30.0 + timeVal * 2.0) * turbulence * 0.1;
        col += sun * turb * sunColor;
    }
}

// Corona
if (showCorona > 0.5) {
    float corona = smoothstep(coronaSize, sunSize, r) * coronaGlow;
    col += corona * float3(0.3, 0.1, 0.0);
}

// Solar flares
float3 flareColor = float3(flareRed, flareGreen, 0.1);
if (showFlares > 0.5) {
    int numFlares = int(flareCount);
    for (int i = 0; i < 12; i++) {
        if (i >= numFlares) break;
        float fi = float(i);
        float flare = sin(a * (fi + 3.0) + timeVal * (fi * 0.5 + 1.0));
        flare = pow(max(0.0, flare), flarePower);
        float flareMask = smoothstep(coronaSize, sunSize, r);
        col += flare * flareMask * flareIntensity * 0.15 * flareColor;
    }
}

// Prominences (arcs from sun surface)
if (prominences > 0.5) {
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float pa = fi * 1.57 + timeVal * 0.2;
        float2 prom = float2(cos(pa), sin(pa)) * (sunSize + 0.1);
        float d = length(pc - prom);
        float prominence = smoothstep(0.1, 0.0, d);
        col += prominence * 0.3 * flareColor;
    }
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let energyOrbCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(3.0)
// @param coreSize "Core Size" range(0.05, 0.3) default(0.2)
// @param ringCount "Ring Count" range(3.0, 10.0) default(6.0)
// @param ringFrequency "Ring Frequency" range(10.0, 40.0) default(20.0)
// @param ringWidth "Ring Width" range(0.1, 0.5) default(0.3)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param energyPulse "Energy Pulse" range(0.0, 1.0) default(0.5)
// @param colorCycle "Color Cycle" range(0.0, 1.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param coreRed "Core Red" range(0.0, 1.0) default(1.0)
// @param coreGreen "Core Green" range(0.0, 1.0) default(1.0)
// @param coreBlue "Core Blue" range(0.0, 1.0) default(1.0)
// @param ringRed "Ring Red" range(0.0, 1.0) default(0.3)
// @param ringGreen "Ring Green" range(0.0, 1.0) default(0.6)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showRings "Show Rings" default(true)
// @toggle showParticles "Show Particles" default(true)
// @toggle radial "Radial" default(true)
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
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle electric "Electric" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Convert to polar
float2 pc = p * 2.0 - 1.0;
float r = length(pc);
float a = atan2(pc.y, pc.x);

float3 col = float3(0.0);

// Core
float3 coreColor = float3(coreRed, coreGreen, coreBlue);
if (showCore > 0.5) {
    float core = smoothstep(coreSize, 0.0, r);
    col += core * coreColor;
}

// Energy rings
if (showRings > 0.5) {
    int numRings = int(ringCount);
    for (int i = 0; i < 10; i++) {
        if (i >= numRings) break;
        float fi = float(i);
        float wave = sin(a * 3.0 + r * ringFrequency - timeVal + fi);
        wave = pow(max(0.0, wave), 2.0) * waveAmplitude;
        float ring = smoothstep(ringWidth + 0.1, ringWidth, r) * wave;
        
        // Color cycling
        float3 ringColor;
        if (colorShift > 0.5) {
            ringColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * colorCycle + hueShift * 6.28);
        } else {
            ringColor = float3(ringRed, ringGreen, 1.0);
        }
        col += ring * 0.3 * ringColor;
    }
}

// Particles orbiting
if (showParticles > 0.5) {
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float pa = fi * 0.785 + timeVal * 0.5;
        float pr = 0.3 + fi * 0.05;
        float2 particlePos = float2(cos(pa), sin(pa)) * pr;
        float d = length(pc - particlePos);
        float particle = smoothstep(0.03, 0.01, d);
        col += particle * coreColor * 0.5;
    }
}

// Electric arcs
if (electric > 0.5) {
    float arc = sin(a * 8.0 + r * 20.0 - timeVal * 5.0);
    arc = step(0.8, arc) * smoothstep(coreSize + 0.2, coreSize, r);
    col += arc * 0.5 * float3(0.5, 0.7, 1.0);
}

// Energy pulse
if (energyPulse > 0.0) {
    float pulseWave = fract(timeVal * 0.5);
    float pulseDist = abs(r - pulseWave * 0.5);
    float pulseRing = smoothstep(0.02, 0.0, pulseDist) * (1.0 - pulseWave);
    col += pulseRing * energyPulse * coreColor;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 4.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""

let electricArcCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param arcCount "Arc Count" range(1.0, 5.0) default(3.0)
// @param arcSegments "Arc Segments" range(5.0, 20.0) default(10.0)
// @param arcSpread "Arc Spread" range(0.1, 0.5) default(0.2)
// @param jitter "Jitter" range(0.01, 0.1) default(0.05)
// @param flickerRate "Flicker Rate" range(10.0, 30.0) default(20.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param arcWidth "Arc Width" range(0.005, 0.03) default(0.02)
// @param glowSpread "Glow Spread" range(0.0, 0.1) default(0.03)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param arcRed "Arc Red" range(0.0, 1.0) default(0.3)
// @param arcGreen "Arc Green" range(0.0, 1.0) default(0.5)
// @param arcBlue "Arc Blue" range(0.0, 1.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.1) default(0.02)
// @param bgGreen "BG Green" range(0.0, 0.1) default(0.02)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showArcs "Show Arcs" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle showSparks "Show Sparks" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

// Background
float3 col = float3(bgRed, bgGreen, 0.05);

// Arc color
float3 arcColor = float3(arcRed, arcGreen, arcBlue);

// Electric arcs
if (showArcs > 0.5) {
    int numArcs = int(arcCount);
    int segments = int(arcSegments);
    
    for (int i = 0; i < 5; i++) {
        if (i >= numArcs) break;
        float fi = float(i);
        float baseY = 0.5 + sin(timeVal * 2.0 + fi) * arcSpread;
        float offset = 0.0;
        
        for (int j = 0; j < 20; j++) {
            if (j >= segments) break;
            float fj = float(j);
            offset += (fract(sin(fj * 43.758 + floor(timeVal * flickerRate) + fi) * 43758.5453) - 0.5) * jitter;
            float segY = baseY + offset;
            
            float d;
            if (horizontal > 0.5) {
                d = abs(p.y - segY);
            } else {
                d = abs(p.x - segY);
            }
            
            float arc = smoothstep(arcWidth, 0.0, d);
            float segMask;
            if (horizontal > 0.5) {
                segMask = smoothstep(fj / arcSegments, (fj + 1.0) / arcSegments, p.x);
                segMask *= smoothstep((fj + 1.0) / arcSegments, fj / arcSegments, p.x - 1.0 / arcSegments);
            } else {
                segMask = smoothstep(fj / arcSegments, (fj + 1.0) / arcSegments, p.y);
            }
            
            col += arc * arcColor * 0.5;
        }
    }
}

// Glow around arcs
if (showGlow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(0.5)) * glowSpread * 10.0;
}

// Sparks
if (showSparks > 0.5) {
    float spark = fract(sin(dot(floor(p * 50.0 * noiseScale), float2(12.9898, 78.233)) + timeVal * 5.0) * 43758.5453);
    spark = step(0.98, spark);
    col += spark * arcColor;
}

// Glow
if (glow > 0.5) {
    col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.8 + 0.2 * fract(sin(floor(timeVal * flickerRate) * 43.758) * 43758.5453);
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

// Master opacity
col *= masterOpacity;

return float4(col, masterOpacity);
"""
