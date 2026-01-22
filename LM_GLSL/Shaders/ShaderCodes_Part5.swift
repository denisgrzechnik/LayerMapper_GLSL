//
//  ShaderCodes_Part5.swift
//  LM_GLSL
//
//  Shader codes - Part 5: ThreeD (3DStyle), Particles, Neon, Tech, Motion, Minimal
//

import Foundation

// MARK: - 3DStyle Category

let raymarchingCubeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param cubeSize "Cube Size" range(0.2, 1.0) default(0.5)
// @param cameraDistance "Camera Distance" range(2.0, 6.0) default(3.0)
// @param maxSteps "Max Steps" range(20.0, 100.0) default(50.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(0.5, 3.0) default(2.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotationX "Rotation X" range(0.0, 6.28) default(0.0)
// @param rotationY "Rotation Y" range(0.0, 6.28) default(0.0)
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
// @param bgRed "BG Red" range(0.0, 0.3) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.0)
// @param fov "FOV" range(0.5, 2.0) default(1.0)
// @param hitThreshold "Hit Threshold" range(0.0005, 0.01) default(0.001)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rotateY "Rotate Y" default(true)
// @toggle rotateX "Rotate X" default(false)
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
// @toggle rounded "Rounded" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 ro = float3(0.0, 0.0, -cameraDistance);
float3 rd = normalize(float3(p * fov, 1.0));
float t = 0.0;
int maxIter = int(maxSteps);

for (int i = 0; i < 100; i++) {
    if (i >= maxIter) break;
    float3 pos = ro + rd * t;
    float a = rotateY > 0.5 ? timeVal : 0.0;
    float c = cos(a); float s = sin(a);
    pos.xz = float2(pos.x * c - pos.z * s, pos.x * s + pos.z * c);
    if (rotateX > 0.5) {
        float ax = timeVal * 0.7;
        float cx = cos(ax); float sx = sin(ax);
        pos.yz = float2(pos.y * cx - pos.z * sx, pos.y * sx + pos.z * cx);
    }
    float d = max(abs(pos.x), max(abs(pos.y), abs(pos.z))) - cubeSize;
    if (d < hitThreshold) break;
    t += d;
    if (t > 10.0) break;
}

