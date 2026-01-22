//
//  ShaderCodes_Part14.swift
//  LM_GLSL
//
//  Shader codes - Part 14: Mechanical & Industrial Effects (20 shaders)
//

import Foundation

// MARK: - Mechanical & Industrial Effects

/// Clockwork Mechanism
let clockworkMechanismCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param gearCount "Gear Count" range(3.0, 8.0) default(5.0)
// @param rotationSpeed "Rotation Speed" range(0.2, 2.0) default(0.5)
// @param gearSize "Gear Size" range(0.1, 0.3) default(0.2)
// @param teethCount "Teeth Count" range(8.0, 24.0) default(12.0)
// @param brassiness "Brassiness" range(0.0, 1.0) default(0.7)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.55)
// @toggle animated "Animated" default(true)
// @toggle ticking "Ticking" default(false)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.85 + 0.15 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 brassColor = mix(float3(0.6, 0.5, 0.3), float3(color1R, color1G, color1B), brassiness);
float3 steelColor = float3(color2R, color2G, color2B);

float3 col = float3(0.05, 0.04, 0.03);
float time = ticking > 0.5 ? floor(timeVal * 2.0) * 0.5 : timeVal;

for (int i = 0; i < 8; i++) {
    if (float(i) >= gearCount) break;
    float fi = float(i);
    float2 gearPos = float2(
        sin(fi * 2.4) * 0.5,
        cos(fi * 2.4) * 0.5
    );
    float gearR = gearSize * (0.8 + fract(sin(fi * 127.1) * 43758.5453) * 0.4);
    float spinDir = fmod(fi, 2.0) < 0.5 ? 1.0 : -1.0;
    float gearSpeed = rotationSpeed / gearR;
    float2 toP = p - gearPos;
    float r = length(toP);
    float a = atan2(toP.y, toP.x) + time * gearSpeed * spinDir;
    float teeth = sin(a * teethCount) * 0.5 + 0.5;
    float gearShape = smoothstep(gearR + 0.02, gearR, r - teeth * 0.02);
    gearShape -= smoothstep(gearR * 0.3, gearR * 0.25, r);
    float3 gearColor;
    if (rainbow > 0.5) {
        gearColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    } else {
        gearColor = fmod(fi, 2.0) < 0.5 ? brassColor : steelColor;
    }
    if (neon > 0.5) gearColor = pow(gearColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) gearColor = mix(gearColor, float3(1.0), 0.3);
    float shading = 0.7 + teeth * 0.3;
    col += gearShape * gearColor * shading * pulseAmt;
    float axle = smoothstep(gearR * 0.15, gearR * 0.1, r);
    col += axle * steelColor * 0.8;
    for (int s = 0; s < 4; s++) {
        float fs = float(s);
        float spokeA = fs * 1.5708 + time * gearSpeed * spinDir;
        float spokeDist = abs(sin(a - spokeA)) * r;
        float spoke = step(spokeDist, 0.01) * step(gearR * 0.2, r) * step(r, gearR * 0.8);
        col += spoke * gearColor * 0.5;
    }
}

if (glow > 0.5) col += col * glowIntensity * 0.2;
if (gradient > 0.5) col *= 0.9 + (p.y * 0.5 + 0.5) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p) * 0.2;

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

/// Steam Pipes
let steamPipesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param pipeCount "Pipe Count" range(3.0, 10.0) default(6.0)
// @param steamAmount "Steam Amount" range(0.0, 1.0) default(0.5)
// @param pipeRadius "Pipe Radius" range(0.02, 0.08) default(0.04)
// @param rustAmount "Rust Amount" range(0.0, 1.0) default(0.3)
// @param pressureLevel "Pressure Level" range(0.5, 2.0) default(1.0)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.35)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.25)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle leaking "Leaking" default(true)
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

float3 metalColor = float3(color1R, color1G, color1B);
float3 rustColor = float3(color2R, color2G, color2B);
float3 steamColor = float3(0.8, 0.8, 0.85);

float3 col = float3(0.1, 0.08, 0.06);

for (int i = 0; i < 10; i++) {
    if (float(i) >= pipeCount) break;
    float fi = float(i);
    float pipeY = (fi + 0.5) / pipeCount;
    float pipeDist = abs(p.y - pipeY);
    float pipe = smoothstep(pipeRadius + 0.005, pipeRadius, pipeDist);
    float rust = sin(p.x * 50.0 + fi * 10.0) * sin(p.x * 30.0 + pipeY * 100.0);
    rust = rust * 0.5 + 0.5;
    rust *= rustAmount;
    float3 pipeColor = mix(metalColor, rustColor, rust * step(pipeDist, pipeRadius));
    if (rainbow > 0.5) pipeColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) pipeColor = pow(pipeColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) pipeColor = mix(pipeColor, float3(1.0), 0.3);
    float highlight = smoothstep(pipeRadius, pipeRadius * 0.5, pipeDist);
    highlight *= 1.0 - smoothstep(pipeRadius * 0.3, 0.0, pipeDist);
    pipeColor += highlight * 0.2;
    col = mix(col, pipeColor, pipe * pulseAmt);
    float jointX = fract(fi * 0.3 + 0.2);
    float jointDist = abs(p.x - jointX);
    float joint = step(jointDist, 0.02) * step(pipeDist, pipeRadius + 0.01);
    col = mix(col, metalColor * 0.8, joint);
    if (leaking > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.5) {
        float leakX = fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1;
        float leakDist = length(float2(p.x - leakX, (p.y - pipeY) * 0.5));
        float steamTime = fract(timeVal * 0.5 + fi * 0.3);
        float steam = exp(-leakDist * 10.0 / pressureLevel) * steamAmount;
        steam *= step(pipeY, p.y) * (1.0 - steamTime);
        float steamNoise = fract(sin(floor(p.y * 50.0) * 127.1 + timeVal * 10.0) * 43758.5453);
        steam *= steamNoise * 0.5 + 0.5;
        col += steam * steamColor;
    }
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Industrial Pistons
let industrialPistonsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param pistonCount "Piston Count" range(2.0, 8.0) default(4.0)
// @param cycleSpeed "Cycle Speed" range(0.5, 3.0) default(1.5)
// @param strokeLength "Stroke Length" range(0.1, 0.4) default(0.2)
// @param shininess "Shininess" range(0.3, 1.0) default(0.6)
// @param oilAmount "Oil Amount" range(0.0, 0.5) default(0.2)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.55)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.7)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.75)
// @toggle animated "Animated" default(true)
// @toggle synchronized "Synchronized" default(false)
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

float3 metalColor = float3(color1R, color1G, color1B);
float3 chromeColor = float3(color2R, color2G, color2B);
float3 oilColor = float3(0.15, 0.12, 0.08);

float3 col = float3(0.08, 0.08, 0.1);

