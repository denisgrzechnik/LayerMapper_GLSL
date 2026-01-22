//
//  ShaderCodes_Part7.swift
//  LM_GLSL
//
//  Shader codes - Part 7: Cosmic & Space Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Cosmic Parametric Shaders

/// Supernova Explosion
let supernovaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param explosionSize "Explosion Size" range(0.1, 1.0) default(0.5)
// @param shockwaveSpeed "Shockwave Speed" range(0.5, 3.0) default(1.5)
// @param particleDensity "Particle Density" range(10.0, 50.0) default(30.0)
// @param coreIntensity "Core Intensity" range(0.5, 3.0) default(1.5)
// @param colorTemp "Color Temperature" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle showShockwave "Show Shockwave" default(true)
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
float r = length(p);
float a = atan2(p.y, p.x);
float time = fract(timeVal * 0.3) * shockwaveSpeed;

float3 col = float3(0.0);
float core = exp(-r / (explosionSize * 0.3)) * coreIntensity;
float3 coreColor = mix(float3(color1Red, color1Green, color1Blue), 
                       float3(color2Red, color2Green, color2Blue), colorTemp);
col += core * coreColor;

if (showShockwave > 0.5) {
    float shockwave = smoothstep(0.05, 0.0, abs(r - time * explosionSize));
    shockwave *= smoothstep(explosionSize * 1.5, 0.0, r);
    col += shockwave * float3(color2Red, color2Green, color2Blue);
}

int maxParticles = int(min(particleDensity, 50.0));
for (int i = 0; i < 50; i++) {
    if (i >= maxParticles) break;
    float fi = float(i);
    float pa = fi * 2.399;
    float pr = time * (0.5 + fract(sin(fi * 43.758) * 43758.5453) * 0.5);
    float2 particlePos = float2(cos(pa), sin(pa)) * pr * explosionSize;
    float pd = length(p - particlePos);
    col += smoothstep(0.02, 0.0, pd) * coreColor * (1.0 - time / shockwaveSpeed);
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

/// Wormhole Portal
let wormholeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param tunnelDepth "Tunnel Depth" range(1.0, 5.0) default(3.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 3.0) default(1.0)
// @param spiralTightness "Spiral Tightness" range(1.0, 10.0) default(5.0)
// @param eventHorizonSize "Event Horizon Size" range(0.05, 0.3) default(0.15)
// @param distortionStrength "Distortion Strength" range(0.0, 1.0) default(0.3)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle accretionDisk "Accretion Disk" default(true)
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
float r = length(p);
float a = atan2(p.y, p.x);

float tunnel = 1.0 / (r + 0.001);
float spiral = a + tunnel * spiralTightness + timeVal * rotationSpeed;
float warp = sin(spiral) * 0.5 + 0.5;
warp *= smoothstep(eventHorizonSize, eventHorizonSize + 0.5, r);

float3 col = warp * (0.5 + 0.5 * cos(tunnel / tunnelDepth + hueShift * 6.28 + float3(0.0, 2.0, 4.0)));
col *= exp(-r * 0.5);

float hole = smoothstep(eventHorizonSize, eventHorizonSize - 0.02, r);
col *= (1.0 - hole);

if (accretionDisk > 0.5) {
    float diskAngle = a + timeVal * rotationSpeed * 2.0;
    float disk = smoothstep(0.03, 0.0, abs(r - 0.3 - sin(diskAngle * 5.0) * 0.02));
    disk *= smoothstep(0.5, 0.2, r);
    col += disk * float3(color1Red, color1Green, color1Blue);
}
col += exp(-r / eventHorizonSize * 0.5) * float3(color2Red, color2Green, color2Blue) * distortionStrength;
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

/// Pulsar Beam
let pulsarBeamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param beamWidth "Beam Width" range(0.05, 0.3) default(0.1)
// @param pulseRate "Pulse Rate" range(1.0, 10.0) default(3.0)
// @param beamLength "Beam Length" range(0.5, 2.0) default(1.0)
// @param rotationSpeed "Rotation Speed" range(0.1, 2.0) default(0.5)
// @param starSize "Star Size" range(0.05, 0.2) default(0.1)
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
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle dualBeam "Dual Beam" default(true)
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
float r = length(p);
float a = atan2(p.y, p.x);

float3 col = float3(0.02, 0.02, 0.05);
float rotAngle = timeVal * rotationSpeed;
float pulseVal = sin(timeVal * pulseRate) * 0.5 + 0.5;
pulseVal = pow(pulseVal, 2.0);

float beam1Angle = rotAngle;
float beam1 = smoothstep(beamWidth, 0.0, abs(sin(a - beam1Angle)));
beam1 *= smoothstep(starSize, starSize + beamLength, r);
beam1 *= pulseVal;
col += beam1 * float3(color1Red, color1Green, color1Blue);

if (dualBeam > 0.5) {
    float beam2Angle = rotAngle + 3.14159;
    float beam2 = smoothstep(beamWidth, 0.0, abs(sin(a - beam2Angle)));
    beam2 *= smoothstep(starSize, starSize + beamLength, r);
    beam2 *= pulseVal;
    col += beam2 * float3(color1Red, color1Green, color1Blue);
}

float star = exp(-r / starSize);
col += star * float3(color2Red, color2Green, color2Blue) * (0.7 + 0.3 * pulseVal);
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

/// Asteroid Field
let asteroidFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param asteroidCount "Asteroid Count" range(10.0, 50.0) default(25.0)
// @param asteroidSize "Asteroid Size" range(0.01, 0.05) default(0.02)
// @param fieldDepth "Field Depth" range(1.0, 5.0) default(2.0)
// @param driftSpeed "Drift Speed" range(0.0, 1.0) default(0.3)
// @param rotationAmount "Rotation Amount" range(0.0, 1.0) default(0.2)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.35)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.01)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.01)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.02)
// @toggle animated "Animated" default(true)
// @toggle parallax "Parallax Effect" default(true)
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
float3 col = float3(color2Red, color2Green, color2Blue);

for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float depth = 1.0 + fl * fieldDepth * 0.5;
    float layerSize = asteroidSize / depth;
    int count = int(asteroidCount / depth);
    for (int i = 0; i < 50; i++) {
        if (i >= count) break;
        float fi = float(i);
        float hash = fract(sin(fi * 43.758 + fl * 12.345) * 43758.5453);
        float2 pos = float2(
            fract(hash * 7.0 + timeVal * driftSpeed / depth) * 2.0 - 1.0,
            fract(hash * 13.0 + sin(timeVal * 0.1 + fi) * rotationAmount) * 2.0 - 1.0
        );
        if (parallax > 0.5) {
            pos.x += sin(timeVal * 0.2) * 0.1 / depth;
        }
        float d = length(p - pos);
        float asteroid = smoothstep(layerSize, layerSize * 0.5, d);
        float shade = 0.5 + 0.5 * sin(fi);
        col += asteroid * float3(color1Red, color1Green, color1Blue) * shade / depth;
    }
}

