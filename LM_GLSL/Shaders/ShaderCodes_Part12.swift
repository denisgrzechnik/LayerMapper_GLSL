//
//  ShaderCodes_Part12.swift
//  LM_GLSL
//
//  Shader codes - Part 12: Weather & Atmospheric Effects (20 shaders)
//

import Foundation

// MARK: - Weather & Atmospheric Effects

/// Rain Storm
let rainStormCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(2.5)
// @param rainDensity "Rain Density" range(10.0, 100.0) default(50.0)
// @param rainAngle "Rain Angle" range(-0.5, 0.5) default(0.1)
// @param dropLength "Drop Length" range(0.02, 0.1) default(0.05)
// @param splashIntensity "Splash Intensity" range(0.0, 1.0) default(0.5)
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
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.12)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.15)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.85)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle lightning "Lightning" default(true)
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

float3 bgCol = float3(color1R, color1G, color1B);
float3 lightCol = float3(color2R, color2G, color2B);
float3 col = bgCol;

float lightningFlash = 0.0;
if (lightning > 0.5) {
    float flash = step(0.98, fract(sin(floor(timeVal * 2.0) * 43.758) * 43758.5453));
    lightningFlash = flash * (sin(timeVal * 100.0) * 0.5 + 0.5);
    col += lightningFlash * lightCol;
}

for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float layerSpeed = speed * (1.0 + fl * 0.3);
    float layerDensity = rainDensity * (1.0 - fl * 0.2);
    for (int i = 0; i < 100; i++) {
        if (float(i) >= layerDensity) break;
        float fi = float(i);
        float dropX = fract(sin(fi * 127.1 + fl * 50.0) * 43758.5453);
        float dropY = fract(sin(fi * 311.7 + fl * 50.0) * 43758.5453 + timeVal * layerSpeed / speed);
        float2 dropPos = float2(dropX + (1.0 - dropY) * rainAngle, 1.0 - dropY);
        float2 toP = p - dropPos;
        float dropDist = abs(toP.x) + max(0.0, toP.y) * 0.5 / (dropLength * pulseAmt);
        dropDist = max(dropDist, -toP.y / (dropLength * pulseAmt));
        float drop = smoothstep(0.01, 0.0, dropDist) * step(-(dropLength * pulseAmt), toP.y);
        float bright = 0.3 + fl * 0.2;
        
        float3 dropCol;
        if (rainbow > 0.5) {
            dropCol = 0.5 + 0.5 * cos(fi * 0.5 + timeVal + float3(0.0, 2.094, 4.188));
        } else {
            dropCol = float3(bright);
        }
        if (neon > 0.5) dropCol = pow(dropCol, float3(0.5)) * 1.5;
        col += drop * dropCol;
    }
}

if (splashIntensity > 0.0) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float splashX = fract(sin(fi * 43.758) * 43758.5453);
        float splashPhase = fract(sin(fi * 78.233) * 43758.5453 + timeVal * 0.5);
        if (p.y < 0.1) {
            float2 splashPos = float2(splashX, 0.05);
            float splashR = splashPhase * 0.05;
            float splash = smoothstep(0.005, 0.0, abs(length(p - splashPos) - splashR));
            splash *= (1.0 - splashPhase) * splashIntensity;
            col += splash * 0.3;
            if (glow > 0.5) col += exp(-abs(length(p - splashPos) - splashR) * 50.0) * glowIntensity * 0.1;
        }
    }
}

if (gradient > 0.5) col *= 1.0 - p.y * 0.3;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

if (showEdges > 0.5) {
    col = mix(col, lightCol, lightningFlash * 0.3);
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

/// Snow Fall
let snowFallCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.3)
// @param snowDensity "Snow Density" range(20.0, 200.0) default(80.0)
// @param windStrength "Wind Strength" range(0.0, 0.5) default(0.1)
// @param flakeSize "Flake Size" range(0.005, 0.02) default(0.01)
// @param sparkle "Sparkle" range(0.0, 1.0) default(0.5)
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
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.15)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.18)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.25)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.95)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.97)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle accumulation "Accumulation" default(true)
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

float3 bgCol = float3(color1R, color1G, color1B);
float3 snowCol = float3(color2R, color2G, color2B);
float3 col = bgCol;

for (int layer = 0; layer < 4; layer++) {
    float fl = float(layer);
    float layerSpeed = speed * (0.5 + fl * 0.3);
    float layerSize = flakeSize * (0.7 + fl * 0.2) * pulseAmt;
    for (int i = 0; i < 200; i++) {
        if (float(i) >= snowDensity / 4.0) break;
        float fi = float(i);
        float seed = fi + fl * 200.0;
        float flakeX = fract(sin(seed * 127.1) * 43758.5453);
        float flakeY = fract(sin(seed * 311.7) * 43758.5453 + timeVal * layerSpeed / speed);
        float wind = sin(timeVal + fi) * windStrength;
        float wobble = sin(timeVal * 2.0 + fi * 3.0) * 0.02;
        float2 flakePos = float2(flakeX + wind + wobble, 1.0 - flakeY);
        float d = length(p - flakePos);
        float flake = smoothstep(layerSize, layerSize * 0.3, d);
        float bright = 0.5 + fl * 0.15;
        
        if (sparkle > 0.0) {
            float sp = step(0.99, sin(timeVal * 10.0 + fi * 5.0)) * sparkle;
            bright += sp * 0.5;
        }
        
        float3 flakeCol;
        if (rainbow > 0.5) {
            flakeCol = 0.5 + 0.5 * cos(fi * 0.3 + timeVal + float3(0.0, 2.094, 4.188));
        } else {
            flakeCol = snowCol * bright;
        }
        if (neon > 0.5) flakeCol = pow(flakeCol, float3(0.5)) * 1.3;
        col += flake * flakeCol;
        
        if (glow > 0.5) {
            col += exp(-d * 30.0) * glowIntensity * 0.1 * snowCol;
        }
    }
}

if (accumulation > 0.5) {
    float groundHeight = 0.08 + sin(p.x * 20.0) * 0.02 + sin(p.x * 50.0) * 0.005;
    float ground = smoothstep(groundHeight + 0.02, groundHeight, p.y);
    col = mix(col, snowCol, ground);
}

if (gradient > 0.5) col *= 1.0 + p.y * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.25);

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

