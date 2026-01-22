//
//  ShaderCodes_Part15.swift
//  LM_GLSL
//
//  Shader codes - Part 15: Surreal & Artistic Effects (20 shaders)
//

import Foundation

// MARK: - Surreal & Artistic Effects

/// Melting Clock
let meltingClockCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param meltAmount "Melt Amount" range(0.0, 0.5) default(0.3)
// @param clockSize "Clock Size" range(0.2, 0.4) default(0.3)
// @param timeSpeed "Time Speed" range(0.1, 2.0) default(1.0)
// @param distortionWave "Distortion Wave" range(0.0, 1.0) default(0.5)
// @param colorIntensity "Color Intensity" range(0.0, 1.0) default(0.6)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.95)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.92)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.85)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle dali "Dali Style" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 pCoord = uv - ctr * 0.5;
pCoord = (pCoord - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = pCoord - 0.5;
pc = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs);
pCoord = pc + 0.5;
if (distortion > 0.0) {
    float2 dc = pCoord - 0.5;
    float rd = length(dc);
    pCoord = 0.5 + dc * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) pCoord.x = abs(pCoord.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 clockColor = float3(color1R, color1G, color1B);
float3 frameColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float3 col = float3(0.9, 0.85, 0.7);

float2 clockP = p;
if (dali > 0.5) {
    float melt = sin(p.x * 3.0 + timeVal * 0.5) * meltAmount;
    melt += pow(max(0.0, -p.y), 2.0) * meltAmount * 2.0;
    clockP.y += melt;
    clockP.x += sin(p.y * 5.0 + distortionWave * timeVal) * meltAmount * 0.3;
}

float r = length(clockP);
float a = atan2(clockP.y, clockP.x);

float clock = smoothstep(clockSize + 0.02, clockSize, r);
clock -= smoothstep(clockSize - 0.02, clockSize - 0.04, r);

float3 clockCol = clockColor;
if (rainbow > 0.5) clockCol = 0.5 + 0.5 * cos(timeVal + a + float3(0.0, 2.094, 4.188));
if (neon > 0.5) clockCol = pow(clockCol, float3(0.7)) * 1.3;
if (pastel > 0.5) clockCol = mix(clockCol, float3(1.0), 0.3);

col = mix(col, clockCol, smoothstep(clockSize, clockSize - 0.01, r));
col = mix(col, frameColor, clock);

for (int i = 0; i < 12; i++) {
    float fi = float(i);
    float tickAngle = fi * 0.5236;
    float2 tickDir = float2(cos(tickAngle), sin(tickAngle));
    float tickStart = clockSize * 0.8;
    float tickEnd = clockSize * 0.9;
    float tickDist = length(clockP - tickDir * (tickStart + tickEnd) * 0.5);
    float tick = smoothstep(0.02, 0.01, tickDist) * step(r, clockSize);
    col = mix(col, float3(0.3, 0.25, 0.2), tick);
}

float hourAngle = timeVal * timeSpeed * 0.1;
float minAngle = timeVal * timeSpeed;
float2 hourDir = float2(sin(hourAngle), cos(hourAngle));
float hourHand = step(abs(dot(clockP, float2(-hourDir.y, hourDir.x))), 0.01);
hourHand *= step(0.0, dot(clockP, hourDir)) * step(length(clockP), clockSize * 0.5);
float2 minDir = float2(sin(minAngle), cos(minAngle));
float minHand = step(abs(dot(clockP, float2(-minDir.y, minDir.x))), 0.005);
minHand *= step(0.0, dot(clockP, minDir)) * step(length(clockP), clockSize * 0.7);

col = mix(col, float3(0.2, 0.15, 0.1), hourHand * step(r, clockSize));
col = mix(col, float3(0.1, 0.1, 0.1), minHand * step(r, clockSize));

if (colorIntensity > 0.0 && dali > 0.5) {
    float3 tint = 0.5 + 0.5 * cos(p.x * 2.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, col * tint, colorIntensity * 0.3);
}

if (glow > 0.5) col += col * glowIntensity * 0.15;
if (gradient > 0.5) col *= 0.8 + pCoord.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Impossible Stairs
let impossibleStairsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param stairCount "Stair Count" range(5.0, 15.0) default(10.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.3)
// @param perspective "Perspective" range(0.3, 0.8) default(0.5)
// @param lineThickness "Line Thickness" range(0.005, 0.02) default(0.01)
// @param shadowDepth "Shadow Depth" range(0.0, 0.5) default(0.3)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.95)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.93)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.9)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.25)
// @toggle animated "Animated" default(true)
// @toggle escher "Escher Style" default(true)
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

float2 ctr = float2(centerX, centerY);
float2 pCoord = uv - ctr * 0.5;
pCoord = (pCoord - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = pCoord - 0.5;
pc = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs);
pCoord = pc + 0.5;
if (distortion > 0.0) {
    float2 dc = pCoord - 0.5;
    float rd = length(dc);
    pCoord = 0.5 + dc * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) pCoord.x = abs(pCoord.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgColor = float3(color1R, color1G, color1B);
float3 lineColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float3 col = bgColor;

float rotAngle = animated > 0.5 ? timeVal * rotationSpeed : 0.0;
float2 rp = float2(
    p.x * cos(rotAngle) - p.y * sin(rotAngle),
    p.x * sin(rotAngle) + p.y * cos(rotAngle)
);

float stairHeight = 1.5 / stairCount;
float stairWidth = 0.1;

for (int i = 0; i < 15; i++) {
    if (float(i) >= stairCount) break;
    float fi = float(i);
    float angle = fi / stairCount * 6.28318 + rotAngle;
    float stairY = -0.7 + fi * stairHeight;
    float stairX = sin(angle) * 0.3;
    float perspScale = 1.0 - (fi / stairCount) * perspective * 0.5;
    float2 stairP = rp - float2(stairX * perspScale, stairY);
    
    float horizontal = step(abs(stairP.y), lineThickness);
    horizontal *= step(-stairWidth * perspScale, stairP.x);
    horizontal *= step(stairP.x, stairWidth * perspScale);
    
    float vertical = step(abs(stairP.x - stairWidth * perspScale), lineThickness);
    vertical *= step(0.0, stairP.y) * step(stairP.y, stairHeight);
    
    float back = step(abs(stairP.x + stairWidth * perspScale), lineThickness);
    back *= step(0.0, stairP.y) * step(stairP.y, stairHeight);
    
    float stairs = horizontal + vertical + back;
    stairs = min(stairs, 1.0);
    
    float3 stairColor = lineColor;
    if (rainbow > 0.5) stairColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) stairColor = pow(stairColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) stairColor = mix(stairColor, float3(1.0), 0.3);
    
    col = mix(col, stairColor, stairs);
    
    if (shadowDepth > 0.0) {
        float shadow = step(-stairWidth * perspScale, stairP.x);
        shadow *= step(stairP.x, stairWidth * perspScale);
        shadow *= step(0.0, stairP.y) * step(stairP.y, stairHeight * 0.5);
        col = mix(col, col * (1.0 - shadowDepth * 0.5), shadow * 0.3);
    }
}

float centerLine = step(abs(rp.x), lineThickness);
centerLine *= step(-0.7, rp.y) * step(rp.y, 0.8);
col = mix(col, lineColor * 0.5, centerLine * 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + pCoord.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Floating Islands
let floatingIslandsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param islandCount "Island Count" range(2.0, 6.0) default(4.0)
// @param floatSpeed "Float Speed" range(0.3, 1.5) default(0.7)
// @param floatAmount "Float Amount" range(0.02, 0.1) default(0.05)
// @param cloudDensity "Cloud Density" range(0.0, 1.0) default(0.5)
// @param mysteryGlow "Mystery Glow" range(0.0, 1.0) default(0.4)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle waterfalls "Waterfalls" default(true)
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

float3 grassColor = float3(color1R, color1G, color1B);
float3 skyColor = float3(color2R, color2G, color2B);

float3 skyTop = skyColor;
float3 skyBottom = skyColor * 1.3 + 0.2;
float3 col = mix(skyBottom, skyTop, p.y);

if (cloudDensity > 0.0) {
    float cloud = sin(p.x * 10.0 + timeVal * 0.2) * sin(p.y * 8.0 + timeVal * 0.1);
    cloud = cloud * 0.5 + 0.5;
    cloud *= smoothstep(0.4, 0.7, p.y) * cloudDensity;
    col = mix(col, float3(1.0, 1.0, 1.0), cloud * 0.3);
}

for (int i = 0; i < 6; i++) {
    if (float(i) >= islandCount) break;
    float fi = float(i);
    float islandX = fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1;
    float islandY = fract(sin(fi * 311.7) * 43758.5453) * 0.4 + 0.3;
    float islandSize = fract(sin(fi * 178.3) * 43758.5453) * 0.08 + 0.05;
    float bobOffset = sin(timeVal * floatSpeed + fi * 2.0) * floatAmount;
    float2 islandPos = float2(islandX, islandY + bobOffset);
    float islandDist = length((p - islandPos) * float2(1.0, 2.0));
    float island = smoothstep(islandSize, islandSize * 0.7, islandDist);
    
    float3 dirtColor = float3(0.4, 0.3, 0.2);
    float3 rockColor = float3(0.4, 0.35, 0.3);
    float3 islandGrass = grassColor;
    if (rainbow > 0.5) islandGrass = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) islandGrass = pow(islandGrass, float3(0.7)) * 1.3;
    if (pastel > 0.5) islandGrass = mix(islandGrass, float3(1.0), 0.3);
    
    float grassMask = smoothstep(islandSize * 0.8, islandSize * 0.5, islandDist);
    float3 islandColor = mix(rockColor, islandGrass, grassMask);
    col = mix(col, islandColor, island);
    
    float bottom = step(p.y, islandPos.y - islandSize * 0.3);
    bottom *= smoothstep(islandSize * 0.7, 0.0, abs(p.x - islandX));
    bottom *= step(islandPos.y - islandSize * 0.8, p.y);
    col = mix(col, rockColor * 0.6, bottom);
    
    if (waterfalls > 0.5 && fi < 3.0) {
        float fallX = islandX + (fract(sin(fi * 43.758) * 43758.5453) - 0.5) * islandSize;
        float fallDist = abs(p.x - fallX);
        float fall = smoothstep(0.01, 0.005, fallDist);
        fall *= step(p.y, islandPos.y - islandSize * 0.3);
        fall *= step(0.05, p.y);
        float flowAnim = fract(p.y * 20.0 - timeVal * 3.0);
        fall *= flowAnim * 0.5 + 0.5;
        col = mix(col, float3(0.7, 0.85, 1.0), fall * 0.7);
    }
    
    if (mysteryGlow > 0.0) {
        float glowAmt = exp(-islandDist * 5.0) * mysteryGlow;
        col += glowAmt * float3(0.3, 0.5, 0.7) * 0.3 * pulseAmt;
    }
}

if (glow > 0.5) col += col * glowIntensity * 0.15;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Dream Portal
let dreamPortalCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param portalSize "Portal Size" range(0.2, 0.5) default(0.35)
// @param spiralSpeed "Spiral Speed" range(0.5, 3.0) default(1.5)
// @param colorDepth "Color Depth" range(1.0, 5.0) default(3.0)
// @param distortionRipple "Distortion Ripple" range(0.0, 0.3) default(0.1)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.5)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle vortex "Vortex" default(true)
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
float2 pCoord = uv - ctr * 0.5;
pCoord = (pCoord - 0.5) / zoom + 0.5;
float cs = cos(rotation);
float sn = sin(rotation);
float2 pc = pCoord - 0.5;
pc = float2(pc.x * cs - pc.y * sn, pc.x * sn + pc.y * cs);
pCoord = pc + 0.5;
if (distortion > 0.0) {
    float2 dc = pCoord - 0.5;
    float rd = length(dc);
    pCoord = 0.5 + dc * (1.0 + distortion * rd * rd);
}
if (mirror > 0.5) pCoord.x = abs(pCoord.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 edgeColor = float3(color1R, color1G, color1B);
float3 glowColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.05, 0.02, 0.1);

float portal = smoothstep(portalSize + 0.05, portalSize, r);
float portalEdge = smoothstep(portalSize, portalSize - 0.03, r);
portalEdge -= smoothstep(portalSize - 0.03, portalSize - 0.06, r);

float2 portalP = p;
if (vortex > 0.5) {
    float twist = (portalSize - r) * 5.0;
    twist = max(0.0, twist);
    portalP = float2(
        p.x * cos(twist + timeVal * spiralSpeed) - p.y * sin(twist + timeVal * spiralSpeed),
        p.x * sin(twist + timeVal * spiralSpeed) + p.y * cos(twist + timeVal * spiralSpeed)
    );
}

if (distortionRipple > 0.0) {
    float ripple = sin(r * 30.0 - timeVal * 5.0) * distortionRipple;
    portalP += portalP * ripple;
}

float portalR = length(portalP);
float portalA = atan2(portalP.y, portalP.x);

float spiral = sin(portalA * 3.0 + portalR * 10.0 - timeVal * spiralSpeed * 2.0);
spiral = spiral * 0.5 + 0.5;

float3 innerColor = 0.5 + 0.5 * cos(portalR * colorDepth + timeVal + float3(0.0, 2.0, 4.0));
if (rainbow > 0.5) innerColor = 0.5 + 0.5 * cos(timeVal + portalA + float3(0.0, 2.094, 4.188));
if (neon > 0.5) innerColor = pow(innerColor, float3(0.7)) * 1.3;
if (pastel > 0.5) innerColor = mix(innerColor, float3(1.0), 0.3);

innerColor *= 0.5 + 0.5 * cos(portalA * 2.0 + timeVal * 0.5 + float3(4.0, 2.0, 0.0));

col = mix(col, innerColor * portal, portal);
col = mix(col, innerColor * spiral * 0.7, portal * spiral * 0.5);
col += portalEdge * edgeColor * 0.8 * pulseAmt;

float glowAmt = exp(-abs(r - portalSize) * 10.0);
col += glowAmt * glowColor * 0.5;

if (starDensity > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float starA = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
        float starR = fract(sin(fi * 311.7) * 43758.5453) * portalSize * 0.8;
        float starTwist = (portalSize - starR) * 3.0;
        float2 starPos = float2(cos(starA + timeVal * spiralSpeed + starTwist), sin(starA + timeVal * spiralSpeed + starTwist)) * starR;
        float d = length(p - starPos);
        float star = smoothstep(0.01, 0.005, d) * portal;
        col += star * float3(1.0, 0.9, 0.8) * starDensity;
    }
}