for (int i = 0; i < 8; i++) {
    if (float(i) >= pistonCount) break;
    float fi = float(i);
    float pistonX = (fi + 0.5) / pistonCount;
    float phase = synchronized > 0.5 ? 0.0 : fi * 0.5;
    float pistonY = sin(timeVal * cycleSpeed * 3.0 + phase) * strokeLength + 0.5;
    float pistonWidth = 0.06;
    float pistonHeight = 0.15;
    float piston = step(abs(p.x - pistonX), pistonWidth);
    piston *= step(pistonY - pistonHeight, p.y) * step(p.y, pistonY);
    float highlight = 1.0 - abs(p.x - pistonX) / pistonWidth;
    highlight = pow(highlight, 2.0) * shininess;
    float3 pistColor = chromeColor * (0.7 + highlight * 0.3);
    if (rainbow > 0.5) pistColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) pistColor = pow(pistColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) pistColor = mix(pistColor, float3(1.0), 0.3);
    col = mix(col, pistColor, piston * pulseAmt);
    float cylinderTop = pistonY - pistonHeight - 0.02;
    float cylinder = step(abs(p.x - pistonX), pistonWidth + 0.01);
    cylinder *= step(0.15, p.y) * step(p.y, cylinderTop);
    col = mix(col, metalColor * 0.6, cylinder);
    float rodWidth = 0.015;
    float rod = step(abs(p.x - pistonX), rodWidth);
    rod *= step(p.y, 0.15) * step(0.0, p.y);
    col = mix(col, chromeColor, rod);
    if (oilAmount > 0.0) {
        float oil = step(abs(p.x - pistonX), pistonWidth + 0.005);
        oil *= step(pistonY - pistonHeight - 0.03, p.y);
        oil *= step(p.y, pistonY - pistonHeight);
        float oilDrip = sin(p.y * 100.0 + timeVal * 5.0 + fi * 20.0) * 0.5 + 0.5;
        oil *= oilDrip * oilAmount;
        col = mix(col, oilColor, oil);
    }
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Factory Sparks
let factorySparksCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param sparkDensity "Spark Density" range(20.0, 100.0) default(50.0)
// @param sparkSpeed "Spark Speed" range(1.0, 4.0) default(2.0)
// @param sparkSize "Spark Size" range(0.005, 0.03) default(0.01)
// @param sourceX "Source X" range(0.0, 1.0) default(0.5)
// @param sourceY "Source Y" range(0.0, 1.0) default(0.7)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle welding "Welding" default(true)
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

float3 sparkColorStart = float3(color1R, color1G, color1B);
float3 sparkColorEnd = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.02, 0.03);
float2 source = float2(sourceX, sourceY);

if (welding > 0.5) {
    float weldGlow = exp(-length(p - source) * 10.0);
    float weldFlicker = sin(timeVal * 50.0) * 0.3 + 0.7;
    col += weldGlow * float3(0.5, 0.7, 1.0) * weldFlicker;
    float weldCore = exp(-length(p - source) * 30.0);
    col += weldCore * float3(1.0, 1.0, 1.0);
}

for (int i = 0; i < 100; i++) {
    if (float(i) >= sparkDensity) break;
    float fi = float(i);
    float birthTime = fract(sin(fi * 127.1) * 43758.5453);
    float sparkAge = fract(timeVal * 0.5 + birthTime);
    float ang = fract(sin(fi * 311.7) * 43758.5453) * 3.14159 - 1.5708;
    float spd = fract(sin(fi * 178.3) * 43758.5453) * 0.5 + 0.5;
    float2 velocity = float2(cos(ang), sin(ang)) * spd * sparkSpeed;
    float gravity = sparkAge * sparkAge * 2.0;
    float2 sparkPos = source + velocity * sparkAge - float2(0.0, gravity * 0.5);
    float d = length(p - sparkPos);
    float spark = smoothstep(sparkSize, sparkSize * 0.3, d);
    spark *= 1.0 - sparkAge;
    float3 sparkColor = mix(sparkColorStart, sparkColorEnd, sparkAge);
    if (rainbow > 0.5) sparkColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) sparkColor = pow(sparkColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) sparkColor = mix(sparkColor, float3(1.0), 0.3);
    col += spark * sparkColor * pulseAmt;
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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
float angle2 = hueShift;
float3 k = float3(0.57735);
col = col * cos(angle2) + cross(k, col) * sin(angle2) + k * dot(k, col) * (1.0 - cos(angle2));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Metal Plates
let metalPlatesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param plateCountX "Plates X" range(2.0, 8.0) default(4.0)
// @param plateCountY "Plates Y" range(2.0, 8.0) default(4.0)
// @param bevelSize "Bevel Size" range(0.01, 0.1) default(0.02)
// @param scratchAmount "Scratch Amount" range(0.0, 1.0) default(0.4)
// @param dirtAmount "Dirt Amount" range(0.0, 0.5) default(0.2)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.45)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.18)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.15)
// @toggle animated "Animated" default(true)
// @toggle rivets "Rivets" default(true)
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

float3 metalColor = float3(color1R, color1G, color1B);
float3 dirtColor = float3(color2R, color2G, color2B);

float3 col = metalColor;

float cellX = floor(p.x * plateCountX);
float cellY = floor(p.y * plateCountY);
float2 cellP = float2(fract(p.x * plateCountX), fract(p.y * plateCountY));
float plateSeed = fract(sin(cellX * 127.1 + cellY * 311.7) * 43758.5453);
col *= 0.9 + plateSeed * 0.2;

float bevelLeft = smoothstep(0.0, bevelSize, cellP.x);
float bevelRight = smoothstep(0.0, bevelSize, 1.0 - cellP.x);
float bevelBottom = smoothstep(0.0, bevelSize, cellP.y);
float bevelTop = smoothstep(0.0, bevelSize, 1.0 - cellP.y);
float bevel = min(min(bevelLeft, bevelRight), min(bevelBottom, bevelTop));
col *= 0.7 + bevel * 0.3;
col += (1.0 - bevelLeft) * 0.1;
col -= (1.0 - bevelRight) * 0.1;

if (rainbow > 0.5) col = 0.5 + 0.5 * cos(timeVal + cellX + cellY + float3(0.0, 2.094, 4.188));
if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (scratchAmount > 0.0) {
    float scratch = sin(p.x * 200.0 + p.y * 50.0 + plateSeed * 100.0);
    scratch = step(1.0 - scratchAmount * 0.1, scratch);
    col += scratch * 0.1;
    float scratch2 = sin(p.x * 50.0 + p.y * 200.0 + plateSeed * 50.0);
    scratch2 = step(1.0 - scratchAmount * 0.1, scratch2);
    col -= scratch2 * 0.05;
}
if (dirtAmount > 0.0) {
    float dirt = sin(p.x * 30.0 + plateSeed * 20.0) * sin(p.y * 25.0 + plateSeed * 30.0);
    dirt = dirt * 0.5 + 0.5;
    dirt *= dirtAmount;
    col = mix(col, dirtColor, dirt * (1.0 - bevel));
}
if (rivets > 0.5) {
    float rivetR = 0.03;
    float2 rivetPositions[4];
    rivetPositions[0] = float2(0.1, 0.1);
    rivetPositions[1] = float2(0.9, 0.1);
    rivetPositions[2] = float2(0.1, 0.9);
    rivetPositions[3] = float2(0.9, 0.9);
    for (int i = 0; i < 4; i++) {
        float d = length(cellP - rivetPositions[i]);
        float rivet = smoothstep(rivetR, rivetR * 0.8, d);
        float rivetHighlight = smoothstep(rivetR * 0.5, rivetR * 0.3, d);
        col = mix(col, float3(0.35, 0.35, 0.4), 1.0 - rivet);
        col += rivetHighlight * 0.1;
    }
}