float3 col = float3(bgRed, bgGreen, bgBlue);
if (t < 10.0) {
    col = 0.5 + 0.5 * cos(t * colorCycles + float3(0.0, 2.0, 4.0) + colorOffset);
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let sphereGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param gridSize "Grid Size" range(3.0, 7.0) default(5.0)
// @param sphereSpacing "Sphere Spacing" range(0.2, 0.5) default(0.3)
// @param baseSize "Base Size" range(0.05, 0.2) default(0.1)
// @param sizeVariation "Size Variation" range(0.0, 0.1) default(0.05)
// @param waveAmplitude "Wave Amplitude" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.3) default(0.1)
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
// @param phaseX "Phase X" range(0.0, 2.0) default(1.0)
// @param phaseY "Phase Y" range(0.0, 2.0) default(1.0)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @param edgeSoftness "Edge Softness" range(0.0, 0.1) default(0.01)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorByPosition "Color By Position" default(true)
// @toggle depthShading "Depth Shading" default(true)
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
// @toggle wave "Wave" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x);

float3 col = float3(bgIntensity);
int gSize = int(gridSize);

for (int i = 0; i < 7; i++) {
    if (i >= gSize) break;
    for (int j = 0; j < 7; j++) {
        if (j >= gSize) break;
        float fi = float(i) - float(gSize - 1) * 0.5;
        float fj = float(j) - float(gSize - 1) * 0.5;
        float2 sphereCenter = float2(fi, fj) * sphereSpacing;
        float z = 0.0;
        if (wave > 0.5) z = sin(timeVal + fi * phaseX + fj * phaseY) * waveAmplitude;
        float size = baseSize + z * sizeVariation;
        float d = length(p - sphereCenter) / size;
        float sphere = smoothstep(1.0, 1.0 - edgeSoftness / size, d);
        float3 scol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + fj);
        if (depthShading > 0.5) scol *= (0.5 + z * depthFade);
        col += sphere * scol;
    }
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let tunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param tunnelTwist "Tunnel Twist" range(0.0, 5.0) default(2.0)
// @param colorCycles "Color Cycles" range(1.0, 5.0) default(1.0)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 0.2) default(0.1)
// @param centerFade "Center Fade" range(0.0, 1.0) default(0.0)
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
// @param segments "Segments" range(1.0, 12.0) default(1.0)
// @param ringWidth "Ring Width" range(0.0, 1.0) default(0.0)
// @param centerGlow "Center Glow" range(0.0, 2.0) default(1.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showRings "Show Rings" default(false)
// @toggle showCenter "Show Center" default(true)
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
// @toggle spiral "Spiral" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float r = length(p);
float a = atan2(p.y, p.x);
float tunnel = 1.0 / max(r, 0.01);
float z = tunnel + timeVal;

float3 col = 0.5 + 0.5 * cos(z + a * tunnelTwist + float3(0.0, 2.0, 4.0) + colorOffset);
col *= smoothstep(0.0, edgeFade, r);
col *= exp(-r * depthFade);
if (showCenter > 0.5) col += pow(max(0.0, 1.0 - r * 5.0), 2.0) * centerGlow;

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let torusCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param majorRadius "Major Radius" range(0.5, 2.0) default(1.0)
// @param minorRadius "Minor Radius" range(0.1, 0.8) default(0.4)
// @param cameraDistance "Camera Distance" range(3.0, 6.0) default(4.0)
// @param fov "FOV" range(0.5, 2.0) default(1.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(0.5, 3.0) default(1.0)
// @param stepSize "Step Size" range(0.3, 1.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotationX "Rotation X" range(0.0, 6.28) default(0.0)
// @param rotationY "Rotation Y" range(0.0, 6.28) default(0.0)
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
// @param bgRed "BG Red" range(0.0, 0.3) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rotateY "Rotate Y" default(true)
// @toggle rotateX "Rotate X" default(false)
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
// @toggle double "Double" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 ro = float3(0.0, 0.0, -cameraDistance);
float3 rd = normalize(float3(p, fov));
float t = 0.0;

for (int i = 0; i < 64; i++) {
    float3 pos = ro + rd * t;
    float a = rotateY > 0.5 ? timeVal : 0.0;
    pos.yz = float2(pos.y * cos(a) - pos.z * sin(a), pos.y * sin(a) + pos.z * cos(a));
    float2 q = float2(length(pos.xz) - majorRadius, pos.y);
    float d = length(q) - minorRadius;
    if (d < 0.001) break;
    t += d * stepSize;
    if (t > 10.0) break;
}

float3 col = (t < 10.0) ? 0.5 + 0.5 * cos(t * colorCycles + float3(0.0, 2.0, 4.0)) : float3(bgRed, bgGreen, bgBlue);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let infiniteGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param horizonY "Horizon Y" range(0.3, 0.7) default(0.5)
// @param gridDensity "Grid Density" range(0.2, 1.0) default(0.5)
// @param perspectiveStrength "Perspective Strength" range(0.2, 0.8) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param lineWidth "Line Width" range(0.02, 0.1) default(0.05)
// @param scrollSpeedX "Scroll Speed X" range(0.0, 2.0) default(1.0)
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
// @param gridRed "Grid Red" range(0.0, 1.0) default(0.0)
// @param gridGreen "Grid Green" range(0.0, 1.0) default(0.8)
// @param gridBlue "Grid Blue" range(0.0, 1.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.3) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle scrollX "Scroll X" default(true)
// @toggle scrollZ "Scroll Z" default(true)
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
// @toggle horizon "Horizon" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float z = 1.0 / (1.0 - p.y * perspectiveStrength);
float x = p.x * z;
if (scrollX > 0.5) x += timeVal * scrollSpeedX;
if (scrollZ > 0.5) z += timeVal;

float gridX = smoothstep(lineWidth, 0.0, abs(fract(x) - 0.5));
float gridZ = smoothstep(lineWidth, 0.0, abs(fract(z * gridDensity) - 0.5));
float grid = max(gridX, gridZ);

float3 gridCol = float3(gridRed, gridGreen, gridBlue);
float3 col = grid * gridCol;
col *= (1.0 - p.y) * 0.5;
col += float3(bgRed, bgGreen, bgBlue);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Particles Category

let particleFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param particleCount "Particle Count" range(10.0, 50.0) default(30.0)
// @param particleSize "Particle Size" range(0.005, 0.05) default(0.02)
// @param driftSpeedX "Drift Speed X" range(0.0, 0.3) default(0.1)
// @param driftSpeedY "Drift Speed Y" range(0.0, 0.3) default(0.15)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorByIndex "Color By Index" default(true)
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
// @toggle soft "Soft" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
int pCount = int(particleCount);

for (int i = 0; i < 50; i++) {
    if (i >= pCount) break;
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453 + timeVal * driftSpeedX),
        fract(sin(fi * 78.233) * 43758.5453 + timeVal * driftSpeedY)
    );
    float d = length(p - pos);
    float particle = soft > 0.5 ? smoothstep(particleSize, 0.0, d) : step(d, particleSize);
    float3 pcol = colorByIndex > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + colorOffset)) : float3(1.0);
    col += particle * pcol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let sparklesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param sparkleCount "Sparkle Count" range(10.0, 40.0) default(20.0)
// @param sparkleSize "Sparkle Size" range(0.01, 0.05) default(0.03)
// @param twinkleSpeed "Twinkle Speed" range(0.1, 2.0) default(0.5)
// @param twinkleSharpness "Twinkle Sharpness" range(1.0, 5.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param sparkleRed "Sparkle Red" range(0.0, 1.0) default(1.0)
// @param sparkleGreen "Sparkle Green" range(0.0, 1.0) default(0.9)
// @param sparkleBlue "Sparkle Blue" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle starShape "Star Shape" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(bgIntensity);
int sCount = int(sparkleCount);

for (int i = 0; i < 40; i++) {
    if (i >= sCount) break;
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453),
        fract(sin(fi * 78.233) * 43758.5453)
    );
    float phase = fract(timeVal * twinkleSpeed + fi * 0.1);
    float brightness2 = sin(phase * 3.14159);
    brightness2 = pow(brightness2, twinkleSharpness);
    float d = length(p - pos);
    float sparkle = smoothstep(sparkleSize, 0.0, d) * brightness2;
    float3 scol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi)) : float3(sparkleRed, sparkleGreen, sparkleBlue);
    col += sparkle * scol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let snowCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param layers "Layers" range(1.0, 5.0) default(3.0)
// @param flakesPerLayer "Flakes Per Layer" range(10.0, 40.0) default(20.0)
// @param baseSize "Base Size" range(0.005, 0.03) default(0.01)
// @param sizeVariation "Size Variation" range(0.0, 0.01) default(0.005)
// @param fallSpeed "Fall Speed" range(0.1, 1.0) default(0.3)
// @param speedVariation "Speed Variation" range(0.0, 0.5) default(0.2)
// @param swayAmount "Sway Amount" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.5)
// @param bgRed "BG Red" range(0.0, 0.3) default(0.1)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.15)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.2)
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
// @param layerFade "Layer Fade" range(0.0, 0.5) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle sway "Sway" default(true)
// @toggle depthFade "Depth Fade" default(true)
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
// @toggle blizzard "Blizzard" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgRed, bgGreen, bgBlue);
int layerCount = int(layers);
int flakeCount = int(flakesPerLayer);