/// Fog Mist
let fogMistCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.2)
// @param fogDensity "Fog Density" range(0.5, 3.0) default(1.5)
// @param layerCount "Layer Count" range(2.0, 6.0) default(4.0)
// @param fogHeight "Fog Height" range(0.0, 1.0) default(0.5)
// @param visibility "Visibility" range(0.1, 1.0) default(0.5)
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
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.25)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.7)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.75)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle volumetric "Volumetric" default(true)
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

float3 bgCol = float3(color1R, color1G, color1B);
float3 fogColor = float3(color2R, color2G, color2B);
float3 col = bgCol;

float fog = 0.0;
int layers = int(layerCount);
for (int i = 0; i < 6; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float2 fogP = p;
    fogP.x += timeVal * (0.5 + fi * 0.2);
    fogP *= 2.0 + fi;
    float n1 = sin(fogP.x * 2.0 + fi) * sin(fogP.y * 1.5 + timeVal * 0.3);
    float n2 = sin(fogP.x * 4.0 - fi * 0.5) * sin(fogP.y * 3.0 - timeVal * 0.2);
    float layerFog = (n1 + n2 * 0.5) * 0.5 + 0.5;
    layerFog *= exp(-fi * 0.3);
    if (volumetric > 0.5) {
        layerFog *= smoothstep(fogHeight + 0.3, fogHeight - 0.1, p.y);
    }
    fog += layerFog / layerCount;
}
fog *= fogDensity * pulseAmt;
fog = clamp(fog, 0.0, 1.0);

if (rainbow > 0.5) {
    fogColor = 0.5 + 0.5 * cos(timeVal * 0.5 + p.x * 3.0 + float3(0.0, 2.094, 4.188));
}
if (neon > 0.5) fogColor = pow(fogColor, float3(0.5)) * 1.3;
if (pastel > 0.5) fogColor = mix(fogColor, float3(1.0), 0.3);

col = mix(col, fogColor, fog * (1.0 - visibility) + (1.0 - visibility) * 0.3);

if (gradient > 0.5) col *= 1.0 + (1.0 - p.y) * 0.2;
if (radial > 0.5) col *= 1.0 - length(p - 0.5) * 0.3;
if (glow > 0.5) col += fog * glowIntensity * 0.2 * fogColor;

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

/// Cloud Formation
let cloudFormationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.1)
// @param cloudCover "Cloud Cover" range(0.0, 1.0) default(0.5)
// @param cloudHeight "Cloud Height" range(0.3, 0.8) default(0.6)
// @param fluffiness "Fluffiness" range(1.0, 5.0) default(3.0)
// @param shadowDepth "Shadow Depth" range(0.0, 0.5) default(0.2)
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
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.9)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle sunset "Sunset" default(false)
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

float3 skyColor;
if (sunset > 0.5) {
    skyColor = mix(float3(0.9, 0.4, 0.2), float3(0.2, 0.1, 0.3), p.y);
} else if (rainbow > 0.5) {
    skyColor = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    skyColor = mix(float3(0.6, 0.8, 1.0), float3(color1R, color1G, color1B), p.y);
}
float3 col = skyColor;

float cloud = 0.0;
for (int oct = 0; oct < 5; oct++) {
    float fo = float(oct);
    float freq = pow(2.0, fo);
    float amp = pow(0.5, fo);
    float2 cloudP = p * freq * fluffiness * pulseAmt;
    cloudP.x += timeVal * (1.0 + fo * 0.5);
    float n = sin(cloudP.x) * sin(cloudP.y * 0.7 + fo);
    n += sin(cloudP.x * 1.5 + cloudP.y) * 0.5;
    cloud += n * amp;
}
cloud = cloud * 0.5 + 0.5;
cloud = smoothstep(1.0 - cloudCover, 1.0 - cloudCover + 0.3, cloud);
cloud *= smoothstep(cloudHeight - 0.3, cloudHeight, p.y);
cloud *= smoothstep(1.0, cloudHeight + 0.1, p.y);

float3 cloudColor = float3(color2R, color2G, color2B);
if (sunset > 0.5) {
    cloudColor = mix(float3(1.0, 0.8, 0.6), float3(0.9, 0.5, 0.4), 1.0 - p.y);
}
if (neon > 0.5) cloudColor = pow(cloudColor, float3(0.5)) * 1.3;
if (pastel > 0.5) cloudColor = mix(cloudColor, float3(1.0), 0.3);

float shadow = cloud * shadowDepth * (1.0 - p.y);
cloudColor *= (1.0 - shadow);
col = mix(col, cloudColor, cloud);

if (glow > 0.5) col += cloud * glowIntensity * 0.2 * cloudColor;
if (gradient > 0.5) col *= 1.0 + p.y * 0.1;
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

/// Thunderstorm
let thunderstormCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param stormIntensity "Storm Intensity" range(0.3, 1.0) default(0.7)
// @param lightningFrequency "Lightning Frequency" range(0.1, 1.0) default(0.3)
// @param rainAmount "Rain Amount" range(0.0, 1.0) default(0.7)
// @param cloudDarkness "Cloud Darkness" range(0.3, 0.8) default(0.5)
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
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.7)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.1)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.12)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle dramaticLighting "Dramatic Lighting" default(true)
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
// @toggle bloom "Bloom" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgCol = float3(color1R, color1G, color1B);
float3 lightCol = float3(color2R, color2G, color2B);
float3 col = bgCol;

float clouds = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float2 cp = p * (2.0 + fi);
    cp.x += timeVal * 0.1 * (1.0 + fi * 0.3);
    float n = sin(cp.x * 3.0) * sin(cp.y * 2.0 + fi);
    clouds += n * pow(0.6, fi);
}
clouds = clouds * 0.5 + 0.5;
clouds = pow(clouds, 1.0 / stormIntensity);
float3 cloudCol = mix(float3(0.2, 0.2, 0.25), float3(0.05, 0.05, 0.08), clouds * cloudDarkness);
col = mix(col, cloudCol, smoothstep(0.3, 0.7, p.y));

float lightning = 0.0;
float lightningTime = floor(timeVal * lightningFrequency * 3.0);
float lightningRand = fract(sin(lightningTime * 43.758) * 43758.5453);
if (lightningRand > 0.7) {
    float flashPhase = fract(timeVal * lightningFrequency * 3.0);
    if (flashPhase < 0.1) {
        float boltX = fract(sin(lightningTime * 127.1) * 43758.5453);
        float boltDist = abs(p.x - boltX);
        float bolt = exp(-boltDist * 20.0) * step(0.5, p.y);
        for (int j = 0; j < 5; j++) {
            float fj = float(j);
            float branchY = 0.9 - fj * 0.1;
            if (p.y < branchY && p.y > branchY - 0.1) {
                float branchX = boltX + (fract(sin(fj * 78.233 + lightningTime) * 43758.5453) - 0.5) * 0.2;
                bolt += exp(-abs(p.x - branchX) * 30.0) * 0.5;
            }
        }
        lightning = bolt * (1.0 - flashPhase * 10.0);
    }
}

