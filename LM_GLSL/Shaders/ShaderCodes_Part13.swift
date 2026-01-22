//
//  ShaderCodes_Part13.swift
//  LM_GLSL
//
//  Shader codes - Part 13: Cyberpunk & Sci-Fi Effects (20 shaders)
//

import Foundation

// MARK: - Cyberpunk & Sci-Fi Effects

/// Neon Grid City
let neonGridCityCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param gridDensity "Grid Density" range(5.0, 25.0) default(10.0)
// @param neonIntensity "Neon Intensity" range(0.5, 2.0) default(1.2)
// @param perspectiveAmount "Perspective" range(0.0, 1.0) default(0.7)
// @param scrollSpeed "Scroll Speed" range(0.0, 2.0) default(0.5)
// @param colorCycle "Color Cycle" range(0.0, 3.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle buildings "Buildings" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = uv - ctr * 0.5;
p = (p - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = p - 0.5;
p = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs) + 0.5;
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

float3 neonCol1 = float3(color1R, color1G, color1B);
float3 neonCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.02, 0.08);
float horizon = 0.4;

if (p.y < horizon) {
    float perspective = pow((horizon - p.y) / horizon, perspectiveAmount + 0.5);
    float2 gridP = float2(p.x - 0.5, perspective);
    gridP.y += timeVal * scrollSpeed;
    float gridX = smoothstep(0.02, 0.0, abs(fract(gridP.x * gridDensity) - 0.5) - 0.45);
    float gridY = smoothstep(0.02, 0.0, abs(fract(gridP.y * gridDensity * 0.5) - 0.5) - 0.45);
    float grid = max(gridX, gridY);
    float3 gridColor;
    if (rainbow > 0.5) {
        gridColor = 0.5 + 0.5 * cos(timeVal * colorCycle + p.x * 3.0 + float3(0.0, 2.094, 4.188));
    } else {
        gridColor = 0.5 + 0.5 * cos(timeVal * colorCycle + float3(0.0, 2.0, 4.0));
    }
    col += grid * gridColor * neonIntensity * pulseAmt * (1.0 - perspective * 0.5);
}

if (buildings > 0.5 && p.y > horizon - 0.1) {
    for (int i = 0; i < 15; i++) {
        float fi = float(i);
        float bx = fract(sin(fi * 127.1) * 43758.5453);
        float bw = fract(sin(fi * 311.7) * 43758.5453) * 0.05 + 0.02;
        float bh = fract(sin(fi * 178.3) * 43758.5453) * 0.3 + 0.1;
        float building = step(abs(p.x - bx), bw) * step(horizon, p.y) * step(p.y, horizon + bh);
        col = mix(col, float3(0.05, 0.05, 0.1), building);
        float windowY = floor((p.y - horizon) * 30.0);
        float windowX = floor((p.x - bx + bw) * 50.0);
        float window = step(0.5, fract(sin(windowX * 127.1 + windowY * 311.7 + fi) * 43758.5453));
        window *= building;
        float3 windowColor = mix(neonCol1, neonCol2, fract(fi * 0.3));
        if (neon > 0.5) windowColor = pow(windowColor, float3(0.7)) * 1.3;
        if (pastel > 0.5) windowColor = mix(windowColor, float3(1.0), 0.3);
        col += window * windowColor * 0.3 * neonIntensity;
    }
}

if (glow > 0.5) {
    float glw = smoothstep(horizon + 0.1, horizon - 0.1, p.y);
    col += glw * neonCol1 * 0.2 * neonIntensity * glowIntensity;
}
if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
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
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Holographic Interface
let holographicInterfaceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param elementCount "Element Count" range(3.0, 10.0) default(6.0)
// @param scanlineSpeed "Scanline Speed" range(0.5, 3.0) default(1.5)
// @param glitchAmount "Glitch Amount" range(0.0, 0.5) default(0.1)
// @param transparency "Transparency" range(0.3, 1.0) default(0.5)
// @param flickerRate "Flicker Rate" range(0.0, 1.0) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle hexGrid "Hex Grid" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
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
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 holoCol1 = float3(color1R, color1G, color1B);
float3 holoCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.05, 0.08);

float scanline = fract(p.y * 100.0 - timeVal * scanlineSpeed);
scanline = step(0.9, scanline) * 0.1;
if (scanlines > 0.5) col += scanline * holoCol1;

if (hexGrid > 0.5) {
    float2 hexP = p * 20.0;
    float hex = smoothstep(0.1, 0.05, length(fract(hexP) - 0.5) - 0.3);
    col += hex * holoCol2 * transparency * 0.3;
}

for (int i = 0; i < 10; i++) {
    if (float(i) >= elementCount) break;
    float fi = float(i);
    float2 elemPos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1,
        fract(sin(fi * 311.7) * 43758.5453) * 0.8 + 0.1
    );
    float elemSize = fract(sin(fi * 178.3) * 43758.5453) * 0.1 + 0.05;
    float elem = smoothstep(elemSize + 0.01, elemSize, length(p - elemPos));
    elem -= smoothstep(elemSize - 0.01, elemSize - 0.02, length(p - elemPos));
    float flickVal = 1.0;
    if (flickerRate > 0.0) {
        flickVal = step(flickerRate, fract(sin(timeVal * 10.0 + fi * 5.0) * 0.5 + 0.5));
    }
    float3 elemColor;
    if (rainbow > 0.5) {
        elemColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
    } else {
        elemColor = mix(holoCol1, holoCol2, fract(fi * 0.3));
    }
    if (neon > 0.5) elemColor = pow(elemColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) elemColor = mix(elemColor, float3(1.0), 0.3);
    col += elem * elemColor * transparency * flickVal * pulseAmt;
}

if (glitchAmount > 0.0) {
    float glitch = step(1.0 - glitchAmount, fract(sin(floor(timeVal * 20.0) * 43.758) * 43758.5453));
    if (glitch > 0.5) col = mix(col, col.gbr, 0.5);
}

if (glow > 0.5) col += exp(-length(p - 0.5) * 3.0) * holoCol1 * 0.2 * glowIntensity;
if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

col *= transparency + 0.5;

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
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Data Matrix
let dataMatrixCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param columnDensity "Column Density" range(10.0, 50.0) default(25.0)
// @param fallSpeed "Fall Speed" range(0.5, 3.0) default(1.5)
// @param charBrightness "Character Brightness" range(0.5, 2.0) default(1.0)
// @param trailLength "Trail Length" range(0.1, 0.5) default(0.3)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(false)
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
// @toggle neon "Neon" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 matrixCol1 = float3(color1R, color1G, color1B);
float3 matrixCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.05, 0.02);
float columnWidth = 1.0 / columnDensity;