col *= pulseAmt;
if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Rotating Fan
let rotatingFanCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param bladeCount "Blade Count" range(3.0, 8.0) default(5.0)
// @param rotationSpeed "Rotation Speed" range(0.5, 5.0) default(2.0)
// @param fanRadius "Fan Radius" range(0.3, 0.5) default(0.4)
// @param bladeWidth "Blade Width" range(0.1, 0.4) default(0.2)
// @param cageOpacity "Cage Opacity" range(0.0, 1.0) default(0.5)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.35)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.45)
// @toggle animated "Animated" default(true)
// @toggle motionBlur "Motion Blur" default(true)
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

float3 bladeColor = float3(color1R, color1G, color1B);
float3 hubColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.1, 0.1, 0.12);

float blade = 0.0;
float rotAngle = timeVal * rotationSpeed * 3.0;
if (motionBlur > 0.5 && rotationSpeed > 2.0) {
    for (int b = 0; b < 8; b++) {
        float fb = float(b);
        float blurOffset = fb * 0.02;
        float bladeA = a - rotAngle + blurOffset;
        float bladeAngle = fmod(bladeA + 100.0, 6.28318 / bladeCount);
        float bladeDist = abs(bladeAngle - 3.14159 / bladeCount);
        float bladeShape = step(bladeDist, bladeWidth) * step(0.08, r) * step(r, fanRadius);
        blade += bladeShape * (1.0 - fb / 8.0);
    }
    blade = min(blade, 1.0) * 0.7;
} else {
    for (int i = 0; i < 8; i++) {
        if (float(i) >= bladeCount) break;
        float fi = float(i);
        float bladeA = fi * 6.28318 / bladeCount + rotAngle;
        float angleDiff = abs(fmod(a - bladeA + 3.14159 + 100.0, 6.28318) - 3.14159);
        float bladeShape = smoothstep(bladeWidth * 0.5, bladeWidth * 0.3, angleDiff);
        bladeShape *= step(0.08, r) * step(r, fanRadius);
        blade = max(blade, bladeShape);
    }
}

float3 bladeFinalColor = bladeColor;
if (rainbow > 0.5) bladeFinalColor = 0.5 + 0.5 * cos(timeVal + a + float3(0.0, 2.094, 4.188));
if (neon > 0.5) bladeFinalColor = pow(bladeFinalColor, float3(0.7)) * 1.3;
if (pastel > 0.5) bladeFinalColor = mix(bladeFinalColor, float3(1.0), 0.3);
col = mix(col, bladeFinalColor, blade * pulseAmt);

float hub = smoothstep(0.1, 0.08, r);
col = mix(col, hubColor, hub);
float hubDetail = smoothstep(0.05, 0.03, r);
col = mix(col, hubColor * 1.2, hubDetail);

if (cageOpacity > 0.0) {
    float cage = 0.0;
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float cageA = fi * 0.785;
        float cageLine = smoothstep(0.02, 0.01, abs(sin(a - cageA) * r));
        cageLine *= step(fanRadius - 0.05, r) * step(r, fanRadius + 0.05);
        cage = max(cage, cageLine);
    }
    float cageRing = smoothstep(0.02, 0.01, abs(r - fanRadius));
    cage = max(cage, cageRing);
    col = mix(col, float3(0.2, 0.2, 0.22), cage * cageOpacity);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.9 + pCoord.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(pCoord - 0.5) * 0.3;

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

/// Pressure Gauge
let pressureGaugeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param pressure "Pressure" range(0.0, 1.0) default(0.6)
// @param needleSmooth "Needle Smooth" range(0.1, 1.0) default(0.5)
// @param gaugeSize "Gauge Size" range(0.3, 0.5) default(0.4)
// @param dangerZone "Danger Zone" range(0.7, 0.95) default(0.8)
// @param glassReflection "Glass Reflection" range(0.0, 0.5) default(0.2)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.85)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle warning "Warning" default(false)
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

float3 faceColor = float3(color1R, color1G, color1B);
float3 needleColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.1, 0.1, 0.1);

float gauge = smoothstep(gaugeSize + 0.02, gaugeSize, r);
if (rainbow > 0.5) faceColor = 0.5 + 0.5 * cos(timeVal + a + float3(0.0, 2.094, 4.188));
if (neon > 0.5) faceColor = pow(faceColor, float3(0.7)) * 1.3;
if (pastel > 0.5) faceColor = mix(faceColor, float3(1.0), 0.3);
col = mix(col, faceColor, gauge);

float rim = smoothstep(gaugeSize, gaugeSize - 0.02, r);
rim -= smoothstep(gaugeSize - 0.02, gaugeSize - 0.04, r);
col = mix(col, float3(0.3, 0.3, 0.35), rim);

float startAngle = 2.35619;
float endAngle = 0.785398;
float dangerStart = startAngle - (startAngle - endAngle) * dangerZone;
for (int i = 0; i <= 10; i++) {
    float fi = float(i);
    float tickAngle = startAngle - (startAngle - endAngle) * fi / 10.0;
    float2 tickDir = float2(cos(tickAngle), sin(tickAngle));
    float tickStart = gaugeSize * 0.7;
    float tickEnd = gaugeSize * 0.85;
    float along = dot(p, tickDir);
    float perp = abs(dot(p, float2(-tickDir.y, tickDir.x)));
    float tick = step(tickStart, along) * step(along, tickEnd) * step(perp, 0.01);
    float3 tickColor = tickAngle < dangerStart ? float3(0.8, 0.2, 0.2) : float3(0.2, 0.2, 0.2);
    col = mix(col, tickColor, tick * gauge);
}

float smoothPressure = pressure;
float needleAngle = startAngle - (startAngle - endAngle) * smoothPressure;
float2 needleDir = float2(cos(needleAngle), sin(needleAngle));
float needleAlong = dot(p, needleDir);
float needlePerp = abs(dot(p, float2(-needleDir.y, needleDir.x)));
float needleWidth = 0.015 * (1.0 - needleAlong / gaugeSize);
float needle = step(0.0, needleAlong) * step(needleAlong, gaugeSize * 0.75);
needle *= step(needlePerp, needleWidth);
col = mix(col, needleColor, needle * gauge);

float hub = smoothstep(0.05, 0.03, r);
col = mix(col, float3(0.3, 0.3, 0.35), hub * gauge);

if (glassReflection > 0.0) {
    float reflection = smoothstep(0.0, gaugeSize, p.x + p.y);
    reflection *= gauge * glassReflection;
    col += reflection * 0.2;
}
if (warning > 0.5 && pressure > dangerZone) {
    float warn = sin(timeVal * 10.0) * 0.5 + 0.5;
    col = mix(col, float3(1.0, 0.3, 0.2), warn * 0.3 * gauge);
}

col *= pulseAmt;
if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.9 + pCoord.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(pCoord - 0.5) * 0.3;

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

/// Chain Links
let chainLinksCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param linkCount "Link Count" range(3.0, 10.0) default(6.0)
// @param linkSize "Link Size" range(0.05, 0.15) default(0.1)
// @param chainAngle "Chain Angle" range(-0.5, 0.5) default(0.0)
// @param swingAmount "Swing Amount" range(0.0, 0.3) default(0.1)
// @param shininess "Shininess" range(0.3, 1.0) default(0.6)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.55)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle rusty "Rusty" default(false)
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