if (dramaticLighting > 0.5) {
    col += lightning * lightCol;
    col += lightning * lightCol * 0.3 * (1.0 - p.y);
}

if (glow > 0.5) {
    col += lightning * glowIntensity * 0.5 * lightCol;
}

if (rainAmount > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float rx = fract(sin(fi * 127.1) * 43758.5453);
        float ry = fract(sin(fi * 311.7) * 43758.5453 + timeVal * 2.0);
        float windForce = 0.2;
        float2 rp = float2(rx + (1.0 - ry) * windForce, 1.0 - ry);
        float rd = abs(p.x - rp.x);
        float rain = smoothstep(0.003, 0.0, rd) * step(rp.y - 0.03, p.y) * step(p.y, rp.y);
        float3 rainCol = rainbow > 0.5 ? 0.5 + 0.5 * cos(fi * 0.5 + timeVal + float3(0.0, 2.094, 4.188)) : float3(0.3);
        col += rain * rainAmount * rainCol;
    }
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.2;
if (pastel > 0.5) col = mix(col, float3(0.5), 0.2);
if (gradient > 0.5) col *= 1.0 - p.y * 0.2;
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

/// Sunrise Gradient
let sunriseGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.05)
// @param sunPosition "Sun Position" range(-0.2, 0.5) default(0.1)
// @param sunSize "Sun Size" range(0.05, 0.2) default(0.1)
// @param atmosphereThickness "Atmosphere Thickness" range(0.5, 2.0) default(1.0)
// @param cloudAmount "Cloud Amount" range(0.0, 1.0) default(0.3)
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
// @param glowIntensity "Glow Intensity" range(0.5, 2.0) default(1.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.95)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle goldenHour "Golden Hour" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 horizonCol = float3(color1R, color1G, color1B);
float3 sunColor = float3(color2R, color2G, color2B);

float2 sunPos = float2(0.5, sunPosition);
float3 col;

if (goldenHour > 0.5) {
    float3 horizon = horizonCol;
    float3 sky = float3(0.4, 0.6, 0.9);
    float3 zenith = float3(0.2, 0.3, 0.6);
    col = mix(horizon, sky, smoothstep(sunPosition, sunPosition + 0.4, p.y));
    col = mix(col, zenith, smoothstep(0.5, 1.0, p.y));
} else if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = mix(float3(0.9, 0.6, 0.4), float3(0.5, 0.7, 1.0), p.y);
}

float sunDist = length(p - sunPos);
float sun = smoothstep(sunSize * pulseAmt, sunSize * 0.8 * pulseAmt, sunDist);
col = mix(col, sunColor, sun);

if (glow > 0.5) {
    float glowAmt = exp(-sunDist * 3.0 / glowIntensity) * glowIntensity;
    float3 glowColor = goldenHour > 0.5 ? float3(1.0, 0.6, 0.3) : float3(1.0, 0.8, 0.5);
    col += glowAmt * glowColor * 0.5;
}

float scatter = exp(-sunDist * 2.0 / atmosphereThickness);
scatter *= smoothstep(sunPosition + 0.3, sunPosition, p.y);
col += scatter * float3(1.0, 0.4, 0.1) * 0.3 * atmosphereThickness;

if (cloudAmount > 0.0) {
    float2 cp = p * 5.0;
    cp.x += timeVal;
    float cloud = sin(cp.x * 2.0) * sin(cp.y * 1.5) * 0.5 + 0.5;
    cloud = smoothstep(1.0 - cloudAmount * 0.5, 1.0, cloud);
    cloud *= smoothstep(sunPosition, sunPosition + 0.5, p.y);
    float3 cloudCol = mix(float3(1.0, 0.7, 0.5), float3(1.0, 0.9, 0.8), p.y);
    if (neon > 0.5) cloudCol = pow(cloudCol, float3(0.5)) * 1.3;
    if (pastel > 0.5) cloudCol = mix(cloudCol, float3(1.0), 0.3);
    col = mix(col, cloudCol, cloud * cloudAmount);
}

if (gradient > 0.5) col *= 1.0 + (1.0 - p.y) * 0.1;
if (radial > 0.5) col *= 1.0 - sunDist * 0.3;

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

/// Northern Lights Advanced
let northernLightsAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(0.3)
// @param waveCount "Wave Count" range(2.0, 8.0) default(4.0)
// @param waveHeight "Wave Height" range(0.1, 0.5) default(0.3)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
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
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.7)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.1)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle stars "Stars" default(true)
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
// @toggle bloom "Bloom" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 auroraCol = float3(color1R, color1G, color1B);
float3 curtainCol = float3(color2R, color2G, color2B);

float3 col = float3(0.02, 0.03, 0.05);

if (stars > 0.5) {
    for (int i = 0; i < 100; i++) {
        float fi = float(i);
        float2 starPos = float2(
            fract(sin(fi * 127.1) * 43758.5453),
            fract(sin(fi * 311.7) * 43758.5453)
        );
        float starD = length(p - starPos);
        float twinkle = sin(timeVal * 3.0 + fi * 2.0) * 0.3 + 0.7;
        float star = smoothstep(0.003, 0.0, starD) * twinkle;
        col += star * 0.5;
    }
}

int waves = int(waveCount);
for (int w = 0; w < 8; w++) {
    if (w >= waves) break;
    float fw = float(w);
    float waveBase = 0.5 + fw * 0.08;
    float waveY = waveBase + sin(p.x * 5.0 + timeVal + fw * 1.5) * waveHeight * 0.3 * pulseAmt;
    waveY += sin(p.x * 8.0 - timeVal * 1.5 + fw) * waveHeight * 0.15 * pulseAmt;
    float wave = smoothstep(waveHeight * 0.5, 0.0, abs(p.y - waveY));
    wave *= smoothstep(0.0, 0.3, p.y);
    
    float3 waveColor;
    float colorPhase = fw / waveCount + colorMix;
    if (rainbow > 0.5) {
        waveColor = 0.5 + 0.5 * cos(colorPhase * 6.28 + timeVal + float3(0.0, 2.094, 4.188));
    } else {
        waveColor = 0.5 + 0.5 * cos(colorPhase * 6.28 + float3(0.0, 2.0, 4.0));
        waveColor = mix(auroraCol, waveColor, colorMix);
    }
    
    if (neon > 0.5) waveColor = pow(waveColor, float3(0.5)) * 1.5;
    if (pastel > 0.5) waveColor = mix(waveColor, float3(1.0), 0.3);
    
    col += wave * waveColor * intensity / waveCount * 2.0;
    
    if (glow > 0.5) {
        col += exp(-abs(p.y - waveY) * 10.0) * glowIntensity * 0.1 * waveColor;
    }
}