for (int c = 0; c < 50; c++) {
    float fc = float(c);
    if (fc >= columnDensity) break;
    float columnX = fc * columnWidth + columnWidth * 0.5;
    float columnSpeed = fract(sin(fc * 127.1) * 43758.5453) * 0.5 + 0.75;
    float columnOffset = fract(sin(fc * 311.7) * 43758.5453);
    float streamY = fract(timeVal * fallSpeed * columnSpeed + columnOffset);
    float dist = abs(p.x - columnX);
    if (dist < columnWidth * 0.5) {
        float charY = fract(p.y * 20.0);
        float charCell = floor(p.y * 20.0);
        float charChange = floor(timeVal * 10.0 + charCell * 0.5 + fc);
        float charPattern = fract(sin(charChange * 43.758 + fc * 78.233) * 43758.5453);
        float charVal = step(0.3, charPattern) * step(charPattern, 0.7);
        charVal *= step(charY, 0.8);
        float relY = 1.0 - p.y;
        float streamDist = relY - streamY;
        float trail = smoothstep(0.0, trailLength, streamDist) * smoothstep(trailLength + 0.1, trailLength, streamDist);
        float head = smoothstep(0.02, 0.0, abs(streamDist));
        float3 charColor;
        if (colorful > 0.5 || rainbow > 0.5) {
            charColor = 0.5 + 0.5 * cos(fc * 0.3 + timeVal + float3(0.0, 2.0, 4.0));
        } else {
            charColor = matrixCol1;
        }
        if (neon > 0.5) charColor = pow(charColor, float3(0.7)) * 1.3;
        if (pastel > 0.5) charColor = mix(charColor, float3(1.0), 0.3);
        col += charVal * trail * charColor * charBrightness * 0.5 * pulseAmt;
        col += head * matrixCol2 * charBrightness;
        if (glow > 0.5 && glowAmount > 0.0) {
            float glw = exp(-dist / columnWidth * 3.0) * trail * glowAmount * glowIntensity;
            col += glw * charColor * 0.3;
        }
    }
}

if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Force Field
let forceFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param fieldRadius "Field Radius" range(0.2, 0.6) default(0.4)
// @param hexSize "Hex Size" range(0.02, 0.1) default(0.05)
// @param pulseSpeed "Pulse Speed" range(0.5, 3.0) default(1.5)
// @param distortionAmount "Distortion Amount" range(0.0, 0.5) default(0.1)
// @param energyFlow "Energy Flow" range(0.0, 1.0) default(0.6)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle impactEffect "Impact Effect" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 fieldCol1 = float3(color1R, color1G, color1B);
float3 fieldCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.02, 0.05);
float r = length(p);
float a = atan2(p.y, p.x);

float fieldMask = smoothstep(fieldRadius + 0.05, fieldRadius, r);
fieldMask -= smoothstep(fieldRadius - 0.02, fieldRadius - 0.05, r);

float2 hexP = p * (1.0 / hexSize);
float2 hexGrid = floor(hexP);
float hexPattern = 0.0;
for (int hx = -1; hx <= 1; hx++) {
    for (int hy = -1; hy <= 1; hy++) {
        float2 cell = hexGrid + float2(float(hx), float(hy));
        float2 cellCenter = cell + 0.5;
        float d = length(hexP - cellCenter);
        hexPattern = max(hexPattern, smoothstep(0.5, 0.4, d));
    }
}

float pulsing = sin(r * 20.0 - timeVal * pulseSpeed * 5.0) * 0.5 + 0.5;
pulsing *= energyFlow;

float3 fieldColor;
if (rainbow > 0.5) {
    fieldColor = 0.5 + 0.5 * cos(timeVal + r * 5.0 + float3(0.0, 2.094, 4.188));
} else {
    fieldColor = mix(fieldCol1, fieldCol2, pulsing);
}
if (neon > 0.5) fieldColor = pow(fieldColor, float3(0.7)) * 1.3;
if (pastel > 0.5) fieldColor = mix(fieldColor, float3(1.0), 0.3);

col += fieldMask * hexPattern * fieldColor * 0.8 * pulseAmt;
col += fieldMask * (1.0 - hexPattern) * fieldColor * 0.2;

if (impactEffect > 0.5) {
    float impactTime = fract(timeVal * 0.5);
    float2 impactPos = float2(cos(floor(timeVal * 0.5) * 2.0), sin(floor(timeVal * 0.5) * 3.0)) * fieldRadius * 0.8;
    float impactDist = length(p - impactPos);
    float impact = smoothstep(impactTime * 0.3, 0.0, impactDist) * (1.0 - impactTime);
    impact *= fieldMask;
    col += impact * float3(1.0, 0.8, 0.3);
    float ripple = sin(impactDist * 30.0 - impactTime * 20.0) * (1.0 - impactTime);
    ripple *= smoothstep(0.3, 0.0, impactDist) * fieldMask;
    col += ripple * fieldCol2 * 0.3;
}

float edge = smoothstep(fieldRadius, fieldRadius - 0.01, r) - smoothstep(fieldRadius - 0.01, fieldRadius - 0.02, r);
if (glow > 0.5) col += edge * fieldCol1 * glowIntensity;

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edg = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edg);
}
if (outline > 0.5) {
    float edg = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edg);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Warp Drive
let warpDriveCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param starDensity "Star Density" range(50.0, 200.0) default(100.0)
// @param warpSpeed "Warp Speed" range(1.0, 5.0) default(2.5)
// @param streakLength "Streak Length" range(0.1, 0.5) default(0.3)
// @param tunnelWidth "Tunnel Width" range(0.1, 0.5) default(0.3)
// @param colorTemperature "Color Temperature" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle hyperspace "Hyperspace" default(false)
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
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 starCol1 = float3(color1R, color1G, color1B);
float3 starCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

for (int i = 0; i < 200; i++) {
    if (float(i) >= starDensity) break;
    float fi = float(i);
    float starAngle = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
    float starDist = fract(sin(fi * 311.7) * 43758.5453 + timeVal * warpSpeed * 0.2);
    float2 starPos = float2(cos(starAngle), sin(starAngle)) * (tunnelWidth + starDist * (1.0 - tunnelWidth));
    float2 prevPos = float2(cos(starAngle), sin(starAngle)) * (tunnelWidth + (starDist - streakLength * warpSpeed * 0.05) * (1.0 - tunnelWidth));
    float2 toP = p - starPos;
    float2 streakDir = normalize(starPos - prevPos);
    float along = dot(toP, -streakDir);
    float perp = abs(dot(toP, float2(streakDir.y, -streakDir.x)));
    float streak = smoothstep(streakLength * starDist, 0.0, along) * step(0.0, along);
    streak *= smoothstep(0.02, 0.005, perp);
    streak *= smoothstep(0.0, 0.1, starDist);
    float3 starColor;
    if (hyperspace > 0.5 || rainbow > 0.5) {
        starColor = 0.5 + 0.5 * cos(fi * 0.1 + timeVal + float3(0.0, 2.0, 4.0));
    } else {
        starColor = mix(starCol1, starCol2, colorTemperature);
    }
    if (neon > 0.5) starColor = pow(starColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) starColor = mix(starColor, float3(1.0), 0.3);
    col += streak * starColor * pulseAmt;
}