for (int layer = 0; layer < 5; layer++) {
    if (layer >= layerCount) break;
    float fl = float(layer);
    float speedMod = fallSpeed + fl * speedVariation;
    float size = baseSize + fl * sizeVariation;
    for (int i = 0; i < 40; i++) {
        if (i >= flakeCount) break;
        float fi = float(i);
        float2 pos = float2(
            fract(sin(fi * 12.9898 + fl) * 43758.5453),
            fract(sin(fi * 78.233 + fl) * 43758.5453 - timeVal * speedMod)
        );
        if (sway > 0.5) pos.x += sin(pos.y * 10.0 + timeVal) * swayAmount;
        float d = length(p - pos);
        float snow = smoothstep(size, 0.0, d);
        float fade = depthFade > 0.5 ? (1.0 - fl * layerFade) : 1.0;
        col += snow * 0.3 * fade;
    }
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let firefliesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param fireflyCount "Firefly Count" range(5.0, 30.0) default(15.0)
// @param glowSize "Glow Size" range(0.05, 0.4) default(0.2)
// @param orbitRadius "Orbit Radius" range(0.3, 1.0) default(0.8)
// @param orbitSpeedX "Orbit Speed X" range(0.1, 1.0) default(0.5)
// @param orbitSpeedY "Orbit Speed Y" range(0.1, 1.0) default(0.3)
// @param blinkSpeed "Blink Speed" range(1.0, 5.0) default(3.0)
// @param blinkSharpness "Blink Sharpness" range(1.0, 4.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.2) default(0.02)
// @param bgGreen "BG Green" range(0.0, 0.2) default(0.03)
// @param bgBlue "BG Blue" range(0.0, 0.2) default(0.05)
// @param fireflyRed "Firefly Red" range(0.0, 1.0) default(0.8)
// @param fireflyGreen "Firefly Green" range(0.0, 1.0) default(1.0)
// @param fireflyBlue "Firefly Blue" range(0.0, 1.0) default(0.3)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle trail "Trail" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgRed, bgGreen, bgBlue);
int fCount = int(fireflyCount);

for (int i = 0; i < 30; i++) {
    if (i >= fCount) break;
    float fi = float(i);
    float2 pos = float2(
        sin(timeVal * orbitSpeedX + fi * 2.0) * orbitRadius,
        cos(timeVal * orbitSpeedY + fi * 1.7) * orbitRadius
    );
    float phase = sin(timeVal * blinkSpeed + fi * 5.0) * 0.5 + 0.5;
    phase = pow(phase, blinkSharpness);
    float d = length(p - pos);
    float glowVal = smoothstep(glowSize, 0.0, d) * phase;
    float3 ffCol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi)) : float3(fireflyRed, fireflyGreen, fireflyBlue);
    col += glowVal * ffCol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let dustMotesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param moteCount "Mote Count" range(10.0, 50.0) default(30.0)
// @param moteSize "Mote Size" range(0.005, 0.02) default(0.01)
// @param driftAmount "Drift Amount" range(0.02, 0.2) default(0.1)
// @param driftSpeedX "Drift Speed X" range(0.05, 0.3) default(0.1)
// @param driftSpeedY "Drift Speed Y" range(0.05, 0.3) default(0.08)
// @param minBrightness "Min Brightness" range(0.1, 0.5) default(0.3)
// @param brightVariation "Bright Variation" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.5)
// @param bgRed "BG Red" range(0.0, 0.2) default(0.05)
// @param bgGreen "BG Green" range(0.0, 0.2) default(0.04)
// @param bgBlue "BG Blue" range(0.0, 0.2) default(0.03)
// @param moteRed "Mote Red" range(0.0, 1.0) default(1.0)
// @param moteGreen "Mote Green" range(0.0, 1.0) default(0.95)
// @param moteBlue "Mote Blue" range(0.0, 1.0) default(0.8)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle floating "Floating" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgRed, bgGreen, bgBlue);
int mCount = int(moteCount);

for (int i = 0; i < 50; i++) {
    if (i >= mCount) break;
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453 + sin(timeVal * driftSpeedX + fi) * driftAmount),
        fract(sin(fi * 78.233) * 43758.5453 + cos(timeVal * driftSpeedY + fi) * driftAmount)
    );
    float d = length(p - pos);
    float mote = smoothstep(moteSize, 0.0, d);
    float bright = minBrightness + brightVariation * sin(timeVal + fi);
    float3 mcol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi)) : float3(moteRed, moteGreen, moteBlue);
    col += mote * bright * mcol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Neon Category

let neonLinesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param lineCount "Line Count" range(2.0, 10.0) default(5.0)
// @param lineThickness "Line Thickness" range(0.01, 0.05) default(0.02)
// @param glowRadius "Glow Radius" range(0.05, 0.3) default(0.15)
// @param waveFrequency "Wave Frequency" range(2.0, 10.0) default(5.0)
// @param waveAmplitude "Wave Amplitude" range(0.1, 0.5) default(0.3)
// @param lineSpacing "Line Spacing" range(0.1, 0.3) default(0.15)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorByLine "Color By Line" default(true)
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
// @toggle horizontal "Horizontal" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
int lCount = int(lineCount);

for (int i = 0; i < 10; i++) {
    if (i >= lCount) break;
    float fi = float(i);
    float y = sin(p.x * waveFrequency + timeVal + fi * 2.0 + colorOffset) * waveAmplitude + fi * lineSpacing - float(lCount) * lineSpacing * 0.5;
    float line = smoothstep(lineThickness, 0.0, abs(p.y - y));
    float glowVal = smoothstep(glowRadius, 0.0, abs(p.y - y));
    float3 lineCol = colorByLine > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + hueShift * 6.28)) : float3(1.0, 0.0, 0.5);
    col += line * lineCol;
    col += glowVal * lineCol * glowIntensity;
}