float curtain = sin(p.x * 30.0 + timeVal * 2.0) * 0.5 + 0.5;
curtain *= smoothstep(0.3, 0.6, p.y) * smoothstep(0.9, 0.6, p.y);
col += curtain * curtainCol * intensity * 0.3;

if (gradient > 0.5) col *= 1.0 + p.y * 0.2;
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

/// Dust Storm
let dustStormCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param dustDensity "Dust Density" range(0.3, 1.0) default(0.6)
// @param windSpeed "Wind Speed" range(1.0, 5.0) default(2.5)
// @param visibility "Visibility" range(0.1, 0.8) default(0.4)
// @param particleSize "Particle Size" range(0.005, 0.05) default(0.01)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.5)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle sandColor "Sand Color" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 sandCol = float3(color1R, color1G, color1B);
float3 grayCol = float3(color2R, color2G, color2B);
float3 baseColor = sandColor > 0.5 ? sandCol : grayCol;

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = baseColor * visibility;
}

for (int layer = 0; layer < 5; layer++) {
    float fl = float(layer);
    float layerSpeed = windSpeed * (0.5 + fl * 0.3);
    float layerTurb = turbulence * (1.0 + fl * 0.2);
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float seed = fi + fl * 100.0;
        float px = fract(sin(seed * 127.1) * 43758.5453 + timeVal * layerSpeed * 0.1);
        float py = fract(sin(seed * 311.7) * 43758.5453);
        float turb = sin(timeVal * 2.0 + fi + fl) * layerTurb * 0.1;
        float2 particlePos = float2(px, py + turb);
        float d = length(p - particlePos);
        float particle = smoothstep(particleSize * (1.0 + fl * 0.5) * pulseAmt, 0.0, d);
        particle *= dustDensity;
        float bright = 0.5 + fl * 0.1;
        float3 partCol = baseColor * bright * 0.3;
        if (neon > 0.5) partCol = pow(partCol, float3(0.7)) * 1.3;
        if (pastel > 0.5) partCol = mix(partCol, float3(1.0), 0.3);
        col += particle * partCol;
    }
}

float ns = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 np = p * (3.0 + fi * 2.0);
    np.x += timeVal * windSpeed * (0.3 + fi * 0.2);
    ns += sin(np.x * 5.0 + np.y * 3.0 + fi) * pow(0.5, fi);
}
ns = ns * 0.5 + 0.5;
col += ns * baseColor * dustDensity * 0.2;
col = mix(col, baseColor * 0.7, (1.0 - visibility) * dustDensity);

if (glow > 0.5) col += col * glowIntensity * 0.2;
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

/// Rainbow Arc
let rainbowArcCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param arcRadius "Arc Radius" range(0.3, 0.8) default(0.5)
// @param arcWidth "Arc Width" range(0.05, 0.3) default(0.1)
// @param arcPosition "Arc Position" range(0.0, 0.5) default(0.2)
// @param colorSpread "Color Spread" range(0.5, 3.0) default(1.0)
// @param secondaryArc "Secondary Arc" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.8)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.4)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.7)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.75)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.95)
// @toggle animated "Animated" default(true)
// @toggle doubleRainbow "Double Rainbow" default(false)
// @toggle rainbow "Rainbow" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 skyColor1 = float3(color1R, color1G, color1B);
float3 skyColor2 = float3(color2R, color2G, color2B);
float3 skyColor = mix(skyColor1, skyColor2, p.y);
if (gradient > 0.5) skyColor *= 0.9 + p.y * 0.2;

float3 col = skyColor;

float2 arcCenter = float2(0.5, arcPosition - 0.2);
float dist = length(p - arcCenter);
float arc = smoothstep(arcWidth * pulseAmt, 0.0, abs(dist - arcRadius * pulseAmt));
arc *= step(arcCenter.y, p.y);

float colorAngle = (dist - arcRadius + arcWidth) / (arcWidth * 2.0);
colorAngle = clamp(colorAngle, 0.0, 1.0);

float3 rainbowColor;
if (rainbow > 0.5) {
    rainbowColor = 0.5 + 0.5 * cos((1.0 - colorAngle) * colorSpread * 3.0 + timeVal + float3(0.0, 2.0, 4.0));
} else {
    rainbowColor = mix(skyColor1, skyColor2, colorAngle);
}

if (neon > 0.5) rainbowColor = pow(rainbowColor, float3(0.7)) * 1.5;
if (pastel > 0.5) rainbowColor = mix(rainbowColor, float3(1.0), 0.3);

col = mix(col, rainbowColor, arc * 0.7);

if (doubleRainbow > 0.5) {
    float secondRadius = arcRadius * 1.4;
    float secondWidth = arcWidth * 0.7;
    float secondDist = length(p - arcCenter);
    float secondArcMask = smoothstep(secondWidth * pulseAmt, 0.0, abs(secondDist - secondRadius * pulseAmt));
    secondArcMask *= step(arcCenter.y, p.y);
    float secondColorAngle = (secondDist - secondRadius + secondWidth) / (secondWidth * 2.0);
    secondColorAngle = clamp(secondColorAngle, 0.0, 1.0);
    float3 secondColor = 0.5 + 0.5 * cos(secondColorAngle * colorSpread * 3.0 + timeVal + float3(0.0, 2.0, 4.0));
    col = mix(col, secondColor, secondArcMask * secondaryArc * 0.4);
}

if (glow > 0.5) {
    float glowAmt = arc * glowIntensity * 0.5;
    col += glowAmt * rainbowColor * 0.3;
}
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