float stars = step(0.998, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.3;
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

/// Solar Eclipse
let solarEclipseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param moonSize "Moon Size" range(0.2, 0.5) default(0.35)
// @param sunSize "Sun Size" range(0.25, 0.6) default(0.4)
// @param coronaSize "Corona Size" range(0.1, 0.5) default(0.25)
// @param eclipseProgress "Eclipse Progress" range(0.0, 1.0) default(0.5)
// @param coronaIntensity "Corona Intensity" range(0.5, 2.0) default(1.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.7)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle diamondRing "Diamond Ring Effect" default(true)
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
float r = length(p);
float a = atan2(p.y, p.x);

float moonOffset = (eclipseProgress - 0.5) * 0.5;
float2 moonCenter = float2(moonOffset, 0.0);
float moonDist = length(p - moonCenter);

float3 col = float3(0.0);
float sun = smoothstep(sunSize + 0.02, sunSize, r);
float3 sunColor = float3(color1Red, color1Green, color1Blue);
col += sun * sunColor;

float corona = exp(-(r - sunSize) / coronaSize) * coronaIntensity;
corona *= (1.0 - sun);
float coronaRays = 0.5 + 0.5 * sin(a * 12.0 + timeVal * 0.5);
col += corona * coronaRays * float3(color2Red, color2Green, color2Blue);

float moon = smoothstep(moonSize + 0.01, moonSize, moonDist);
col *= (1.0 - moon);

if (diamondRing > 0.5 && abs(eclipseProgress - 0.5) < 0.1) {
    float edgeDist = abs(moonDist - moonSize);
    float diamond = exp(-edgeDist * 50.0) * step(moonDist, moonSize + 0.02);
    diamond *= smoothstep(0.0, 0.02, abs(a - moonOffset * 10.0));
    col += diamond * float3(1.0, 1.0, 1.0) * 2.0;
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

/// Cosmic Web
let cosmicWebCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param webDensity "Web Density" range(2.0, 10.0) default(5.0)
// @param filamentWidth "Filament Width" range(0.01, 0.1) default(0.03)
// @param nodeSize "Node Size" range(0.02, 0.1) default(0.05)
// @param pulseSpeed "Pulse Speed" range(0.0, 3.0) default(1.0)
// @param colorVariation "Color Variation" range(0.0, 2.0) default(1.0)
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
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.01)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.02)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.03)
// @toggle animated "Animated" default(true)
// @toggle showNodes "Show Nodes" default(true)
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
float2 p = ((uv - center) * zoom + center) * webDensity;
float2 id = floor(p);
float2 f = fract(p);

float3 col = float3(color2Red, color2Green, color2Blue);
float minDist = 10.0;
float2 closestNode = float2(0.0);