if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let neonSignCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringRadius "Ring Radius" range(0.2, 0.8) default(0.5)
// @param ringThickness "Ring Thickness" range(0.01, 0.1) default(0.03)
// @param glowRadius "Glow Radius" range(0.1, 0.4) default(0.2)
// @param crossSize "Cross Size" range(0.1, 0.5) default(0.3)
// @param crossThickness "Cross Thickness" range(0.01, 0.05) default(0.02)
// @param flickerSpeed "Flicker Speed" range(10.0, 50.0) default(30.0)
// @param flickerAmount "Flicker Amount" range(0.0, 0.2) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
// @param ringRed "Ring Red" range(0.0, 1.0) default(1.0)
// @param ringGreen "Ring Green" range(0.0, 1.0) default(0.1)
// @param ringBlue "Ring Blue" range(0.0, 1.0) default(0.5)
// @param crossRed "Cross Red" range(0.0, 1.0) default(0.1)
// @param crossGreen "Cross Green" range(0.0, 1.0) default(0.5)
// @param crossBlue "Cross Blue" range(0.0, 1.0) default(1.0)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCross "Show Cross" default(true)
// @toggle showRing "Show Ring" default(true)
// @toggle gradient "Gradient" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(bgIntensity);
float flickerVal = flicker > 0.5 ? (0.9 + flickerAmount * sin(timeVal * flickerSpeed) * sin(timeVal * 17.0)) : 1.0;
float3 ringCol = float3(ringRed, ringGreen, ringBlue) * flickerVal;
float3 crossCol = float3(crossRed, crossGreen, crossBlue) * flickerVal;

if (showRing > 0.5) {
    float d = abs(length(p) - ringRadius);
    float ring = smoothstep(ringThickness, 0.0, d);
    float glowVal = smoothstep(glowRadius, 0.0, d);
    col += ring * ringCol;
    col += glowVal * ringCol * glowIntensity;
}

if (showCross > 0.5) {
    float crossH = smoothstep(crossThickness, 0.0, abs(p.y)) * step(abs(p.x), crossSize);
    float crossV = smoothstep(crossThickness, 0.0, abs(p.x)) * step(abs(p.y), crossSize);
    col += (crossH + crossV) * crossCol;
}

if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let laserGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param gridScale "Grid Scale" range(3.0, 20.0) default(10.0)
// @param lineThickness "Line Thickness" range(0.02, 0.1) default(0.05)
// @param pulseSpeed "Pulse Speed" range(1.0, 5.0) default(3.0)
// @param pulseDepth "Pulse Depth" range(0.0, 0.5) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
// @param gridRedX "Grid Red X" range(0.0, 1.0) default(1.0)
// @param gridGreenX "Grid Green X" range(0.0, 1.0) default(0.0)
// @param gridBlueX "Grid Blue X" range(0.0, 1.0) default(0.5)
// @param gridRedY "Grid Red Y" range(0.0, 1.0) default(0.0)
// @param gridGreenY "Grid Green Y" range(0.0, 1.0) default(0.5)
// @param gridBlueY "Grid Blue Y" range(0.0, 1.0) default(1.0)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showIntersect "Show Intersect" default(true)
// @toggle gradient "Gradient" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * gridScale;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(bgIntensity);
float pulseVal = pulse > 0.5 ? (0.5 + pulseDepth * sin(timeVal * pulseSpeed)) : 1.0;

float gridX = smoothstep(lineThickness, 0.0, abs(fract(p.x) - 0.5));
float gridY = smoothstep(lineThickness, 0.0, abs(fract(p.y) - 0.5));

col += gridX * float3(gridRedX, gridGreenX, gridBlueX) * pulseVal;
col += gridY * float3(gridRedY, gridGreenY, gridBlueY) * pulseVal;
if (showIntersect > 0.5) col += gridX * gridY * float3(1.0, 0.5, 1.0);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let glowingEdgesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param boxSize "Box Size" range(0.2, 0.8) default(0.5)
// @param edgeThickness "Edge Thickness" range(0.01, 0.05) default(0.02)
// @param glowRadius "Glow Radius" range(0.1, 0.4) default(0.2)
// @param hueSpeed "Hue Speed" range(0.0, 0.5) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbowEdge "Rainbow Edge" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
float box = max(abs(p.x), abs(p.y));
float edge = smoothstep(edgeThickness, 0.0, abs(box - boxSize));
float glowVal = smoothstep(glowRadius, 0.0, abs(box - boxSize));

float hue = atan2(p.y, p.x) / 6.28 + 0.5 + timeVal * hueSpeed + hueShift;
float3 edgeCol = rainbowEdge > 0.5 ? (0.5 + 0.5 * cos(hue * 6.28 + float3(0.0, 2.0, 4.0) + colorOffset)) : float3(1.0, 0.0, 0.5);

col += edge * edgeCol;
col += glowVal * edgeCol * glowIntensity;