/// Hail Storm
let hailStormCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param hailDensity "Hail Density" range(10.0, 50.0) default(25.0)
// @param hailSize "Hail Size" range(0.01, 0.05) default(0.02)
// @param fallSpeed "Fall Speed" range(1.0, 4.0) default(2.0)
// @param bounceHeight "Bounce Height" range(0.0, 0.3) default(0.1)
// @param iceSheen "Ice Sheen" range(0.0, 1.0) default(0.5)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.15)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.18)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.22)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.92)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.95)
// @toggle animated "Animated" default(true)
// @toggle ground "Ground" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgColor = float3(color1R, color1G, color1B);
float3 hailColor = float3(color2R, color2G, color2B);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = bgColor;
}

if (ground > 0.5) {
    float groundLine = 0.1;
    if (p.y < groundLine) {
        col = float3(0.3, 0.32, 0.35);
        float ice = sin(p.x * 50.0) * sin(p.x * 30.0 + 1.0) * 0.5 + 0.5;
        col += ice * 0.1 * iceSheen;
    }
}

for (int i = 0; i < 50; i++) {
    if (float(i) >= hailDensity) break;
    float fi = float(i);
    float hx = fract(sin(fi * 127.1) * 43758.5453);
    float hy = fract(sin(fi * 311.7) * 43758.5453 + timeVal * fallSpeed);
    float groundY = 0.1;
    float fallY = 1.0 - hy;
    float bouncePhase = 0.0;
    if (fallY < groundY + bounceHeight) {
        float bounceT = (groundY + bounceHeight - fallY) / bounceHeight;
        bouncePhase = sin(bounceT * 3.14159);
    }
    float2 hailPos = float2(hx, max(groundY, fallY) + bouncePhase * bounceHeight * (1.0 - hy));
    float d = length(p - hailPos);
    float hail = smoothstep(hailSize * pulseAmt, hailSize * 0.5 * pulseAmt, d);
    float3 hCol = hailColor;
    float sheen = exp(-d / hailSize * 2.0) * iceSheen;
    hCol += sheen * 0.3;
    if (neon > 0.5) hCol = pow(hCol, float3(0.7)) * 1.3;
    if (pastel > 0.5) hCol = mix(hCol, float3(1.0), 0.3);
    col = mix(col, hCol, hail);
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

if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Heat Shimmer
let heatShimmerCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param shimmerIntensity "Shimmer Intensity" range(0.0, 0.15) default(0.03)
// @param shimmerSpeed "Shimmer Speed" range(1.0, 5.0) default(2.0)
// @param shimmerScale "Shimmer Scale" range(5.0, 40.0) default(15.0)
// @param horizonHeight "Horizon Height" range(0.2, 0.6) default(0.3)
// @param heatIntensity "Heat Intensity" range(0.0, 1.0) default(0.5)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.85)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.75)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.55)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.6)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.75)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.95)
// @toggle animated "Animated" default(true)
// @toggle desert "Desert" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 groundColor = float3(color1R, color1G, color1B);
float3 skyColor = float3(color2R, color2G, color2B);

float shimmerMask = smoothstep(horizonHeight + 0.3, horizonHeight, p.y);
float2 shimmer = float2(
    sin(p.y * shimmerScale + timeVal * shimmerSpeed) * sin(p.y * shimmerScale * 1.7 + timeVal * shimmerSpeed * 0.7),
    sin(p.x * shimmerScale * 0.5 + timeVal * shimmerSpeed * 0.5)
) * shimmerIntensity * shimmerMask * pulseAmt;

float2 sp = p + shimmer;

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(sp.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else if (desert > 0.5) {
    float3 desertSky = mix(float3(0.9, 0.85, 0.7), skyColor, sp.y);
    col = mix(groundColor, desertSky, smoothstep(horizonHeight - 0.05, horizonHeight + 0.05, sp.y));
} else {
    col = mix(float3(0.3, 0.35, 0.3), skyColor, sp.y);
}

float heatHaze = shimmerMask * heatIntensity;
col = mix(col, col * 1.1, heatHaze * sin(p.y * 50.0 + timeVal * 3.0) * 0.5 + 0.5);

if (desert > 0.5 && p.y < horizonHeight) {
    float mirage = smoothstep(horizonHeight, horizonHeight - 0.1, p.y);
    mirage *= shimmerMask;
    float3 mirageColor = mix(float3(0.7, 0.85, 1.0), col, 0.5);
    col = mix(col, mirageColor, mirage * 0.3);
}

if (neon > 0.5) col = pow(col, float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (glow > 0.5) col += col * glowIntensity * heatHaze * 0.3;
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

/// Tornado Funnel
let tornadoFunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param funnelWidth "Funnel Width" range(0.05, 0.3) default(0.1)
// @param rotationSpeed "Rotation Speed" range(1.0, 5.0) default(3.0)
// @param debrisAmount "Debris Amount" range(0.0, 1.0) default(0.5)
// @param funnelHeight "Funnel Height" range(0.5, 1.0) default(0.8)
// @param intensity "Intensity" range(0.5, 2.0) default(1.0)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.3)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.35)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.18)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.15)
// @toggle animated "Animated" default(true)
// @toggle touchingGround "Touching Ground" default(true)
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

float3 skyColor = float3(color1R, color1G, color1B);
float3 funnelBase = float3(color2R, color2G, color2B);

float2 tp = p * 2.0 - 1.0;
float3 col;

if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(tp.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = skyColor;
}

float cloudBase = 0.6;
if (tp.y > cloudBase) {
    float cloud = sin(tp.x * 5.0 + timeVal * 0.5) * 0.1 + 0.5;
    col = mix(col, float3(0.2, 0.22, 0.25), cloud);
}

float groundY = touchingGround > 0.5 ? -0.8 : -0.5;
float funnelY = (tp.y - groundY) / (cloudBase - groundY);
funnelY = clamp(funnelY, 0.0, 1.0);
float currentWidth = funnelWidth * (0.3 + funnelY * 0.7) * pulseAmt;
float twist = atan2(tp.x, funnelY + 0.1) + timeVal * rotationSpeed;
float spiral = sin(twist * 5.0 + funnelY * 10.0) * 0.5 + 0.5;
float funnelDist = abs(tp.x) - currentWidth;
float funnel = smoothstep(0.05, 0.0, funnelDist);
funnel *= step(groundY, tp.y) * step(tp.y, cloudBase);

float3 funnelColor = mix(funnelBase, float3(0.35, 0.32, 0.28), spiral);
funnelColor *= intensity;
if (neon > 0.5) funnelColor = pow(funnelColor, float3(0.7)) * 1.3;
if (pastel > 0.5) funnelColor = mix(funnelColor, float3(0.7), 0.3);
col = mix(col, funnelColor, funnel);

if (debrisAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float debrisAngle = fi * 0.5 + timeVal * rotationSpeed * (0.8 + fract(sin(fi) * 0.4));
        float debrisY = fract(fi * 0.123 + timeVal * 0.3) * (cloudBase - groundY) + groundY;
        float debrisR = currentWidth * (1.0 + sin(fi) * 0.5) * ((debrisY - groundY) / (cloudBase - groundY));
        float2 debrisPos = float2(sin(debrisAngle) * debrisR, debrisY);
        float d = length(tp - debrisPos);
        float debris = smoothstep(0.02, 0.01, d) * debrisAmount;
        col = mix(col, float3(0.15, 0.12, 0.1), debris);
    }
}

if (glow > 0.5) col += col * glowIntensity * funnel * 0.2;
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

/// Blizzard
let blizzardCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param snowIntensity "Snow Intensity" range(50.0, 200.0) default(100.0)
// @param windStrength "Wind Strength" range(0.2, 1.0) default(0.5)
// @param visibility "Visibility" range(0.1, 0.5) default(0.3)
// @param whiteoutAmount "Whiteout Amount" range(0.0, 0.5) default(0.2)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.5)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.7)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.75)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.92)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.95)
// @toggle animated "Animated" default(true)
// @toggle ground "Ground" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 skyColor = float3(color1R, color1G, color1B);
float3 snowColor = float3(color2R, color2G, color2B);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = skyColor * visibility;
}

if (ground > 0.5 && p.y < 0.2) {
    col = snowColor;
    float snowDrift = sin(p.x * 10.0 + timeVal * windStrength) * 0.02;
    col *= 0.95 + snowDrift;
}

for (int layer = 0; layer < 5; layer++) {
    float fl = float(layer);
    float layerWind = windStrength * (0.8 + fl * 0.2);
    float layerTurb = turbulence * (1.0 + fl * 0.3);
    for (int i = 0; i < 40; i++) {
        if (float(i) >= snowIntensity / 5.0) break;
        float fi = float(i);
        float seed = fi + fl * 200.0;
        float sx = fract(sin(seed * 127.1) * 43758.5453 + timeVal * layerWind * 0.2);
        float sy = fract(sin(seed * 311.7) * 43758.5453 + timeVal * 0.5);
        float turb = sin(timeVal * 3.0 + fi + fl) * layerTurb * 0.05;
        sx += turb;
        float2 snowPos = float2(sx, 1.0 - sy);
        float d = length(p - snowPos);
        float flakeSize = 0.008 * (0.7 + fl * 0.2) * pulseAmt;
        float snow = smoothstep(flakeSize, flakeSize * 0.3, d);
        float bright = 0.4 + fl * 0.15;
        float3 flakeCol = snowColor * bright;
        if (neon > 0.5) flakeCol = pow(flakeCol, float3(0.7)) * 1.3;
        if (pastel > 0.5) flakeCol = mix(flakeCol, float3(1.0), 0.2);
        col += snow * flakeCol * 0.3;
    }
}

float whiteout = whiteoutAmount * (1.0 - visibility);
col = mix(col, float3(0.85, 0.88, 0.9), whiteout);
col += whiteout * sin(p.x * 20.0 + timeVal * windStrength * 5.0) * 0.05;

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

if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Acid Rain
let acidRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param rainDensity "Rain Density" range(20.0, 80.0) default(40.0)
// @param rainSpeed "Rain Speed" range(1.0, 4.0) default(2.0)
// @param toxicity "Toxicity" range(0.0, 1.0) default(0.6)
// @param puddleSize "Puddle Size" range(0.0, 0.4) default(0.15)
// @param steamAmount "Steam Amount" range(0.0, 1.0) default(0.3)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(1.0)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle glowing "Glowing" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 acidColor = float3(color1R, color1G, color1B);
float3 puddleBaseColor = float3(color2R, color2G, color2B);

float3 skyColor;
if (rainbow > 0.5) {
    skyColor = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    skyColor = mix(float3(0.2, 0.25, 0.15), float3(0.1, 0.15, 0.1), p.y);
}
float3 col = skyColor;

for (int i = 0; i < 80; i++) {
    if (float(i) >= rainDensity) break;
    float fi = float(i);
    float rx = fract(sin(fi * 127.1) * 43758.5453);
    float ry = fract(sin(fi * 311.7) * 43758.5453 + timeVal * rainSpeed);
    float2 rainPos = float2(rx, 1.0 - ry);
    float rd = abs(p.x - rainPos.x);
    float rain = smoothstep(0.003 * pulseAmt, 0.0, rd);
    rain *= step(rainPos.y - 0.04, p.y) * step(p.y, rainPos.y);
    float3 rainColor;
    if (glowing > 0.5) {
        rainColor = mix(acidColor, acidColor * 0.7, toxicity);
        rain *= 1.0 + toxicity * 0.5;
    } else {
        rainColor = float3(0.6, 0.7, 0.4);
    }
    if (neon > 0.5) rainColor = pow(rainColor, float3(0.7)) * 1.5;
    if (pastel > 0.5) rainColor = mix(rainColor, float3(1.0), 0.3);
    col += rain * rainColor * 0.5;
}

if (puddleSize > 0.0 && p.y < 0.15) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float px = fract(sin(fi * 43.758) * 43758.5453);
        float2 puddlePos = float2(px, 0.08);
        float pd = length((p - puddlePos) * float2(1.0, 3.0));
        float puddle = smoothstep(puddleSize * pulseAmt, puddleSize - 0.05, pd);
        float3 puddleColor = mix(puddleBaseColor, acidColor * 0.8, toxicity);
        if (glowing > 0.5) {
            puddleColor += float3(0.1, 0.2, 0.05) * sin(timeVal * 2.0 + fi) * 0.5;
        }
        col = mix(col, puddleColor, puddle * 0.7);
    }
}