for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 nodeId = id + neighbor;
        float2 nodeOffset = float2(
            fract(sin(dot(nodeId, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(nodeId, float2(269.5, 183.3))) * 43758.5453)
        );
        nodeOffset = 0.5 + 0.4 * sin(timeVal * pulseSpeed * 0.3 + 6.28 * nodeOffset);
        float2 nodePos = neighbor + nodeOffset - f;
        float d = length(nodePos);
        if (d < minDist) {
            minDist = d;
            closestNode = nodeId;
        }
    }
}

for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 nodeId = id + neighbor;
        if (nodeId.x == closestNode.x && nodeId.y == closestNode.y) continue;
        float2 nodeOffset = 0.5 + 0.4 * sin(timeVal * pulseSpeed * 0.3 + 6.28 * 
            float2(fract(sin(dot(nodeId, float2(127.1, 311.7))) * 43758.5453),
                   fract(sin(dot(nodeId, float2(269.5, 183.3))) * 43758.5453)));
        float2 nodePos = neighbor + nodeOffset - f;
        float2 closestOffset = 0.5 + 0.4 * sin(timeVal * pulseSpeed * 0.3 + 6.28 *
            float2(fract(sin(dot(closestNode, float2(127.1, 311.7))) * 43758.5453),
                   fract(sin(dot(closestNode, float2(269.5, 183.3))) * 43758.5453)));
        float2 closestPos = closestNode - id + closestOffset - f;
        float2 toNode = nodePos - closestPos;
        float2 toPoint = -closestPos;
        float t = clamp(dot(toPoint, toNode) / dot(toNode, toNode), 0.0, 1.0);
        float2 closest = closestPos + t * toNode;
        float lineDist = length(closest);
        float line = smoothstep(filamentWidth, 0.0, lineDist);
        float3 lineColor = 0.5 + 0.5 * cos(dot(nodeId, float2(1.0, 0.5)) * colorVariation + hueShift * 6.28 + float3(0.0, 2.0, 4.0));
        col += line * lineColor * 0.3;
    }
}