float3 metalColor = rusty > 0.5 ? float3(color2R, color2G, color2B) : float3(color1R, color1G, color1B);
float3 rustColor = float3(0.4, 0.2, 0.1);

float3 col = float3(0.1, 0.1, 0.12);
float swing = sin(timeVal * 2.0) * swingAmount;

for (int i = 0; i < 10; i++) {
    if (float(i) >= linkCount) break;
    float fi = float(i);
    float linkSwing = swing * (1.0 + fi * 0.2);
    float2 linkCenter = float2(
        0.5 + sin(chainAngle + linkSwing) * fi * linkSize * 0.8,
        0.9 - fi * linkSize * 1.5
    );
    float linkAngle = chainAngle + linkSwing + (fmod(fi, 2.0) < 0.5 ? 0.0 : 1.5708);
    float2 toP = p - linkCenter;
    float2 rotP = float2(
        toP.x * cos(linkAngle) + toP.y * sin(linkAngle),
        -toP.x * sin(linkAngle) + toP.y * cos(linkAngle)
    );
    float outerW = linkSize * 0.6;
    float outerH = linkSize;
    float innerW = linkSize * 0.3;
    float innerH = linkSize * 0.7;
    float outer = step(abs(rotP.x), outerW) * step(abs(rotP.y), outerH);
    float inner = step(abs(rotP.x), innerW) * step(abs(rotP.y), innerH);
    float link = outer - inner;
    float cornerDist = length(float2(abs(rotP.x) - innerW, abs(rotP.y) - innerH));
    link = max(link, step(cornerDist, (outerW - innerW) * 0.5) * step(innerW, abs(rotP.x)));
    float highlight = (rotP.x + outerW) / (outerW * 2.0) * shininess;
    float3 linkColor = metalColor * (0.7 + highlight * 0.5);
    if (rainbow > 0.5) linkColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) linkColor = pow(linkColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) linkColor = mix(linkColor, float3(1.0), 0.3);
    if (rusty > 0.5) {
        float rust = sin(rotP.x * 100.0 + rotP.y * 80.0 + fi * 20.0) * 0.5 + 0.5;
        linkColor = mix(linkColor, rustColor, rust * 0.3);
    }
    col = mix(col, linkColor, link * pulseAmt);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Control Panel
let controlPanelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param buttonCount "Button Count" range(4.0, 12.0) default(8.0)
// @param ledBrightness "LED Brightness" range(0.5, 1.5) default(1.0)
// @param screenGlow "Screen Glow" range(0.0, 1.0) default(0.5)
// @param activeButtons "Active Buttons" range(0.0, 1.0) default(0.6)
// @param flickerRate "Flicker Rate" range(0.0, 0.5) default(0.1)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle powered "Powered" default(true)
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

float3 buttonActiveColor = float3(color1R, color1G, color1B);
float3 ledActiveColor = float3(color2R, color2G, color2B);

float3 col = float3(0.15, 0.15, 0.18);
float panelBorder = step(0.02, p.x) * step(p.x, 0.98);
panelBorder *= step(0.02, p.y) * step(p.y, 0.98);
col = mix(float3(0.1, 0.1, 0.12), col, panelBorder);

if (powered > 0.5) {
    float screenArea = step(0.1, p.x) * step(p.x, 0.5);
    screenArea *= step(0.6, p.y) * step(p.y, 0.9);
    float3 screenColor = float3(0.1, 0.3, 0.15);
    float scanline = sin(p.y * 200.0 + timeVal * 5.0) * 0.1 + 0.9;
    col = mix(col, screenColor * scanline, screenArea);
    float screenGlowEffect = exp(-length(p - float2(0.3, 0.75)) * 3.0) * screenGlow;
    col += screenGlowEffect * float3(0.0, 0.2, 0.1);
}

int buttonsPerRow = int(ceil(buttonCount / 2.0));
for (int i = 0; i < 12; i++) {
    if (float(i) >= buttonCount) break;
    float fi = float(i);
    int row = i / buttonsPerRow;
    int colIdx = i - row * buttonsPerRow;
    float bx = 0.6 + float(colIdx) * 0.1;
    float by = 0.75 - float(row) * 0.15;
    float buttonDist = length(p - float2(bx, by));
    float button = smoothstep(0.03, 0.025, buttonDist);
    float isActive = step(fi / buttonCount, activeButtons);
    float flick = 1.0;
    if (flickerRate > 0.0 && powered > 0.5) {
        flick = step(flickerRate, fract(sin(timeVal * 10.0 + fi * 5.0) * 0.5 + 0.5));
    }
    float3 btnColor = isActive > 0.5 && powered > 0.5 ? buttonActiveColor * flick : float3(0.2, 0.2, 0.2);
    if (rainbow > 0.5 && isActive > 0.5) btnColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) btnColor = pow(btnColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) btnColor = mix(btnColor, float3(1.0), 0.3);
    col = mix(col, btnColor, button * pulseAmt);
    if (powered > 0.5) {
        float ledX = bx;
        float ledY = by + 0.05;
        float ledDist = length(p - float2(ledX, ledY));
        float led = smoothstep(0.008, 0.005, ledDist);
        float3 ledColor = isActive > 0.5 ? ledActiveColor : float3(0.5, 0.0, 0.0);
        ledColor *= ledBrightness * flick;
        col += led * ledColor;
    }
}

for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float sliderX = 0.2 + fi * 0.1;
    float sliderY = 0.3;
    float sliderHeight = 0.2;
    float sliderTrack = step(abs(p.x - sliderX), 0.01);
    sliderTrack *= step(sliderY - sliderHeight * 0.5, p.y);
    sliderTrack *= step(p.y, sliderY + sliderHeight * 0.5);
    col = mix(col, float3(0.1, 0.1, 0.1), sliderTrack);
    float sliderPos = sin(timeVal * (1.0 + fi * 0.3)) * 0.5 + 0.5;
    float sliderKnob = length(p - float2(sliderX, sliderY - sliderHeight * 0.5 + sliderPos * sliderHeight));
    float knob = smoothstep(0.02, 0.015, sliderKnob);
    col = mix(col, float3(0.4, 0.4, 0.45), knob);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Mechanical Heart
let mechanicalHeartCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param beatRate "Beat Rate" range(0.5, 2.0) default(1.0)
// @param heartSize "Heart Size" range(0.2, 0.5) default(0.3)
// @param gearDetail "Gear Detail" range(0.3, 1.0) default(0.7)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param steamAmount "Steam Amount" range(0.0, 0.5) default(0.2)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.7)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.7)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle beating "Beating" default(true)
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

float3 brassColor = float3(color1R, color1G, color1B);
float3 copperColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float3 col = float3(0.05, 0.04, 0.03);
float beat = beating > 0.5 ? sin(timeVal * beatRate * 6.0) * 0.1 + 1.0 : 1.0;
float2 hp = p / (heartSize * beat);
float heart = pow(abs(hp.x), 2.0/3.0) + pow(abs(hp.y), 2.0/3.0);
heart = 1.0 - smoothstep(0.8, 1.0, heart);

float3 heartCol = brassColor;
if (rainbow > 0.5) heartCol = 0.5 + 0.5 * cos(timeVal + atan2(hp.y, hp.x) + float3(0.0, 2.094, 4.188));
if (neon > 0.5) heartCol = pow(heartCol, float3(0.7)) * 1.3;
if (pastel > 0.5) heartCol = mix(heartCol, float3(1.0), 0.3);
col = mix(col, heartCol, heart);