if (glow > 0.5) col += col * glowIntensity * 0.15;
if (gradient > 0.5) col *= 0.8 + pCoord.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Paper Cutout
let paperCutoutCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param layerCount "Layer Count" range(3.0, 8.0) default(5.0)
// @param layerDepth "Layer Depth" range(0.02, 0.1) default(0.05)
// @param colorfulness "Colorfulness" range(0.0, 1.0) default(0.7)
// @param paperTexture "Paper Texture" range(0.0, 0.3) default(0.1)
// @param animSpeed "Animation Speed" range(0.0, 1.0) default(0.3)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.95)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.92)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.88)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.85)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle shadows "Shadows" default(true)
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
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgColor = float3(color1R, color1G, color1B);
float3 paperColor = float3(color2R, color2G, color2B);

float3 col = bgColor;

for (int i = int(layerCount) - 1; i >= 0; i--) {
    float fi = float(i);
    float layerY = fi / layerCount;
    float waveOffset = sin(p.x * 10.0 + fi * 2.0 + timeVal * animSpeed) * 0.05;
    float wave2 = sin(p.x * 20.0 - fi * 3.0 + timeVal * animSpeed * 0.7) * 0.02;
    float cutY = layerY * 0.7 + 0.15 + waveOffset + wave2;
    float layer = smoothstep(cutY + 0.01, cutY, p.y);
    
    float3 layerColor;
    if (colorfulness > 0.0) {
        layerColor = 0.5 + 0.5 * cos(fi * 1.5 + float3(0.0, 2.0, 4.0));
        if (rainbow > 0.5) layerColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
        layerColor = mix(paperColor, layerColor, colorfulness);
    } else {
        float shade = 0.9 - fi / layerCount * 0.3;
        layerColor = float3(shade);
    }
    if (neon > 0.5) layerColor = pow(layerColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) layerColor = mix(layerColor, float3(1.0), 0.3);
    
    if (paperTexture > 0.0) {
        float texture = sin(p.x * 200.0 + fi * 50.0) * sin(p.y * 200.0 + fi * 30.0);
        texture = texture * 0.5 + 0.5;
        layerColor += (texture - 0.5) * paperTexture;
    }
    
    if (shadows > 0.5 && i < int(layerCount) - 1) {
        float shadowY = cutY + layerDepth * (layerCount - fi) * 0.5;
        float shadow = smoothstep(shadowY, cutY, p.y) * (1.0 - layer);
        col = mix(col, col * 0.7, shadow * 0.5);
    }
    
    col = mix(col, layerColor, layer);
    float edge = smoothstep(cutY + 0.005, cutY, p.y) - smoothstep(cutY, cutY - 0.005, p.y);
    col = mix(col, layerColor * 0.8, edge * 0.5);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Stained Glass
let stainedGlassCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param cellCount "Cell Count" range(5, 20) default(12)
// @param leadWidth "Lead Width" range(0.01, 0.05) default(0.02)
// @param colorIntensity "Color Intensity" range(0.5, 1.0) default(0.8)
// @param lightDirection "Light Direction" range(0.0, 6.28) default(0.785)
// @param glowAmount "Glow Amount" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle cathedral "Cathedral" default(true)
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
float2 p = uv;

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(0.1, 0.1, 0.1);
float2 cellP = p * float(cellCount);
float2 cellId = floor(cellP);
float2 cellLocal = fract(cellP) - 0.5;
float minDist = 10.0;
float2 closestCell = cellId;

for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
        float2 neighbor = cellId + float2(x, y);
        float2 cellCenter = float2(
            fract(sin(neighbor.x * 127.1 + neighbor.y * 311.7) * 43758.5453),
            fract(sin(neighbor.x * 269.5 + neighbor.y * 183.3) * 43758.5453)
        ) * 0.8 + 0.1;
        float2 diff = neighbor + cellCenter - cellP;
        float d = length(diff);
        if (d < minDist) {
            minDist = d;
            closestCell = neighbor;
        }
    }
}

