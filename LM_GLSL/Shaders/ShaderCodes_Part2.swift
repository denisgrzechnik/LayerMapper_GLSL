//
//  ShaderCodes_Part2.swift
//  LM_GLSL
//
//  Shader codes - Part 2: Retro, Psychedelic, Abstract
//

import Foundation

// MARK: - Retro Category

let matrixRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param density "Density" range(10.0, 50.0) default(20.0)
// @param dropLength "Drop Length" range(10.0, 50.0) default(30.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param fadeAmount "Fade Amount" range(0.0, 1.0) default(0.1)
// @param characterSize "Character Size" range(0.5, 2.0) default(1.0)
// @param colorHue "Color Hue" range(0.0, 1.0) default(0.33)
// @param colorSaturation "Color Saturation" range(0.0, 1.0) default(1.0)
// @param trailLength "Trail Length" range(0.1, 1.0) default(0.5)
// @param flickerSpeed "Flicker Speed" range(0.0, 5.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.3)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(true)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
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

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + iTime), cos(p.x * 10.0 + iTime)) * distortion * 0.1;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float2 mp = p;
mp.y = mod(mp.y - timeVal, 1.0);

float charDensity = density * characterSize;
float dropLen = dropLength;

float col = step(0.9, fract(sin(floor(mp.x * charDensity) * 43.758 + floor(mp.y * dropLen)) * 43758.5453));
col *= step(fract(sin(floor(mp.x * charDensity) * 12.345) * 43758.5453), trailLength);

// Flicker effect
if (flicker > 0.5) {
    col *= 0.8 + 0.2 * sin(iTime * flickerSpeed * 10.0 + mp.x * 100.0);
}

float3 color = float3(redAmount, greenAmount, blueAmount) * col;
color += float3(redAmount * 0.1, greenAmount * 0.1, blueAmount * 0.1) * (1.0 - uv.y) * fadeAmount;

// Glow
if (glow > 0.5) {
    float glowVal = col * glowIntensity;
    color += float3(redAmount * 0.3, greenAmount * 0.5, blueAmount * 0.3) * glowVal;
}

// Pulse
if (pulse > 0.5) color *= 0.8 + 0.2 * sin(iTime * 3.0);

// Contrast and brightness
color = (color - 0.5) * contrast + 0.5;
color *= brightness;

// Gamma
color = pow(max(color, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) color = pow(max(color, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) color = mix(color, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) color = smoothstep(0.3, 0.7, color);

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    color += (n - 0.5) * 0.1;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    color += (grain - 0.5) * 0.08;
}

// Chromatic aberration
if (chromatic > 0.5) {
    color.r += fract(sin(dot((uv + chromaticAmount) * 100.0, float2(12.9898, 78.233))) * 43758.5453) * 0.05;
    color.b += fract(sin(dot((uv - chromaticAmount) * 100.0, float2(12.9898, 78.233))) * 43758.5453) * 0.05;
}

// Scanlines
if (scanlines > 0.5) {
    color *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(color, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        color += (color - bloomThreshold) * bloomIntensity;
    }
}

// Invert
if (invert > 0.5) color = 1.0 - color;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    color *= max(vig, 0.0);
}

// Shadow and highlight
color = color * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) color = clamp(color, 0.0, 1.0);