float tunnel = smoothstep(tunnelWidth, tunnelWidth - 0.05, r);
if (hyperspace > 0.5) {
    float3 tunnelColor = 0.5 + 0.5 * cos(r * 10.0 + timeVal * 3.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, tunnelColor * 0.3, tunnel);
}
if (glow > 0.5) col += exp(-r * 2.0) * starCol1 * 0.2 * glowIntensity;

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Cyber Brain
let cyberBrainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param neuronDensity "Neuron Density" range(10.0, 30.0) default(20.0)
// @param synapseSpeed "Synapse Speed" range(0.5, 3.0) default(1.5)
// @param pulseRate "Pulse Rate" range(0.5, 3.0) default(1.0)
// @param connectionStrength "Connection Strength" range(0.3, 1.0) default(0.6)
// @param glowRadius "Glow Radius" range(0.02, 0.15) default(0.05)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle activeThought "Active Thought" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 neuronCol1 = float3(color1R, color1G, color1B);
float3 neuronCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.03, 0.05);

float2 neurons[30];
for (int i = 0; i < 30; i++) {
    float fi = float(i);
    neurons[i] = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0,
        fract(sin(fi * 311.7) * 43758.5453) * 2.0 - 1.0
    ) * 0.8;
}

for (int i = 0; i < 30; i++) {
    if (float(i) >= neuronDensity) break;
    for (int j = i + 1; j < 30; j++) {
        if (float(j) >= neuronDensity) break;
        float fi = float(i);
        float fj = float(j);
        float dist = length(neurons[i] - neurons[j]);
        if (dist < 0.6 * connectionStrength) {
            float2 dir = normalize(neurons[j] - neurons[i]);
            float2 toP = p - neurons[i];
            float along = dot(toP, dir);
            float perp = abs(dot(toP, float2(-dir.y, dir.x)));
            float connection = step(0.0, along) * step(along, dist);
            connection *= smoothstep(0.01, 0.003, perp);
            float signal = fract((along / dist - timeVal * synapseSpeed + fi * 0.1) * 3.0);
            signal = smoothstep(0.0, 0.1, signal) * smoothstep(0.2, 0.1, signal);
            col += connection * neuronCol2 * 0.3;
            float3 signalColor = rainbow > 0.5 ? 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188)) : neuronCol2;
            col += connection * signal * signalColor * pulseAmt;
        }
    }
}

for (int i = 0; i < 30; i++) {
    if (float(i) >= neuronDensity) break;
    float fi = float(i);
    float d = length(p - neurons[i]);
    float neuron = smoothstep(0.02, 0.01, d);
    float pulsing = sin(timeVal * pulseRate * 5.0 + fi * 2.0) * 0.3 + 0.7;
    float3 nColor = neuronCol1;
    if (neon > 0.5) nColor = pow(nColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) nColor = mix(nColor, float3(1.0), 0.3);
    col += neuron * nColor * pulsing * pulseAmt;
    if (glow > 0.5) {
        float glw = exp(-d / glowRadius) * 0.5 * glowIntensity;
        col += glw * neuronCol2;
    }
}

if (activeThought > 0.5) {
    float thoughtPhase = fract(timeVal * 0.3);
    int thoughtNeuron = int(fmod(floor(timeVal * 0.3 * neuronDensity), neuronDensity));
    float d = length(p - neurons[thoughtNeuron]);
    float thought = exp(-d * 10.0) * (1.0 - thoughtPhase);
    col += thought * float3(1.0, 0.8, 0.3);
}

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""
/// Laser Scan
let laserScanCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param scanSpeed "Scan Speed" range(0.5, 3.0) default(1.5)
// @param lineCount "Line Count" range(1.0, 5.0) default(2.0)
// @param lineWidth "Line Width" range(0.01, 0.05) default(0.02)
// @param laserGlowIntensity "Laser Glow" range(0.5, 2.0) default(1.0)
// @param scanPattern "Scan Pattern" range(0.0, 2.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle gridOverlay "Grid Overlay" default(true)
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
// @toggle neon "Neon" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 laserCol1 = float3(color1R, color1G, color1B);
float3 laserCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.02, 0.05);

if (gridOverlay > 0.5) {
    float gridX = smoothstep(0.01, 0.0, abs(fract(p.x * 20.0) - 0.5) - 0.48);
    float gridY = smoothstep(0.01, 0.0, abs(fract(p.y * 20.0) - 0.5) - 0.48);
    col += (gridX + gridY) * float3(0.0, 0.1, 0.15);
}

for (int i = 0; i < 5; i++) {
    if (float(i) >= lineCount) break;
    float fi = float(i);
    float offset = fi / lineCount;
    float scanPos;
    if (scanPattern < 1.0) {
        scanPos = fract(timeVal * scanSpeed * 0.5 + offset);
    } else if (scanPattern < 2.0) {
        scanPos = abs(fract(timeVal * scanSpeed * 0.25 + offset) * 2.0 - 1.0);
    } else {
        scanPos = fract(timeVal * scanSpeed * 0.5 + offset + sin(timeVal + fi) * 0.1);
    }
    float scanDist = abs(p.y - scanPos);
    float scan = smoothstep(lineWidth, 0.0, scanDist);
    float3 scanColor;
    if (rainbow > 0.5) {
        scanColor = 0.5 + 0.5 * cos(timeVal + fi * 2.0 + float3(0.0, 2.094, 4.188));
    } else {
        scanColor = mix(laserCol1, laserCol2, fract(fi * 0.5));
    }
    if (neon > 0.5) scanColor = pow(scanColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) scanColor = mix(scanColor, float3(1.0), 0.3);
    col += scan * scanColor * laserGlowIntensity * pulseAmt;
    if (glow > 0.5) {
        float glw = exp(-scanDist * 30.0) * laserGlowIntensity * glowIntensity;
        col += glw * scanColor * 0.3;
    }
    float particle = smoothstep(0.01, 0.0, scanDist) * step(0.95, fract(p.x * 50.0 + timeVal * 10.0));
    col += particle * float3(1.0);
}

if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Tractor Beam
let tractorBeamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param beamWidth "Beam Width" range(0.1, 0.4) default(0.2)
// @param ringSpeed "Ring Speed" range(0.5, 3.0) default(1.5)
// @param ringCount "Ring Count" range(5.0, 20.0) default(10.0)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
// @param particleDensity "Particle Density" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle active "Active" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 beamCol1 = float3(color1R, color1G, color1B);
float3 beamCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.02, 0.05);

float2 beamTop = float2(0.0, 1.0);
float2 beamBottom = float2(0.0, -0.8);
float beamT = (p.y - beamBottom.y) / (beamTop.y - beamBottom.y);
beamT = clamp(beamT, 0.0, 1.0);
float currentWidth = beamWidth * (1.0 - beamT * 0.5);
float beamDist = abs(p.x) - currentWidth * (1.0 - beamT);
float beam = smoothstep(0.05, 0.0, beamDist);
beam *= step(beamBottom.y, p.y);