if (steamAmount > 0.0) {
    float steam = sin(p.x * 10.0 + timeVal) * sin(p.y * 8.0 + timeVal * 0.7) * 0.5 + 0.5;
    steam *= smoothstep(0.3, 0.0, p.y) * steamAmount;
    float3 steamColor = float3(0.4, 0.5, 0.3);
    col = mix(col, steamColor, steam * 0.3);
}

if (glow > 0.5) col += col * glowIntensity * toxicity * 0.2;
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

/// Meteor Rain
let meteorRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param meteorCount "Meteor Count" range(5.0, 30.0) default(15.0)
// @param meteorSpeed "Meteor Speed" range(1.0, 5.0) default(2.5)
// @param trailLength "Trail Length" range(0.1, 0.5) default(0.2)
// @param fireIntensity "Fire Intensity" range(0.0, 1.0) default(0.7)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.6)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle explosions "Explosions" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 trailStart = float3(color1R, color1G, color1B);
float3 trailEnd = float3(color2R, color2G, color2B);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188)) * 0.05;
} else {
    col = float3(0.02, 0.02, 0.05);
}

for (int i = 0; i < 50; i++) {
    float fi = float(i);
    if (fi > starDensity * 50.0) break;
    float2 starPos = float2(
        fract(sin(fi * 127.1) * 43758.5453),
        fract(sin(fi * 311.7) * 43758.5453)
    );
    float starD = length(p - starPos);
    float star = smoothstep(0.002 * pulseAmt, 0.0, starD);
    col += star * 0.3;
}