if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let cyberpunkCityCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param horizonLine "Horizon Line" range(0.2, 0.6) default(0.4)
// @param buildingDensity "Building Density" range(10.0, 30.0) default(20.0)
// @param maxBuildingHeight "Max Building Height" range(0.3, 0.8) default(0.6)
// @param windowDensity "Window Density" range(40.0, 100.0) default(80.0)
// @param windowProbability "Window Probability" range(0.5, 0.95) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param skyRed "Sky Red" range(0.0, 1.0) default(0.5)
// @param skyGreen "Sky Green" range(0.0, 1.0) default(0.0)
// @param skyBlue "Sky Blue" range(0.0, 1.0) default(0.3)
// @param horizonRed "Horizon Red" range(0.0, 0.3) default(0.0)
// @param horizonGreen "Horizon Green" range(0.0, 0.3) default(0.0)
// @param horizonBlue "Horizon Blue" range(0.0, 0.3) default(0.1)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showWindows "Show Windows" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(0.02, 0.01, 0.03);
if (p.y < horizonLine) {
    float grad = p.y / horizonLine;
    col = mix(float3(skyRed, skyGreen, skyBlue), float3(horizonRed, horizonGreen, horizonBlue), grad);
} else {
    float gy = (p.y - horizonLine) / (1.0 - horizonLine);
    float buildings = step(0.5, fract(sin(floor(p.x * buildingDensity) * 43.758) * 43758.5453));
    float height = fract(sin(floor(p.x * buildingDensity) * 78.233) * 43758.5453) * maxBuildingHeight;
    buildings *= step(gy, height);
    col += buildings * float3(0.05);
    if (showWindows > 0.5) {
        float window = step(windowProbability, fract(sin(dot(floor(p * float2(windowDensity, 40.0)), float2(12.9898, 78.233))) * 43758.5453));
        window *= buildings;
        float flickerVal = flicker > 0.5 ? (0.8 + 0.2 * sin(timeVal * 5.0 + floor(p.x * windowDensity))) : 1.0;
        float3 windowCol = 0.5 + 0.5 * cos(floor(p.x * buildingDensity) + float3(0.0, 2.0, 4.0) + hueShift * 6.28);
        col += window * windowCol * 0.5 * flickerVal;
    }
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Tech Category

let circuitBoardCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param gridScale "Grid Scale" range(10.0, 30.0) default(20.0)
// @param traceThickness "Trace Thickness" range(0.4, 0.6) default(0.48)
// @param traceProbability "Trace Probability" range(0.3, 0.8) default(0.7)
// @param padSize "Pad Size" range(0.1, 0.25) default(0.15)
// @param padProbability "Pad Probability" range(0.8, 1.0) default(0.9)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.3) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.2)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.1)
// @param traceRed "Trace Red" range(0.0, 1.0) default(0.6)
// @param traceGreen "Trace Green" range(0.0, 1.0) default(0.5)
// @param traceBlue "Trace Blue" range(0.0, 1.0) default(0.2)
// @param padRed "Pad Red" range(0.0, 1.0) default(0.8)
// @param padGreen "Pad Green" range(0.0, 1.0) default(0.7)
// @param padBlue "Pad Blue" range(0.0, 1.0) default(0.3)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showPads "Show Pads" default(true)
// @toggle showTraces "Show Traces" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * gridScale;
float2 i = floor(p);
float2 f = fract(p);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(bgRed, bgGreen, bgBlue);
float trace = 0.0;
float h = fract(sin(dot(i, float2(12.9898, 78.233))) * 43758.5453);

if (showTraces > 0.5) {
    if (h > traceProbability) {
        trace = smoothstep(0.52, traceThickness, abs(f.x - 0.5));
    } else if (h > traceProbability - 0.3) {
        trace = smoothstep(0.52, traceThickness, abs(f.y - 0.5));
    }
    col += trace * float3(traceRed, traceGreen, traceBlue);
}

if (showPads > 0.5) {
    float pad = step(length(f - 0.5), padSize) * step(padProbability, h);
    col += pad * float3(padRed, padGreen, padBlue);
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let dataStreamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param streamCount "Stream Count" range(5.0, 20.0) default(10.0)
// @param dotSize "Dot Size" range(0.02, 0.1) default(0.05)
// @param baseSpeed "Base Speed" range(0.5, 2.0) default(1.0)
// @param speedVariation "Speed Variation" range(0.0, 1.0) default(0.5)
// @param dotDensity "Dot Density" range(10.0, 30.0) default(20.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
// @param dotRed "Dot Red" range(0.0, 1.0) default(0.0)
// @param dotGreen "Dot Green" range(0.0, 1.0) default(1.0)
// @param dotBlue "Dot Blue" range(0.0, 1.0) default(0.5)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle horizontal "Horizontal" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
int sCount = int(streamCount);

for (int i = 0; i < 20; i++) {
    if (i >= sCount) break;
    float fi = float(i);
    float x = fi / float(sCount) + 0.05;
    float streamSpeed = baseSpeed + fract(sin(fi * 43.758) * 43758.5453) * speedVariation;
    float y = fract(timeVal * streamSpeed + fi * 0.3);
    float bit = step(0.5, fract(sin(floor(y * dotDensity) * 43.758 + fi) * 43758.5453));
    float d = length(p - float2(x, y));
    float glowVal = smoothstep(dotSize, 0.0, d) * bit;
    float3 dcol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + hueShift * 6.28)) : float3(dotRed, dotGreen, dotBlue);
    col += glowVal * dcol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let hologramCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringRadius "Ring Radius" range(0.3, 0.7) default(0.5)
// @param ringSegments "Ring Segments" range(10.0, 40.0) default(20.0)
// @param ringSpeed "Ring Speed" range(1.0, 10.0) default(5.0)
// @param scanlineFrequency "Scanline Frequency" range(20.0, 80.0) default(50.0)
// @param scanlineSpeed "Scanline Speed" range(5.0, 20.0) default(10.0)
// @param flickerSpeed "Flicker Speed" range(20.0, 80.0) default(50.0)
// @param flickerAmount "Flicker Amount" range(0.0, 0.1) default(0.05)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param holoRed "Holo Red" range(0.0, 1.0) default(0.0)
// @param holoGreen "Holo Green" range(0.0, 1.0) default(0.8)
// @param holoBlue "Holo Blue" range(0.0, 1.0) default(1.0)
// @param innerGlowRed "Inner Glow Red" range(0.0, 0.5) default(0.0)
// @param innerGlowGreen "Inner Glow Green" range(0.0, 0.5) default(0.2)
// @param innerGlowBlue "Inner Glow Blue" range(0.0, 0.5) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showRing "Show Ring" default(true)
// @toggle showScanlines "Show Scanlines" default(true)
// @toggle showInnerGlow "Show Inner Glow" default(true)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(0.0);
float3 holoCol = float3(holoRed, holoGreen, holoBlue);

if (showRing > 0.5) {
    float ring = smoothstep(0.02, 0.0, abs(r - ringRadius));
    ring *= 0.5 + 0.5 * sin(a * ringSegments - timeVal * ringSpeed);
    col += ring * holoCol;
}

if (showScanlines > 0.5) {
    float scanline = sin(p.y * scanlineFrequency + timeVal * scanlineSpeed) * 0.5 + 0.5;
    col *= 0.7 + 0.3 * scanline;
}

if (flicker > 0.5) {
    float flickerVal = 0.95 + flickerAmount * sin(timeVal * flickerSpeed);
    col *= flickerVal;
}

if (showInnerGlow > 0.5) {
    col += smoothstep(0.6, 0.0, r) * float3(innerGlowRed, innerGlowGreen, innerGlowBlue) * 0.3;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let binaryRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param columnCount "Column Count" range(10.0, 30.0) default(20.0)
// @param dotsPerColumn "Dots Per Column" range(5.0, 15.0) default(10.0)
// @param baseSpeed "Base Speed" range(0.3, 1.0) default(0.5)
// @param speedVariation "Speed Variation" range(0.0, 0.5) default(0.25)
// @param dotSpacing "Dot Spacing" range(0.03, 0.1) default(0.05)
// @param dotSize "Dot Size" range(0.01, 0.05) default(0.02)
// @param fadeFactor "Fade Factor" range(0.05, 0.2) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param mainRed "Main Red" range(0.0, 1.0) default(0.0)
// @param mainGreen "Main Green" range(0.0, 1.0) default(1.0)
// @param mainBlue "Main Blue" range(0.0, 1.0) default(0.3)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle trail "Trail" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(0.0);
int cCount = int(columnCount);
int dCount = int(dotsPerColumn);

for (int i = 0; i < 30; i++) {
    if (i >= cCount) break;
    float fi = float(i);
    float x = fi / float(cCount) + 0.025;
    float fallSpeed = baseSpeed + fract(sin(fi * 12.9898) * 43758.5453) * speedVariation;
    float y = fract(timeVal * fallSpeed + fi * 0.5);
    for (int j = 0; j < 15; j++) {
        if (j >= dCount) break;
        float fj = float(j);
        float by = fract(y + fj * dotSpacing);
        float bit = step(0.5, fract(sin(fj * 78.233 + floor(timeVal * 5.0) + fi) * 43758.5453));
        float d = length(p - float2(x, by));
        float glowVal = smoothstep(dotSize, 0.0, d);
        float fade = trail > 0.5 ? (1.0 - fj * fadeFactor) : 1.0;
        float3 dcol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + hueShift * 6.28)) : float3(mainRed, mainGreen, mainBlue);
        col += glowVal * dcol * fade;
    }
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let loadingSpinnerCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param innerRadius "Inner Radius" range(0.2, 0.4) default(0.35)
// @param outerRadius "Outer Radius" range(0.35, 0.5) default(0.45)
// @param segments "Segments" range(6.0, 20.0) default(12.0)
// @param gapSize "Gap Size" range(0.2, 0.5) default(0.35)
// @param fadePower "Fade Power" range(1.0, 4.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
// @param spinnerRed "Spinner Red" range(0.0, 1.0) default(0.2)
// @param spinnerGreen "Spinner Green" range(0.0, 1.0) default(0.5)
// @param spinnerBlue "Spinner Blue" range(0.0, 1.0) default(1.0)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
float seg = floor(a / 6.28 * segments + 0.5);
float arcLength = mod(timeVal, segments);
float bright = 1.0 - mod(seg - arcLength + segments, segments) / segments;
bright = pow(bright, fadePower);

float ring = smoothstep(outerRadius, outerRadius - 0.05, r) * smoothstep(innerRadius, innerRadius + 0.05, r);
ring *= step(abs(fract(a / 6.28 * segments) - 0.5), gapSize);

float3 spinCol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + seg * 0.5 + hueShift * 6.28)) : float3(spinnerRed, spinnerGreen, spinnerBlue);
col += ring * bright * spinCol;

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Motion Category

let flowFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param fieldScale "Field Scale" range(2.0, 10.0) default(5.0)
// @param flowLayers "Flow Layers" range(1.0, 5.0) default(3.0)
// @param flowStrength "Flow Strength" range(0.05, 0.2) default(0.1)
// @param colorCycles "Color Cycles" range(1.0, 10.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.0)
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
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
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
// @toggle turbulent "Turbulent" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * fieldScale;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float2 flow = float2(0.0);
int layers = int(flowLayers);
for (int i = 0; i < 5; i++) {
    if (i >= layers) break;
    float fi = float(i);
    flow.x += sin(p.y * (fi + 1.0) + timeVal);
    flow.y += cos(p.x * (fi + 1.0) + timeVal);
}
flow *= flowStrength;

float3 col = rainbow > 0.5 ? (0.5 + 0.5 * cos(length(flow) * colorCycles + float3(0.0, 2.0, 4.0) + timeVal + colorOffset + hueShift * 6.28)) : float3(length(flow) * 2.0);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let vortexCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param spiralTightness "Spiral Tightness" range(1.0, 10.0) default(5.0)
// @param centerBrightness "Center Brightness" range(0.0, 2.0) default(1.0)
// @param centerFalloff "Center Falloff" range(2.0, 10.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.0)
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
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle showCenter "Show Center" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;
float r = length(p);
float a = atan2(p.y, p.x);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

a += timeVal;
a += r * spiralTightness;