if (active > 0.5) {
    for (int i = 0; i < 20; i++) {
        if (float(i) >= ringCount) break;
        float fi = float(i);
        float ringY = fract(fi / ringCount - timeVal * ringSpeed * 0.5);
        ringY = beamBottom.y + ringY * (beamTop.y - beamBottom.y);
        float ringWidth = beamWidth * (1.0 - (ringY - beamBottom.y) / (beamTop.y - beamBottom.y) * 0.5);
        float ringDist = abs(p.y - ringY);
        float ring = smoothstep(0.03, 0.01, ringDist);
        ring *= step(abs(p.x), ringWidth);
        float3 ringColor;
        if (rainbow > 0.5) {
            ringColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
        } else {
            ringColor = beamCol1;
        }
        if (neon > 0.5) ringColor = pow(ringColor, float3(0.7)) * 1.3;
        col += ring * ringColor * intensity * 0.5 * pulseAmt;
    }
}

col += beam * beamCol1 * intensity * 0.5;
float edge = smoothstep(0.02, 0.0, abs(beamDist)) * step(beamBottom.y, p.y);
if (glow > 0.5) col += edge * beamCol2 * intensity * glowIntensity;

if (particleDensity > 0.0 && active > 0.5) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float px = (fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0) * beamWidth;
        float py = fract(sin(fi * 311.7) * 43758.5453 - timeVal * ringSpeed * 0.3);
        py = beamBottom.y + py * (beamTop.y - beamBottom.y);
        float d = length(p - float2(px * (1.0 - (py - beamBottom.y) / (beamTop.y - beamBottom.y) * 0.5), py));
        float particle = smoothstep(0.02, 0.01, d) * particleDensity;
        if (pastel > 0.5) col += particle * mix(beamCol2, float3(1.0), 0.3);
        else col += particle * beamCol2;
    }
}

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edg = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edg);
}
if (outline > 0.5) {
    float edg = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edg);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Quantum Tunnel
let quantumTunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param tunnelSpeed "Tunnel Speed" range(0.5, 3.0) default(1.5)
// @param waveFrequency "Wave Frequency" range(5.0, 20.0) default(10.0)
// @param colorShiftAmount "Color Shift" range(0.0, 2.0) default(1.0)
// @param probability "Probability" range(0.3, 1.0) default(0.7)
// @param entanglement "Entanglement" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.5)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle superposition "Superposition" default(true)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 quantumCol1 = float3(color1R, color1G, color1B);
float3 quantumCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

float tunnel = fract(log(r + 0.001) * 2.0 - timeVal * tunnelSpeed);
float wave = sin(tunnel * waveFrequency * 6.28 + a * 3.0) * 0.5 + 0.5;
float probWave = pow(wave, 1.0 / probability);

float3 tunnelColor;
if (rainbow > 0.5) {
    tunnelColor = 0.5 + 0.5 * cos(tunnel * 3.0 + colorShiftAmount * timeVal + float3(0.0, 2.094, 4.188));
} else {
    tunnelColor = mix(quantumCol1, quantumCol2, tunnel);
}
if (neon > 0.5) tunnelColor = pow(tunnelColor, float3(0.7)) * 1.3;
if (pastel > 0.5) tunnelColor = mix(tunnelColor, float3(1.0), 0.3);

col += probWave * tunnelColor * (1.0 - tunnel * 0.5) * pulseAmt;

if (superposition > 0.5) {
    float tunnel2 = fract(log(r + 0.001) * 2.0 - timeVal * tunnelSpeed + 0.5);
    float wave2 = sin(tunnel2 * waveFrequency * 6.28 - a * 3.0) * 0.5 + 0.5;
    float3 color2 = mix(quantumCol2, quantumCol1, tunnel2);
    col += wave2 * color2 * (1.0 - tunnel2 * 0.5) * 0.5;
}

if (entanglement > 0.0) {
    float entangle = sin(a * 8.0 + timeVal * 3.0) * sin(r * 20.0 - timeVal * tunnelSpeed * 5.0);
    entangle = entangle * 0.5 + 0.5;
    col += entangle * quantumCol2 * entanglement * 0.3;
}

if (glow > 0.5) col += exp(-r * 3.0) * quantumCol1 * 0.2 * glowIntensity;
col *= smoothstep(0.0, 0.1, r);

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Cyberpunk Rain
let cyberpunkRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param rainDensity "Rain Density" range(20.0, 80.0) default(40.0)
// @param rainSpeed "Rain Speed" range(1.0, 4.0) default(2.0)
// @param neonReflection "Neon Reflection" range(0.0, 1.0) default(0.6)
// @param fogAmount "Fog Amount" range(0.0, 0.5) default(0.2)
// @param colorVariety "Color Variety" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.1)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle wetSurface "Wet Surface" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
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
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 neonCol1 = float3(color1R, color1G, color1B);
float3 neonCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.05, 0.05, 0.1);

float3 neonColors[4];
neonColors[0] = neonCol1;
neonColors[1] = neonCol2;
neonColors[2] = float3(0.0, 1.0, 0.5);
neonColors[3] = float3(1.0, 0.5, 0.0);

for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float neonY = 0.7 + fract(sin(fi * 127.1) * 43758.5453) * 0.2;
    float neonX = fract(sin(fi * 311.7) * 43758.5453);
    float d = length(p - float2(neonX, neonY));
    if (glow > 0.5) {
        float glw = exp(-d * 5.0) * neonReflection * glowIntensity;
        float3 nColor = neonColors[i];
        if (neon > 0.5) nColor = pow(nColor, float3(0.7)) * 1.3;
        col += glw * nColor * 0.3 * pulseAmt;
    }
}

for (int i = 0; i < 80; i++) {
    if (float(i) >= rainDensity) break;
    float fi = float(i);
    float rx = fract(sin(fi * 127.1) * 43758.5453);
    float ry = fract(sin(fi * 311.7) * 43758.5453 + timeVal * rainSpeed);
    float2 rainPos = float2(rx, 1.0 - ry);
    float rd = abs(p.x - rainPos.x);
    float rain = smoothstep(0.003, 0.0, rd);
    rain *= step(rainPos.y - 0.05, p.y) * step(p.y, rainPos.y);
    int colorIdx = int(fmod(fi, 4.0));
    float3 rainColor;
    if (rainbow > 0.5) {
        rainColor = 0.5 + 0.5 * cos(timeVal + fi * 0.3 + float3(0.0, 2.094, 4.188));
    } else {
        rainColor = mix(float3(0.6, 0.7, 0.8), neonColors[colorIdx], colorVariety);
    }
    if (pastel > 0.5) rainColor = mix(rainColor, float3(1.0), 0.3);
    col += rain * rainColor * 0.4;
}