for (int i = 0; i < 30; i++) {
    if (float(i) >= meteorCount) break;
    float fi = float(i);
    float startX = fract(sin(fi * 127.1) * 43758.5453);
    float startY = fract(sin(fi * 311.7) * 43758.5453) * 0.5 + 0.5;
    float meteorPhase = fract(timeVal * meteorSpeed * 0.2 + fi * 0.1);
    float2 meteorPos = float2(
        startX + meteorPhase * 0.3,
        startY - meteorPhase
    );
    if (meteorPos.y < 0.0) continue;
    float2 dir = normalize(float2(0.3, -1.0));
    float2 toP = p - meteorPos;
    float along = dot(toP, -dir);
    float perp = abs(dot(toP, float2(dir.y, -dir.x)));
    float trail = smoothstep(trailLength * pulseAmt, 0.0, along) * step(0.0, along);
    trail *= smoothstep(0.02, 0.005, perp);
    float3 trailColor = mix(trailStart, trailEnd, along / trailLength);
    trailColor *= fireIntensity;
    if (neon > 0.5) trailColor = pow(trailColor, float3(0.7)) * 1.5;
    if (pastel > 0.5) trailColor = mix(trailColor, float3(1.0), 0.3);
    col += trail * trailColor;
    float head = smoothstep(0.02, 0.01, length(toP));
    col += head * float3(1.0, 0.9, 0.7);
    if (glow > 0.5) {
        float glowAmt = exp(-length(toP) * 10.0) * glowIntensity;
        col += glowAmt * float3(1.0, 0.5, 0.2);
    }
}

if (explosions > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float explodeTime = fract(timeVal * 0.5 + fi * 0.2);
        if (explodeTime < 0.2) {
            float2 explodePos = float2(
                fract(sin(fi * 43.758 + floor(timeVal * 0.5)) * 43758.5453),
                0.05 + fract(sin(fi * 78.233 + floor(timeVal * 0.5)) * 43758.5453) * 0.1
            );
            float explodeR = explodeTime * 0.3;
            float explode = smoothstep(explodeR + 0.02, explodeR, length(p - explodePos));
            explode *= (1.0 - explodeTime * 5.0);
            col += explode * trailStart;
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

if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Eclipse
let eclipseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param eclipsePhase "Eclipse Phase" range(0.0, 1.0) default(0.5)
// @param coronaSize "Corona Size" range(0.1, 0.5) default(0.2)
// @param coronaIntensity "Corona Intensity" range(0.5, 2.0) default(1.0)
// @param sunSize "Sun Size" range(0.15, 0.4) default(0.2)
// @param diamondRing "Diamond Ring" range(0.0, 1.0) default(0.0)
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
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle totalEclipse "Total Eclipse" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 coronaColor1 = float3(color1R, color1G, color1B);
float3 coronaColor2 = float3(color2R, color2G, color2B);

float2 tp = p * 2.0 - 1.0;
float3 col;

if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(length(tp) * 3.0 + timeVal + float3(0.0, 2.094, 4.188)) * 0.05;
} else {
    col = float3(0.02, 0.02, 0.05);
}

for (int i = 0; i < 100; i++) {
    float fi = float(i);
    float2 starPos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0,
        fract(sin(fi * 311.7) * 43758.5453) * 2.0 - 1.0
    );
    float starD = length(tp - starPos);
    float star = smoothstep(0.003 * pulseAmt, 0.0, starD) * 0.5;
    col += star;
}

float2 sunPos = float2(0.0, 0.0);
float sunDist = length(tp - sunPos);
float moonOffset = totalEclipse > 0.5 ? 0.0 : (eclipsePhase - 0.5) * 0.3;
float2 moonPos = float2(moonOffset, 0.0);
float moonDist = length(tp - moonPos);

float corona = exp(-sunDist / coronaSize) * coronaIntensity * pulseAmt;
float3 coronaCol = mix(coronaColor1, coronaColor2, sunDist / coronaSize);
if (neon > 0.5) coronaCol = pow(coronaCol, float3(0.7)) * 1.5;
if (pastel > 0.5) coronaCol = mix(coronaCol, float3(1.0), 0.3);
col += corona * coronaCol;

float streamers = 0.0;
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float sAngle = fi * 0.785 + timeVal * 0.1;
    float2 dir = float2(cos(sAngle), sin(sAngle));
    float streamer = exp(-abs(dot(tp, float2(-dir.y, dir.x))) * 10.0);
    streamer *= exp(-sunDist * 3.0);
    streamers += streamer;
}
col += streamers * coronaCol * coronaIntensity * 0.3;

float sun = smoothstep(sunSize * pulseAmt + 0.01, sunSize * pulseAmt, sunDist);
col = mix(col, float3(1.0, 0.95, 0.8), sun);

float moonSize = sunSize * (0.9 + eclipsePhase * 0.2);
float moon = smoothstep(moonSize + 0.005, moonSize, moonDist);
col *= (1.0 - moon);

if (diamondRing > 0.0 && abs(eclipsePhase - 0.5) < 0.1) {
    float ringAngle = 0.785;
    float2 ringDir = float2(cos(ringAngle), sin(ringAngle));
    float ring = exp(-length(tp - ringDir * sunSize) * 20.0);
    col += ring * float3(1.0, 1.0, 1.0) * diamondRing * 2.0;
}

if (glow > 0.5) col += col * glowIntensity * corona * 0.2;
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
float angl = hueShift;
float3 k = float3(0.57735);
col = col * cos(angl) + cross(k, col) * sin(angl) + k * dot(k, col) * (1.0 - cos(angl));
col *= brightness * flickerAmt;
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, 0.0), float3(1.0 / gamma));