return float4(color * masterOpacity, masterOpacity);
"""

let crtTvCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(1.0)
// @param scanlineFrequency "Scanline Frequency" range(100.0, 800.0) default(400.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 0.5) default(0.1)
// @param curvature "Curvature" range(0.0, 0.5) default(0.1)
// @param vignetteStrength "Vignette Strength" range(0.0, 2.0) default(1.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorFrequency "Color Frequency" range(1.0, 20.0) default(5.0)
// @param flickerAmount "Flicker Amount" range(0.0, 0.2) default(0.02)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.05)
// @param rgbOffset "RGB Offset" range(0.0, 0.02) default(0.005)
// @param bloomAmount "Bloom Amount" range(0.0, 1.0) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.01)
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
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.1)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
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

// CRT curve distortion
float2 curve = (p - 0.5) * 2.0;
float barrel = 1.0 + curvature * dot(curve, curve);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + iTime), cos(p.x * 10.0 + iTime)) * distortion * 0.1;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

// Scanline effect
float scanline = 0.0;
if (scanlines > 0.5) {
    scanline = sin(p.y * scanlineFrequency) * scanlineIntensity;
}

// Vignette
float vignetteVal = 1.0 - length((p - 0.5) * vignetteStrength);

// Base color
float3 col = 0.5 + 0.5 * cos(timeVal + p.xyx * colorFrequency + float3(0.0, 2.0, 4.0));

// Chromatic aberration
if (chromatic > 0.5) {
    col.r = 0.5 + 0.5 * cos(timeVal + (p.x + rgbOffset * chromaticAmount * 10.0) * colorFrequency);
    col.b = 0.5 + 0.5 * cos(timeVal + (p.x - rgbOffset * chromaticAmount * 10.0) * colorFrequency + 4.0);
}

col *= float3(redAmount, greenAmount, blueAmount);
col *= 0.9 + scanline;
if (vignette > 0.5) col *= vignetteVal;

// Flicker
if (flicker > 0.5) {
    col *= 1.0 - flickerAmount * sin(timeVal * 50.0);
}

// Edge mask
col *= smoothstep(1.0, 1.0 - edgeSoftness, max(abs(curve.x), abs(curve.y)) * barrel);

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(p * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let glitchCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param glitchFrequency "Glitch Frequency" range(5.0, 50.0) default(20.0)
// @param glitchIntensity "Glitch Intensity" range(0.0, 0.2) default(0.05)
// @param glitchThreshold "Glitch Threshold" range(0.8, 1.0) default(0.95)
// @param colorSplit "Color Split" range(0.0, 0.05) default(0.01)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(10.0, 100.0) default(50.0)
// @param noiseStrength "Noise Strength" range(0.0, 1.0) default(0.3)
// @param blockSize "Block Size" range(1.0, 50.0) default(10.0)
// @param shiftAmount "Shift Amount" range(0.0, 0.2) default(0.05)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.02)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
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

// Glitch calculation
float glitch = step(glitchThreshold, fract(sin(floor(timeVal * glitchFrequency) * 43.758) * 43758.5453));
float offset = glitch * sin(p.y * waveFrequency + timeVal * 100.0) * glitchIntensity * shiftAmount * 10.0;

if (horizontal > 0.5) p.x += offset;
if (vertical > 0.5) p.y += offset;
if (diagonal > 0.5) { p.x += offset * 0.7; p.y += offset * 0.7; }

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Base color with RGB split
float3 col = float3(0.0);
col.r = 0.5 + 0.5 * sin(p.x * blockSize + timeVal);
col.g = 0.5 + 0.5 * sin((p.x + colorSplit) * blockSize + timeVal);
col.b = 0.5 + 0.5 * sin((p.x - colorSplit) * blockSize + timeVal);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r = 0.5 + 0.5 * sin((p.x + chromaticAmount) * blockSize + timeVal);
    col.b = 0.5 + 0.5 * sin((p.x - chromaticAmount) * blockSize + timeVal);
}

// Glitch noise
if (noise > 0.5) {
    col += glitch * float3(fract(sin(p.y * 1000.0) * 43758.5453)) * noiseStrength;
}

col *= float3(redAmount, greenAmount, blueAmount);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
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

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let synthwaveGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param horizon "Horizon" range(0.2, 0.6) default(0.4)
// @param gridDensity "Grid Density" range(1.0, 20.0) default(10.0)
// @param perspective "Perspective" range(1.0, 5.0) default(2.0)
// @param sunSize "Sun Size" range(0.05, 0.3) default(0.15)
// @param sunGlow "Sun Glow" range(0.0, 1.0) default(0.5)
// @param gridWidth "Grid Width" range(0.01, 0.1) default(0.05)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param skyColorR "Sky Color R" range(0.0, 1.0) default(0.0)
// @param skyColorG "Sky Color G" range(0.0, 1.0) default(0.0)
// @param skyColorB "Sky Color B" range(0.0, 1.0) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

p.y = 1.0 - p.y;
float horizonLine = horizon;
float3 col = float3(0.0);

if (p.y < horizonLine) {
    // Sky gradient
    col = mix(float3(skyColorR, skyColorG, skyColorB), float3(0.5, 0.0, 0.5), p.y / horizonLine);
    
    // Sun
    float sunDist = length(float2(p.x - 0.5, (p.y - horizonLine) * 2.0));
    float sun = smoothstep(sunSize, 0.0, sunDist);
    col += sun * float3(1.0, 0.3, 0.5);
    
    // Sun glow
    if (glow > 0.5) {
        col += smoothstep(sunSize * 3.0, 0.0, sunDist) * float3(1.0, 0.5, 0.3) * sunGlow * glowIntensity;
    }
} else {
    // Grid floor
    float gy = (p.y - horizonLine) / (1.0 - horizonLine);
    float persp = 1.0 / (gy + 0.01) * perspective;
    float gridX = abs(fract((p.x - 0.5) * persp + timeVal) - 0.5);
    float gridY = abs(fract(gy * gridDensity - timeVal * 2.0) - 0.5);
    float grid = min(gridX, gridY);
    col = smoothstep(gridWidth, 0.0, grid) * float3(redAmount, greenAmount, blueAmount);
    col *= gy;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.4;

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount;
    col.b *= 1.0 - chromaticAmount;
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let vhsDistortionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.2) default(0.1)
// @param waveStrength "Wave Strength" range(0.0, 0.05) default(0.01)
// @param waveFrequency "Wave Frequency" range(5.0, 50.0) default(20.0)
// @param colorShiftAmount "Color Shift Amount" range(0.0, 0.02) default(0.005)
// @param scanlineFrequency "Scanline Frequency" range(50.0, 400.0) default(200.0)
// @param scanlineSpeed "Scanline Speed" range(10.0, 100.0) default(50.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorFrequency "Color Frequency" range(1.0, 20.0) default(5.0)
// @param trackingError "Tracking Error" range(0.0, 0.1) default(0.02)
// @param staticAmount "Static Amount" range(0.0, 0.5) default(0.1)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.01)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.5)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle filmGrain "Film Grain" default(true)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
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

// VHS noise
float vhsNoise = fract(sin(dot(floor(p * 100.0 + timeVal * 10.0), float2(12.9898, 78.233))) * 43758.5453);

// Wave distortion
if (horizontal > 0.5) p.x += sin(p.y * waveFrequency + timeVal * 5.0) * waveStrength;
if (vertical > 0.5) p.y += vhsNoise * noiseAmount * 0.5;

// Tracking error
p.y += sin(timeVal * 0.5) * trackingError * step(0.95, sin(timeVal * 2.0));

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Base color with color shift
float3 col = float3(0.0);
col.r = 0.5 + 0.5 * sin(p.x * colorFrequency + timeVal);
col.g = 0.5 + 0.5 * sin((p.x + colorShiftAmount) * colorFrequency + timeVal);
col.b = 0.5 + 0.5 * sin((p.x - colorShiftAmount) * colorFrequency + timeVal);

// Chromatic aberration
if (chromatic > 0.5) {
    col.r = 0.5 + 0.5 * sin((p.x + chromaticAmount) * colorFrequency + timeVal);
    col.b = 0.5 + 0.5 * sin((p.x - chromaticAmount) * colorFrequency + timeVal);
}

col *= float3(redAmount, greenAmount, blueAmount);

// Scanlines
if (scanlines > 0.5) {
    float scanline = sin(p.y * scanlineFrequency + timeVal * scanlineSpeed) * scanlineIntensity * 0.2 + (1.0 - scanlineIntensity * 0.1);
    col *= scanline;
}

// Static noise
if (noise > 0.5) {
    col += vhsNoise * staticAmount;
}

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * sin(timeVal * 60.0);
}

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let scanlinesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scanlineFrequency "Scanline Frequency" range(100.0, 800.0) default(300.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.5)
// @param secondaryFrequency "Secondary Frequency" range(200.0, 1000.0) default(600.0)
// @param colorFrequency "Color Frequency" range(1.0, 10.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param flickerSpeed "Flicker Speed" range(1.0, 20.0) default(10.0)
// @param flickerAmount "Flicker Amount" range(0.0, 0.2) default(0.1)
// @param lineThickness "Line Thickness" range(0.1, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(true)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
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
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p.y = abs(p.y - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Base color
float3 col = 0.5 + 0.5 * cos(timeVal + p.xyx * colorFrequency + float3(0.0, 2.0, 4.0) + phaseOffset);

// Scanline effects
float scanlineVal = 1.0;
if (scanlines > 0.5) {
    if (vertical > 0.5) {
        scanlineVal = sin(p.y * scanlineFrequency * lineThickness) * scanlineIntensity + (1.0 - scanlineIntensity * 0.5);
    }
    if (horizontal > 0.5) {
        scanlineVal *= sin(p.x * scanlineFrequency * lineThickness) * scanlineIntensity + (1.0 - scanlineIntensity * 0.5);
    }
    if (diagonal > 0.5) {
        scanlineVal *= sin((p.x + p.y) * scanlineFrequency * lineThickness * 0.7) * scanlineIntensity + (1.0 - scanlineIntensity * 0.5);
    }
}

col *= 0.8 + 0.2 * scanlineVal;
col *= 0.9 + 0.1 * sin(p.y * secondaryFrequency + timeVal * flickerSpeed);

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Flicker
if (flicker > 0.5) {
    col *= 1.0 - flickerAmount + flickerAmount * sin(timeVal * flickerSpeed);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + sin(p.y * scanlineFrequency + chromaticAmount * 100.0) * 0.1;
    col.b *= 1.0 + sin(p.y * scanlineFrequency - chromaticAmount * 100.0) * 0.1;
}

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let pixelSortCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param threshold "Threshold" range(0.0, 1.0) default(0.5)
// @param thresholdRange "Threshold Range" range(0.0, 0.5) default(0.3)
// @param sortDensity "Sort Density" range(10.0, 100.0) default(50.0)
// @param colorFrequency "Color Frequency" range(1.0, 20.0) default(10.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param bandWidth "Band Width" range(0.01, 0.2) default(0.05)
// @param sortSpeed "Sort Speed" range(0.0, 2.0) default(0.5)
// @param glitchAmount "Glitch Amount" range(0.0, 1.0) default(0.3)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(true)
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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Threshold calculation
float thresholdVal = sin(timeVal) * thresholdRange + threshold;
float y = floor(p.y * sortDensity) / sortDensity;
float sort = step(thresholdVal, fract(sin(y * 43.758) * 43758.5453));

// Sorting effect
float2 sortedP = p;
if (sort > 0.5) {
    if (horizontal > 0.5) sortedP.x = fract(p.x + timeVal * sortSpeed);
    if (vertical > 0.5) sortedP.y = fract(p.y + timeVal * sortSpeed);
    if (diagonal > 0.5) {
        sortedP.x = fract(p.x + timeVal * sortSpeed * 0.7);
        sortedP.y = fract(p.y + timeVal * sortSpeed * 0.7);
    }
}

// Base color
float3 col = 0.5 + 0.5 * cos(sortedP.x * colorFrequency + float3(0.0, 2.0, 4.0) + phaseOffset);

// Stripes
if (stripes > 0.5) {
    col *= 0.5 + 0.5 * sin(p.y * sortDensity);
}

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glitch effect
if (glitchAmount > 0.0) {
    float glitch = step(0.95, fract(sin(floor(timeVal * 20.0) * 43.758) * 43758.5453));
    col += glitch * glitchAmount * 0.5;
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r = 0.5 + 0.5 * cos((sortedP.x + chromaticAmount) * colorFrequency);
    col.b = 0.5 + 0.5 * cos((sortedP.x - chromaticAmount) * colorFrequency + 4.0);
}

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let asciiArtCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param gridSize "Grid Size" range(10.0, 60.0) default(30.0)
// @param characterDensity "Character Density" range(0.2, 0.8) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param charWidth "Character Width" range(0.1, 0.5) default(0.3)
// @param charHeight "Character Height" range(0.1, 0.5) default(0.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.0)
// @param foregroundR "Foreground R" range(0.0, 1.0) default(0.0)
// @param foregroundG "Foreground G" range(0.0, 1.0) default(1.0)
// @param foregroundB "Foreground B" range(0.0, 1.0) default(0.0)
// @param backgroundR "Background R" range(0.0, 1.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
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
// @toggle stripes "Stripes" default(false)
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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Grid calculation
float2 grid = floor(p * gridSize);
float2 f = fract(p * gridSize);

// Hash for character visibility
float h = fract(sin(dot(grid, float2(12.9898, 78.233)) + timeVal) * 43758.5453);

// Character shape
float charVal = step(charWidth, f.x) * step(f.x, 1.0 - charWidth) * step(charHeight, f.y) * step(f.y, 1.0 - charHeight);
charVal *= step(characterDensity, h);

// Base color
float3 col = float3(foregroundR + redAmount, foregroundG + greenAmount, foregroundB + blueAmount) * charVal;
col += float3(backgroundR, backgroundR, backgroundR) * (1.0 - charVal);

// Glow
if (glow > 0.5) {
    float glowVal = charVal * glowIntensity * 0.5;
    col += float3(foregroundR, foregroundG, foregroundB) * glowVal;
}

// Flicker
if (flicker > 0.5) {
    col *= 0.9 + 0.1 * sin(timeVal * 20.0 + grid.x * 10.0);
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(p.y * 400.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 2.0;
    col.b *= 1.0 - chromaticAmount * 2.0;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let commodore64Code = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.1)
// @param pixelDensity "Pixel Density" range(20.0, 80.0) default(40.0)
// @param colorCount "Color Count" range(2.0, 8.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param dithering "Dithering" range(0.0, 1.0) default(0.0)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.5)
// @param palette1R "Palette 1 R" range(0.0, 1.0) default(0.0)
// @param palette1G "Palette 1 G" range(0.0, 1.0) default(0.0)
// @param palette1B "Palette 1 B" range(0.0, 1.0) default(0.67)
// @param palette2R "Palette 2 R" range(0.0, 1.0) default(0.67)
// @param palette2G "Palette 2 G" range(0.0, 1.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.3)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(true)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
p += center;

// Pixelate (C64 style)
p = floor(p * pixelDensity) / pixelDensity;

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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// C64 color palette
float3 c64colors[5];
c64colors[0] = float3(0.0, 0.0, 0.0);
c64colors[1] = float3(palette1R, palette1G, palette1B);
c64colors[2] = float3(palette2R, palette2G, 0.0);
c64colors[3] = float3(0.0, 0.67, 0.0);
c64colors[4] = float3(0.67, 0.67, 0.67);

// Color selection hash
float h = fract(sin(dot(p + timeVal * 0.1, float2(12.9898, 78.233))) * 43758.5453);

// Dithering
if (dithering > 0.0) {
    float2 ditherCoord = floor(uv * pixelDensity * 2.0);
    float ditherVal = fract(sin(dot(ditherCoord, float2(12.9898, 78.233))) * 43758.5453);
    h = mix(h, ditherVal, dithering * 0.5);
}

int idx = int(h * colorCount);
idx = idx % 5;

float3 col = c64colors[idx];
col *= float3(redAmount, greenAmount, blueAmount);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * sin(timeVal * 30.0 + p.y * 100.0);
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * pixelDensity * 3.14159 * scanlineIntensity * 10.0);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 2.0;
    col.b *= 1.0 - chromaticAmount * 2.0;
}

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

// Pulse
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

// MARK: - Psychedelic Category

let liquidMetalCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.3)
// @param scale "Scale" range(1.0, 8.0) default(4.0)
// @param iterations "Iterations" range(3.0, 12.0) default(8.0)
// @param foldAmount "Fold Amount" range(0.5, 1.5) default(0.8)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param metallic "Metallic" range(0.0, 1.0) default(0.5)
// @param reflectivity "Reflectivity" range(0.0, 1.0) default(0.5)
// @param waveStrength "Wave Strength" range(0.0, 0.5) default(0.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * scale - scale * 0.5;

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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Liquid metal fractal
float3 col = float3(0.0);
int iters = int(iterations);
for (int i = 0; i < 12; i++) {
    if (i >= iters) break;
    float fi = float(i);
    p = abs(p) / dot(p, p) - foldAmount;
    p += float2(sin(timeVal * 0.3 + fi), cos(timeVal * 0.2 + fi)) * waveStrength;
    col += 0.5 + 0.5 * cos(length(p) * 3.0 + timeVal * colorSpeed + float3(0.0, 2.0, 4.0) + fi + phaseOffset);
}
col /= iterations;

col *= float3(redAmount, greenAmount, blueAmount);

// Metallic effect
float lum = dot(col, float3(0.299, 0.587, 0.114));
col = mix(col, float3(lum) * 1.2, metallic);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let neonPulseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param pulseFrequency "Pulse Frequency" range(1.0, 20.0) default(10.0)
// @param pulseIntensity "Pulse Intensity" range(1.0, 10.0) default(5.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.0)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 B" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 3.0) default(1.5)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param glowSpread "Glow Spread" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Radial pulse
float r = length(p);
float pulseVal = sin(r * pulseFrequency - timeVal) * 0.5 + 0.5;
pulseVal = pow(pulseVal, pulseIntensity);

// Colors
float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float3 col = color1 * pulseVal;
col += color2 * (1.0 - pulseVal) * smoothstep(glowSpread, 0.0, r);

col *= float3(redAmount, greenAmount, blueAmount);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-r * 2.0) * glowIntensity;
    col += glowVal * (color1 + color2) * 0.5;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Pulse effect
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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let fractalWarpCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.1)
// @param scale "Scale" range(1.0, 8.0) default(4.0)
// @param iterations "Iterations" range(3.0, 15.0) default(10.0)
// @param foldScale "Fold Scale" range(1.0, 2.0) default(1.5)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.1)
// @param colorIntensity "Color Intensity" range(0.0, 1.0) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param warpAmount "Warp Amount" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param complexity "Complexity" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * scale - scale * 0.5;

// Initial rotation
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Fractal warp iterations
float3 col = float3(0.0);
int iters = int(iterations);
for (int i = 0; i < 15; i++) {
    if (i >= iters) break;
    p = abs(p) - warpAmount * complexity;
    p *= foldScale;
    float a = timeVal * rotationSpeed + float(i) * 0.5;
    float c = cos(a); float s = sin(a);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    col += colorIntensity * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + length(p) + phaseOffset));
}

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let colorExplosionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 10.0) default(5.0)
// @param explosionPower "Explosion Power" range(1.0, 5.0) default(2.0)
// @param rayCount "Ray Count" range(5.0, 20.0) default(10.0)
// @param rayFrequency "Ray Frequency" range(10.0, 40.0) default(20.0)
// @param coreSize "Core Size" range(0.1, 0.5) default(0.2)
// @param corePower "Core Power" range(1.0, 6.0) default(4.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param coreColorR "Core Color R" range(0.0, 1.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Explosion calculation
float r = length(p);
float a = atan2(p.y, p.x);

float explosion = pow(max(0.0, 1.0 - r), explosionPower);
explosion *= 0.5 + 0.5 * sin(a * rayCount + r * rayFrequency - timeVal);

// Color based on angle
float3 col = explosion * (0.5 + 0.5 * cos(a * colorSpeed + timeVal + float3(0.0, 2.0, 4.0) + phaseOffset));

// Core glow
float core = pow(max(0.0, 1.0 - r * (1.0 / coreSize)), corePower);
col += core * float3(coreColorR, 0.8, 0.5);

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-r * 2.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let acidTripCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param iterations "Iterations" range(2.0, 8.0) default(5.0)
// @param foldSize "Fold Size" range(0.2, 1.0) default(0.5)
// @param expansionRate "Expansion Rate" range(1.0, 1.5) default(1.2)
// @param colorPower "Color Power" range(0.3, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param spiralTwist "Spiral Twist" range(0.0, 2.0) default(0.5)
// @param waveIntensity "Wave Intensity" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle kaleidoscope "Kaleidoscope" default(true)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Initial rotation
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Acid trip fractal
int iters = int(iterations);
for (int i = 0; i < 8; i++) {
    if (i >= iters) break;
    p = abs(p) - foldSize;
    p *= expansionRate;
    float c = cos(timeVal + spiralTwist * float(i));
    float s = sin(timeVal + spiralTwist * float(i));
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
}

// Wave effect
if (waveIntensity > 0.0) {
    p += sin(p.yx * waveFrequency) * waveIntensity * 0.1;
}

float3 col = 0.5 + 0.5 * cos(length(p) + timeVal * colorSpeed + float3(0.0, 2.0, 4.0) + phaseOffset);
col = pow(max(col, float3(0.0)), float3(colorPower));

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let mushroomVisionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param rippleFrequency "Ripple Frequency" range(5.0, 30.0) default(15.0)
// @param spiralAmount "Spiral Amount" range(1.0, 10.0) default(5.0)
// @param spiralIntensity "Spiral Intensity" range(0.0, 4.0) default(2.0)
// @param colorMultiplier "Color Multiplier" range(1.0, 4.0) default(2.0)
// @param fadeStrength "Fade Strength" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorPower "Color Power" range(0.5, 1.5) default(0.8)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param waveModulation "Wave Modulation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(true)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Mushroom vision effect
float r = length(p);
float a = atan2(p.y, p.x);

float spiralWave = sin(a * spiralAmount + timeVal * waveModulation) * spiralIntensity;
float ripple = sin(r * rippleFrequency - timeVal + spiralWave);

float3 col = 0.5 + 0.5 * cos(ripple * colorMultiplier + float3(0.0, 2.0, 4.0) + a + timeVal + phaseOffset);
col *= 1.0 - r * fadeStrength;
col = pow(max(col, float3(0.0)), float3(colorPower));

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-r * 2.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let morphingShapesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param morphRate "Morph Rate" range(0.0, 2.0) default(1.0)
// @param shapeSize "Shape Size" range(0.2, 0.8) default(0.5)
// @param edgeSharpness "Edge Sharpness" range(0.01, 0.1) default(0.02)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param backgroundColor "Background Color" range(0.0, 0.5) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.0)
// @param layerCount "Layer Count" range(1.0, 5.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Animated rotation
float animRot = timeVal * rotationSpeed;
float cosA = cos(animRot); float sinA = sin(animRot);
p = float2(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);

// Morphing between shapes
float morph = sin(timeVal * morphRate) * 0.5 + 0.5;

float circle = length(p);
float square = max(abs(p.x), abs(p.y));
float diamond = abs(p.x) + abs(p.y);
float star = min(circle, diamond * 0.7);

// Blend between shapes
float shape = mix(circle, square, morph);
shape = mix(shape, star, sin(timeVal * morphRate * 0.5) * 0.5 + 0.5);

float d = smoothstep(shapeSize, shapeSize - edgeSharpness, shape);

float3 col = d * (0.5 + 0.5 * cos(timeVal * colorSpeed + float3(0.0, 2.0, 4.0) + phaseOffset));
col += (1.0 - d) * backgroundColor;

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-shape * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let colorFlowCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(1.0)
// @param waveCountX "Wave Count X" range(1.0, 10.0) default(5.0)
// @param waveCountY "Wave Count Y" range(1.0, 10.0) default(3.0)
// @param waveIntensity "Wave Intensity" range(0.1, 0.5) default(0.2)
// @param colorPower "Color Power" range(0.3, 1.5) default(0.7)
// @param layerCount "Layer Count" range(2.0, 8.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param flowDirection "Flow Direction" range(0.0, 6.28) default(0.0)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(true)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p = abs(p - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Flow direction offset
float2 flowOffset = float2(cos(flowDirection), sin(flowDirection)) * timeVal * 0.1;
p += flowOffset;

// Color flow layers
float3 col = float3(0.0);
int layers = int(layerCount);
for (int i = 0; i < 8; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float wave = 0.0;
    if (horizontal > 0.5) wave += sin(p.x * waveCountX + timeVal + fi);
    if (vertical > 0.5) wave += sin(p.y * waveCountY + timeVal * 0.8 + fi);
    if (diagonal > 0.5) wave += sin((p.x + p.y) * waveCountX * 0.7 + timeVal + fi);
    if (radial > 0.5) wave += sin(length(p - 0.5) * waveCountX * 2.0 + timeVal + fi);
    
    wave = wave * 0.5 + 0.5;
    
    // Turbulence
    if (turbulence > 0.0) {
        wave += sin(p.x * 20.0 + p.y * 20.0 + timeVal) * turbulence * 0.2;
    }
    
    col += wave * waveIntensity * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + phaseOffset));
}

col = pow(max(col, float3(0.0)), float3(colorPower));
col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let dreamWeaverCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.0)
// @param scale "Scale" range(1.0, 5.0) default(3.0)
// @param waveFrequency "Wave Frequency" range(2.0, 10.0) default(5.0)
// @param layerCount "Layer Count" range(2.0, 10.0) default(6.0)
// @param offsetSpeed "Offset Speed" range(0.0, 1.0) default(0.3)
// @param offsetScale "Offset Scale" range(0.5, 2.0) default(1.0)
// @param colorIntensity "Color Intensity" range(0.1, 0.5) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param dreamDepth "Dream Depth" range(0.0, 1.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(true)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * scale;

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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Dream weaver layers
float3 col = float3(0.0);
int layers = int(layerCount);
for (int i = 0; i < 10; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float2 offset = float2(sin(timeVal * offsetSpeed + fi), cos(timeVal * morphSpeed + fi)) * offsetScale;
    float wave = sin(length(p + offset) * waveFrequency - timeVal * speed);
    
    // Dream depth modulation
    wave *= 1.0 - dreamDepth * 0.5 * sin(fi + timeVal * 0.2);
    
    col += (0.5 + 0.5 * wave) * colorIntensity * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + phaseOffset));
}

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

// MARK: - Abstract Category

let metaballsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ballCount "Ball Count" range(2.0, 8.0) default(5.0)
// @param ballSize "Ball Size" range(0.05, 0.3) default(0.1)
// @param threshold "Threshold" range(0.5, 3.0) default(0.8)
// @param smoothness "Smoothness" range(0.5, 2.0) default(2.0)
// @param orbitRadius "Orbit Radius" range(0.2, 0.8) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param wobbleAmount "Wobble Amount" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
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
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p = abs(p);

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Metaballs calculation
float v = 0.0;
int balls = int(ballCount);
for (int i = 0; i < 8; i++) {
    if (i >= balls) break;
    float fi = float(i);
    float wobble = sin(timeVal * 0.5 + fi * 2.0) * wobbleAmount;
    float2 ballCenter = float2(
        sin(timeVal + fi * 2.0 + wobble) * orbitRadius,
        cos(timeVal * 0.7 + fi * 1.5 + wobble) * orbitRadius
    );
    v += ballSize / length(p - ballCenter);
}

float3 col = smoothstep(threshold, smoothness, v) * (0.5 + 0.5 * cos(v + timeVal * colorSpeed + float3(0.0, 2.0, 4.0) + phaseOffset));

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowVal = smoothstep(threshold * 0.5, smoothness, v) * glowIntensity * 0.5;
    col += glowVal;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let sineWavesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(5.0, 20.0) default(10.0)
// @param waveAmplitude "Wave Amplitude" range(0.05, 0.3) default(0.1)
// @param lineThickness "Line Thickness" range(0.005, 0.05) default(0.02)
// @param lineCount "Line Count" range(2.0, 10.0) default(5.0)
// @param lineSpacing "Line Spacing" range(0.05, 0.2) default(0.1)
// @param phaseSpeed "Phase Speed" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param waveShape "Wave Shape" range(0.0, 1.0) default(0.0)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
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

if (mirror > 0.5) p.y = abs(p.y - 0.5) + 0.5;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Sine waves
float3 col = float3(0.0);
int lines = int(lineCount);
for (int i = 0; i < 10; i++) {
    if (i >= lines) break;
    float fi = float(i);
    
    float waveY = 0.0;
    if (horizontal > 0.5) {
        waveY = sin(p.x * waveFrequency + timeVal * phaseSpeed + fi * phaseOffset) * waveAmplitude;
    }
    if (vertical > 0.5) {
        waveY += cos(p.y * waveFrequency * 0.5 + timeVal * phaseSpeed + fi) * waveAmplitude * 0.5;
    }
    
    // Wave shape blend (sine to triangle)
    if (waveShape > 0.0) {
        float triangleWave = abs(fract(p.x * waveFrequency / 6.28 + timeVal * phaseSpeed / 6.28) - 0.5) * 4.0 - 1.0;
        waveY = mix(waveY, triangleWave * waveAmplitude, waveShape);
    }
    
    float wave = waveY + 0.5 + fi * lineSpacing;
    float lineVal = smoothstep(lineThickness, 0.0, abs(p.y - wave));
    
    // Glow around lines
    if (glow > 0.5) {
        lineVal += smoothstep(lineThickness * 5.0, 0.0, abs(p.y - wave)) * glowIntensity * 0.3;
    }
    
    col += lineVal * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + phaseOffset));
}

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let moirePatternCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param patternScale "Pattern Scale" range(10.0, 100.0) default(50.0)
// @param centerOffset "Center Offset" range(0.0, 0.5) default(0.1)
// @param lineThickness "Line Thickness" range(0.5, 2.0) default(1.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.5)
// @param patternDensity "Pattern Density" range(0.5, 3.0) default(1.0)
// @param waveAmount "Wave Amount" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param interference "Interference" range(0.0, 1.0) default(0.5)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle circularPattern "Circular Pattern" default(true)
// @toggle linearPattern "Linear Pattern" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0 - 0.5;

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

if (mirror > 0.5) {
    p.x = abs(p.x);
    p.y = abs(p.y);
}

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Second pattern offset
float2 p2 = p + float2(sin(timeVal * rotationSpeed) * centerOffset, cos(timeVal * rotationSpeed) * centerOffset);

// Calculate pattern values
float v = 0.0;

if (circularPattern > 0.5) {
    float r1 = length(p);
    float r2 = length(p2);
    v += sin(r1 * patternScale * patternDensity + phaseOffset) * sin(r2 * patternScale * patternDensity);
}

if (linearPattern > 0.5) {
    v += sin(p.x * patternScale * 0.5 + timeVal) * sin(p2.x * patternScale * 0.5);
    v += sin(p.y * patternScale * 0.5 + timeVal * 0.7) * sin(p2.y * patternScale * 0.5);
}

if (diagonal > 0.5) {
    v += sin((p.x + p.y) * patternScale * 0.3 + timeVal) * 0.5;
}

if (radial > 0.5) {
    float angle1 = atan2(p.y, p.x);
    float angle2 = atan2(p2.y, p2.x);
    v += sin(angle1 * 10.0) * sin(angle2 * 10.0) * 0.3;
}

// Wave modulation
if (waveAmount > 0.0) {
    v *= 1.0 + sin(timeVal * 2.0 + length(p) * 5.0) * waveAmount;
}

// Interference pattern
v = v * interference + (1.0 - interference) * sin(v * 3.14159);

float3 col = 0.5 + 0.5 * float3(v * lineThickness);

// Color shifting
if (colorShift > 0.5) {
    col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28);
}

col *= float3(redAmount, greenAmount, blueAmount);

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let inkBlotCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param blobScale "Blob Scale" range(1.0, 10.0) default(3.0)
// @param blobCount "Blob Count" range(2.0, 10.0) default(5.0)
// @param threshold "Threshold" range(0.1, 0.7) default(0.3)
// @param softness "Softness" range(0.01, 0.3) default(0.2)
// @param spreadAmount "Spread Amount" range(0.0, 1.0) default(0.5)
// @param inkDensity "Ink Density" range(0.1, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param morphAmount "Morph Amount" range(0.0, 1.0) default(0.3)
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
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.3)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.1)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.1)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.2)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror for ink blot symmetry
if (mirror > 0.5) p.x = abs(p.x);

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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Generate ink blot pattern
float2 q = p * blobScale;
float n = 0.0;

int blobs = int(blobCount);
for (int i = 0; i < 10; i++) {
    if (i >= blobs) break;
    float fi = float(i);
    float phase = fi * phaseOffset + timeVal * morphSpeed;
    float wave = sin(q.x * (fi + 1.0) + phase) * sin(q.y * (fi + 1.0) + phase * 0.7);
    n += wave * morphAmount;
}

// Normalize and apply threshold
n = n * 0.2 * inkDensity + 0.5;

// Shape mask based on distance from center
float dist = length(p) * spreadAmount;
float shapeMask = 1.0 - smoothstep(0.5, 1.0, dist);

float blob = smoothstep(threshold, threshold + softness, n * shapeMask);

// Base color
float3 col = float3(redAmount, greenAmount, blueAmount);

// Apply blob pattern
col = blob * col;

// Glow around edges
if (glow > 0.5) {
    float edge = smoothstep(threshold - 0.1, threshold, n * shapeMask) - blob;
    col += edge * glowIntensity * 0.5;
}

// Stripes pattern
if (stripes > 0.5) {
    float stripe = sin(p.y * 50.0 + timeVal) * 0.1;
    col += stripe * blob;
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise texture
if (noise > 0.5) {
    float noiseVal = fract(sin(dot(uv * 100.0 * noiseScale + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * 0.1 * blob;
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

// Shadow
col *= 1.0 - shadowIntensity * (1.0 - blob) * 0.5;

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

return float4(col * masterOpacity, masterOpacity);
"""

let rorschachCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param patternScale "Pattern Scale" range(5.0, 30.0) default(10.0)
// @param threshold "Threshold" range(0.2, 0.6) default(0.4)
// @param blobSize "Blob Size" range(0.5, 1.5) default(0.8)
// @param noiseFrequency "Noise Frequency" range(0.5, 5.0) default(1.0)
// @param morphRate "Morph Rate" range(0.0, 2.0) default(0.5)
// @param inkAmount "Ink Amount" range(0.1, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param symmetryAmount "Symmetry Amount" range(0.0, 1.0) default(1.0)
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
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.3)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.3)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.3)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(true)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Symmetry (Rorschach style)
if (mirror > 0.5) {
    p.x = abs(p.x);
}
if (vertical > 0.5) {
    p.y = abs(p.y);
}

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
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Generate Rorschach pattern using noise
float2 gridPos = floor(p * patternScale * noiseFrequency + timeVal * morphRate);
float n = fract(sin(dot(gridPos, float2(12.9898, 78.233))) * 43758.5453);

// Additional noise layers
float n2 = fract(sin(dot(gridPos * 1.3 + phaseOffset, float2(78.233, 12.9898))) * 43758.5453);
n = mix(n, n2, 0.5);

// Blob shape with distance falloff
float dist = length(p);
float blob = step(threshold, n) * step(dist, blobSize);