if (wetSurface > 0.5 && p.y < 0.15) {
    float2 reflP = float2(p.x, 0.15 - p.y);
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float neonY = 0.7 + fract(sin(fi * 127.1) * 43758.5453) * 0.2;
        float neonX = fract(sin(fi * 311.7) * 43758.5453);
        float wave = sin(p.x * 50.0 + timeVal * 3.0) * 0.01;
        float d = length(reflP + float2(wave, 0.0) - float2(neonX, neonY));
        float refl = exp(-d * 8.0) * neonReflection;
        col += refl * neonColors[i] * 0.2 * (1.0 - p.y / 0.15);
    }
}

if (fogAmount > 0.0) {
    float fog = fogAmount * (1.0 - p.y);
    col = mix(col, float3(0.1, 0.1, 0.15), fog);
}

if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Android Vision
let androidVisionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param scanIntensity "Scan Intensity" range(0.0, 0.5) default(0.2)
// @param overlayOpacity "Overlay Opacity" range(0.3, 1.0) default(0.5)
// @param dataSpeed "Data Speed" range(0.5, 3.0) default(1.5)
// @param focusX "Focus X" range(0.0, 1.0) default(0.5)
// @param focusY "Focus Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.2)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle targeting "Targeting" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = uv - ctr * 0.5;
p = (p - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = p - 0.5;
p = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs) + 0.5;
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 hudCol1 = float3(color1R, color1G, color1B);
float3 hudCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.1, 0.15, 0.1);

if (scanlines > 0.5) {
    float scan = sin(p.y * 200.0 + timeVal * 5.0) * 0.5 + 0.5;
    scan = 1.0 - scan * scanIntensity;
    col *= scan;
}

float2 focus = float2(focusX, focusY);
if (targeting > 0.5) {
    float focusDist = length(p - focus);
    float targetRing = smoothstep(0.12, 0.11, focusDist) - smoothstep(0.11, 0.10, focusDist);
    targetRing += smoothstep(0.08, 0.07, focusDist) - smoothstep(0.07, 0.06, focusDist);
    float3 targetColor = rainbow > 0.5 ? 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.094, 4.188)) : hudCol2;
    col += targetRing * targetColor * pulseAmt;
    float crossV = step(abs(p.x - focus.x), 0.002) * step(abs(p.y - focus.y), 0.05);
    float crossH = step(abs(p.y - focus.y), 0.002) * step(abs(p.x - focus.x), 0.05);
    crossV *= step(0.02, abs(p.y - focus.y));
    crossH *= step(0.02, abs(p.x - focus.x));
    col += (crossV + crossH) * hudCol2;
}

float dataBar = step(0.02, p.x) * step(p.x, 0.15);
dataBar *= step(0.1, p.y) * step(p.y, 0.9);
if (dataBar > 0.5) {
    float dataY = floor(p.y * 30.0);
    float dataScroll = floor(timeVal * dataSpeed * 10.0);
    float data = fract(sin((dataY + dataScroll) * 43.758) * 43758.5453);
    float bar = step(0.05, p.x) * step(p.x, 0.05 + data * 0.08);
    float3 barColor = hudCol1;
    if (neon > 0.5) barColor = pow(barColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) barColor = mix(barColor, float3(1.0), 0.3);
    col += bar * barColor * overlayOpacity;
}

float borderH = step(abs(p.y - 0.5), 0.48) - step(abs(p.y - 0.5), 0.47);
float borderV = step(abs(p.x - 0.5), 0.48) - step(abs(p.x - 0.5), 0.47);
float border = max(borderH * step(abs(p.x - 0.5), 0.48), borderV * step(abs(p.y - 0.5), 0.48));
col += border * hudCol1 * 0.5 * overlayOpacity;

float2 corners[4];
corners[0] = float2(0.05, 0.05);
corners[1] = float2(0.95, 0.05);
corners[2] = float2(0.05, 0.95);
corners[3] = float2(0.95, 0.95);
for (int i = 0; i < 4; i++) {
    float cDist = length(p - corners[i]);
    float corner = smoothstep(0.03, 0.02, cDist);
    if (glow > 0.5) col += corner * hudCol1 * overlayOpacity * glowIntensity;
    else col += corner * hudCol1 * overlayOpacity;
}

if (gradient > 0.5) col *= 0.9 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

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
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= clamp(vig, 0.0, 1.0);
}
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""
/// Teleporter
let teleporterCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(3.0, 10.0) default(6.0)
// @param spinSpeed "Spin Speed" range(0.5, 3.0) default(1.5)
// @param particleAmount "Particle Amount" range(0.0, 1.0) default(0.6)
// @param energyPulse "Energy Pulse" range(0.0, 1.0) default(0.5)
// @param convergence "Convergence" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle active "Active" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 teleCol1 = float3(color1R, color1G, color1B);
float3 teleCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

float baseR = 0.3;
for (int i = 0; i < 10; i++) {
    if (float(i) >= ringCount) break;
    float fi = float(i);
    float ringR = baseR + fi * 0.08;
    float spinDir = (i % 2 == 0) ? 1.0 : -1.0;
    float ringA = a + timeVal * spinSpeed * spinDir * (1.0 + fi * 0.2);
    float segments = 8.0 + fi * 2.0;
    float segmentMask = step(0.5, sin(ringA * segments) * 0.5 + 0.5);
    float ring = smoothstep(0.02, 0.01, abs(r - ringR)) * segmentMask;
    float puls = active > 0.5 ? sin(timeVal * 5.0 + fi) * 0.3 + 0.7 : 0.5;
    float3 ringColor;
    if (rainbow > 0.5) {
        ringColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
    } else {
        ringColor = mix(teleCol1, teleCol2, fi / ringCount);
    }
    if (neon > 0.5) ringColor = pow(ringColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) ringColor = mix(ringColor, float3(1.0), 0.3);
    col += ring * ringColor * puls * pulseAmt;
}

if (active > 0.5 && particleAmount > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float particleA = fract(sin(fi * 127.1) * 43758.5453) * 6.28;
        float particleR = fract(sin(fi * 311.7) * 43758.5453);
        float converge = timeVal * 2.0 * convergence + fi * 0.1;
        particleR = fract(particleR - converge * 0.1) * (0.7 - baseR) + baseR;
        float2 particlePos = float2(cos(particleA), sin(particleA)) * particleR;
        float d = length(p - particlePos);
        float particle = smoothstep(0.015, 0.005, d) * particleAmount;
        col += particle * teleCol2;
    }
}

if (active > 0.5 && energyPulse > 0.0) {
    float core = smoothstep(baseR, 0.0, r);
    float puls = sin(timeVal * 8.0) * 0.5 + 0.5;
    if (glow > 0.5) col += core * teleCol1 * puls * energyPulse * glowIntensity;
    else col += core * teleCol1 * puls * energyPulse;
}

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Cyber Lock
let cyberLockCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param ringCount "Ring Count" range(2.0, 6.0) default(4.0)
// @param rotationSpeed "Rotation Speed" range(0.2, 2.0) default(0.5)
// @param segmentCount "Segment Count" range(4.0, 16.0) default(8.0)
// @param lockGlowIntensity "Lock Glow" range(0.5, 2.0) default(1.0)
// @param unlockProgress "Unlock Progress" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle locked "Locked" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 lockCol = float3(color1R, color1G, color1B);
float3 unlockCol = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