float cellSeed = fract(sin(closestCell.x * 127.1 + closestCell.y * 311.7) * 43758.5453);
float3 glassColor;

if (cathedral > 0.5) {
    if (cellSeed < 0.2) glassColor = float3(0.8, 0.2, 0.2);
    else if (cellSeed < 0.4) glassColor = float3(0.2, 0.3, 0.8);
    else if (cellSeed < 0.6) glassColor = float3(0.8, 0.7, 0.2);
    else if (cellSeed < 0.8) glassColor = float3(0.2, 0.6, 0.3);
    else glassColor = float3(0.6, 0.2, 0.6);
} else {
    glassColor = 0.5 + 0.5 * cos(cellSeed * 6.28 + float3(0.0, 2.0, 4.0));
}

if (rainbow > 0.5) {
    glassColor = 0.5 + 0.5 * cos(timeVal + cellSeed * 6.28 + float3(0.0, 2.0, 4.0));
}

glassColor = mix(glassColor, mix(userColor1, userColor2, cellSeed), 0.3);
glassColor *= colorIntensity;

float2 lightDir = float2(cos(lightDirection + timeVal * 0.1), sin(lightDirection + timeVal * 0.1));
float lightFactor = dot(normalize(cellLocal), lightDir) * 0.3 + 0.7;
glassColor *= lightFactor;
col = glassColor;

float lead = smooth > 0.5 ? smoothstep(leadWidth, leadWidth * 0.5, minDist) : step(minDist, leadWidth);
col = mix(col, float3(0.15, 0.15, 0.15), lead);

if (glow > 0.5 && glowAmount > 0.0) {
    float glowVal = (1.0 - minDist * 2.0) * glowAmount;
    glowVal = max(0.0, glowVal);
    col += glowVal * glassColor * glowIntensity;
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Abstract Expressionism
let abstractExpressionismCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param brushStrokes "Brush Strokes" range(10, 50) default(30)
// @param strokeWidth "Stroke Width" range(0.02, 0.1) default(0.05)
// @param colorVariety "Color Variety" range(0.3, 1.0) default(0.8)
// @param chaosAmount "Chaos Amount" range(0.0, 1.0) default(0.6)
// @param layering "Layering" range(0.3, 1.0) default(0.7)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle dripping "Dripping" default(true)
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

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(0.95, 0.93, 0.9);

for (int i = 0; i < 50; i++) {
    if (i >= int(brushStrokes)) break;
    float fi = float(i);
    float seed = fract(sin(fi * 127.1 + timeVal * 0.1) * 43758.5453);
    float2 strokeStart = float2(
        fract(sin(fi * 311.7) * 43758.5453),
        fract(sin(fi * 178.3) * 43758.5453)
    );
    float strokeAngle = seed * 3.14159 * chaosAmount;
    float strokeLen = fract(sin(fi * 43.758) * 43758.5453) * 0.3 + 0.1;
    float2 strokeEnd = strokeStart + float2(cos(strokeAngle), sin(strokeAngle)) * strokeLen;
    float2 strokeDir = normalize(strokeEnd - strokeStart);
    float2 toP = p - strokeStart;
    float along = dot(toP, strokeDir);
    float perp = abs(dot(toP, float2(-strokeDir.y, strokeDir.x)));
    float strokeMask = step(0.0, along) * step(along, strokeLen);
    float widthVar = strokeWidth * (1.0 + sin(along * 20.0 + fi) * 0.3);
    strokeMask *= smooth > 0.5 ? smoothstep(widthVar, widthVar * 0.3, perp) : step(perp, widthVar);
    
    float3 strokeColor;
    if (rainbow > 0.5) {
        strokeColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.0, 4.0));
    } else {
        strokeColor = 0.5 + 0.5 * cos(fi * colorVariety + float3(0.0, 2.0, 4.0));
    }
    strokeColor = mix(strokeColor, mix(userColor1, userColor2, seed), 0.3);
    if (fract(sin(fi * 91.37) * 43758.5453) > 0.5) {
        strokeColor = float3(0.1, 0.1, 0.1);
    }
    col = mix(col, strokeColor, strokeMask * layering);
    
    if (dripping > 0.5 && seed > 0.7) {
        float dripX = strokeEnd.x + (fract(sin(fi * 53.12) * 43758.5453) - 0.5) * 0.02;
        float dripStart = strokeEnd.y;
        float dripLen = fract(sin(fi * 87.23) * 43758.5453) * 0.2;
        float drip = step(abs(p.x - dripX), 0.005);
        drip *= step(p.y, dripStart) * step(dripStart - dripLen, p.y);
        float dripFade = (dripStart - p.y) / dripLen;
        col = mix(col, strokeColor, drip * (1.0 - dripFade) * layering);
    }
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Watercolor Wash
let watercolorWashCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param bleedAmount "Bleed Amount" range(0.0, 0.5) default(0.3)
// @param pigmentDensity "Pigment Density" range(0.3, 1.0) default(0.6)
// @param wetness "Wetness" range(0.0, 1.0) default(0.5)
// @param colorLayers "Color Layers" range(2, 6) default(4)
// @param granulation "Granulation" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle paperGrain "Paper Grain" default(true)
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
// @toggle pastel "Pastel" default(true)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 p = uv;

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(0.98, 0.96, 0.93);

if (paperGrain > 0.5) {
    float grain = sin(p.x * 300.0) * sin(p.y * 300.0) * 0.02;
    col -= grain;
}