// Soft edges option
if (edgeSoftness > 0.0) {
    blob = smoothstep(threshold - edgeSoftness, threshold + edgeSoftness, n) * smoothstep(blobSize + edgeSoftness, blobSize - edgeSoftness, dist);
}

// Base color
float3 col = float3(blob * inkAmount);

// Color tint
col *= float3(redAmount, greenAmount, blueAmount);

// Color shifting
if (colorShift > 0.5) {
    col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28);
}

// Glow effect
if (glow > 0.5) {
    float edge = smoothstep(threshold - 0.1, threshold, n) * step(dist, blobSize) - blob;
    col += edge * glowIntensity * 0.5;
}

// Stripes
if (stripes > 0.5) {
    float stripe = sin(p.y * 50.0 + timeVal) * 0.1;
    col += stripe * blob;
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise texture
if (noise > 0.5) {
    float noiseVal = fract(sin(dot(uv * 100.0 * noiseScale + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * 0.1;
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
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

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

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.5) + highlightIntensity * 0.2;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let fabricCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param weaveScale "Weave Scale" range(5.0, 50.0) default(20.0)
// @param threadThickness "Thread Thickness" range(0.5, 2.0) default(1.0)
// @param warpFrequency "Warp Frequency" range(1.0, 5.0) default(2.0)
// @param weftFrequency "Weft Frequency" range(1.0, 5.0) default(2.0)
// @param waveAmount "Wave Amount" range(0.0, 1.0) default(0.5)
// @param textureDepth "Texture Depth" range(0.0, 1.0) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param threadVariation "Thread Variation" range(0.0, 1.0) default(0.3)
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
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(true)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
p = p * weaveScale + center;

// Pixelate
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float2 kp = (p / weaveScale) - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(kp);
    p = float2(cos(angle), sin(angle)) * radius * weaveScale + 0.5 * weaveScale;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) {
    p.x = abs(p.x - weaveScale * 0.5) + weaveScale * 0.5;
}

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 0.5 + timeVal), cos(p.x * 0.5 + timeVal)) * distortion * 2.0;
}