float3 currentLockColor = locked > 0.5 ? lockCol : unlockCol;

for (int i = 0; i < 6; i++) {
    if (float(i) >= ringCount) break;
    float fi = float(i);
    float ringR = 0.2 + fi * 0.12;
    float spinDir = (i % 2 == 0) ? 1.0 : -1.0;
    float ringOffset = fi * 0.5;
    float isUnlocked = step(fi / ringCount, unlockProgress);
    float targetAngle = isUnlocked > 0.5 ? 0.0 : ringOffset;
    float ringA = a + timeVal * rotationSpeed * spinDir * (1.0 - isUnlocked) + targetAngle;
    float segmentLocal = fract((ringA + 3.14159) / (6.28318 / segmentCount));
    float gap = step(0.1, segmentLocal) * step(segmentLocal, 0.9);
    float ring = smoothstep(0.03, 0.02, abs(r - ringR)) * gap;
    float3 ringColor;
    if (rainbow > 0.5) {
        ringColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
    } else {
        ringColor = mix(currentLockColor, float3(0.2, 0.6, 1.0), fi / ringCount);
        if (isUnlocked > 0.5) ringColor = unlockCol;
    }
    if (neon > 0.5) ringColor = pow(ringColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) ringColor = mix(ringColor, float3(1.0), 0.3);
    col += ring * ringColor * lockGlowIntensity * 0.7 * pulseAmt;
    if (glow > 0.5) {
        float glw = exp(-abs(r - ringR) * 20.0) * gap * 0.3 * glowIntensity;
        col += glw * ringColor * lockGlowIntensity;
    }
}

float core = smoothstep(0.12, 0.1, r);
float coreGlow = exp(-r * 5.0) * 0.5;
float3 coreColor = unlockProgress >= 1.0 ? unlockCol : currentLockColor;
col += core * coreColor * lockGlowIntensity * pulseAmt;
col += coreGlow * coreColor * lockGlowIntensity;

float icon = 0.0;
if (locked > 0.5 && unlockProgress < 1.0) {
    icon = step(abs(p.x), 0.03) * step(abs(p.y), 0.05);
    icon += step(abs(p.y + 0.02), 0.02) * step(abs(p.x), 0.05);
} else {
    float checkV = step(abs(p.x + 0.02), 0.015) * step(-0.03, p.y) * step(p.y, 0.02);
    float checkD = step(abs(p.x - p.y * 0.5 - 0.01), 0.015) * step(-0.02, p.y) * step(p.y, 0.04);
    icon = max(checkV, checkD);
}
col += icon * float3(1.0) * step(r, 0.08);

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Energy Core
let energyCoreCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param coreSize "Core Size" range(0.1, 0.3) default(0.2)
// @param pulseSpeed "Pulse Speed" range(0.5, 3.0) default(1.5)
// @param rayCount "Ray Count" range(4.0, 16.0) default(8.0)
// @param instability "Instability" range(0.0, 0.5) default(0.1)
// @param powerLevel "Power Level" range(0.3, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle overload "Overload" default(false)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 coreCol1 = float3(color1R, color1G, color1B);
float3 coreCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

float pulsing = sin(timeVal * pulseSpeed * 5.0) * 0.2 + 0.8;
pulsing *= powerLevel;

float jitter = 0.0;
if (instability > 0.0) {
    jitter = sin(timeVal * 20.0 + a * 5.0) * instability * 0.05;
}
float currentSize = coreSize * pulsing + jitter;

float core = smoothstep(currentSize, currentSize * 0.5, r);
float3 coreColor;
if (overload > 0.5) {
    coreColor = coreCol2;
} else if (rainbow > 0.5) {
    coreColor = 0.5 + 0.5 * cos(timeVal + r * 5.0 + float3(0.0, 2.094, 4.188));
} else {
    coreColor = coreCol1;
}
if (neon > 0.5) coreColor = pow(coreColor, float3(0.7)) * 1.3;
if (pastel > 0.5) coreColor = mix(coreColor, float3(1.0), 0.3);
col += core * coreColor * powerLevel * pulseAmt;

for (int i = 0; i < 16; i++) {
    if (float(i) >= rayCount) break;
    float fi = float(i);
    float rayAngle = fi / rayCount * 6.28318 + timeVal * (overload > 0.5 ? 2.0 : 0.5);
    float rayJitter = sin(timeVal * 10.0 + fi * 3.0) * instability;
    float angleDiff = abs(fmod(a - rayAngle + 3.14159, 6.28318) - 3.14159);
    float ray = exp(-angleDiff * 10.0);
    ray *= smoothstep(currentSize, currentSize + 0.3 + rayJitter, r);
    ray *= smoothstep(0.8, currentSize + 0.1, r);
    col += ray * coreColor * powerLevel * 0.5;
}

if (glow > 0.5) {
    float glw = exp(-r / (coreSize * 2.0)) * powerLevel * glowIntensity;
    col += glw * coreColor * 0.5;
}

if (overload > 0.5) {
    float arc = sin(a * 10.0 + timeVal * 20.0) * sin(r * 30.0 - timeVal * 15.0);
    arc = step(0.9, arc);
    arc *= step(currentSize, r) * step(r, 0.6);
    col += arc * coreCol2 * powerLevel;
}