for (int i = 0; i < 6; i++) {
    if (i >= int(colorLayers)) break;
    float fi = float(i);
    float2 center = float2(
        fract(sin(fi * 127.1 + timeVal * 0.05) * 43758.5453) * 0.6 + 0.2,
        fract(sin(fi * 311.7 + timeVal * 0.05) * 43758.5453) * 0.6 + 0.2
    );
    float size = fract(sin(fi * 178.3) * 43758.5453) * 0.3 + 0.1;
    float2 toP = p - center;
    float dist = length(toP);
    float bleedNoise = sin(atan2(toP.y, toP.x) * 8.0 + fi * 5.0 + timeVal) * bleedAmount;
    bleedNoise += sin(dist * 30.0 + fi * 10.0 + timeVal) * bleedAmount * 0.5;
    float wash = smooth > 0.5 ? smoothstep(size + bleedNoise, size * 0.3 + bleedNoise * 0.5, dist) : step(dist, size + bleedNoise);
    
    float3 washColor;
    if (rainbow > 0.5) {
        washColor = 0.5 + 0.5 * cos(timeVal + fi * 1.0 + float3(0.0, 2.0, 4.0));
    } else {
        washColor = 0.5 + 0.5 * cos(fi * 1.8 + float3(0.0, 2.0, 4.0));
    }
    washColor = mix(washColor, mix(userColor1, userColor2, fi / 6.0), 0.3);
    washColor = mix(float3(0.9), washColor, pigmentDensity);
    
    float wetEdge = smoothstep(size + bleedNoise, size * 0.8 + bleedNoise, dist);
    wetEdge -= smoothstep(size * 0.8 + bleedNoise, size * 0.5, dist);
    washColor = mix(washColor, washColor * 0.7, wetEdge * wetness);
    
    if (granulation > 0.0) {
        float granule = sin(p.x * 100.0 + fi * 30.0) * sin(p.y * 100.0 + fi * 20.0);
        granule = granule * 0.5 + 0.5;
        washColor = mix(washColor, washColor * 0.8, granule * granulation * wash);
    }
    col = mix(col, washColor, wash * 0.5);
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 500.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}
if (filmGrain > 0.5) {
    float grainVal = fract(sin(dot(uv + fract(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += (grainVal - 0.5) * 0.1;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Pop Art Dots
let popArtDotsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param dotSize "Dot Size" range(0.02, 0.08) default(0.04)
// @param dotSpacing "Dot Spacing" range(0.03, 0.12) default(0.06)
// @param colorScheme "Color Scheme" range(0.0, 4.0) default(0.0)
// @param popContrast "Pop Contrast" range(0.5, 1.5) default(1.0)
// @param halftoneAngle "Halftone Angle" range(0.0, 1.57) default(0.26)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle outlined "Outlined" default(false)
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

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(1.0);
float currentAngle = halftoneAngle + timeVal * 0.1;
float2 rotP = float2(
    p.x * cos(currentAngle) - p.y * sin(currentAngle),
    p.x * sin(currentAngle) + p.y * cos(currentAngle)
);
float2 gridP = rotP / dotSpacing;
float2 cellId = floor(gridP);
float2 cellCenter = (cellId + 0.5) * dotSpacing;
float2 origCenter = float2(
    cellCenter.x * cos(-currentAngle) - cellCenter.y * sin(-currentAngle),
    cellCenter.x * sin(-currentAngle) + cellCenter.y * cos(-currentAngle)
);

float zoneSeed = fract(sin(cellId.x * 127.1 + cellId.y * 311.7) * 43758.5453);
float zoneValue = pow(zoneSeed, 1.0 / popContrast);
float actualDotSize = dotSize * zoneValue * pulseAmt;

float3 bgColor;
float3 dotColor;

if (rainbow > 0.5) {
    bgColor = 0.5 + 0.5 * cos(timeVal + cellId.x * 0.3 + float3(0.0, 2.0, 4.0));
    dotColor = 0.5 + 0.5 * cos(timeVal + cellId.y * 0.3 + float3(4.0, 2.0, 0.0));
} else {
    int scheme = int(colorScheme);
    if (scheme == 0) {
        bgColor = userColor1;
        dotColor = userColor2;
    } else if (scheme == 1) {
        bgColor = float3(0.0, 0.8, 1.0);
        dotColor = float3(1.0, 0.3, 0.0);
    } else if (scheme == 2) {
        bgColor = float3(1.0, 0.4, 0.6);
        dotColor = float3(0.2, 0.2, 0.8);
    } else if (scheme == 3) {
        bgColor = float3(0.1, 0.8, 0.3);
        dotColor = float3(1.0, 1.0, 0.0);
    } else {
        bgColor = 0.5 + 0.5 * cos(cellId.x * 0.5 + float3(0.0, 2.0, 4.0));
        dotColor = 0.5 + 0.5 * cos(cellId.y * 0.5 + float3(4.0, 2.0, 0.0));
    }
}

col = bgColor;
float dist = length(p - origCenter);
float dotVal = smooth > 0.5 ? smoothstep(actualDotSize, actualDotSize * 0.8, dist) : step(dist, actualDotSize);
col = mix(col, dotColor, dotVal);

if (outlined > 0.5 && actualDotSize > dotSize * 0.3) {
    float outlineVal = smoothstep(actualDotSize + 0.005, actualDotSize, dist);
    outlineVal -= smoothstep(actualDotSize, actualDotSize - 0.005, dist);
    col = mix(col, float3(0.0), outlineVal);
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Neon Sign Art
let neonSignArtCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param neonGlowIntensity "Neon Glow Intensity" range(0.5, 2.0) default(1.2)
// @param flickerAmount "Flicker Amount" range(0.0, 0.5) default(0.1)
// @param tubeWidth "Tube Width" range(0.01, 0.04) default(0.02)
// @param colorHue "Color Hue" range(0.0, 1.0) default(0.0)
// @param glowRadius "Glow Radius" range(0.05, 0.2) default(0.1)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.8)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle broken "Broken" default(false)
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
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 pOrig = uv;

pOrig = (pOrig - 0.5) / zoom + 0.5;
pOrig -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
pOrig = float2(cosR * (pOrig.x - 0.5) - sinR * (pOrig.y - 0.5) + 0.5, sinR * (pOrig.x - 0.5) + cosR * (pOrig.y - 0.5) + 0.5);

if (mirror > 0.5) pOrig.x = pOrig.x < 0.5 ? pOrig.x : 1.0 - pOrig.x;
if (distortion > 0.0) {
    pOrig.x += sin(pOrig.y * 10.0 + timeVal) * distortion * 0.1;
    pOrig.y += cos(pOrig.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) pOrig = floor(pOrig * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = pOrig - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    pOrig = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float2 p = pOrig * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);

float3 neonColor;
if (rainbow > 0.5) {
    neonColor = 0.5 + 0.5 * cos(timeVal + float3(0.0, 2.0, 4.0));
} else {
    neonColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
    neonColor = mix(neonColor, userColor1, 0.5);
}

float neonFlicker = 1.0;
if (flickerAmount > 0.0) {
    neonFlicker = 1.0 - flickerAmount * step(0.95, fract(sin(timeVal * 20.0) * 43758.5453));
    neonFlicker *= 1.0 - flickerAmount * 0.3 * sin(timeVal * 60.0);
}

float star = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float angle = fi * 0.785 + timeVal * 0.2;
    float2 dir = float2(cos(angle), sin(angle));
    float line = abs(dot(p, float2(-dir.y, dir.x)));
    float along = abs(dot(p, dir));
    float arm = smooth > 0.5 ? smoothstep(tubeWidth, tubeWidth * 0.5, line) : step(line, tubeWidth);
    arm *= smoothstep(0.4, 0.0, along);
    star = max(star, arm);
}

float circle = smooth > 0.5 ? smoothstep(tubeWidth, tubeWidth * 0.5, abs(length(p) - 0.3)) : step(abs(length(p) - 0.3), tubeWidth);
float shape = max(star, circle);

if (broken > 0.5) {
    float breakMask = step(0.7, fract(sin(p.x * 20.0 + p.y * 30.0) * 43758.5453));
    shape *= 1.0 - breakMask * 0.8;
}

col += shape * neonColor * neonGlowIntensity * neonFlicker * pulseAmt;

if (glow > 0.5) {
    float glowVal = exp(-length(p) / glowRadius) * shape;
    glowVal += exp(-(abs(length(p) - 0.3)) / glowRadius) * 0.5;
    col += glowVal * neonColor * glowIntensity * 0.3 * neonFlicker;
    
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float angle = fi * 0.785 + timeVal * 0.2;
        float2 dir = float2(cos(angle), sin(angle));
        float armGlow = exp(-abs(dot(p, float2(-dir.y, dir.x))) / glowRadius);
        armGlow *= smoothstep(0.5, 0.0, abs(dot(p, dir)));
        col += armGlow * neonColor * glowIntensity * 0.2 * neonFlicker;
    }
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (gradient > 0.5) col *= 0.8 + pOrig.y * 0.4;
if (radial > 0.5) col *= 1.0 - length(pOrig - 0.5) * 0.3;

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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Ink Blot Art
let inkBlotArtCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param blotCount "Blot Count" range(1, 5) default(3)
// @param spreadAmount "Spread Amount" range(0.1, 0.4) default(0.25)
// @param inkDensity "Ink Density" range(0.5, 1.0) default(0.8)
// @param symmetry "Symmetry" range(0.0, 1.0) default(1.0)
// @param edgeBleed "Edge Bleed" range(0.0, 0.3) default(0.15)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.08)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.12)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.98)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.96)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.93)
// @toggle animated "Animated" default(true)
// @toggle rorschach "Rorschach" default(true)
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

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = userColor2;
float3 inkColor = userColor1;

float2 sp = p;
if (rorschach > 0.5) {
    sp.x = abs(sp.x - 0.5) + 0.5;
}

for (int i = 0; i < 5; i++) {
    if (i >= int(blotCount)) break;
    float fi = float(i);
    float2 blotCenter = float2(
        fract(sin(fi * 127.1 + timeVal * 0.05) * 43758.5453) * 0.4 + 0.5,
        fract(sin(fi * 311.7 + timeVal * 0.05) * 43758.5453) * 0.6 + 0.2
    );
    float blotSize = fract(sin(fi * 178.3) * 43758.5453) * spreadAmount + 0.1;
    float2 toP = sp - blotCenter;
    float dist = length(toP);
    float angle = atan2(toP.y, toP.x);
    float edgeNoise = 0.0;
    for (int j = 1; j <= 5; j++) {
        float fj = float(j);
        edgeNoise += sin(angle * fj * 3.0 + fi * 5.0 + timeVal) * edgeBleed / fj;
    }
    float blot = smooth > 0.5 ? smoothstep(blotSize + edgeNoise, blotSize * 0.3 + edgeNoise * 0.5, dist) : step(dist, blotSize + edgeNoise);
    float densityVar = sin(sp.x * 50.0 + fi * 20.0) * sin(sp.y * 50.0 + fi * 30.0);
    densityVar = densityVar * 0.2 + 0.8;
    float3 blotColor = inkColor * (inkDensity * densityVar);
    if (rainbow > 0.5) {
        blotColor = 0.5 + 0.5 * cos(timeVal + fi * 0.5 + float3(0.0, 2.0, 4.0));
        blotColor *= inkDensity;
    }
    col = mix(col, blotColor, blot * 0.8);
    
    float edge = smoothstep(blotSize + edgeNoise, blotSize * 0.8 + edgeNoise, dist);
    edge -= smoothstep(blotSize * 0.8 + edgeNoise, blotSize * 0.5 + edgeNoise, dist);
    col = mix(col, blotColor * 0.5, edge * 0.3);
}

if (rorschach > 0.5 && symmetry > 0.0) {
    float mirrorBlend = smoothstep(0.48, 0.5, p.x) * smoothstep(0.52, 0.5, p.x);
    col = mix(col, col * 0.95, mirrorBlend * symmetry);
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Oil Painting
let oilPaintingCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param brushSize "Brush Size" range(0.02, 0.08) default(0.04)
// @param textureDepth "Texture Depth" range(0.0, 0.5) default(0.3)
// @param colorRichness "Color Richness" range(0.5, 1.0) default(0.8)
// @param strokeDirection "Stroke Direction" range(0.0, 6.28) default(0.785)
// @param impasto "Impasto" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.6)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle varnish "Varnish" default(true)
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

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(0.3, 0.25, 0.2);
float currentDirection = strokeDirection + timeVal * 0.1;
float2 strokeDir = float2(cos(currentDirection), sin(currentDirection));
float2 quantP = floor(p / brushSize) * brushSize;
float brushSeed = fract(sin(quantP.x * 127.1 + quantP.y * 311.7) * 43758.5453);

float3 baseColor;
if (rainbow > 0.5) {
    baseColor = 0.5 + 0.5 * cos(timeVal + brushSeed * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    baseColor = 0.5 + 0.5 * cos(brushSeed * 6.28 * colorRichness + float3(0.0, 2.0, 4.0));
}
baseColor = mix(baseColor, mix(userColor1, userColor2, brushSeed), 0.3);
baseColor = mix(baseColor * 0.5, baseColor, colorRichness);
col = baseColor;

if (textureDepth > 0.0) {
    float brushTexture = sin(dot(p, strokeDir) * 100.0 + brushSeed * 50.0);
    brushTexture *= sin(dot(p, float2(-strokeDir.y, strokeDir.x)) * 50.0 + brushSeed * 30.0);
    brushTexture = brushTexture * 0.5 + 0.5;
    col += (brushTexture - 0.5) * textureDepth * 0.3;
}

if (impasto > 0.0) {
    float2 cellP = fract(p / (brushSize * 0.5)) - 0.5;
    float impastoHeight = length(cellP) * 2.0;
    impastoHeight = 1.0 - smoothstep(0.0, 1.0, impastoHeight);
    float lightDir = dot(normalize(float2(1.0, 1.0)), normalize(cellP));
    col += impastoHeight * lightDir * impasto * 0.2;
}

if (varnish > 0.5) {
    float varnishShine = pow(1.0 - abs(p.x - 0.5) * 2.0, 3.0);
    varnishShine *= pow(1.0 - abs(p.y - 0.5) * 2.0, 3.0);
    col += varnishShine * 0.1;
    col *= 1.05;
}

float edge = 0.0;
float2 neighbors[4];
neighbors[0] = float2(brushSize, 0.0);
neighbors[1] = float2(-brushSize, 0.0);
neighbors[2] = float2(0.0, brushSize);
neighbors[3] = float2(0.0, -brushSize);
for (int i = 0; i < 4; i++) {
    float2 neighborP = floor((p + neighbors[i]) / brushSize) * brushSize;
    float neighborSeed = fract(sin(neighborP.x * 127.1 + neighborP.y * 311.7) * 43758.5453);
    edge += abs(brushSeed - neighborSeed);
}
edge *= 0.1;
col = mix(col, col * 0.9, edge);

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Kaleidoscope Dream
let kaleidoscopeDreamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param segments "Segments" range(3, 12) default(6)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.5)
// @param zoomPulse "Zoom Pulse" range(0.0, 0.3) default(0.1)
// @param kaleidoColorShift "Color Shift" range(0.0, 2.0) default(1.0)
// @param complexity "Complexity" range(1.0, 5.0) default(3.0)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle morphing "Morphing" default(true)
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

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float2 pOrig = uv;

pOrig = (pOrig - 0.5) / zoom + 0.5;
pOrig -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
pOrig = float2(cosR * (pOrig.x - 0.5) - sinR * (pOrig.y - 0.5) + 0.5, sinR * (pOrig.x - 0.5) + cosR * (pOrig.y - 0.5) + 0.5);

if (mirror > 0.5) pOrig.x = pOrig.x < 0.5 ? pOrig.x : 1.0 - pOrig.x;
if (distortion > 0.0) {
    pOrig.x += sin(pOrig.y * 10.0 + timeVal) * distortion * 0.1;
    pOrig.y += cos(pOrig.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) pOrig = floor(pOrig * pixelSize * 20.0) / (pixelSize * 20.0);

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float2 p = pOrig * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float segmentAngle = 6.28318 / float(segments);
float ka = fmod(a + 3.14159, segmentAngle);
if (fmod(floor((a + 3.14159) / segmentAngle), 2.0) > 0.5) {
    ka = segmentAngle - ka;
}
ka -= segmentAngle * 0.5;
ka += timeVal * rotationSpeed;

float zoomVal = 1.0 + sin(timeVal * 2.0) * zoomPulse;
float2 kp = float2(cos(ka), sin(ka)) * r * zoomVal;

float3 col = float3(0.0);
float pattern = 0.0;
for (int i = 1; i <= 5; i++) {
    float fi = float(i);
    if (fi > complexity) break;
    float freq = fi * 3.0;
    float phase = timeVal * (morphing > 0.5 ? fi * 0.3 : 0.0);
    pattern += sin(kp.x * freq + phase) * sin(kp.y * freq * 1.3 + phase * 0.7) / fi;
}
pattern = pattern * 0.5 + 0.5;

float3 kColor1, kColor2;
if (rainbow > 0.5) {
    kColor1 = 0.5 + 0.5 * cos(pattern * 3.0 + kaleidoColorShift * timeVal + float3(0.0, 2.0, 4.0));
    kColor2 = 0.5 + 0.5 * cos(r * 5.0 + kaleidoColorShift * timeVal + float3(4.0, 2.0, 0.0));
} else {
    kColor1 = mix(userColor1, userColor2, pattern);
    kColor2 = mix(userColor2, userColor1, r);
}
col = mix(kColor1, kColor2, pattern);

float radialPattern = sin(r * 20.0 - timeVal * 2.0) * 0.5 + 0.5;
col = mix(col, col * 1.3, radialPattern * 0.3);

if (glow > 0.5) {
    float centerGlow = exp(-r * 3.0);
    col += centerGlow * float3(1.0, 0.9, 0.8) * glowIntensity;
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (gradient > 0.5) col *= 0.8 + pOrig.y * 0.4;
if (radial > 0.5) col *= 1.0 - length(pOrig - 0.5) * 0.3;

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
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Cubist Portrait
let cubistPortraitCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.5)
// @param fragmentation "Fragmentation" range(3, 10) default(6)
// @param angleVariation "Angle Variation" range(0.0, 1.0) default(0.5)
// @param colorPalette "Color Palette" range(0.0, 3.0) default(1.0)
// @param edgeEmphasis "Edge Emphasis" range(0.0, 0.5) default(0.2)
// @param facetDepth "Facet Depth" range(0.0, 0.5) default(0.3)
// @param brightness "Brightness" range(0.5, 1.5) default(1.0)
// @param contrast "Contrast" range(0.5, 1.5) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-0.5, 0.5) default(0.0)
// @param centerY "Center Y" range(-0.5, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 2.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 0.5) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.3) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 20.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.7)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle geometric "Geometric" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(true)
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

p = (p - 0.5) / zoom + 0.5;
p -= float2(centerX, centerY);
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(cosR * (p.x - 0.5) - sinR * (p.y - 0.5) + 0.5, sinR * (p.x - 0.5) + cosR * (p.y - 0.5) + 0.5);

if (mirror > 0.5) p.x = p.x < 0.5 ? p.x : 1.0 - p.x;
if (distortion > 0.0) {
    p.x += sin(p.y * 10.0 + timeVal) * distortion * 0.1;
    p.y += cos(p.x * 10.0 + timeVal) * distortion * 0.1;
}
if (pixelate > 0.5) p = floor(p * pixelSize * 20.0) / (pixelSize * 20.0);
if (kaleidoscope > 0.5) {
    float2 cp = p - 0.5;
    float angle = atan2(cp.y, cp.x);
    float radius = length(cp);
    angle = fmod(abs(angle), 0.785) - 0.392;
    p = float2(cos(angle), sin(angle)) * radius + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + sin(timeVal * 3.0) * 0.1 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + fract(sin(timeVal * 20.0) * 43758.5453) * 0.1 : 1.0;

float3 userColor1 = float3(color1R, color1G, color1B);
float3 userColor2 = float3(color2R, color2G, color2B);

float3 col = float3(0.9, 0.85, 0.8);
float cellSize = 1.0 / float(fragmentation);
float2 cellId = floor(p / cellSize);
float2 cellLocal = fract(p / cellSize);
float cellSeed = fract(sin(cellId.x * 127.1 + cellId.y * 311.7 + timeVal * 0.1) * 43758.5453);
float cellAngle = (cellSeed - 0.5) * angleVariation * 3.14159;
float2 rotLocal = float2(
    cellLocal.x * cos(cellAngle) - cellLocal.y * sin(cellAngle),
    cellLocal.x * sin(cellAngle) + cellLocal.y * cos(cellAngle)
);

float3 facetColor;
if (rainbow > 0.5) {
    facetColor = 0.5 + 0.5 * cos(timeVal + cellSeed * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    int palette = int(colorPalette);
    if (palette == 0) {
        facetColor = mix(float3(0.6, 0.5, 0.4), float3(0.9, 0.8, 0.7), cellSeed);
    } else if (palette == 1) {
        facetColor = mix(float3(0.3, 0.4, 0.5), float3(0.7, 0.6, 0.5), cellSeed);
        if (cellSeed > 0.7) facetColor = float3(0.8, 0.3, 0.2);
    } else if (palette == 2) {
        facetColor = 0.5 + 0.5 * cos(cellSeed * 6.28 + float3(0.0, 2.0, 4.0));
    } else {
        facetColor = float3(cellSeed > 0.5 ? 0.9 : 0.2);
    }
}
facetColor = mix(facetColor, mix(userColor1, userColor2, cellSeed), 0.3);

float depth = 0.0;
if (geometric > 0.5) {
    float diagonal = rotLocal.x + rotLocal.y;
    depth = step(0.5, fract(diagonal * 2.0)) * facetDepth;
}
facetColor *= 1.0 - depth;
col = facetColor;

if (showEdges > 0.5) {
    float edge = 0.0;
    edge = max(edge, smooth > 0.5 ? smoothstep(0.05, 0.0, cellLocal.x) : step(cellLocal.x, 0.05));
    edge = max(edge, smooth > 0.5 ? smoothstep(0.05, 0.0, cellLocal.y) : step(cellLocal.y, 0.05));
    edge = max(edge, smooth > 0.5 ? smoothstep(0.95, 1.0, cellLocal.x) : step(0.95, cellLocal.x));
    edge = max(edge, smooth > 0.5 ? smoothstep(0.95, 1.0, cellLocal.y) : step(0.95, cellLocal.y));
    col = mix(col, float3(0.1), edge * edgeEmphasis);
    
    if (geometric > 0.5) {
        float diag1 = abs(rotLocal.x - rotLocal.y);
        float diag2 = abs(rotLocal.x + rotLocal.y - 1.0);
        float diagLine = min(smoothstep(0.02, 0.0, diag1), smoothstep(0.02, 0.0, diag2));
        col = mix(col, float3(0.2), diagLine * edgeEmphasis);
    }
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.8 + p.y * 0.4;
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Pointillism
let pointillismCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param dotDensity "Dot Density" range(20, 60) default(40)
// @param dotVariation "Variation" range(0.0, 0.5) default(0.2)
// @param colorMixing "Color Mixing" range(0.0, 1.0) default(0.6)
// @param warmth "Warmth" range(0.0, 1.0) default(0.5)
// @param dotBlend "Dot Blend" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.2, 3.0) default(1.0)
// @param contrast "Contrast" range(0.2, 3.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 2.0) default(1.0)
// @param chromaticAmount "Chromatic Shift" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 2.0) default(1.0)
// @param highlightIntensity "Highlight" range(0.0, 2.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.0)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle impressionist "Impressionist" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise FX" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines FX" default(false)
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

float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = uv - center;
if (mirror > 0.5) p.x = abs(p.x);
float angle = rotation;
float cosA = cos(angle); float sinA = sin(angle);
p = float2(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);
p /= zoom;
if (distortion > 0.0) {
    float dist = length(p);
    p *= 1.0 + distortion * dist * dist;
}
p += center;
if (pixelate > 0.5 && pixelSize > 1.0) {
    p = floor(p * (100.0 / pixelSize)) / (100.0 / pixelSize);
}
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float kSeg = 6.28318 / 6.0;
    kAngle = fmod(abs(kAngle), kSeg);
    float kDist = length(kp);
    p = float2(cos(kAngle), sin(kAngle)) * kDist + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + 0.1 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.95 + 0.05 * fract(sin(timeVal * 20.0) * 43758.5453) : 1.0;

float3 col = float3(0.95, 0.93, 0.9);
float cellSize = 1.0 / dotDensity;
for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
        float2 cellId = floor(p / cellSize) + float2(dx, dy);
        float2 cellCenter = (cellId + 0.5) * cellSize;
        float cellSeed = fract(sin(cellId.x * 127.1 + cellId.y * 311.7) * 43758.5453);
        float2 dotOffset = float2(
            fract(sin(cellSeed * 178.3) * 43758.5453) - 0.5,
            fract(sin(cellSeed * 267.9) * 43758.5453) - 0.5
        ) * cellSize * dotVariation * 2.0;
        float2 dotPos = cellCenter + dotOffset;
        float dotSz = cellSize * 0.3 * (0.8 + cellSeed * 0.4) * (1.0 + dotBlend * 0.5);
        float dist = length(p - dotPos);
        float dotVal = smooth > 0.5 ? smoothstep(dotSz, dotSz * 0.3, dist) : step(dist, dotSz);
        float3 dotColor;
        if (rainbow > 0.5) {
            dotColor = 0.5 + 0.5 * cos(cellSeed * 6.28 + timeVal + float3(0.0, 2.0, 4.0));
        } else if (impressionist > 0.5) {
            float hue = cellSeed + (cellId.x + cellId.y) * 0.02 + timeVal * 0.1;
            dotColor = 0.5 + 0.5 * cos(hue * 6.28 + float3(0.0, 2.0, 4.0));
            dotColor = mix(dotColor, dotColor * float3(1.1, 1.0, 0.9), warmth);
        } else if (gradient > 0.5) {
            dotColor = mix(color1, color2, cellSeed);
        } else {
            dotColor = float3(cellSeed, fract(cellSeed * 2.0), fract(cellSeed * 3.0));
        }
        col = mix(col, dotColor, dotVal * colorMixing);
    }
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(col, col * 1.5, lum);
}
if (showEdges > 0.5) {
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (radial > 0.5) {
    float radialDist = length(p - 0.5);
    col *= 1.0 + 0.2 * sin(radialDist * 20.0 + timeVal);
}
if (glow > 0.5) {
    float glowAmt = 1.0 + glowIntensity * 0.5;
    col *= glowAmt;
}
if (noise > 0.5) {
    float n = fract(sin(dot(p, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Art Nouveau
let artNouveauCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param curveComplexity "Curve Complexity" range(2.0, 6.0) default(4.0)
// @param flowSpeed "Flow Speed" range(0.0, 1.0) default(0.3)
// @param lineWeight "Line Weight" range(0.005, 0.02) default(0.01)
// @param fillOpacity "Fill Opacity" range(0.0, 0.5) default(0.3)
// @param goldAccent "Gold Accent" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.2, 3.0) default(1.0)
// @param contrast "Contrast" range(0.2, 3.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 2.0) default(1.0)
// @param chromaticAmount "Chromatic Shift" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 2.0) default(1.0)
// @param highlightIntensity "Highlight" range(0.0, 2.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(0.85)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.65)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.55)
// @param color2B "Color 2 B" range(0.0, 1.0) default(0.35)
// @toggle animated "Animated" default(true)
// @toggle organic "Organic" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise FX" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines FX" default(false)
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

float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 st = uv - center;
if (mirror > 0.5) st.x = abs(st.x);
float angle = rotation;
float cosA = cos(angle); float sinA = sin(angle);
st = float2(st.x * cosA - st.y * sinA, st.x * sinA + st.y * cosA);
st /= zoom;
if (distortion > 0.0) {
    float dist = length(st);
    st *= 1.0 + distortion * dist * dist;
}
st += center;
if (pixelate > 0.5 && pixelSize > 1.0) {
    st = floor(st * (100.0 / pixelSize)) / (100.0 / pixelSize);
}
if (kaleidoscope > 0.5) {
    float2 kp = st - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float kSeg = 6.28318 / 6.0;
    kAngle = fmod(abs(kAngle), kSeg);
    float kDist = length(kp);
    st = float2(cos(kAngle), sin(kAngle)) * kDist + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + 0.1 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.95 + 0.05 * fract(sin(timeVal * 20.0) * 43758.5453) : 1.0;

float2 p = st * 2.0 - 1.0;
float3 col = float3(0.95, 0.93, 0.88);
float3 lineColor = float3(0.15, 0.12, 0.1);
float3 goldColor = color1;
float3 fillColor = color2;
float pattern = 0.0;
float fill = 0.0;
for (int i = 1; i <= 6; i++) {
    float fi = float(i);
    if (fi > curveComplexity) break;
    float freq = fi * 2.0;
    float phase = organic > 0.5 ? timeVal * flowSpeed * fi * 0.3 : 0.0;
    float wave1 = sin(p.x * freq + phase) * cos(p.y * freq * 0.7 + phase * 0.5);
    float wave2 = sin(p.y * freq * 1.2 + phase * 0.8) * cos(p.x * freq * 0.8 + phase);
    float curve = wave1 + wave2;
    float line = smooth > 0.5 ? smoothstep(lineWeight, 0.0, abs(curve) / fi) : step(abs(curve) / fi, lineWeight);
    pattern = max(pattern, line);
    fill += step(0.0, curve) / (curveComplexity * 2.0);
}
col = mix(col, fillColor, fill * fillOpacity);
if (rainbow > 0.5) {
    float3 rainbowCol = 0.5 + 0.5 * cos(timeVal + fill * 6.28 + float3(0.0, 2.0, 4.0));
    col = mix(col, rainbowCol, pattern);
} else {
    col = mix(col, lineColor, pattern);
}
float2 cp = p;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float cornerAngle = fi * 1.5708;
    float2 cornerPos = float2(cos(cornerAngle), sin(cornerAngle)) * 0.6;
    float2 toCorner = cp - cornerPos;
    float spiralAngle = atan2(toCorner.y, toCorner.x);
    float spiralDist = length(toCorner);
    float spiral = sin(spiralAngle * 3.0 + spiralDist * 10.0 + timeVal * flowSpeed);
    spiral = smoothstep(lineWeight * 2.0, 0.0, abs(spiral) * spiralDist);
    spiral *= smoothstep(0.4, 0.1, spiralDist);
    if (goldAccent > 0.0) {
        col = mix(col, goldColor, spiral * goldAccent);
    } else {
        col = mix(col, lineColor, spiral);
    }
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(col, col * 1.5, lum);
}
if (showEdges > 0.5) {
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (radial > 0.5) {
    float radialDist = length(st - 0.5);
    col *= 1.0 + 0.2 * sin(radialDist * 20.0 + timeVal);
}
if (glow > 0.5) {
    float glowAmt = 1.0 + glowIntensity * 0.5;
    col *= glowAmt;
}
if (noise > 0.5) {
    float n = fract(sin(dot(st, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Graffiti Tag
let graffitiTagCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param sprayDensity "Spray Density" range(0.3, 1.0) default(0.7)
// @param dripAmount "Drip Amount" range(0.0, 0.5) default(0.3)
// @param colorVibrancy "Color Vibrancy" range(0.5, 1.5) default(1.2)
// @param outlineThickness "Outline Thickness" range(0.01, 0.05) default(0.02)
// @param tagScale "Tag Scale" range(0.5, 1.5) default(1.0)
// @param brightness "Brightness" range(0.2, 3.0) default(1.0)
// @param contrast "Contrast" range(0.2, 3.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 2.0) default(1.0)
// @param chromaticAmount "Chromatic Shift" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 2.0) default(1.0)
// @param highlightIntensity "Highlight" range(0.0, 2.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 B" range(0.0, 1.0) default(0.95)
// @toggle animated "Animated" default(true)
// @toggle chrome "Chrome" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise FX" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines FX" default(false)
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

float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 st = uv - center;
if (mirror > 0.5) st.x = abs(st.x);
float ang = rotation;
float cosA = cos(ang); float sinA = sin(ang);
st = float2(st.x * cosA - st.y * sinA, st.x * sinA + st.y * cosA);
st /= zoom;
if (distortion > 0.0) {
    float dist = length(st);
    st *= 1.0 + distortion * dist * dist;
}
st += center;
if (pixelate > 0.5 && pixelSize > 1.0) {
    st = floor(st * (100.0 / pixelSize)) / (100.0 / pixelSize);
}
if (kaleidoscope > 0.5) {
    float2 kp = st - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float kSeg = 6.28318 / 6.0;
    kAngle = fmod(abs(kAngle), kSeg);
    float kDist = length(kp);
    st = float2(cos(kAngle), sin(kAngle)) * kDist + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + 0.1 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.95 + 0.05 * fract(sin(timeVal * 20.0) * 43758.5453) : 1.0;

float2 p = (st - 0.5) * 2.0 / tagScale + 0.5;
float3 col = float3(0.7, 0.65, 0.6);
float brickX = floor(p.x * 8.0);
float brickY = floor(p.y * 16.0);
float brickOffset = fmod(brickY, 2.0) * 0.5;
float brickVal = step(0.05, fract((p.x + brickOffset * 0.125) * 8.0));
brickVal *= step(0.1, fract(p.y * 16.0));
col = mix(col * 0.9, col, brickVal);
float tag = 0.0;
float2 tp = p - float2(0.5, 0.5);
float curve1 = sin(tp.x * 10.0 + timeVal * 0.5) * 0.15;
tag = max(tag, smoothstep(0.08, 0.05, abs(tp.y - curve1) - abs(tp.x) * 0.1));
tag *= step(-0.3, tp.x) * step(tp.x, 0.3);
float curve2 = cos(tp.x * 8.0 + 1.0 + timeVal * 0.3) * 0.1;
float line2 = smoothstep(0.06, 0.03, abs(tp.y - curve2 - 0.1));
line2 *= step(-0.2, tp.x) * step(tp.x, 0.35);
tag = max(tag, line2);
float3 tagColor;
if (chrome > 0.5) {
    float chromeVal = tp.y * 5.0 + 0.5 + sin(timeVal) * 0.2;
    tagColor = mix(float3(0.3, 0.3, 0.35), float3(0.9, 0.9, 0.95), chromeVal);
} else if (rainbow > 0.5) {
    tagColor = 0.5 + 0.5 * cos(timeVal + tp.x * 3.0 + float3(0.0, 2.0, 4.0));
} else if (gradient > 0.5) {
    tagColor = mix(color1, color2, tp.x + 0.5);
} else {
    tagColor = color1 * colorVibrancy;
}
if (sprayDensity < 1.0) {
    float spray = fract(sin(p.x * 500.0 + p.y * 700.0) * 43758.5453);
    tag *= step(1.0 - sprayDensity, spray);
    float overspray = step(0.95, spray) * step(0.03, abs(tp.y - curve1) - abs(tp.x) * 0.1);
    overspray *= step(abs(tp.y - curve1), 0.15);
    tag = max(tag, overspray * 0.3);
}
float outlineVal = smoothstep(0.1, 0.08, abs(tp.y - curve1) - abs(tp.x) * 0.1);
outlineVal -= smoothstep(0.08 - outlineThickness, 0.05, abs(tp.y - curve1) - abs(tp.x) * 0.1);
outlineVal *= step(-0.32, tp.x) * step(tp.x, 0.32);
col = mix(col, float3(0.1), outlineVal);
col = mix(col, tagColor, tag);
if (dripAmount > 0.0) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float dripX = -0.2 + fi * 0.12;
        float dripStart = curve1 + 0.05;
        if (abs(tp.x - dripX) < 0.02) {
            float dripLen = fract(sin(fi * 127.1) * 43758.5453) * dripAmount;
            float drip = step(tp.y, dripStart) * step(dripStart - dripLen, tp.y);
            drip *= smoothstep(0.015, 0.005, abs(tp.x - dripX));
            float dripFade = (dripStart - tp.y) / dripLen;
            drip *= 1.0 - dripFade * 0.5;
            col = mix(col, tagColor, drip * 0.8);
        }
    }
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(col, col * 1.5, lum);
}
if (showEdges > 0.5) {
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (radial > 0.5) {
    float radialDist = length(st - 0.5);
    col *= 1.0 + 0.2 * sin(radialDist * 20.0 + timeVal);
}
if (glow > 0.5) {
    float glowAmt = 1.0 + glowIntensity * 0.5;
    col *= glowAmt;
}
if (noise > 0.5) {
    float n = fract(sin(dot(st, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Zen Garden
let zenGardenCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param rakeLineCount "Rake Lines" range(10, 30) default(20)
// @param stoneCount "Stone Count" range(0, 5) default(3)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.1) default(0.03)
// @param sandColor "Sand Color" range(0.0, 1.0) default(0.5)
// @param peacefulness "Peacefulness" range(0.0, 1.0) default(0.7)
// @param brightness "Brightness" range(0.2, 3.0) default(1.0)
// @param contrast "Contrast" range(0.2, 3.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 2.0) default(1.0)
// @param chromaticAmount "Chromatic Shift" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 2.0) default(1.0)
// @param highlightIntensity "Highlight" range(0.0, 2.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.85)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.75)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.35)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.33)
// @param color2B "Color 2 B" range(0.0, 1.0) default(0.3)
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
// @toggle noise "Noise FX" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines FX" default(false)
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

float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = uv - center;
if (mirror > 0.5) p.x = abs(p.x);
float ang = rotation;
float cosA = cos(ang); float sinA = sin(ang);
p = float2(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);
p /= zoom;
if (distortion > 0.0) {
    float dist = length(p);
    p *= 1.0 + distortion * dist * dist;
}
p += center;
if (pixelate > 0.5 && pixelSize > 1.0) {
    p = floor(p * (100.0 / pixelSize)) / (100.0 / pixelSize);
}
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float kSeg = 6.28318 / 6.0;
    kAngle = fmod(abs(kAngle), kSeg);
    float kDist = length(kp);
    p = float2(cos(kAngle), sin(kAngle)) * kDist + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + 0.1 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.95 + 0.05 * fract(sin(timeVal * 20.0) * 43758.5453) : 1.0;

float3 sandLight = mix(color1, color1 * 0.95, sandColor);
float3 sandDark = sandLight * 0.85;
float3 col = sandLight;
float lineSpacing = 1.0 / float(rakeLineCount);
for (int i = 0; i < 5; i++) {
    if (i >= int(stoneCount)) break;
    float fi = float(i);
    float2 stonePos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2,
        fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2
    );
    float stoneSize = fract(sin(fi * 178.3) * 43758.5453) * 0.05 + 0.03;
    float stoneDist = length((p - stonePos) * float2(1.0, 1.5));
    if (ripples > 0.5) {
        float rippleDist = length(p - stonePos);
        for (int r = 1; r <= 5; r++) {
            float fr = float(r);
            float rippleR = stoneSize + fr * lineSpacing * 1.5;
            float ripple = smooth > 0.5 ? smoothstep(lineSpacing * 0.3, 0.0, abs(rippleDist - rippleR)) : step(abs(rippleDist - rippleR), lineSpacing * 0.3);
            ripple *= smoothstep(rippleR + lineSpacing * 3.0, rippleR, rippleDist);
            col = mix(col, sandDark, ripple * 0.5);
        }
    }
}
float rakeY = p.y + sin(timeVal * 0.2) * 0.01 * peacefulness;
for (int i = 0; i < 5; i++) {
    if (i >= int(stoneCount)) break;
    float fi = float(i);
    float2 stonePos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2,
        fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2
    );
    float stoneDist = length(p - stonePos);
    float stoneInfluence = exp(-stoneDist * 5.0);
    rakeY += stoneInfluence * waveAmplitude * sin(atan2(p.y - stonePos.y, p.x - stonePos.x) * 2.0);
}
float rakeLine = fract(rakeY / lineSpacing);
float rake = smooth > 0.5 ? smoothstep(0.3, 0.5, rakeLine) - smoothstep(0.5, 0.7, rakeLine) : step(0.4, rakeLine) * step(rakeLine, 0.6);
col = mix(col, sandDark, rake * 0.4);
for (int i = 0; i < 5; i++) {
    if (i >= int(stoneCount)) break;
    float fi = float(i);
    float2 stonePos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2,
        fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2
    );
    float stoneSize = fract(sin(fi * 178.3) * 43758.5453) * 0.05 + 0.03;
    float stoneDist = length((p - stonePos) * float2(1.0, 1.3));
    float stone = smooth > 0.5 ? smoothstep(stoneSize, stoneSize * 0.7, stoneDist) : step(stoneDist, stoneSize);
    float3 stoneColor = color2;
    float stoneShade = 1.0 - (p.x - stonePos.x + p.y - stonePos.y) * 2.0;
    stoneColor *= 0.8 + stoneShade * 0.4;
    col = mix(col, stoneColor, stone);
}
if (rainbow > 0.5) {
    float3 rainbowCol = 0.5 + 0.5 * cos(timeVal + p.x * 6.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, rainbowCol, 0.3);
}
if (peacefulness > 0.0) {
    float peace = sin(p.x * 3.0 + timeVal * 0.1 * (1.0 - peacefulness)) * 0.02;
    peace += sin(p.y * 2.0 + timeVal * 0.05 * (1.0 - peacefulness)) * 0.02;
    col += peace * peacefulness;
}

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(col, col * 1.5, lum);
}
if (showEdges > 0.5) {
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (radial > 0.5) {
    float radialDist = length(p - 0.5);
    col *= 1.0 + 0.2 * sin(radialDist * 20.0 + timeVal);
}
if (glow > 0.5) {
    float glowAmt = 1.0 + glowIntensity * 0.5;
    col *= glowAmt;
}
if (noise > 0.5) {
    float n = fract(sin(dot(p, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Mosaic
let mosaicCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param tileSize "Tile Size" range(0.02, 0.1) default(0.05)
// @param groutWidth "Grout Width" range(0.0, 0.3) default(0.1)
// @param colorVariation "Color Variation" range(0.0, 0.5) default(0.2)
// @param irregularity "Irregularity" range(0.0, 0.3) default(0.1)
// @param shininess "Shininess" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.2, 3.0) default(1.0)
// @param contrast "Contrast" range(0.2, 3.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param vignetteSize "Vignette Size" range(0.0, 2.0) default(1.0)
// @param chromaticAmount "Chromatic Shift" range(0.0, 1.0) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 2.0) default(1.0)
// @param highlightIntensity "Highlight" range(0.0, 2.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28) default(0.0)
// @param color1R "Color 1 R" range(0.0, 1.0) default(0.85)
// @param color1G "Color 1 G" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 B" range(0.0, 1.0) default(0.7)
// @param color2R "Color 2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 G" range(0.0, 1.0) default(0.35)
// @param color2B "Color 2 B" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle roman "Roman" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise FX" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines FX" default(false)
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

float3 color1 = float3(color1R, color1G, color1B);
float3 color2 = float3(color2R, color2G, color2B);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = uv - center;
if (mirror > 0.5) p.x = abs(p.x);
float ang = rotation;
float cosA = cos(ang); float sinA = sin(ang);
p = float2(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);
p /= zoom;
if (distortion > 0.0) {
    float dist = length(p);
    p *= 1.0 + distortion * dist * dist;
}
p += center;
if (pixelate > 0.5 && pixelSize > 1.0) {
    p = floor(p * (100.0 / pixelSize)) / (100.0 / pixelSize);
}
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float kSeg = 6.28318 / 6.0;
    kAngle = fmod(abs(kAngle), kSeg);
    float kDist = length(kp);
    p = float2(cos(kAngle), sin(kAngle)) * kDist + 0.5;
}

float pulseAmt = pulse > 0.5 ? 1.0 + 0.1 * sin(timeVal * 3.0) : 1.0;
float flickerAmt = flicker > 0.5 ? 0.95 + 0.05 * fract(sin(timeVal * 20.0) * 43758.5453) : 1.0;

float3 col = float3(0.3, 0.28, 0.25);
float2 tileId = floor(p / tileSize);
float tileSeed = fract(sin(tileId.x * 127.1 + tileId.y * 311.7 + timeVal * 0.1) * 43758.5453);
float2 tileOffset = float2(0.0);
if (irregularity > 0.0) {
    tileOffset = float2(
        fract(sin(tileSeed * 178.3) * 43758.5453) - 0.5,
        fract(sin(tileSeed * 267.9) * 43758.5453) - 0.5
    ) * irregularity * tileSize;
}
float2 tileLocal = fract(p / tileSize);
float grout = step(groutWidth * 0.5, tileLocal.x) * step(tileLocal.x, 1.0 - groutWidth * 0.5);
grout *= step(groutWidth * 0.5, tileLocal.y) * step(tileLocal.y, 1.0 - groutWidth * 0.5);
float3 tileColor;
if (rainbow > 0.5) {
    tileColor = 0.5 + 0.5 * cos(tileSeed * 6.28 + timeVal + float3(0.0, 2.0, 4.0));
} else if (roman > 0.5) {
    if (tileSeed < 0.3) tileColor = color1;
    else if (tileSeed < 0.5) tileColor = float3(0.7, 0.5, 0.4);
    else if (tileSeed < 0.7) tileColor = color2;
    else if (tileSeed < 0.85) tileColor = float3(0.8, 0.75, 0.6);
    else tileColor = float3(0.5, 0.45, 0.4);
} else if (gradient > 0.5) {
    tileColor = mix(color1, color2, p.x);
} else {
    tileColor = 0.5 + 0.5 * cos(tileSeed * 6.28 + float3(0.0, 2.0, 4.0));
}
float colorVar = (fract(sin(tileSeed * 43.758) * 43758.5453) - 0.5) * colorVariation;
tileColor += colorVar;
if (shininess > 0.0) {
    float shine = pow(1.0 - length(tileLocal - 0.5) * 1.5, 3.0);
    shine = max(0.0, shine);
    tileColor += shine * shininess;
}
col = mix(col, tileColor, grout);
float edge = grout * (1.0 - grout);
col = mix(col, col * 0.8, edge * 10.0);

if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(col, col * 1.5, lum);
}
if (showEdges > 0.5) {
    float edgeVal = fwidth(length(col)) * 10.0;
    col = mix(col, float3(1.0), edgeVal);
}
if (radial > 0.5) {
    float radialDist = length(p - 0.5);
    col *= 1.0 + 0.2 * sin(radialDist * 20.0 + timeVal);
}
if (glow > 0.5) {
    float glowAmt = 1.0 + glowIntensity * 0.5;
    col *= glowAmt;
}
if (noise > 0.5) {
    float n = fract(sin(dot(p, float2(12.9898, 78.233)) + timeVal) * 43758.5453);
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
if (outline > 0.5) {
    float edgeVal = fwidth(length(col)) * 5.0;
    col = mix(col, float3(0.0), edgeVal);
}
if (invert > 0.5) col = 1.0 - col;

col = mix(float3(dot(col, float3(0.299, 0.587, 0.114))), col, colorSaturation);
float hueAngle = hueShift;
float3 k = float3(0.57735);
col = col * cos(hueAngle) + cross(k, col) * sin(hueAngle) + k * dot(k, col) * (1.0 - cos(hueAngle));
col *= brightness * flickerAmt * pulseAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