if (showNodes > 0.5) {
    float node = smoothstep(nodeSize, nodeSize * 0.5, minDist);
    float pulseFx = 0.8 + 0.2 * sin(timeVal * pulseSpeed + dot(closestNode, float2(1.0, 1.0)));
    col += node * float3(color1Red, color1Green, color1Blue) * pulseFx;
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

/// Quasar Jet
let quasarJetCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param jetWidth "Jet Width" range(0.05, 0.3) default(0.15)
// @param jetLength "Jet Length" range(0.3, 1.0) default(0.7)
// @param coreSize "Core Size" range(0.05, 0.2) default(0.1)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.3)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle counterJet "Counter Jet" default(true)
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
float r = length(p);
float a = atan2(p.y, p.x);

float3 col = float3(0.01, 0.01, 0.02);
float core = exp(-r / coreSize);
col += core * float3(1.0, 0.9, 0.7) * intensity;

float jetAngle = 1.5708;
float turbNoise = sin(p.y * 10.0 + timeVal * 3.0) * turbulence * 0.1;
float jet1 = smoothstep(jetWidth + turbNoise, 0.0, abs(a - jetAngle));
jet1 *= smoothstep(0.0, jetLength, p.y);
jet1 *= smoothstep(coreSize * 2.0, coreSize, r);
float3 jetColor = float3(color1Red, color1Green, color1Blue);
col += jet1 * jetColor * intensity;

if (counterJet > 0.5) {
    float jet2 = smoothstep(jetWidth + turbNoise, 0.0, abs(a + jetAngle));
    jet2 *= smoothstep(0.0, jetLength, -p.y);
    jet2 *= smoothstep(coreSize * 2.0, coreSize, r);
    col += jet2 * jetColor * intensity * 0.7;
}

float disk = smoothstep(0.02, 0.0, abs(p.y)) * smoothstep(0.5, coreSize, r);
col += disk * float3(color2Red, color2Green, color2Blue) * 0.5;
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

/// Planetary Rings
let planetaryRingsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param planetSize "Planet Size" range(0.15, 0.35) default(0.25)
// @param ringInner "Ring Inner Edge" range(0.3, 0.5) default(0.35)
// @param ringOuter "Ring Outer Edge" range(0.5, 0.9) default(0.7)
// @param ringBands "Ring Bands" range(2.0, 10.0) default(5.0)
// @param tilt "Tilt" range(0.0, 0.5) default(0.2)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.6)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.6)
// @toggle animated "Animated" default(true)
// @toggle atmosphere "Atmosphere" default(true)
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
p.y /= (1.0 - tilt);
float r = length(p);
float a = atan2(p.y, p.x);

float3 col = float3(0.01, 0.01, 0.02);
float planet = smoothstep(planetSize + 0.01, planetSize, r);
float3 planetColor = float3(color1Red, color1Green, color1Blue);
float shade = 0.5 + 0.5 * p.x / planetSize;
col += planet * planetColor * shade;

if (atmosphere > 0.5) {
    float atmo = smoothstep(planetSize + 0.1, planetSize, r) - planet;
    col += atmo * float3(0.3, 0.5, 0.8) * 0.5;
}

float ring = smoothstep(ringInner, ringInner + 0.02, r) * smoothstep(ringOuter + 0.02, ringOuter, r);
ring *= (1.0 - planet);

float bands = 0.0;
int maxBands = int(min(ringBands, 10.0));
for (int i = 0; i < 10; i++) {
    if (i >= maxBands) break;
    float fi = float(i);
    float bandPos = ringInner + (ringOuter - ringInner) * fi / ringBands;
    bands += smoothstep(0.02, 0.0, abs(r - bandPos)) * 0.5;
}

float3 ringColor = float3(color2Red, color2Green, color2Blue) * (0.5 + bands);
float shadow = step(0.0, p.y) * step(abs(p.x), planetSize) * step(r, ringOuter);
ringColor *= (1.0 - shadow * 0.5);
col += ring * ringColor;
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

/// Space Dust Cloud
let spaceDustCloudCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param cloudDensity "Cloud Density" range(0.5, 3.0) default(1.5)
// @param cloudScale "Cloud Scale" range(2.0, 10.0) default(5.0)
// @param driftSpeed "Drift Speed" range(0.0, 1.0) default(0.2)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.5)
// @param colorHue "Color Hue" range(0.0, 1.0) default(0.7)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle nebulaBrightSpots "Bright Spots" default(true)
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
p += float2(timeVal * driftSpeed, sin(timeVal * driftSpeed * 0.5) * 0.1);

float cloud = 0.0;
float amp = 1.0;
float2 freq = float2(cloudScale, cloudScale);
for (int i = 0; i < 5; i++) {
    float n = sin(p.x * freq.x) * sin(p.y * freq.y) * 0.5 + 0.5;
    cloud += n * amp;
    freq *= 2.0;
    amp *= 0.5;
    p += float2(0.5, 0.3);
}
cloud = pow(cloud * 0.5, cloudDensity);

float3 cloudColor = 0.5 + 0.5 * cos((colorHue + hueShift) * 6.28 + float3(0.0, 2.0, 4.0));
float3 col = cloud * cloudColor * 0.5;

float stars = step(1.0 - starDensity * 0.01, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
float starTwinkle = 0.7 + 0.3 * sin(timeVal * 5.0 + dot(floor(uv * 100.0), float2(1.0, 1.0)));
col += stars * starTwinkle * (1.0 - cloud * 0.5);

if (nebulaBrightSpots > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float2 spotPos = float2(fract(sin(fi * 127.1) * 43758.5453), fract(sin(fi * 311.7) * 43758.5453));
        float spot = exp(-length(uv - spotPos) * 5.0) * 0.3;
        col += spot * cloudColor * 2.0;
    }
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

/// Binary Star System
let binaryStarCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param star1Size "Star 1 Size" range(0.05, 0.2) default(0.12)
// @param star2Size "Star 2 Size" range(0.03, 0.15) default(0.08)
// @param orbitRadius "Orbit Radius" range(0.2, 0.5) default(0.3)
// @param orbitSpeed "Orbit Speed" range(0.1, 2.0) default(0.5)
// @param glowAmount "Glow Amount" range(0.5, 2.0) default(1.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle massTransfer "Mass Transfer" default(true)
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

float orbitAngle = timeVal * orbitSpeed;
float2 star1Pos = float2(cos(orbitAngle), sin(orbitAngle)) * orbitRadius * 0.6;
float2 star2Pos = float2(cos(orbitAngle + 3.14159), sin(orbitAngle + 3.14159)) * orbitRadius;

float3 col = float3(0.01, 0.01, 0.02);
float d1 = length(p - star1Pos);
float star1 = exp(-d1 / star1Size) * glowAmount;
float3 star1Color = float3(color1Red, color1Green, color1Blue);
col += star1 * star1Color;

float d2 = length(p - star2Pos);
float star2 = exp(-d2 / star2Size) * glowAmount;
float3 star2Color = float3(color2Red, color2Green, color2Blue);
col += star2 * star2Color;

if (massTransfer > 0.5) {
    float2 mid = (star1Pos + star2Pos) * 0.5;
    float2 dir = normalize(star2Pos - star1Pos);
    float2 perp = float2(-dir.y, dir.x);
    float stream = 0.0;
    for (int i = 0; i < 10; i++) {
        float fi = float(i) / 10.0;
        float2 streamPos = mix(star1Pos, star2Pos, fi);
        streamPos += perp * sin(fi * 6.28 + timeVal * 5.0) * 0.05;
        float sd = length(p - streamPos);
        stream += smoothstep(0.02, 0.0, sd) * (1.0 - fi);
    }
    col += stream * float3(1.0, 0.5, 0.3) * 0.5;
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

// MARK: - Space Environment Shaders

/// Aurora Borealis Advanced
let auroraAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param waveCount "Wave Count" range(2.0, 8.0) default(5.0)
// @param waveHeight "Wave Height" range(0.1, 0.5) default(0.2)
// @param flowSpeed "Flow Speed" range(0.1, 2.0) default(0.5)
// @param colorShiftVal "Color Shift" range(0.0, 6.28) default(0.0)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
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
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle multiLayer "Multi Layer" default(true)
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
float3 col = float3(0.01, 0.02, 0.05);

int layers = multiLayer > 0.5 ? 3 : 1;
int maxWaves = int(min(waveCount, 8.0));
for (int layer = 0; layer < 3; layer++) {
    if (layer >= layers) break;
    float fl = float(layer);
    float layerOffset = fl * 0.1;
    for (int i = 0; i < 8; i++) {
        if (i >= maxWaves) break;
        float fi = float(i);
        float waveY = 0.3 + fi * 0.1 + layerOffset;
        float wave = sin(p.x * 3.0 + timeVal * flowSpeed + fi * 1.5) * waveHeight;
        wave += sin(p.x * 5.0 - timeVal * flowSpeed * 0.7 + fi) * waveHeight * 0.5;
        float d = abs(p.y - waveY - wave);
        float glowVal = smoothstep(0.15, 0.0, d);
        float3 auroraCol = 0.5 + 0.5 * cos(fi * 0.5 + colorShiftVal + hueShift * 6.28 + fl + float3(0.0, 2.0, 4.0));
        col += glowVal * auroraCol * intensity * (1.0 / float(layers));
    }
}

float stars = step(0.997, fract(sin(dot(floor(uv * 150.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.3 * (1.0 - col);
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

/// Meteor Shower
let meteorShowerCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param meteorCount "Meteor Count" range(5.0, 30.0) default(15.0)
// @param meteorSpeed "Meteor Speed" range(0.5, 3.0) default(1.5)
// @param tailLength "Tail Length" range(0.05, 0.3) default(0.15)
// @param meteorSize "Meteor Size" range(0.005, 0.02) default(0.01)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle randomDirection "Random Direction" default(false)
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
float3 col = float3(0.01, 0.01, 0.02);

float stars = step(0.998, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.4;

int maxMeteors = int(min(meteorCount, 30.0));
for (int i = 0; i < 30; i++) {
    if (i >= maxMeteors) break;
    float fi = float(i);
    float hash = fract(sin(fi * 43.758) * 43758.5453);
    float phase = fract(timeVal * meteorSpeed * (0.5 + hash * 0.5) + hash * 10.0);
    float2 startPos = float2(hash, 1.0 - hash * 0.5);
    float2 dir = float2(1.0, -1.0);
    if (randomDirection > 0.5) {
        float angle = hash * 1.57 - 0.785;
        dir = float2(cos(angle), sin(angle));
    }
    dir = normalize(dir);
    float2 meteorPos = startPos + dir * phase * 1.5;
    float d = length(p - meteorPos);
    float meteor = smoothstep(meteorSize, 0.0, d);
    for (int t = 1; t < 10; t++) {
        float ft = float(t) / 10.0;
        float2 tailPos = meteorPos - dir * ft * tailLength;
        float td = length(p - tailPos);
        float tail = smoothstep(meteorSize * (1.0 - ft * 0.8), 0.0, td) * (1.0 - ft);
        meteor += tail * 0.3;
    }
    meteor *= (1.0 - phase * 0.5);
    float3 meteorColor = float3(color1Red, color1Green, color1Blue);
    col += meteor * meteorColor;
    if (glowAmount > 0.0) {
        float glowVal = smoothstep(0.1, 0.0, d) * glowAmount * (1.0 - phase);
        col += glowVal * float3(color2Red, color2Green, color2Blue);
    }
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

/// Stargate Activation
let stargateCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param ringCount "Ring Count" range(1.0, 5.0) default(3.0)
// @param symbolCount "Symbol Count" range(6.0, 12.0) default(9.0)
// @param rotationSpeed "Rotation Speed" range(0.1, 2.0) default(0.5)
// @param eventHorizon "Event Horizon" range(0.0, 1.0) default(0.7)
// @param glowAmount "Glow Amount" range(0.5, 2.0) default(1.0)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.6)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle active "Active" default(true)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.03);

int maxRings = int(min(ringCount, 5.0));
for (int i = 0; i < 5; i++) {
    if (i >= maxRings) break;
    float fi = float(i);
    float ringR = 0.6 + fi * 0.1;
    float ringWidth = 0.03;
    float ring = smoothstep(ringWidth, 0.0, abs(r - ringR));
    float rot = timeVal * rotationSpeed * (fi + 1.0) * (fmod(fi, 2.0) * 2.0 - 1.0);
    float symbols = step(0.7, sin((a + rot) * symbolCount));
    symbols *= ring;
    float3 ringColor = float3(color1Red, color1Green, color1Blue) * glowAmount;
    col += ring * ringColor * 0.3;
    col += symbols * float3(1.0, 0.8, 0.4) * glowAmount;
}

if (active > 0.5 && eventHorizon > 0.0) {
    float horizon = smoothstep(0.5, 0.0, r) * eventHorizon;
    float ripple = sin(r * 20.0 - timeVal * 5.0) * 0.5 + 0.5;
    float3 horizonColor = float3(color2Red, color2Green, color2Blue) * (0.5 + ripple * 0.5);
    col += horizon * horizonColor * glowAmount;
}
float outerGlow = exp(-(r - 0.9) * 5.0) * step(0.9, r) * glowAmount;
col += outerGlow * float3(0.4, 0.3, 0.2);
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

/// Galactic Core
let galacticCoreCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param coreSize "Core Size" range(0.1, 0.4) default(0.2)
// @param armCount "Arm Count" range(2.0, 6.0) default(4.0)
// @param armTightness "Arm Tightness" range(1.0, 5.0) default(2.5)
// @param starDensity "Star Density" range(0.5, 2.0) default(1.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.2)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle darkMatter "Dark Matter" default(true)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float r = length(p);
float a = atan2(p.y, p.x) + timeVal * rotationSpeed;
float3 col = float3(0.02, 0.01, 0.03);

float spiral = sin(a * armCount + r * armTightness * 6.28);
spiral = pow(spiral * 0.5 + 0.5, 2.0);
float falloff = exp(-r * 3.0);
float3 armColor = float3(color1Red, color1Green, color1Blue);
col += spiral * falloff * armColor * starDensity;

float core = exp(-r / coreSize);
float3 coreColor = float3(color2Red, color2Green, color2Blue);
col += core * coreColor;

if (darkMatter > 0.5) {
    float dm = sin(a * 7.0 + r * 10.0 - timeVal) * 0.5 + 0.5;
    dm *= exp(-r * 2.0);
    col *= (1.0 - dm * 0.3);
}

float2 starP = uv * 100.0;
float star = fract(sin(dot(floor(starP), float2(12.9898, 78.233))) * 43758.5453);
star = step(1.0 - 0.01 * starDensity * (1.0 - r), star);
float twinkle = 0.7 + 0.3 * sin(timeVal * 5.0 + dot(floor(starP), float2(1.0, 1.0)));
col += star * twinkle * (0.3 + 0.7 * (1.0 - falloff));
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

/// Comet Trail
let cometTrailCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param cometSize "Comet Size" range(0.02, 0.1) default(0.05)
// @param tailLength "Tail Length" range(0.2, 0.8) default(0.5)
// @param tailWidth "Tail Width" range(0.02, 0.15) default(0.08)
// @param cometSpeed "Comet Speed" range(0.1, 1.0) default(0.3)
// @param dustAmount "Dust Amount" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle ionTail "Ion Tail" default(true)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float time = timeVal * cometSpeed;
float2 cometPos = float2(sin(time) * 0.5, cos(time * 0.7) * 0.3);
float3 col = float3(0.01, 0.01, 0.02);

float stars = step(0.997, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.4;

float2 velocity = float2(cos(time), -sin(time * 0.7) * 0.7);
velocity = normalize(velocity);
float2 toComet = p - cometPos;
float along = dot(toComet, -velocity);
float perp = length(toComet - along * (-velocity));
float dustTail = smoothstep(tailWidth, 0.0, perp);
dustTail *= smoothstep(0.0, tailLength, along);
dustTail *= smoothstep(tailLength * 1.5, tailLength * 0.5, along);
dustTail *= dustAmount;
float3 dustColor = float3(color1Red, color1Green, color1Blue);
col += dustTail * dustColor;

if (ionTail > 0.5) {
    float2 ionDir = velocity + float2(0.2, 0.5);
    ionDir = normalize(ionDir);
    float ionAlong = dot(toComet, -ionDir);
    float ionPerp = length(toComet - ionAlong * (-ionDir));
    float ionTailShape = smoothstep(tailWidth * 0.3, 0.0, ionPerp);
    ionTailShape *= smoothstep(0.0, tailLength * 0.8, ionAlong);
    ionTailShape *= smoothstep(tailLength, tailLength * 0.3, ionAlong);
    col += ionTailShape * float3(color2Red, color2Green, color2Blue) * 0.7;
}

float comet = smoothstep(cometSize, cometSize * 0.5, length(toComet));
float coma = exp(-length(toComet) / cometSize * 2.0);
col += comet * float3(1.0, 1.0, 1.0);
col += coma * float3(0.8, 0.9, 1.0) * 0.5;
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

/// Dark Energy Field
let darkEnergyCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param fieldDensity "Field Density" range(2.0, 10.0) default(5.0)
// @param flowSpeed "Flow Speed" range(0.1, 2.0) default(0.5)
// @param waveAmplitude "Wave Amplitude" range(0.1, 1.0) default(0.4)
// @param darkIntensity "Dark Intensity" range(0.0, 1.0) default(0.5)
// @param energyBursts "Energy Bursts" range(0.0, 1.0) default(0.3)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle voidRift "Void Rift" default(false)
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
float2 p = (uv - center) * zoom * fieldDensity + center;
float time = timeVal * flowSpeed;
float field = 0.0;
field += sin(p.x + time) * sin(p.y * 1.3 + time * 0.7);
field += sin(p.x * 1.5 - time * 0.5) * sin(p.y + time * 1.2) * 0.5;
field += sin((p.x + p.y) * 0.7 + time * 0.3) * 0.3;
field = field * waveAmplitude;

float3 darkColor = float3(0.05, 0.02, 0.1);
float3 energyColor = float3(color1Red, color1Green, color1Blue);
float3 col = mix(darkColor, energyColor, field * 0.5 + 0.5);
col *= (1.0 - darkIntensity * 0.5);

if (energyBursts > 0.0) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float2 burstPos = float2(fract(sin(fi * 127.1 + floor(time)) * 43758.5453),
                                  fract(sin(fi * 311.7 + floor(time)) * 43758.5453));
        float burstPhase = fract(time + fi * 0.2);
        float burst = exp(-length(uv - burstPos) / (burstPhase * 0.3 + 0.01));
        burst *= (1.0 - burstPhase);
        col += burst * float3(color2Red, color2Green, color2Blue) * energyBursts;
    }
}

if (voidRift > 0.5) {
    float2 riftP = uv - 0.5;
    float rift = smoothstep(0.02, 0.0, abs(riftP.x + sin(riftP.y * 10.0 + time * 2.0) * 0.05));
    rift *= smoothstep(0.5, 0.0, abs(riftP.y));
    col *= (1.0 - rift * 0.8);
    col += rift * float3(0.1, 0.0, 0.2);
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

/// Cosmic String
let cosmicStringCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param stringCurvature "String Curvature" range(0.5, 3.0) default(1.5)
// @param stringThickness "String Thickness" range(0.01, 0.1) default(0.03)
// @param oscillationSpeed "Oscillation Speed" range(0.1, 3.0) default(1.0)
// @param glowRadius "Glow Radius" range(0.1, 0.5) default(0.2)
// @param warpStrength "Warp Strength" range(0.0, 0.3) default(0.1)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.7)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle quantumFoam "Quantum Foam" default(true)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float stringY = sin(p.x * stringCurvature * 3.14159 + timeVal * oscillationSpeed) * 0.5;
stringY += sin(p.x * stringCurvature * 6.28 - timeVal * oscillationSpeed * 1.5) * 0.2;
float distToString = abs(p.y - stringY);

if (warpStrength > 0.0) {
    float warp = exp(-distToString / glowRadius) * warpStrength;
    p.y += (p.y - stringY) * warp;
}

float3 col = float3(0.02, 0.02, 0.03);
if (quantumFoam > 0.5) {
    float foam = fract(sin(dot(floor(uv * 50.0 + timeVal), float2(12.9898, 78.233))) * 43758.5453);
    foam = step(0.95, foam) * 0.1;
    col += foam;
}

float stringCore = smoothstep(stringThickness, 0.0, distToString);
float3 stringColor = float3(color1Red, color1Green, color1Blue);
col += stringCore * stringColor;
float glowVal = exp(-distToString / glowRadius);
float3 glowColor = float3(color2Red, color2Green, color2Blue);
col += glowVal * glowColor * 0.5;
float energy = sin(p.x * 20.0 - timeVal * 5.0) * 0.5 + 0.5;
energy *= stringCore;
col += energy * float3(0.3, 0.5, 1.0) * 0.5;
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

/// Gravitational Lensing
let gravitationalLensingCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param lensStrength "Lens Strength" range(0.1, 1.0) default(0.5)
// @param lensRadius "Lens Radius" range(0.1, 0.5) default(0.3)
// @param einsteinRing "Einstein Ring" range(0.0, 1.0) default(0.5)
// @param backgroundComplexity "Background Complexity" range(1.0, 5.0) default(3.0)
// @param distortionSmooth "Distortion Smooth" range(0.1, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.7)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle showLens "Show Lens" default(false)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float2 lensCenter = float2(0.0, 0.0);
float r = length(p - lensCenter);
float2 distortedP = p;

if (r < lensRadius + 0.3) {
    float strength = lensStrength * exp(-r / distortionSmooth);
    float2 toCenter = normalize(p - lensCenter);
    distortedP = p + toCenter * strength * (lensRadius - r);
}

float2 bgP = distortedP * backgroundComplexity + 10.0;
float bg = sin(bgP.x) * sin(bgP.y);
bg += sin(bgP.x * 1.7 + timeVal) * sin(bgP.y * 1.3) * 0.5;
bg = bg * 0.5 + 0.5;
float3 col = 0.5 + 0.5 * cos(bg * 3.14 + float3(0.0, 2.0, 4.0));
col *= 0.3;

float stars = step(0.99, fract(sin(dot(floor(distortedP * 30.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.8;

if (einsteinRing > 0.0) {
    float ring = smoothstep(0.03, 0.0, abs(r - lensRadius * 1.2));
    ring *= smoothstep(lensRadius, lensRadius * 1.5, r);
    col += ring * float3(color1Red, color1Green, color1Blue) * einsteinRing;
}
if (showLens > 0.5) {
    float lens = smoothstep(lensRadius + 0.02, lensRadius, r);
    col = mix(col, float3(0.0, 0.0, 0.0), lens * 0.8);
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

/// Neutron Star Surface
let neutronStarCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param magneticPoles "Magnetic Poles" range(0.1, 0.5) default(0.2)
// @param surfaceTemp "Surface Temperature" range(0.0, 1.0) default(0.7)
// @param rotationSpeed "Rotation Speed" range(0.5, 5.0) default(2.0)
// @param pulseIntensity "Pulse Intensity" range(0.0, 1.0) default(0.5)
// @param crustPattern "Crust Pattern" range(2.0, 10.0) default(5.0)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle xrayBurst "X-Ray Burst" default(false)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float r = length(p);
float a = atan2(p.y, p.x) + timeVal * rotationSpeed;
float3 col = float3(0.02, 0.02, 0.03);

float surface = smoothstep(0.52, 0.48, r);
float3 surfaceColor = mix(float3(color1Red, color1Green, color1Blue), float3(1.0, 0.9, 0.8), surfaceTemp);
float crust = sin(a * crustPattern + r * 10.0) * sin(r * 15.0 - timeVal);
crust = crust * 0.5 + 0.5;
surfaceColor *= (0.8 + crust * 0.2);
col += surface * surfaceColor;

float pole1 = exp(-length(p - float2(0.0, 0.4)) / magneticPoles);
float pole2 = exp(-length(p - float2(0.0, -0.4)) / magneticPoles);
float pulseVal = sin(timeVal * 10.0) * 0.5 + 0.5;
pulseVal = pow(pulseVal, 4.0) * pulseIntensity;
col += (pole1 + pole2) * float3(color2Red, color2Green, color2Blue) * (0.5 + pulseVal);

if (xrayBurst > 0.5) {
    float burst = sin(timeVal * 20.0) * 0.5 + 0.5;
    burst = step(0.95, burst);
    col += burst * float3(1.0, 1.0, 1.0) * surface;
}
float atmosphere = smoothstep(0.6, 0.5, r) - surface;
col += atmosphere * float3(0.3, 0.4, 0.6) * 0.5;
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

/// Event Horizon
let eventHorizonCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param holeSize "Hole Size" range(0.1, 0.4) default(0.25)
// @param diskIntensity "Disk Intensity" range(0.3, 1.0) default(0.7)
// @param rotationSpeed "Rotation Speed" range(0.5, 3.0) default(1.0)
// @param lensingStrength "Lensing Strength" range(0.0, 0.5) default(0.2)
// @param hawkingRadiation "Hawking Radiation" range(0.0, 1.0) default(0.3)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle photonSphere "Photon Sphere" default(true)
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
float2 p = (uv - center) * zoom * 2.0 + center - 0.5;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.01, 0.01, 0.02);

// Gravitational lensing effect
float2 lensedP = p;
if (r > holeSize && r < 1.0) {
    float lensing = lensingStrength / (r - holeSize + 0.1);
    lensedP = p * (1.0 + lensing * 0.1);
}

// Accretion disk
float diskAngle = atan2(lensedP.y, lensedP.x) + timeVal * rotationSpeed;
float diskR = length(lensedP);
float diskMask = smoothstep(holeSize + 0.05, holeSize + 0.15, diskR);
diskMask *= smoothstep(0.6, 0.4, diskR);
diskMask *= smoothstep(0.1, 0.0, abs(lensedP.y / (diskR + 0.01)) - 0.3);
float diskSpiral = sin(diskAngle * 8.0 + diskR * 20.0 - timeVal * 3.0) * 0.5 + 0.5;
float3 diskColor = mix(float3(color1Red, color1Green, color1Blue), float3(1.0, 0.9, 0.7), diskSpiral);
col += diskMask * diskColor * diskIntensity;

// Photon sphere
if (photonSphere > 0.5) {
    float photonR = holeSize * 1.5;
    float photon = smoothstep(0.03, 0.0, abs(r - photonR));
    col += photon * float3(0.8, 0.9, 1.0) * 0.5;
}

// Event horizon (pure black)
float horizon = smoothstep(holeSize + 0.01, holeSize, r);
col *= (1.0 - horizon);

// Hawking radiation
if (hawkingRadiation > 0.0) {
    float radiation = smoothstep(holeSize + 0.02, holeSize, r);
    radiation *= sin(a * 20.0 + timeVal * 10.0) * 0.5 + 0.5;
    col += radiation * float3(color2Red, color2Green, color2Blue) * hawkingRadiation * 0.3;
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