if (gearDetail > 0.0) {
    float gearR = heartSize * 0.4;
    float gearA = atan2(p.y, p.x) + timeVal * 2.0 * (beating > 0.5 ? beat : 1.0);
    float r = length(p);
    float teeth = sin(gearA * 12.0) * 0.5 + 0.5;
    float gear = smoothstep(gearR + 0.01, gearR - 0.01, r - teeth * 0.02);
    gear -= smoothstep(gearR * 0.4, gearR * 0.3, r);
    gear *= heart * gearDetail;
    col = mix(col, copperColor, gear);
    float smallGearR = heartSize * 0.15;
    float2 smallGearPos = float2(heartSize * 0.3, heartSize * 0.2);
    float smallGearDist = length(p - smallGearPos);
    float smallGearA = atan2(p.y - smallGearPos.y, p.x - smallGearPos.x) - timeVal * 4.0;
    float smallTeeth = sin(smallGearA * 8.0) * 0.5 + 0.5;
    float smallGear = smoothstep(smallGearR, smallGearR - 0.01, smallGearDist - smallTeeth * 0.01);
    smallGear -= smoothstep(smallGearR * 0.3, smallGearR * 0.2, smallGearDist);
    smallGear *= heart;
    col = mix(col, brassColor * 0.8, smallGear * gearDetail);
}

if (glowAmount > 0.0 && beating > 0.5) {
    float gl = heart * (beat - 0.9) * 5.0;
    gl = max(0.0, gl);
    col += gl * float3(1.0, 0.3, 0.1) * glowAmount;
}
if (steamAmount > 0.0 && beating > 0.5) {
    float2 steamPos = float2(0.0, heartSize * 0.8);
    float steamDist = length(p - steamPos);
    float steam = exp(-steamDist * 5.0) * steamAmount;
    float steamNoise = fract(sin(floor(p.y * 30.0 + timeVal * 10.0) * 127.1) * 43758.5453);
    steam *= steamNoise;
    steam *= step(heartSize * 0.5, p.y);
    col += steam * float3(0.8, 0.8, 0.85);
}

col *= pulseAmt;
if (glow > 0.5) col += col * glowIntensity * 0.1;
if (gradient > 0.5) col *= 0.9 + pCoord.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(pCoord - 0.5) * 0.3;

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

/// Conveyor Belt
let conveyorBeltCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param beltSpeed "Belt Speed" range(0.5, 3.0) default(1.5)
// @param segmentCount "Segment Count" range(10.0, 30.0) default(20.0)
// @param beltWidth "Belt Width" range(0.2, 0.5) default(0.3)
// @param itemCount "Item Count" range(0.0, 5.0) default(3.0)
// @param wearAmount "Wear Amount" range(0.0, 0.5) default(0.2)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.22)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.45)
// @toggle animated "Animated" default(true)
// @toggle running "Running" default(true)
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

float3 beltColor = float3(color1R, color1G, color1B);
float3 rollerColor = float3(color2R, color2G, color2B);

float3 col = float3(0.15, 0.15, 0.18);

float beltY = 0.5;
float beltTop = beltY + beltWidth * 0.5;
float beltBottom = beltY - beltWidth * 0.5;
float belt = step(beltBottom, p.y) * step(p.y, beltTop);

float beltX = p.x;
if (running > 0.5) {
    beltX = fract(p.x + timeVal * beltSpeed * 0.1);
}
float segment = floor(beltX * segmentCount);
float segmentLocal = fract(beltX * segmentCount);
float segmentLine = step(0.95, segmentLocal) + step(segmentLocal, 0.05);
segmentLine *= 0.3;

float3 bColor = beltColor;
if (rainbow > 0.5) bColor = 0.5 + 0.5 * cos(timeVal + segment + float3(0.0, 2.094, 4.188));
if (neon > 0.5) bColor = pow(bColor, float3(0.7)) * 1.3;
if (pastel > 0.5) bColor = mix(bColor, float3(1.0), 0.3);

if (wearAmount > 0.0) {
    float wear = sin(segment * 17.3 + p.y * 50.0) * 0.5 + 0.5;
    wear *= wearAmount;
    bColor = mix(bColor, float3(0.15, 0.14, 0.13), wear);
}
col = mix(col, bColor, belt);
col = mix(col, float3(0.1, 0.1, 0.1), belt * segmentLine);

float rollerRadius = 0.05;
float2 rollerLeft = float2(0.08, beltY);
float2 rollerRight = float2(0.92, beltY);
float leftRoller = smoothstep(rollerRadius + 0.01, rollerRadius, length(p - rollerLeft));
float rightRoller = smoothstep(rollerRadius + 0.01, rollerRadius, length(p - rollerRight));
col = mix(col, rollerColor, leftRoller + rightRoller);

for (int i = 0; i < 5; i++) {
    if (float(i) >= itemCount) break;
    float fi = float(i);
    float itemX = fract(fi / itemCount + (running > 0.5 ? timeVal * beltSpeed * 0.1 : 0.0));
    itemX = 0.15 + itemX * 0.7;
    float itemSize = 0.05 + fract(sin(fi * 127.1) * 43758.5453) * 0.03;
    float itemDist = length(p - float2(itemX, beltY + beltWidth * 0.5 + itemSize));
    float item = smoothstep(itemSize + 0.01, itemSize, itemDist);
    float3 itemColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, itemColor * 0.6, item * pulseAmt);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Warning Lights
let warningLightsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param lightCount "Light Count" range(1.0, 5.0) default(3.0)
// @param flashSpeed "Flash Speed" range(0.5, 4.0) default(2.0)
// @param lightSize "Light Size" range(0.05, 0.2) default(0.1)
// @param glowRadius "Glow Radius" range(0.1, 0.5) default(0.2)
// @param warningLevel "Warning Level" range(0.0, 1.0) default(0.5)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle alternating "Alternating" default(true)
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

float3 warningColor1 = float3(color1R, color1G, color1B);
float3 warningColor2 = float3(color2R, color2G, color2B);
float3 warningColor = mix(warningColor1, warningColor2, warningLevel);

float3 col = float3(0.05, 0.05, 0.06);

for (int i = 0; i < 5; i++) {
    if (float(i) >= lightCount) break;
    float fi = float(i);
    float lightX = (fi + 0.5) / lightCount;
    float2 lightPos = float2(lightX, 0.5);
    float phase = alternating > 0.5 ? fi * 3.14159 : 0.0;
    float flash = sin(timeVal * flashSpeed * 3.14159 + phase);
    flash = step(0.0, flash);
    flash *= 0.7 + warningLevel * 0.3;
    float lightDist = length(p - lightPos);
    float light = smoothstep(lightSize, lightSize * 0.7, lightDist);
    float3 lColor = warningColor;
    if (rainbow > 0.5) lColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) lColor = pow(lColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) lColor = mix(lColor, float3(1.0), 0.3);
    col += light * lColor * flash * pulseAmt;
    float glowEffect = exp(-lightDist / glowRadius) * flash;
    col += glowEffect * lColor * 0.5;
    float housing = smoothstep(lightSize + 0.02, lightSize + 0.01, lightDist);
    housing -= smoothstep(lightSize + 0.01, lightSize, lightDist);
    col = mix(col, float3(0.2, 0.2, 0.22), housing);
    float lens = smoothstep(lightSize * 0.9, lightSize * 0.8, lightDist);
    lens *= step(lightDist, lightSize);
    col += lens * 0.3 * (1.0 - flash * 0.5);
}