if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

/// Volcanic Ash
let volcanicAshCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param ashDensity "Ash Density" range(0.3, 1.0) default(0.6)
// @param fallSpeed "Fall Speed" range(0.1, 0.7) default(0.2)
// @param emberAmount "Ember Amount" range(0.0, 1.0) default(0.4)
// @param smokeOpacity "Smoke Opacity" range(0.3, 0.8) default(0.5)
// @param lavaGlow "Lava Glow" range(0.0, 1.0) default(0.3)
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
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.1)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(0.28)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(0.25)
// @toggle animated "Animated" default(true)
// @toggle volcano "Volcano" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Show Edges" default(false)
// @toggle gradient "Gradient" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.1 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 lavaColor = float3(color1R, color1G, color1B);
float3 ashColor = float3(color2R, color2G, color2B);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188)) * 0.2;
} else {
    col = float3(0.15, 0.1, 0.08);
}

if (volcano > 0.5) {
    float volcanoShape = smoothstep(0.3, 0.0, abs(p.x - 0.5) - (0.3 - p.y * 0.3));
    volcanoShape *= step(p.y, 0.4);
    col = mix(col, float3(0.1, 0.08, 0.06), volcanoShape);
    float crater = smoothstep(0.05, 0.0, abs(p.x - 0.5)) * step(0.35, p.y) * step(p.y, 0.42);
    float3 craterGlow = lavaColor * lavaGlow * pulseAmt;
    craterGlow *= 0.8 + sin(timeVal * 3.0) * 0.2;
    col += crater * craterGlow;
}

for (int i = 0; i < 100; i++) {
    float fi = float(i);
    float ax = fract(sin(fi * 127.1) * 43758.5453);
    float ay = fract(sin(fi * 311.7) * 43758.5453 + timeVal * fallSpeed);
    float2 ashPos = float2(ax, 1.0 - ay);
    float wind = sin(timeVal + fi) * 0.05;
    ashPos.x += wind;
    float d = length(p - ashPos);
    float ash = smoothstep(0.008, 0.003, d) * ashDensity;
    float3 ashCol = ashColor;
    if (neon > 0.5) ashCol = pow(ashCol, float3(0.7)) * 1.3;
    if (pastel > 0.5) ashCol = mix(ashCol, float3(0.7), 0.3);
    col += ash * ashCol;
}

if (emberAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float ex = fract(sin(fi * 43.758) * 43758.5453) * 0.4 + 0.3;
        float ey = fract(sin(fi * 78.233) * 43758.5453 - timeVal * 0.3);
        if (volcano > 0.5) {
            ey = 0.4 + ey * 0.5;
        }
        float2 emberPos = float2(ex, ey);
        float d = length(p - emberPos);
        float ember = smoothstep(0.01, 0.005, d) * emberAmount;
        float emberFlicker = sin(timeVal * 10.0 + fi * 5.0) * 0.3 + 0.7;
        col += ember * lavaColor * emberFlicker;
    }
}

float smoke = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 sp = p * (2.0 + fi);
    sp.y -= timeVal * 0.1 * (1.0 + fi * 0.3);
    smoke += sin(sp.x * 3.0 + fi) * sin(sp.y * 2.0) * pow(0.5, fi);
}
smoke = smoke * 0.5 + 0.5;
smoke *= step(0.3, p.y) * smokeOpacity;
col = mix(col, float3(0.2, 0.18, 0.15), smoke * 0.5);

if (glow > 0.5) col += col * glowIntensity * lavaGlow * 0.2;
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

/// Wind Patterns
let windPatternsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(1.0)
// @param windSpeed "Wind Speed" range(0.5, 3.0) default(1.5)
// @param streamCount "Stream Count" range(5.0, 20.0) default(10.0)
// @param streamLength "Stream Length" range(0.1, 0.6) default(0.3)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.3)
// @param visibility "Visibility" range(0.2, 1.0) default(0.5)
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
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color 1 Red" range(0.0, 1.0) default(0.7)
// @param color1G "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1B "Color 1 Blue" range(0.0, 1.0) default(0.9)
// @param color2R "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2G "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2B "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle showParticles "Show Particles" default(true)
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
float pulseAmt = pulse > 0.5 ? sin(timeVal * 3.0) * 0.05 + 1.0 : 1.0;
float flickerAmt = flicker > 0.5 ? 0.9 + 0.1 * fract(sin(timeVal * 43.0) * 4357.0) : 1.0;

float3 bgColor = float3(color1R, color1G, color1B);
float3 streamColor = float3(color2R, color2G, color2B);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(p.y * 3.0 + timeVal + float3(0.0, 2.094, 4.188));
} else {
    col = bgColor;
}

for (int i = 0; i < 20; i++) {
    if (float(i) >= streamCount) break;
    float fi = float(i);
    float streamY = fract(sin(fi * 127.1) * 43758.5453);
    float streamPhase = fract(timeVal * windSpeed * 0.2 + fi * 0.1);
    float waveY = sin(p.x * 10.0 + timeVal * windSpeed + fi) * turbulence * 0.1;
    float streamDist = abs(p.y - streamY - waveY);
    float stream = smoothstep(0.02 * pulseAmt, 0.005, streamDist);
    float fade = smoothstep(0.0, streamLength, streamPhase) * smoothstep(1.0, 1.0 - streamLength, streamPhase);
    float xMask = smoothstep(streamPhase - streamLength, streamPhase, p.x);
    xMask *= smoothstep(streamPhase + 0.02, streamPhase, p.x);
    float3 sCol = streamColor;
    if (neon > 0.5) sCol = pow(sCol, float3(0.7)) * 1.3;
    if (pastel > 0.5) sCol = mix(sCol, float3(1.0), 0.3);
    col += stream * visibility * fade * xMask * sCol * 0.3;
}

if (showParticles > 0.5) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float px = fract(sin(fi * 127.1) * 43758.5453 + timeVal * windSpeed * 0.3);
        float py = fract(sin(fi * 311.7) * 43758.5453);
        float wobble = sin(timeVal * 2.0 + fi) * turbulence * 0.05;
        float2 particlePos = float2(px, py + wobble);
        float d = length(p - particlePos);
        float particle = smoothstep(0.005 * pulseAmt, 0.002, d);
        col += particle * visibility * streamColor * 0.2;
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

if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