float3 col = rainbow > 0.5 ? (0.5 + 0.5 * cos(a + float3(0.0, 2.0, 4.0) + colorOffset + hueShift * 6.28)) : float3(0.5 + 0.5 * sin(a));
col *= smoothstep(1.0, 0.0, r);
if (showCenter > 0.5) col += pow(max(0.0, 1.0 - r * centerFalloff), 2.0) * centerBrightness;

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let wavesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveCount "Wave Count" range(2.0, 8.0) default(5.0)
// @param baseFrequency "Base Frequency" range(5.0, 20.0) default(10.0)
// @param waveAmplitude "Wave Amplitude" range(0.1, 0.4) default(0.2)
// @param lineThickness "Line Thickness" range(0.01, 0.05) default(0.02)
// @param glowRadius "Glow Radius" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.0)
// @param waveRed "Wave Red" range(0.0, 1.0) default(0.2)
// @param waveGreen "Wave Green" range(0.0, 1.0) default(0.5)
// @param waveBlue "Wave Blue" range(0.0, 1.0) default(1.0)
// @param glowRed "Glow Red" range(0.0, 0.5) default(0.1)
// @param glowGreen "Glow Green" range(0.0, 0.5) default(0.2)
// @param glowBlue "Glow Blue" range(0.0, 0.5) default(0.4)
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
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float wave = 0.0;
int wCount = int(waveCount);
for (int i = 0; i < 8; i++) {
    if (i >= wCount) break;
    float fi = float(i);
    wave += sin(p.x * baseFrequency * (fi + 1.0) + timeVal * (fi + 1.0)) * (1.0 / (fi + 1.0));
}
wave = wave * waveAmplitude + 0.5;

float3 col = float3(bgIntensity);
float line = smoothstep(lineThickness, 0.0, abs(p.y - wave));
float glowVal = smoothstep(glowRadius, 0.0, abs(p.y - wave));

float3 waveCol = rainbow > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + p.x * 5.0 + hueShift * 6.28)) : float3(waveRed, waveGreen, waveBlue);
col += line * waveCol;
if (glow > 0.5) col += glowVal * float3(glowRed, glowGreen, glowBlue) * glowIntensity;

if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let oscillationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(3.0, 12.0) default(8.0)
// @param ringRadius "Ring Radius" range(0.1, 0.3) default(0.2)
// @param orbitRadius "Orbit Radius" range(0.3, 0.7) default(0.5)
// @param phaseOffset "Phase Offset" range(0.0, 1.0) default(0.5)
// @param lineThickness "Line Thickness" range(0.01, 0.05) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
int rCount = int(ringCount);

for (int i = 0; i < 12; i++) {
    if (i >= rCount) break;
    float fi = float(i);
    float phase = timeVal + fi * phaseOffset;
    float2 center = float2(sin(phase), cos(phase * 1.3)) * orbitRadius;
    float d = length(p - center);
    float ring = smoothstep(lineThickness, 0.0, abs(d - ringRadius));
    float3 ringCol = rainbow > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + colorOffset + hueShift * 6.28)) : float3(1.0);
    col += ring * ringCol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let pendulumCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param pendulumCount "Pendulum Count" range(2.0, 8.0) default(5.0)
// @param baseLength "Base Length" range(0.2, 0.5) default(0.3)
// @param lengthStep "Length Step" range(0.05, 0.15) default(0.1)
// @param swingAngle "Swing Angle" range(0.3, 1.2) default(0.8)
// @param phaseOffset "Phase Offset" range(0.0, 1.0) default(0.5)
// @param ballSize "Ball Size" range(0.03, 0.08) default(0.05)
// @param lineThickness "Line Thickness" range(0.005, 0.02) default(0.01)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
// @param pivotX "Pivot X" range(0.0, 1.0) default(0.0)
// @param pivotY "Pivot Y" range(0.5, 1.0) default(0.8)
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
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle showLines "Show Lines" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = uv * 2.0 - 1.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgIntensity);
float2 pivot = float2(pivotX, pivotY);
int pCount = int(pendulumCount);

for (int i = 0; i < 8; i++) {
    if (i >= pCount) break;
    float fi = float(i);
    float len = baseLength + fi * lengthStep;
    float angle = sin(timeVal + fi * phaseOffset) * swingAngle;
    float2 bob = pivot + float2(sin(angle), -cos(angle)) * len;
    
    if (showLines > 0.5) {
        float2 dir = normalize(bob - pivot);
        float2 toP = p - pivot;
        float proj = dot(toP, dir);
        float2 closest = pivot + dir * clamp(proj, 0.0, len);
        float lineDist = length(p - closest);
        float line = smoothstep(lineThickness, 0.0, lineDist);
        col += line * 0.3;
    }
    
    float d = length(p - bob);
    float ball = smoothstep(ballSize, ballSize - 0.02, d);
    float3 ballCol = rainbow > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + hueShift * 6.28)) : float3(1.0);
    col += ball * ballCol;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Minimal Category

let singleCircleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param circleRadius "Circle Radius" range(0.2, 0.8) default(0.5)
// @param edgeSoftness "Edge Softness" range(0.01, 0.1) default(0.04)
// @param circleRed "Circle Red" range(0.0, 1.0) default(1.0)
// @param circleGreen "Circle Green" range(0.0, 1.0) default(1.0)
// @param circleBlue "Circle Blue" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.0)
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
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle filled "Filled" default(true)
// @toggle outline "Outline" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;
float d = length(p);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float radiusVal = pulse > 0.5 ? circleRadius + 0.05 * sin(timeVal * 3.0) : circleRadius;
float circle = filled > 0.5 ? smoothstep(radiusVal + edgeSoftness, radiusVal - edgeSoftness, d) : smoothstep(edgeSoftness, 0.0, abs(d - radiusVal));