// Weave pattern - warp and weft
float warp = sin(p.x * threadThickness + phaseOffset);
float weft = sin(p.y * threadThickness + phaseOffset);

// Animated weave
float weave = warp * weft;
if (animated > 0.5) {
    weave += sin(p.x + timeVal) * sin(p.y + timeVal) * waveAmount;
}

// Secondary thread pattern
if (horizontal > 0.5) {
    weave += sin(p.x * warpFrequency) * 0.3;
}
if (vertical > 0.5) {
    weave += sin(p.y * weftFrequency) * 0.3;
}
if (diagonal > 0.5) {
    weave += sin((p.x + p.y) * 0.5) * 0.2;
}

// Thread texture
float threadTex = 0.8 + 0.2 * sin(p.x * warpFrequency) * sin(p.y * weftFrequency);
threadTex *= 1.0 - textureDepth * 0.5 + textureDepth * fract(sin(dot(floor(p), float2(12.9898, 78.233))) * 43758.5453);

// Thread variation
if (threadVariation > 0.0) {
    float variation = fract(sin(dot(floor(p * 0.5), float2(78.233, 12.9898))) * 43758.5453);
    weave *= 1.0 - threadVariation * 0.3 + variation * threadVariation * 0.6;
}

// Base color from weave pattern
float3 col = 0.5 + 0.5 * cos(weave + float3(0.0, 2.0, 4.0) + hueShift * 6.28);