if (warningLevel > 0.5) {
    float ambient = sin(timeVal * flashSpeed * 6.28) * 0.5 + 0.5;
    ambient *= warningLevel - 0.5;
    col += ambient * warningColor * 0.1;
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Hydraulic Press
let hydraulicPressCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param pressSpeed "Press Speed" range(0.3, 2.0) default(0.8)
// @param pressForce "Press Force" range(0.3, 0.7) default(0.5)
// @param pistonWidth "Piston Width" range(0.15, 0.4) default(0.2)
// @param oilLevel "Oil Level" range(0.0, 0.3) default(0.15)
// @param metalShine "Metal Shine" range(0.3, 1.0) default(0.6)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.55)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.15)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.12)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.08)
// @toggle animated "Animated" default(true)
// @toggle crushing "Crushing" default(false)
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

float3 pistonColor = float3(color1R, color1G, color1B);
float3 oilColor = float3(color2R, color2G, color2B);

float3 col = float3(0.12, 0.12, 0.14);

float pressPhase = sin(timeVal * pressSpeed) * 0.5 + 0.5;
float pressY = 0.9 - pressPhase * pressForce;
float pistonX = abs(p.x - 0.5);
float piston = step(pistonX, pistonWidth);
piston *= step(pressY, p.y);

float3 pistCol = pistonColor;
float highlight = (1.0 - pistonX / pistonWidth) * metalShine;
pistCol += highlight * 0.2;
if (rainbow > 0.5) pistCol = 0.5 + 0.5 * cos(timeVal + p.y * 3.0 + float3(0.0, 2.094, 4.188));
if (neon > 0.5) pistCol = pow(pistCol, float3(0.7)) * 1.3;
if (pastel > 0.5) pistCol = mix(pistCol, float3(1.0), 0.3);
col = mix(col, pistCol, piston * pulseAmt);

float baseY = 0.15;
float base = step(p.y, baseY);
col = mix(col, float3(0.35, 0.35, 0.4), base);

float plateY = baseY;
if (crushing > 0.5) {
    float squish = (1.0 - pressPhase) * 0.05;
    plateY = baseY + squish;
}
float plate = step(abs(p.x - 0.5), pistonWidth + 0.05);
plate *= step(baseY, p.y) * step(p.y, plateY + 0.03);
col = mix(col, float3(0.4, 0.35, 0.3), plate);

if (crushing > 0.5 && pressPhase > 0.8) {
    float2 crushCenter = float2(0.5, plateY);
    float crushDist = length(p - crushCenter);
    float sparks = step(0.95, fract(sin(crushDist * 100.0 + timeVal * 20.0) * 43758.5453));
    sparks *= step(crushDist, 0.3);
    col += sparks * float3(1.0, 0.7, 0.3);
}

if (oilLevel > 0.0) {
    float oil = step(p.y, baseY + oilLevel);
    oil *= step(abs(p.x - 0.5), 0.4);
    oil *= step(baseY, p.y);
    float3 oColor = oilColor;
    float oilShine = sin(p.x * 50.0 + timeVal) * 0.1 + 0.1;
    oColor += oilShine;
    col = mix(col, oColor, oil * 0.8);
}

float frameL = step(p.x, 0.1);
float frameR = step(0.9, p.x);
float frame = (frameL + frameR) * step(0.1, p.y);
col = mix(col, float3(0.3, 0.3, 0.35), frame);

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Engine Cylinder
let engineCylinderCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param cylinderCount "Cylinder Count" range(1.0, 6.0) default(4.0)
// @param rpmSpeed "RPM Speed" range(0.5, 4.0) default(2.0)
// @param exhaustGlow "Exhaust Glow" range(0.0, 1.0) default(0.5)
// @param oilTemp "Oil Temp" range(0.0, 1.0) default(0.3)
// @param wear "Wear" range(0.0, 0.5) default(0.1)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.45)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.45)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle firing "Firing" default(true)
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

float3 metalColor = float3(color1R, color1G, color1B);
float3 hotColor = float3(color2R, color2G, color2B);

float3 col = float3(0.1, 0.1, 0.12);

for (int i = 0; i < 6; i++) {
    if (float(i) >= cylinderCount) break;
    float fi = float(i);
    float cylX = (fi + 0.5) / cylinderCount;
    float cylWidth = 0.4 / cylinderCount;
    float cylinder = step(abs(p.x - cylX), cylWidth * 0.8);
    cylinder *= step(0.2, p.y) * step(p.y, 0.9);
    float phase = fi * 6.28318 / cylinderCount;
    float pistonPos = sin(timeVal * rpmSpeed * 5.0 + phase) * 0.15 + 0.55;
    float pistonHeight = 0.1;
    float piston = step(abs(p.x - cylX), cylWidth * 0.7);
    piston *= step(pistonPos - pistonHeight, p.y) * step(p.y, pistonPos);
    float3 cylColor = metalColor;
    if (rainbow > 0.5) cylColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    if (neon > 0.5) cylColor = pow(cylColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) cylColor = mix(cylColor, float3(1.0), 0.3);
    if (wear > 0.0) {
        float wearPattern = sin(p.y * 50.0 + fi * 10.0) * 0.5 + 0.5;
        cylColor = mix(cylColor, cylColor * 0.7, wearPattern * wear);
    }
    if (oilTemp > 0.5) {
        float heat = (oilTemp - 0.5) * 2.0;
        cylColor = mix(cylColor, hotColor, heat * 0.3);
    }
    col = mix(col, cylColor * 0.6, cylinder);
    col = mix(col, metalColor * 0.9, piston * pulseAmt);
    if (firing > 0.5) {
        float firePhase = fract(timeVal * rpmSpeed * 2.5 + phase / 6.28318);
        if (firePhase < 0.1 && pistonPos > 0.6) {
            float fireDist = length(p - float2(cylX, pistonPos + 0.05));
            float fire = exp(-fireDist * 30.0);
            col += fire * float3(1.0, 0.6, 0.2) * exhaustGlow;
        }
    }
}

float crankY = 0.15;
float crank = step(0.05, p.x) * step(p.x, 0.95);
crank *= step(crankY - 0.03, p.y) * step(p.y, crankY + 0.03);
col = mix(col, float3(0.35, 0.35, 0.4), crank);

for (int i = 0; i < 6; i++) {
    if (float(i) >= cylinderCount) break;
    float fi = float(i);
    float cylX = (fi + 0.5) / cylinderCount;
    float phase = fi * 6.28318 / cylinderCount;
    float crankAngle = timeVal * rpmSpeed * 5.0 + phase;
    float2 crankPin = float2(cylX + cos(crankAngle) * 0.03, crankY + sin(crankAngle) * 0.02);
    float pin = smoothstep(0.015, 0.01, length(p - crankPin));
    col = mix(col, float3(0.5, 0.5, 0.55), pin);
}

if (glow > 0.5) col += col * glowIntensity * 0.1;
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

/// Radar Dish
let radarDishCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param rotationSpeed "Rotation Speed" range(0.2, 2.0) default(0.5)
// @param dishSize "Dish Size" range(0.3, 0.5) default(0.4)
// @param signalStrength "Signal Strength" range(0.0, 1.0) default(0.6)
// @param sweepWidth "Sweep Width" range(0.1, 0.5) default(0.3)
// @param targetCount "Target Count" range(0.0, 5.0) default(2.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotationAngle "Rotation Angle" range(0.0, 6.28318) default(0.0)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.02)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.05)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.02)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle transmitting "Transmitting" default(true)
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
float cs = cos(rotationAngle);
float sn = sin(rotationAngle);
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

float3 bgColor = float3(color1R, color1G, color1B);
float3 radarColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = bgColor;

float sweepAngle = timeVal * rotationSpeed * 2.0;
float angleDiff = fmod(a - sweepAngle + 3.14159, 6.28318) - 3.14159;
float sweep = smoothstep(sweepWidth, 0.0, angleDiff) * step(0.0, angleDiff);
sweep *= step(r, dishSize);
if (rainbow > 0.5) {
    float3 rainbowCol = 0.5 + 0.5 * cos(timeVal + a + float3(0.0, 2.094, 4.188));
    col += sweep * rainbowCol * 0.4 * signalStrength;
} else {
    col += sweep * radarColor * 0.4 * signalStrength;
}

float dish = smoothstep(dishSize + 0.02, dishSize, r);
dish -= smoothstep(dishSize - 0.02, dishSize - 0.04, r);
float3 dishCol = radarColor * 0.3;
if (neon > 0.5) dishCol = pow(dishCol, float3(0.7)) * 1.3;
if (pastel > 0.5) dishCol = mix(dishCol, float3(1.0), 0.3);
col += dish * dishCol;

for (int i = 1; i <= 4; i++) {
    float ringR = dishSize * float(i) / 4.0;
    float ring = smoothstep(0.01, 0.005, abs(r - ringR));
    col += ring * radarColor * 0.2;
}

float crossH = step(abs(p.y), 0.005) * step(r, dishSize);
float crossV = step(abs(p.x), 0.005) * step(r, dishSize);
col += (crossH + crossV) * radarColor * 0.15;

float centerDot = smoothstep(0.03, 0.02, r);
col += centerDot * radarColor * 0.5;
float centerPulse = sin(timeVal * 5.0) * 0.5 + 0.5;
col += centerDot * centerPulse * radarColor * 0.3 * signalStrength * pulseAmt;

for (int i = 0; i < 5; i++) {
    if (float(i) >= targetCount) break;
    float fi = float(i);
    float targetA = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
    float targetR = fract(sin(fi * 311.7) * 43758.5453) * (dishSize - 0.05) + 0.05;
    float2 targetPos = float2(cos(targetA), sin(targetA)) * targetR;
    float targetDist = length(p - targetPos);
    float sweepHit = step(abs(fmod(targetA - sweepAngle + 3.14159, 6.28318) - 3.14159), sweepWidth * 0.5);
    float target = smoothstep(0.02, 0.01, targetDist) * sweepHit;
    float fade = 1.0 - fract(timeVal * rotationSpeed * 0.5);
    target *= fade;
    col += target * radarColor;
}

if (transmitting > 0.5) {
    float wave = fract(timeVal * 2.0 - r * 3.0);
    wave = smoothstep(0.0, 0.1, wave) * smoothstep(0.2, 0.1, wave);
    wave *= step(dishSize, r) * step(r, 0.8);
    wave *= signalStrength * 0.5;
    col += wave * radarColor * 0.3;
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

/// Steel Mesh
let steelMeshCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param meshDensity "Mesh Density" range(5.0, 20.0) default(10.0)
// @param wireThickness "Wire Thickness" range(0.02, 0.1) default(0.05)
// @param rustAmount "Rust Amount" range(0.0, 0.5) default(0.2)
// @param depth "Depth" range(0.0, 0.3) default(0.1)
// @param lightAngle "Light Angle" range(0.0, 6.28318) default(0.785)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.45)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.25)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.15)
// @toggle animated "Animated" default(true)
// @toggle woven "Woven" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 wireColor = float3(color1R, color1G, color1B);
float3 rustColor = float3(color2R, color2G, color2B);

float3 col = float3(0.05, 0.05, 0.06);

float2 gridP = p * meshDensity;
float2 gridCell = floor(gridP);
float2 gridLocal = fract(gridP);

float wireH = smoothstep(wireThickness, wireThickness * 0.5, abs(gridLocal.y - 0.5));
float wireV = smoothstep(wireThickness, wireThickness * 0.5, abs(gridLocal.x - 0.5));

float depthH = 0.0;
float depthV = 0.0;
if (woven > 0.5) {
    float weavePattern = fmod(gridCell.x + gridCell.y, 2.0);
    depthH = weavePattern * depth;
    depthV = (1.0 - weavePattern) * depth;
}

float3 wireHColor = wireColor * (1.0 - depthH);
float3 wireVColor = wireColor * (1.0 - depthV);

if (rainbow > 0.5) {
    wireHColor = 0.5 + 0.5 * cos(timeVal + gridCell.y * 0.5 + float3(0.0, 2.094, 4.188));
    wireVColor = 0.5 + 0.5 * cos(timeVal + gridCell.x * 0.5 + float3(0.0, 2.094, 4.188));
}
if (neon > 0.5) {
    wireHColor = pow(wireHColor, float3(0.7)) * 1.3;
    wireVColor = pow(wireVColor, float3(0.7)) * 1.3;
}
if (pastel > 0.5) {
    wireHColor = mix(wireHColor, float3(1.0), 0.3);
    wireVColor = mix(wireVColor, float3(1.0), 0.3);
}

float2 lightDir = float2(cos(lightAngle), sin(lightAngle));
float highlightH = dot(float2(0.0, 1.0), lightDir) * 0.5 + 0.5;
float highlightV = dot(float2(1.0, 0.0), lightDir) * 0.5 + 0.5;
wireHColor *= 0.7 + highlightH * 0.3;
wireVColor *= 0.7 + highlightV * 0.3;

if (rustAmount > 0.0) {
    float rustH = sin(p.x * 100.0 + gridCell.y * 20.0) * sin(p.y * 80.0) * 0.5 + 0.5;
    float rustV = sin(p.y * 100.0 + gridCell.x * 20.0) * sin(p.x * 80.0) * 0.5 + 0.5;
    wireHColor = mix(wireHColor, rustColor, rustH * rustAmount);
    wireVColor = mix(wireVColor, rustColor, rustV * rustAmount);
}

if (woven > 0.5) {
    if (depthH < depthV) {
        col = mix(col, wireVColor, wireV);
        col = mix(col, wireHColor, wireH);
    } else {
        col = mix(col, wireHColor, wireH);
        col = mix(col, wireVColor, wireV);
    }
} else {
    col = mix(col, wireHColor, wireH);
    col = mix(col, wireVColor, wireV);
}

float joint = wireH * wireV;
col = mix(col, wireColor * 0.9, joint * 0.5);

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

/// Turbine Blades
let turbineBladesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param bladeCount "Blade Count" range(6.0, 20.0) default(12.0)
// @param rotationSpeed "Rotation Speed" range(0.5, 5.0) default(2.0)
// @param bladeAngle "Blade Angle" range(0.1, 0.5) default(0.3)
// @param hubSize "Hub Size" range(0.1, 0.25) default(0.15)
// @param tipGlow "Tip Glow" range(0.0, 1.0) default(0.3)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.55)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle afterburner "Afterburner" default(false)
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

float3 bladeColor = float3(color1R, color1G, color1B);
float3 tipColor = float3(color2R, color2G, color2B);

float2 p = pCoord * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.05, 0.05, 0.08);

float rotAngle = timeVal * rotationSpeed * 3.0;
float bladeAngleRad = a - rotAngle;
float bladeId = floor((bladeAngleRad + 3.14159) / (6.28318 / bladeCount));
float bladeLocal = fract((bladeAngleRad + 3.14159) / (6.28318 / bladeCount));
float bladeCurve = bladeLocal - 0.5 + (r - hubSize) * bladeAngle * 2.0;
float blade = smoothstep(0.15, 0.05, abs(bladeCurve));
blade *= step(hubSize, r) * step(r, 0.45);

float3 bladeCol = bladeColor;
if (rainbow > 0.5) bladeCol = 0.5 + 0.5 * cos(timeVal + bladeId + float3(0.0, 2.094, 4.188));
if (neon > 0.5) bladeCol = pow(bladeCol, float3(0.7)) * 1.3;
if (pastel > 0.5) bladeCol = mix(bladeCol, float3(1.0), 0.3);

float highlightB = 1.0 - abs(bladeCurve) * 3.0;
highlightB *= (r - hubSize) / 0.3;
bladeCol += highlightB * 0.2;
col = mix(col, bladeCol, blade);

if (tipGlow > 0.0) {
    float tip = blade * smoothstep(0.35, 0.45, r);
    float3 tipC = afterburner > 0.5 ? float3(1.0, 0.5, 0.2) : tipColor;
    col += tip * tipC * tipGlow * pulseAmt;
}

float hub = smoothstep(hubSize + 0.01, hubSize, r);
float hubHighlight = smoothstep(hubSize, hubSize * 0.5, r);
col = mix(col, float3(0.4, 0.4, 0.45), hub);
col += hubHighlight * 0.1;

float center = smoothstep(hubSize * 0.4, hubSize * 0.3, r);
col = mix(col, float3(0.3, 0.3, 0.35), center);

if (afterburner > 0.5) {
    float exhaust = smoothstep(0.5, 0.45, r) * step(0.45, r);
    float flame = sin(r * 30.0 - timeVal * 20.0) * 0.5 + 0.5;
    float flameNoise = fract(sin(a * 10.0 + timeVal * 5.0) * 43758.5453);
    exhaust *= flame * flameNoise;
    float3 exhaustColor = mix(float3(1.0, 0.3, 0.1), float3(1.0, 0.8, 0.3), flame);
    col += exhaust * exhaustColor;
}

float housing = smoothstep(0.48, 0.46, r) - smoothstep(0.46, 0.44, r);
col = mix(col, float3(0.25, 0.25, 0.3), housing);

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

/// Electrical Panel
let electricalPanelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param circuitDensity "Circuit Density" range(0.3, 1.0) default(0.6)
// @param sparkChance "Spark Chance" range(0.0, 0.3) default(0.1)
// @param powerLevel "Power Level" range(0.0, 1.0) default(0.7)
// @param wiringComplexity "Wiring Complexity" range(1.0, 3.0) default(2.0)
// @param indicatorBrightness "Indicator Brightness" range(0.5, 1.5) default(1.0)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle damaged "Damaged" default(false)
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

float3 ledColor = float3(color1R, color1G, color1B);
float3 sparkColor = float3(color2R, color2G, color2B);

float3 col = float3(0.12, 0.12, 0.14);

float panel = step(0.05, p.x) * step(p.x, 0.95);
panel *= step(0.05, p.y) * step(p.y, 0.95);
col = mix(float3(0.08, 0.08, 0.1), col, panel);

int circuitCount = int(circuitDensity * 8.0);
for (int i = 0; i < 8; i++) {
    if (i >= circuitCount) break;
    float fi = float(i);
    float startX = fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2;
    float startY = fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2;
    float2 circuitPos = float2(startX, startY);
    float wire = 0.0;
    float segmentCount = floor(wiringComplexity * 3.0);
    float2 currentPos = circuitPos;
    for (int s = 0; s < 9; s++) {
        if (s >= int(segmentCount)) break;
        float fs = float(s);
        float2 nextPos;
        if (int(fs) % 2 == 0) {
            nextPos = currentPos + float2(fract(sin((fi + fs) * 178.3) * 43758.5453) * 0.2 - 0.1, 0.0);
        } else {
            nextPos = currentPos + float2(0.0, fract(sin((fi + fs) * 43.758) * 43758.5453) * 0.2 - 0.1);
        }
        if (int(fs) % 2 == 0) {
            float segmentWire = step(min(currentPos.x, nextPos.x), p.x);
            segmentWire *= step(p.x, max(currentPos.x, nextPos.x));
            segmentWire *= step(abs(p.y - currentPos.y), 0.003);
            wire = max(wire, segmentWire);
        } else {
            float segmentWire = step(min(currentPos.y, nextPos.y), p.y);
            segmentWire *= step(p.y, max(currentPos.y, nextPos.y));
            segmentWire *= step(abs(p.x - currentPos.x), 0.003);
            wire = max(wire, segmentWire);
        }
        currentPos = nextPos;
    }
    float3 wireColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 2.0, 4.0));
    if (rainbow > 0.5) wireColor = 0.5 + 0.5 * cos(timeVal + fi + float3(0.0, 2.094, 4.188));
    wireColor *= 0.4;
    if (neon > 0.5) wireColor = pow(wireColor, float3(0.7)) * 1.3;
    if (pastel > 0.5) wireColor = mix(wireColor, float3(1.0), 0.3);
    if (powerLevel > 0.0) {
        float pulsePower = sin(timeVal * 5.0 + fi * 2.0) * 0.3 + 0.7;
        wireColor *= pulsePower * powerLevel + (1.0 - powerLevel);
    }
    col += wire * wireColor * panel;
}

for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float2 ledPos = float2(0.15 + fi * 0.12, 0.85);
    float ledDist = length(p - ledPos);
    float led = smoothstep(0.012, 0.008, ledDist);
    float isOn = step(fi / 6.0, powerLevel);
    float3 ledCol = isOn > 0.5 ? ledColor : float3(0.3, 0.0, 0.0);
    if (damaged > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.7) {
        float flickerDamage = step(0.5, fract(sin(timeVal * 20.0 + fi * 10.0) * 0.5 + 0.5));
        ledCol *= flickerDamage;
    }
    col += led * ledCol * indicatorBrightness * panel * pulseAmt;
}

if (damaged > 0.5 && sparkChance > 0.0) {
    float sparkTime = floor(timeVal * 10.0);
    float sparkRand = fract(sin(sparkTime * 127.1) * 43758.5453);
    if (sparkRand < sparkChance) {
        float2 sparkPos = float2(
            fract(sin(sparkTime * 311.7) * 43758.5453) * 0.8 + 0.1,
            fract(sin(sparkTime * 178.3) * 43758.5453) * 0.8 + 0.1
        );
        float sparkDist = length(p - sparkPos);
        float spark = exp(-sparkDist * 30.0);
        col += spark * sparkColor * panel;
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