float3 col = float3(bgRed, bgGreen, bgBlue);
float3 circleCol = float3(circleRed, circleGreen, circleBlue);
col = mix(col, circleCol, circle);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let crosshairCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param lineThickness "Line Thickness" range(0.01, 0.05) default(0.02)
// @param innerGap "Inner Gap" range(0.05, 0.2) default(0.1)
// @param outerLength "Outer Length" range(0.2, 0.6) default(0.4)
// @param lineRed "Line Red" range(0.0, 1.0) default(1.0)
// @param lineGreen "Line Green" range(0.0, 1.0) default(1.0)
// @param lineBlue "Line Blue" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.02)
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
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCenter "Show Center" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float3 col = float3(bgIntensity);
float3 lineCol = float3(lineRed, lineGreen, lineBlue);

float h = smoothstep(lineThickness, 0.0, abs(p.y)) * step(innerGap, abs(p.x)) * step(abs(p.x), outerLength);
float v = smoothstep(lineThickness, 0.0, abs(p.x)) * step(innerGap, abs(p.y)) * step(abs(p.y), outerLength);
col += (h + v) * lineCol;

if (showCenter > 0.5) {
    float centerDot = smoothstep(0.03, 0.0, length(p));
    col += centerDot * lineCol;
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(timeVal * 3.0);
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let dotGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param gridScale "Grid Scale" range(5.0, 20.0) default(10.0)
// @param dotRadius "Dot Radius" range(0.05, 0.25) default(0.15)
// @param dotSharpness "Dot Sharpness" range(0.02, 0.1) default(0.05)
// @param dotRed "Dot Red" range(0.0, 1.0) default(1.0)
// @param dotGreen "Dot Green" range(0.0, 1.0) default(1.0)
// @param dotBlue "Dot Blue" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.0)
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
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorful "Colorful" default(false)
// @toggle hexGrid "Hex Grid" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 p = fract(uv * gridScale) - 0.5;
float2 cellId = floor(uv * gridScale);
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float d = length(p);
float radiusVal = pulse > 0.5 ? dotRadius + 0.03 * sin(timeVal * 3.0 + cellId.x + cellId.y) : dotRadius;
float dot = smoothstep(radiusVal, radiusVal - dotSharpness, d);

float3 col = float3(bgRed, bgGreen, bgBlue);
float3 dCol = colorful > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + cellId.x * 0.5 + cellId.y * 0.3 + hueShift * 6.28)) : float3(dotRed, dotGreen, dotBlue);
col = mix(col, dCol, dot);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let stripesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param stripeCount "Stripe Count" range(3.0, 20.0) default(10.0)
// @param stripeRatio "Stripe Ratio" range(0.2, 0.8) default(0.5)
// @param stripeRed1 "Stripe Red 1" range(0.0, 1.0) default(0.9)
// @param stripeGreen1 "Stripe Green 1" range(0.0, 1.0) default(0.9)
// @param stripeBlue1 "Stripe Blue 1" range(0.0, 1.0) default(0.9)
// @param stripeRed2 "Stripe Red 2" range(0.0, 1.0) default(0.1)
// @param stripeGreen2 "Stripe Green 2" range(0.0, 1.0) default(0.1)
// @param stripeBlue2 "Stripe Blue 2" range(0.0, 1.0) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgIntensity "BG Intensity" range(0.0, 0.2) default(0.0)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float coord = vertical > 0.5 ? uv.y : uv.x;
if (diagonal > 0.5) coord = (uv.x + uv.y) * 0.5;
coord += timeVal;

float stripe = step(stripeRatio, fract(coord * stripeCount));
float3 col1 = float3(stripeRed1, stripeGreen1, stripeBlue1);
float3 col2 = float3(stripeRed2, stripeGreen2, stripeBlue2);
float3 col = mix(col1, col2, stripe);

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3 + hueShift * 6.28);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let pulsingDotCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param baseRadius "Base Radius" range(0.1, 0.5) default(0.3)
// @param pulseAmount "Pulse Amount" range(0.05, 0.2) default(0.1)
// @param edgeSoftness "Edge Softness" range(0.01, 0.1) default(0.02)
// @param dotRed "Dot Red" range(0.0, 1.0) default(1.0)
// @param dotGreen "Dot Green" range(0.0, 1.0) default(1.0)
// @param dotBlue "Dot Blue" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.0)
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
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorPulse "Color Pulse" default(false)
// @toggle filled "Filled" default(true)
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
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float pulseVal = baseRadius + pulseAmount * sin(timeVal);
float d = length(p);
float dotShape = filled > 0.5 ? smoothstep(pulseVal + edgeSoftness, pulseVal, d) : smoothstep(edgeSoftness, 0.0, abs(d - pulseVal));

float3 col = float3(bgRed, bgGreen, bgBlue);
float3 dCol = colorPulse > 0.5 ? (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal + hueShift * 6.28)) : float3(dotRed, dotGreen, dotBlue);
col = mix(col, dCol, dotShape);

if (glow > 0.5) {
    float glowShape = smoothstep(pulseVal + 0.3, pulseVal, d);
    col += glowShape * dCol * glowIntensity * 0.5;
}
if (bloom > 0.5) { float lum = dot(col, float3(0.299, 0.587, 0.114)); if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity; }
if (colorShift > 0.5) col *= 0.8 + 0.2 * cos(float3(0.0, 2.0, 4.0) + timeVal * 0.3);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
if (chromatic > 0.5) { col.r *= 1.0 + chromaticAmount * 5.0; col.b *= 1.0 - chromaticAmount * 5.0; }
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
if (noise > 0.5) { float n = fract(sin(dot(uv * 100.0 * noiseScale, float2(12.9898, 78.233))) * 43758.5453); col += (n - 0.5) * 0.1; }
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (filmGrain > 0.5) { float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453); col += (grain - 0.5) * 0.08; }
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 1.5, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""