// Apply thread texture
col *= threadTex;

col *= float3(redAmount, greenAmount, blueAmount);

// Color shifting
if (colorShift > 0.5) {
    col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

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

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise texture
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

// Shadow depth
col *= 1.0 - shadowIntensity * (1.0 - threadTex) * 0.5;

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

return float4(col * masterOpacity, masterOpacity);
"""

let marbleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param patternScale "Pattern Scale" range(1.0, 10.0) default(5.0)
// @param veinIntensity "Vein Intensity" range(0.0, 1.0) default(0.5)
// @param veinFrequency "Vein Frequency" range(1.0, 5.0) default(2.0)
// @param turbulence "Turbulence" range(0.0, 2.0) default(1.0)
// @param octaves "Octaves" range(1.0, 8.0) default(5.0)
// @param lacunarity "Lacunarity" range(1.5, 3.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.2)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param waveDistortion "Wave Distortion" range(0.0, 1.0) default(0.3)
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
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.9)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.9)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.85)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * patternScale;

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

// Fractal noise for marble veins
float n = 0.0;
float amp = 1.0;
float freq = 1.0;
int oct = int(octaves);
for (int i = 0; i < 8; i++) {
    if (i >= oct) break;
    float fi = float(i);
    float wave = sin(p.x * freq + p.y * 0.5 * freq + timeVal * morphSpeed + phaseOffset);
    
    if (horizontal > 0.5) wave += sin(p.x * freq * 1.5) * 0.3;
    if (vertical > 0.5) wave += cos(p.y * freq * 1.5) * 0.3;
    if (diagonal > 0.5) wave += sin((p.x + p.y) * freq * 0.5) * 0.2;
    
    n += amp * wave;
    amp *= 0.5;
    freq *= lacunarity;
}

// Wave distortion
n *= turbulence;
if (waveDistortion > 0.0) {
    n += sin(p.y * 3.0 + timeVal) * waveDistortion;
}

// Vein pattern
float vein = abs(sin(p.x * veinFrequency + n));
vein = pow(vein, 1.0 + veinIntensity * 2.0);

// Marble base colors
float3 lightMarble = float3(redAmount, greenAmount, blueAmount);
float3 darkMarble = float3(0.3, 0.3, 0.35);

// Mix based on vein pattern
float3 col = mix(lightMarble, darkMarble, vein);

// Radial veins
if (radial > 0.5) {
    float angle = atan2(p.y, p.x);
    float radialVein = abs(sin(angle * 8.0 + n));
    col = mix(col, darkMarble, radialVein * 0.3);
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.9 + 0.1 * cos(float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    col += (1.0 - vein) * glowIntensity * 0.2;
}

// Bloom
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Noise texture (stone grain)
if (noise > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.05;
}

// Stripes
if (stripes > 0.5) {
    float stripe = sin(p.x * 10.0 + n) * 0.05;
    col += stripe;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Shadow in veins
col *= 1.0 - shadowIntensity * vein * 0.3;

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
    float filmGr = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (filmGr - 0.5) * 0.04;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let woodGrainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param grainScale "Grain Scale" range(5.0, 30.0) default(10.0)
// @param ringFrequency "Ring Frequency" range(1.0, 10.0) default(5.0)
// @param ringWave "Ring Wave" range(0.0, 5.0) default(2.0)
// @param grainIntensity "Grain Intensity" range(0.0, 1.0) default(0.5)
// @param knotSize "Knot Size" range(0.0, 1.0) default(0.3)
// @param woodDensity "Wood Density" range(0.5, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param grainVariation "Grain Variation" range(0.0, 1.0) default(0.3)
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
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(0.5)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(0.32)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(0.15)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(true)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * grainScale;

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
    p += float2(sin(p.y * 0.5 + timeVal), cos(p.x * 0.5 + timeVal)) * distortion * 2.0;
}

// Wood ring pattern (radial from center)
float2 ringCenter = float2(grainScale * 0.5, grainScale * 0.5);
float r = length(p - ringCenter);

// Wave distortion for rings
float waveOffset = 0.0;
if (horizontal > 0.5) waveOffset += sin(p.y * woodDensity + timeVal * morphSpeed) * ringWave;
if (vertical > 0.5) waveOffset += cos(p.x * woodDensity + timeVal * morphSpeed) * ringWave * 0.5;
if (diagonal > 0.5) waveOffset += sin((p.x + p.y) * 0.5 + timeVal) * ringWave * 0.3;

float n = sin(r * ringFrequency + waveOffset + phaseOffset);

// Grain variation
if (grainVariation > 0.0) {
    float variation = fract(sin(p.x * 100.0 + p.y * 50.0) * 43758.5453);
    n += (variation - 0.5) * grainVariation;
}

// Wood colors - light and dark
float3 lightWood = float3(redAmount * 1.2, greenAmount * 1.3, blueAmount * 1.4);
float3 darkWood = float3(redAmount * 0.8, greenAmount * 0.6, blueAmount * 0.5);

// Mix based on ring pattern
float3 col = mix(darkWood, lightWood, 0.5 + 0.5 * n);

// Grain texture
if (noise > 0.5) {
    float grain = fract(sin(p.x * 100.0 * noiseScale) * 43758.5453);
    col *= 0.9 + 0.1 * grain * grainIntensity;
}

// Knots
if (knotSize > 0.0) {
    float2 knotPos = float2(grainScale * 0.3, grainScale * 0.4);
    float knotDist = length(p - knotPos);
    float knot = smoothstep(knotSize, knotSize * 0.5, knotDist);
    col = mix(col, darkWood * 0.5, knot);
}

// Radial grain lines
if (radial > 0.5) {
    float radialGrain = sin(atan2(p.y - ringCenter.y, p.x - ringCenter.x) * 20.0);
    col *= 0.95 + 0.05 * radialGrain;
}

// Stripes (extra grain lines)
if (stripes > 0.5) {
    float stripe = sin(p.x * 30.0) * 0.05;
    col += stripe;
}

// Color shifting
if (colorShift > 0.5) {
    col *= 0.9 + 0.1 * cos(float3(0.0, 1.0, 2.0) + timeVal + hueShift * 6.28);
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

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

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Shadow in darker areas
col *= 1.0 - shadowIntensity * (1.0 - (0.5 + 0.5 * n)) * 0.3;

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
    float filmGr = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (filmGr - 0.5) * 0.05;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""