float ring = smoothstep(0.02, 0.01, abs(r - 0.5));
col += ring * coreColor * 0.3 * powerLevel;

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Mech HUD
let mechHUDCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param hudOpacity "HUD Opacity" range(0.3, 1.0) default(0.7)
// @param warningLevel "Warning Level" range(0.0, 1.0) default(0.0)
// @param radarRange "Radar Range" range(0.1, 0.3) default(0.2)
// @param targetCount "Target Count" range(0.0, 5.0) default(2.0)
// @param systemStatus "System Status" range(0.0, 1.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle combatMode "Combat Mode" default(false)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle scanlines "Scanlines" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 p = uv - ctr * 0.5;
p = (p - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = p - 0.5;
pc = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs);
p = pc + 0.5;
if (distortion > 0.0) {
    float2 dc = p - 0.5;
    float rd = length(dc);
    p = 0.5 + dc * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 hudCol1 = float3(color1R, color1G, color1B);
float3 hudCol2 = float3(color2R, color2G, color2B);

float3 col = float3(0.05, 0.08, 0.05);
float3 hudColor = combatMode > 0.5 ? hudCol2 : hudCol1;
if (rainbow > 0.5) hudColor = 0.5 + 0.5 * cos(timeVal + p.y * 3.0 + float3(0.0, 2.094, 4.188));
if (neon > 0.5) hudColor = pow(hudColor, float3(0.7)) * 1.3;
if (pastel > 0.5) hudColor = mix(hudColor, float3(1.0), 0.3);
float3 warningColor = float3(1.0, 0.8, 0.0);

float topBar = step(0.92, p.y) * step(0.05, p.x) * step(p.x, 0.95);
col += topBar * hudColor * hudOpacity * 0.3 * pulseAmt;
float bottomBar = step(p.y, 0.08) * step(0.05, p.x) * step(p.x, 0.95);
col += bottomBar * hudColor * hudOpacity * 0.3 * pulseAmt;
float leftBorder = step(p.x, 0.02) * step(0.1, p.y) * step(p.y, 0.9);
float rightBorder = step(0.98, p.x) * step(0.1, p.y) * step(p.y, 0.9);
col += (leftBorder + rightBorder) * hudColor * hudOpacity * pulseAmt;

float2 radarCenter = float2(0.15, 0.15);
float radarDist = length(p - radarCenter);
float radar = smoothstep(radarRange + 0.01, radarRange, radarDist);
radar -= smoothstep(radarRange - 0.01, radarRange - 0.02, radarDist);
col += radar * hudColor * hudOpacity * pulseAmt;
float sweep = smoothstep(0.02, 0.0, abs(atan2(p.y - radarCenter.y, p.x - radarCenter.x) - fract(timeVal * 0.5) * 6.28 + 3.14));
sweep *= step(radarDist, radarRange);
col += sweep * hudColor * hudOpacity * 0.5;

for (int i = 0; i < 5; i++) {
    if (float(i) >= targetCount) break;
    float fi = float(i);
    float2 targetPos = radarCenter + float2(
        sin(timeVal + fi * 2.0) * radarRange * 0.6,
        cos(timeVal * 0.7 + fi * 2.0) * radarRange * 0.6
    );
    float targetD = length(p - targetPos);
    float target = smoothstep(0.01, 0.005, targetD);
    col += target * float3(1.0, 0.3, 0.3) * hudOpacity * pulseAmt;
}

float statusX = 0.85;
float statusY = 0.7;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float barY = statusY - fi * 0.08;
    float barFill = step(fi / 5.0, systemStatus);
    float bar = step(statusX, p.x) * step(p.x, statusX + 0.1);
    bar *= step(barY, p.y) * step(p.y, barY + 0.05);
    float3 barColor = barFill > 0.5 ? hudColor : float3(0.3, 0.3, 0.3);
    col += bar * barColor * hudOpacity * 0.5 * pulseAmt;
}

if (warningLevel > 0.0) {
    float warning = sin(timeVal * 10.0) * 0.5 + 0.5;
    warning *= warningLevel;
    col += warning * warningColor * 0.2;
}

float crosshairV = step(abs(p.x - 0.5), 0.001) * step(abs(p.y - 0.5), 0.05);
float crosshairH = step(abs(p.y - 0.5), 0.001) * step(abs(p.x - 0.5), 0.05);
crosshairV *= step(0.01, abs(p.y - 0.5));
crosshairH *= step(0.01, abs(p.x - 0.5));
col += (crosshairV + crosshairH) * hudColor * hudOpacity * pulseAmt;

if (glow > 0.5) col += col * glowIntensity * 0.3;
if (gradient > 0.5) col *= 0.9 + (p.y) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.5;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Particle Accelerator
let particleAcceleratorCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param ringRadius "Ring Radius" range(0.3, 0.5) default(0.4)
// @param particleSpeed "Particle Speed" range(1.0, 5.0) default(3.0)
// @param particleCount "Particle Count" range(2.0, 10.0) default(4.0)
// @param collisionEnergy "Collision Energy" range(0.0, 1.0) default(0.0)
// @param magnetStrength "Magnet Strength" range(0.5, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.7)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle beamOn "Beam On" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 partCol1 = float3(color1R, color1G, color1B);
float3 partCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);

float ring = smoothstep(0.02, 0.01, abs(r - ringRadius));
col += ring * float3(0.2, 0.2, 0.3) * pulseAmt;
for (int i = -1; i <= 1; i++) {
    float innerR = ringRadius - 0.03 + float(i) * 0.015;
    float detail = smoothstep(0.005, 0.002, abs(r - innerR));
    col += detail * float3(0.1, 0.1, 0.2);
}

if (beamOn > 0.5) {
    for (int i = 0; i < 10; i++) {
        if (float(i) >= particleCount) break;
        float fi = float(i);
        float particleAngle = timeVal * particleSpeed + fi * 6.28318 / particleCount;
        if (fmod(fi, 2.0) > 0.5) particleAngle = -particleAngle;
        float2 particlePos = float2(cos(particleAngle), sin(particleAngle)) * ringRadius;
        float d = length(p - particlePos);
        float particle = smoothstep(0.03, 0.01, d);
        float3 particleColor;
        if (rainbow > 0.5) {
            particleColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
        } else {
            particleColor = (fmod(fi, 2.0) < 0.5) ? partCol1 : partCol2;
        }
        if (neon > 0.5) particleColor = pow(particleColor, float3(0.7)) * 1.3;
        if (pastel > 0.5) particleColor = mix(particleColor, float3(1.0), 0.3);
        col += particle * particleColor * magnetStrength * pulseAmt;
        float trail = 0.0;
        for (int t = 1; t < 10; t++) {
            float ft = float(t);
            float trailAngle = particleAngle - ft * 0.1 * (fmod(fi, 2.0) < 0.5 ? 1.0 : -1.0);
            float2 trailPos = float2(cos(trailAngle), sin(trailAngle)) * ringRadius;
            trail += smoothstep(0.02, 0.01, length(p - trailPos)) * (1.0 - ft / 10.0);
        }
        col += trail * particleColor * 0.2;
    }
}

if (collisionEnergy > 0.0) {
    float collision = exp(-r * 5.0) * collisionEnergy;
    float burst = sin(timeVal * 30.0) * 0.5 + 0.5;
    col += collision * float3(1.0, 0.9, 0.5) * burst * pulseAmt;
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float rayAngle = fi * 0.785 + timeVal * 2.0;
        float rayDist = abs(sin(a - rayAngle));
        float ray = exp(-rayDist * 10.0) * collisionEnergy * 0.5;
        ray *= smoothstep(0.0, 0.3, r);
        col += ray * float3(1.0, 0.7, 0.3);
    }
}

if (glow > 0.5) {
    float glw = exp(-abs(r - ringRadius) * 10.0) * magnetStrength * 0.3 * glowIntensity;
    col += glw * partCol1;
}

if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Stasis Field
let stasisFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param fieldStrength "Field Strength" range(0.3, 1.0) default(0.7)
// @param crystalCount "Crystal Count" range(3.0, 12.0) default(6.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.3)
// @param pulseRate "Pulse Rate" range(0.5, 3.0) default(1.0)
// @param iceAmount "Ice Amount" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.5)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle frozen "Frozen" default(true)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0 - ctr;
p /= zoom;
float cs = cos(rotation);
float sn = sin(rotation);
p = float2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
if (distortion > 0.0) {
    float rd = length(p);
    p *= 1.0 + distortion * rd * rd;
}
if (mirror > 0.5) p.x = abs(p.x);
if (kaleidoscope > 0.5) {
    float ak = atan2(p.y, p.x);
    ak = fmod(ak + 3.14159, 3.14159 / 4.0) - 3.14159 / 8.0;
    p = float2(cos(ak), sin(ak)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 iceCol1 = float3(color1R, color1G, color1B);
float3 iceCol2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.05, 0.08);

float pulsing = frozen > 0.5 ? 1.0 : sin(timeVal * pulseRate * 3.0) * 0.3 + 0.7;
pulsing *= pulseAmt;

for (int i = 0; i < 12; i++) {
    if (float(i) >= crystalCount) break;
    float fi = float(i);
    float crystalAngle = fi / crystalCount * 6.28318;
    if (frozen < 0.5) crystalAngle += timeVal * rotationSpeed;
    float2 crystalDir = float2(cos(crystalAngle), sin(crystalAngle));
    float2 crystalPos = crystalDir * 0.3;
    float2 toP = p - crystalPos;
    float along = dot(toP, crystalDir);
    float perp = abs(dot(toP, float2(-crystalDir.y, crystalDir.x)));
    float crystal = step(-0.05, along) * step(along, 0.2);
    crystal *= step(perp, 0.02 + (0.2 - along) * 0.1);
    float3 crystalColor = rainbow > 0.5 ? 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188)) : iceCol1;
    if (neon > 0.5) crystalColor = pow(crystalColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) crystalColor = mix(crystalColor, float3(1.0), 0.3);
    col += crystal * crystalColor * fieldStrength * pulsing;
}

float field = exp(-r * 3.0) * fieldStrength;
col += field * iceCol2 * pulsing;

float fieldEdge = smoothstep(0.52, 0.48, r) - smoothstep(0.48, 0.44, r);
float edgePattern = sin(a * 20.0 + (frozen > 0.5 ? 0.0 : timeVal * 2.0)) * 0.5 + 0.5;
col += fieldEdge * edgePattern * iceCol2 * fieldStrength * pulsing;

if (iceAmount > 0.0) {
    float ice = sin(p.x * 50.0 + p.y * 30.0) * sin(p.x * 30.0 - p.y * 50.0);
    ice = ice * 0.5 + 0.5;
    ice *= smoothstep(0.5, 0.3, r) * iceAmount;
    col += ice * iceCol1 * 0.3;
}

if (frozen > 0.5) {
    float frost = sin(r * 100.0) * sin(a * 30.0) * 0.5 + 0.5;
    frost *= fieldStrength * 0.2;
    col += frost * float3(0.8, 0.9, 1.0);
}

if (glow > 0.5) col += exp(-r * 2.0) * iceCol2 * 0.3 * glowIntensity;
if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - r * 0.3;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Alien Script
let alienScriptCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param symbolSize "Symbol Size" range(0.05, 0.15) default(0.08)
// @param scrollSpeed "Scroll Speed" range(0.1, 1.0) default(0.3)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param complexity "Complexity" range(1.0, 3.0) default(2.0)
// @param colorHue "Color Hue" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.05)
// @param pixelSize "Pixel Size" range(10.0, 200.0) default(100.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle ancient "Ancient" default(false)
// @toggle rainbow "Rainbow" default(false)
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
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 ctr = float2(centerX, centerY);
float2 p = uv - ctr * 0.5;
p = (p - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = p - 0.5;
pc = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs);
p = pc + 0.5;
if (distortion > 0.0) {
    float2 dc = p - 0.5;
    float rd = length(dc);
    p = 0.5 + dc * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.15 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 scriptCol1 = float3(color1R, color1G, color1B);
float3 scriptCol2 = float3(color2R, color2G, color2B);

float3 col = ancient > 0.5 ? float3(0.05, 0.04, 0.02) : float3(0.02, 0.02, 0.05);
float3 glyphColor;
if (rainbow > 0.5) {
    glyphColor = 0.5 + 0.5 * cos(timeVal + p.y * 5.0 + float3(0.0, 2.094, 4.188));
} else if (ancient > 0.5) {
    glyphColor = scriptCol2;
} else {
    glyphColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
}
if (neon > 0.5) glyphColor = pow(glyphColor, float3(0.7)) * 1.3;
if (pastel > 0.5) glyphColor = mix(glyphColor, float3(1.0), 0.3);

float gridX = floor(p.x / symbolSize);
float gridY = floor((p.y + timeVal * scrollSpeed) / symbolSize);
float2 cellP = float2(
    fract(p.x / symbolSize) - 0.5,
    fract((p.y + timeVal * scrollSpeed) / symbolSize) - 0.5
) * 2.0;

float seed = fract(sin(gridX * 127.1 + gridY * 311.7) * 43758.5453);
float symbolType = floor(seed * 5.0);
float symbol = 0.0;

if (symbolType < 1.0) {
    symbol = smoothstep(0.6, 0.5, length(cellP));
    symbol -= smoothstep(0.4, 0.3, length(cellP));
} else if (symbolType < 2.0) {
    float arm1 = step(abs(cellP.x), 0.1) * step(abs(cellP.y), 0.6);
    float arm2 = step(abs(cellP.y), 0.1) * step(abs(cellP.x), 0.6);
    symbol = max(arm1, arm2);
} else if (symbolType < 3.0) {
    float tri = step(abs(cellP.x), 0.6 - abs(cellP.y) * 0.8);
    tri *= step(-0.5, cellP.y) * step(cellP.y, 0.5);
    symbol = tri;
} else if (symbolType < 4.0) {
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float lineY = -0.4 + fi * 0.4;
        symbol += step(abs(cellP.y - lineY), 0.08) * step(abs(cellP.x), 0.5);
    }
    symbol = min(symbol, 1.0);
} else {
    float ag = atan2(cellP.y, cellP.x);
    float spiral = fract(ag / 6.28 + length(cellP) * complexity);
    symbol = step(0.4, spiral) * step(spiral, 0.6);
    symbol *= step(length(cellP), 0.6);
}

col += symbol * glyphColor * 0.8 * pulseAmt;

if (glow > 0.5 && glowAmount > 0.0) {
    float glw = symbol * glowAmount * glowIntensity;
    col += glw * glyphColor * 0.3;
}

if (ancient > 0.5) {
    float crack = sin(p.x * 100.0 + p.y * 80.0) * sin(p.x * 60.0 - p.y * 120.0);
    crack = step(0.95, crack) * 0.1;
    col -= crack;
}

if (gradient > 0.5) col *= 0.9 + (p.y) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.5;

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
if (colorShift > 0.5) col.rgb = col.gbr;
if (showEdges > 0.5) {
    float edge = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edge);
}
if (outline > 0.5) {
    float edge = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edge);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float angle = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle) + cross(k, col) * sin(angle) + k * dot(k, col) * (1.0 - cos(angle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

