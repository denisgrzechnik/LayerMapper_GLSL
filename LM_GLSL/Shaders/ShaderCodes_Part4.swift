//
//  ShaderCodes_Part4.swift
//  LM_GLSL
//
//  Shader codes - Part 4: Patterns, Fractals, AudioReactive, Gradient
//

import Foundation

// MARK: - Patterns Category

let chevronCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(2.0, 20.0) default(10.0)
// @param chevronWidth "Chevron Width" range(0.3, 0.7) default(0.5)
// @param sharpness "Sharpness" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param stripeWidth "Stripe Width" range(0.1, 0.5) default(0.2)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showStripes "Show Stripes" default(true)
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

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

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

if (distortion > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
}

float2 sp = p * scale;
float y = sp.y + abs(fract(sp.x) - 0.5) * 2.0;
float chevron = step(chevronWidth, fract(y + timeVal));

if (showStripes > 0.5) {
    float stripe = step(stripeWidth, fract(sp.x));
    chevron = mix(chevron, stripe, 0.3);
}

if (showEdges > 0.5) {
    float edge = smoothstep(sharpness * 0.1, 0.0, abs(fract(y + timeVal) - chevronWidth));
    chevron = max(chevron, edge);
}

float3 col1 = float3(color1Red, color1Green, color1Blue);
float3 col2 = float3(color2Red, color2Green, color2Blue);
float3 col = mix(col1, col2, chevron);

if (gradient > 0.5) {
    col *= 0.7 + 0.3 * p.y;
}

if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}
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
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

col *= masterOpacity;
return float4(col, masterOpacity);
"""

let houndstoothCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(5.0, 20.0) default(10.0)
// @param patternSize "Pattern Size" range(0.3, 0.7) default(0.5)
// @param edgeSharpness "Edge Sharpness" range(0.0, 1.0) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param mixAmount "Mix Amount" range(0.0, 1.0) default(0.5)
// @param waveAmount "Wave Amount" range(0.0, 0.5) default(0.0)
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
// @param lightColor "Light Color" range(0.5, 1.0) default(0.9)
// @param darkColor "Dark Color" range(0.0, 0.5) default(0.1)
// @param accentRed "Accent Red" range(0.0, 1.0) default(0.5)
// @param accentGreen "Accent Green" range(0.0, 1.0) default(0.3)
// @param accentBlue "Accent Blue" range(0.0, 1.0) default(0.2)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showPattern "Show Pattern" default(true)
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
// @toggle waves "Waves" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (distortion > 0.0) p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;
if (waves > 0.5) p += sin(p.yx * 10.0 + timeVal) * waveAmount * 0.1;

float2 sp = p * scale;
float2 pid = floor(sp);
float2 f = fract(sp);
float check = mod(pid.x + pid.y, 2.0);
float tooth = 0.0;
if (check > 0.5) { tooth = step(f.x, f.y); }
else { tooth = step(f.y, f.x); }
tooth = mix(tooth, 1.0 - tooth, step(0.5, fract((pid.x + pid.y) * mixAmount)));

float3 col;
if (colorful > 0.5) {
    col = mix(float3(accentRed, accentGreen, accentBlue), float3(lightColor), tooth);
} else {
    col = mix(float3(darkColor), float3(lightColor), tooth);
}

if (gradient > 0.5) col *= 0.7 + 0.3 * p.y;
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

let herringboneCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(5.0, 20.0) default(10.0)
// @param brickWidth "Brick Width" range(0.3, 0.7) default(0.5)
// @param lineThickness "Line Thickness" range(0.01, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param groutColor "Grout Color" range(0.0, 0.5) default(0.1)
// @param colorVariation "Color Variation" range(0.0, 0.3) default(0.1)
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
// @param baseRed "Base Red" range(0.0, 1.0) default(0.6)
// @param baseGreen "Base Green" range(0.0, 1.0) default(0.4)
// @param baseBlue "Base Blue" range(0.0, 1.0) default(0.3)
// @param altRed "Alt Red" range(0.0, 1.0) default(0.4)
// @param altGreen "Alt Green" range(0.0, 1.0) default(0.25)
// @param altBlue "Alt Blue" range(0.0, 1.0) default(0.15)
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showGrout "Show Grout" default(true)
// @toggle randomColors "Random Colors" default(false)
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
// @toggle weathered "Weathered" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (distortion > 0.0) p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;

float2 sp = p * scale;
float2 i = floor(sp);
float2 f = fract(sp);
float row = mod(i.y, 2.0);
float brick = step(brickWidth, fract((sp.x + row * 0.5) * 0.5));

float line = 0.0;
if (showGrout > 0.5) {
    line = smoothstep(lineThickness, 0.0, abs(f.y - 0.5));
    line += smoothstep(lineThickness, 0.0, abs(fract((sp.x + row * 0.5) * 0.5)));
}

float3 baseCol = float3(baseRed, baseGreen, baseBlue);
float3 altCol = float3(altRed, altGreen, altBlue);
float3 col = mix(baseCol, altCol, brick);

if (randomColors > 0.5) {
    float rnd = fract(sin(dot(i, float2(12.9898, 78.233))) * 43758.5453);
    col *= 0.8 + rnd * colorVariation;
}
if (weathered > 0.5) {
    float wear = fract(sin(dot(sp * 10.0, float2(12.9898, 78.233))) * 43758.5453);
    col *= 0.9 + wear * 0.2;
}

col = mix(col, float3(groutColor), line * 0.5);

if (gradient > 0.5) col *= 0.7 + 0.3 * p.y;
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

let islamicPatternCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(3.0, 12.0) default(6.0)
// @param starPoints "Star Points" range(6.0, 12.0) default(8.0)
// @param starSize "Star Size" range(0.2, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param circleSize "Circle Size" range(0.3, 0.5) default(0.4)
// @param lineWidth "Line Width" range(0.01, 0.05) default(0.02)
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
// @param bgRed "BG Red" range(0.0, 0.5) default(0.1)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.3)
// @param bgBlue "BG Blue" range(0.0, 1.0) default(0.5)
// @param fgRed "FG Red" range(0.5, 1.0) default(0.9)
// @param fgGreen "FG Green" range(0.5, 1.0) default(0.8)
// @param fgBlue "FG Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCircles "Show Circles" default(true)
// @toggle showStars "Show Stars" default(true)
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
// @toggle goldAccent "Gold Accent" default(true)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (distortion > 0.0) p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;

float2 sp = p * scale;
float2 i = floor(sp);
float2 f = fract(sp) - 0.5;

float pattern = 0.0;
if (showCircles > 0.5) {
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float2 offset = float2(float(x), float(y));
            float d = length(f - offset);
            pattern += smoothstep(circleSize, circleSize - lineWidth, d);
        }
    }
}

if (showStars > 0.5) {
    float star = 1.0 - smoothstep(0.0, lineWidth, abs(length(f) - starSize));
    star *= step(0.2, abs(sin(atan2(f.y, f.x) * starPoints + timeVal)));
    pattern += star;
}

float3 bgCol = float3(bgRed, bgGreen, bgBlue);
float3 fgCol = float3(fgRed, fgGreen, fgBlue);
if (goldAccent > 0.5) fgCol = mix(fgCol, float3(1.0, 0.85, 0.4), 0.5);

float3 col = mix(bgCol, fgCol, clamp(pattern, 0.0, 1.0));

if (gradient > 0.5) col *= 0.7 + 0.3 * p.y;
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

let celticKnotCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scale "Scale" range(2.0, 8.0) default(4.0)
// @param knotComplexity "Knot Complexity" range(2.0, 8.0) default(4.0)
// @param ringInner "Ring Inner" range(0.2, 0.35) default(0.25)
// @param ringOuter "Ring Outer" range(0.3, 0.4) default(0.35)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param weaveDepth "Weave Depth" range(0.0, 1.0) default(0.5)
// @param shadowAmount "Shadow Amount" range(0.0, 0.5) default(0.2)
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
// @param knotRed "Knot Red" range(0.0, 1.0) default(0.8)
// @param knotGreen "Knot Green" range(0.0, 1.0) default(0.6)
// @param knotBlue "Knot Blue" range(0.0, 1.0) default(0.2)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.1)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.2)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showWeave "Show Weave" default(true)
// @toggle showShadow "Show Shadow" default(true)
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
// @toggle metallic "Metallic" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (distortion > 0.0) p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortion * 0.05;

float2 sp = p * scale;
float2 i = floor(sp);
float2 f = fract(sp) - 0.5;

float knot = 0.0;
float r = length(f);
float a = atan2(f.y, f.x);
float weave = sin(a * knotComplexity + i.x + i.y + timeVal);
float ring = smoothstep(ringOuter, ringOuter - 0.02, r) * smoothstep(ringInner, ringInner + 0.02, r);

if (showWeave > 0.5) {
    ring *= 0.5 + 0.5 * sign(weave) * weaveDepth;
}

float3 knotCol = float3(knotRed, knotGreen, knotBlue);
float3 bgCol = float3(bgRed, bgGreen, bgBlue);

if (metallic > 0.5) {
    knotCol = mix(knotCol, float3(0.9, 0.8, 0.5), 0.3);
    knotCol *= 0.8 + 0.2 * sin(a * 8.0);
}

float3 col = ring * knotCol;
if (showShadow > 0.5) {
    col *= 1.0 - shadowAmount * (1.0 - ring);
}
col += (1.0 - ring) * bgCol;

if (gradient > 0.5) col *= 0.7 + 0.3 * p.y;
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

// MARK: - Fractals Category

let mandelbrotCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.1)
// @param iterations "Iterations" range(20.0, 200.0) default(100.0)
// @param zoomLevel "Zoom Level" range(0.5, 3.0) default(1.0)
// @param escapeRadius "Escape Radius" range(2.0, 10.0) default(4.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(1.0, 10.0) default(1.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param offsetX "Offset X" range(-2.0, 1.0) default(-0.5)
// @param offsetY "Offset Y" range(-1.5, 1.5) default(0.0)
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
// @param insideRed "Inside Red" range(0.0, 1.0) default(0.0)
// @param insideGreen "Inside Green" range(0.0, 1.0) default(0.0)
// @param insideBlue "Inside Blue" range(0.0, 1.0) default(0.0)
// @param outsideMix "Outside Mix" range(0.0, 1.0) default(0.5)
// @param smoothColoring "Smooth Coloring" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showInside "Show Inside" default(true)
// @toggle smoothEscape "Smooth Escape" default(true)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle julia "Julia" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float2 c = (p - 0.5) * 3.0 / zoomLevel;
c.x += offsetX;
c.y += offsetY;
c *= 1.0 + sin(timeVal) * 0.5;

float2 z = float2(0.0);
int iter = 0;
int maxIter = int(iterations);
for (int i = 0; i < 200; i++) {
    if (i >= maxIter) break;
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > escapeRadius) break;
    iter = i;
}

float t = float(iter) / iterations;
float3 insideCol = float3(insideRed, insideGreen, insideBlue);
float3 col = 0.5 + 0.5 * cos(t * 6.28 * colorCycles + float3(0.0, 2.0, 4.0) + colorOffset + timeVal);

if (showInside > 0.5 && t < 0.01) {
    col = insideCol;
}
col *= step(0.01, t);

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

let juliaSetCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.3)
// @param iterations "Iterations" range(20.0, 200.0) default(100.0)
// @param zoomLevel "Zoom Level" range(0.5, 3.0) default(1.0)
// @param cReal "C Real" range(-1.0, 1.0) default(0.0)
// @param cImag "C Imaginary" range(-1.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(1.0, 10.0) default(1.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param escapeRadius "Escape Radius" range(2.0, 10.0) default(4.0)
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
// @param morphAmount "Morph Amount" range(0.0, 0.5) default(0.4)
// @param morphSpeed "Morph Speed" range(0.1, 1.0) default(0.3)
// @param insideRed "Inside Red" range(0.0, 1.0) default(0.0)
// @param insideGreen "Inside Green" range(0.0, 1.0) default(0.0)
// @param insideBlue "Inside Blue" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle morphC "Morph C" default(true)
// @toggle showInside "Show Inside" default(false)
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
// @toggle orbit "Orbit" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float2 z = (p - 0.5) * 3.0 / zoomLevel;
float2 c;
if (morphC > 0.5) {
    c = float2(sin(timeVal * morphSpeed) * morphAmount, cos(timeVal * morphSpeed * 0.7) * morphAmount);
} else {
    c = float2(cReal, cImag);
}

int iter = 0;
int maxIter = int(iterations);
for (int i = 0; i < 200; i++) {
    if (i >= maxIter) break;
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > escapeRadius) break;
    iter = i;
}

float t = float(iter) / iterations;
float3 col = 0.5 + 0.5 * cos(t * 6.28 * colorCycles + float3(0.0, 2.0, 4.0) + colorOffset);

if (showInside > 0.5 && t > 0.99) {
    col = float3(insideRed, insideGreen, insideBlue);
}
col *= step(0.01, t);

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

let sierpinskiCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param iterations "Iterations" range(3.0, 15.0) default(10.0)
// @param scale "Scale" range(1.5, 3.0) default(2.0)
// @param offsetX "Offset X" range(-0.5, 0.5) default(0.0)
// @param offsetY "Offset Y" range(-0.5, 0.5) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorSpeed "Color Speed" range(0.0, 3.0) default(1.0)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
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
// @param bgRed "BG Red" range(0.0, 0.5) default(0.0)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.0)
// @param fgMix "FG Mix" range(0.0, 1.0) default(0.5)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle carpet "Carpet" default(false)
// @toggle colorByDepth "Color By Depth" default(true)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle gasket "Gasket" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom + center;

float cosR = cos(rotation); float sinR = sin(rotation);
float2 rp = p - center;
rp = float2(rp.x * cosR - rp.y * sinR, rp.x * sinR + rp.y * cosR);
p = rp + center;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

p.x += offsetX;
p.y += offsetY;

float3 col = float3(bgRed, bgGreen, bgBlue);
int maxIter = int(iterations);
for (int i = 0; i < 15; i++) {
    if (i >= maxIter) break;
    p *= scale;
    float2 m = mod(p, 2.0);
    
    bool hit = false;
    if (carpet > 0.5) {
        hit = m.x > 0.333 && m.x < 0.666 && m.y > 0.333 && m.y < 0.666;
    } else {
        hit = m.x > 1.0 && m.y > 1.0;
    }
    
    if (hit) {
        if (colorByDepth > 0.5) {
            col = 0.5 + 0.5 * cos(float(i) + timeVal * colorSpeed + float3(0.0, 2.0, 4.0));
        } else {
            col = float3(1.0);
        }
        break;
    }
    p = fract(p) * 2.0;
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

let burningShipCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.1)
// @param iterations "Iterations" range(20.0, 200.0) default(100.0)
// @param zoomLevel "Zoom Level" range(0.5, 3.0) default(1.0)
// @param escapeRadius "Escape Radius" range(2.0, 10.0) default(4.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(1.0, 10.0) default(1.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.4)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param offsetX "Offset X" range(-2.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.5, 1.5) default(0.0)
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
// @param insideRed "Inside Red" range(0.0, 1.0) default(0.0)
// @param insideGreen "Inside Green" range(0.0, 1.0) default(0.0)
// @param insideBlue "Inside Blue" range(0.0, 1.0) default(0.0)
// @param outsideMix "Outside Mix" range(0.0, 1.0) default(0.5)
// @param smoothColoring "Smooth Coloring" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showInside "Show Inside" default(false)
// @toggle flipped "Flipped" default(false)
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
// @toggle colorShift "Color Shift" default(true)
// @toggle orbit "Orbit" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float2 c = (p - center) * 3.0 / zoomLevel;
c.x += offsetX;
c.y += offsetY;
if (flipped > 0.5) c.y = -c.y;
c *= 1.0 + sin(timeVal) * 0.1;

float2 z = float2(0.0);
int iter = 0;
int maxIter = int(iterations);
for (int i = 0; i < 200; i++) {
    if (i >= maxIter) break;
    z = abs(z);
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > escapeRadius) break;
    iter = i;
}

float t = float(iter) / iterations;
float3 col = 0.5 + 0.5 * cos(t * 6.28 * colorCycles + float3(0.0, 1.0, 2.0) + colorOffset + timeVal * 0.5);

if (showInside > 0.5 && t < 0.01) {
    col = float3(insideRed, insideGreen, insideBlue);
}
col *= step(0.01, t);

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

let fractalTreeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param branches "Branches" range(4.0, 12.0) default(8.0)
// @param branchScale "Branch Scale" range(0.5, 0.9) default(0.7)
// @param branchAngle "Branch Angle" range(0.2, 1.0) default(0.5)
// @param branchLength "Branch Length" range(0.1, 0.25) default(0.15)
// @param lineThickness "Line Thickness" range(0.01, 0.05) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param swayAmount "Sway Amount" range(0.0, 0.5) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param startY "Start Y" range(-1.0, 0.0) default(-0.5)
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
// @param trunkRed "Trunk Red" range(0.0, 1.0) default(0.4)
// @param trunkGreen "Trunk Green" range(0.0, 1.0) default(0.25)
// @param trunkBlue "Trunk Blue" range(0.0, 1.0) default(0.1)
// @param bgRed "BG Red" range(0.0, 0.5) default(0.1)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.15)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle leaves "Leaves" default(false)
// @toggle coloredBranches "Colored Branches" default(false)
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
// @toggle seasonal "Seasonal" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0;
p.y += 0.5 + startY;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x);

float tree = 0.0;
float2 dir = float2(0.0, branchLength);
float2 pos = float2(0.0, startY);
float scale = 1.0;
int maxBranch = int(branches);

for (int i = 0; i < 12; i++) {
    if (i >= maxBranch) break;
    float thickness = lineThickness * scale;
    float branch = smoothstep(thickness, 0.0, abs(p.x - pos.x)) * 
                   step(pos.y, p.y) * step(p.y, pos.y + dir.y);
    tree += branch;
    
    pos.y += dir.y;
    dir *= branchScale;
    float angle = branchAngle + sin(timeVal + float(i)) * swayAmount;
    float side = sign(sin(float(i) * 2.3));
    pos.x += side * dir.y * angle;
    scale *= 0.8;
}

float3 col = tree * float3(trunkRed, trunkGreen, trunkBlue);
if (coloredBranches > 0.5) col = tree * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal));
col += (1.0 - step(0.01, tree)) * float3(bgRed, bgGreen, bgBlue);

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

// MARK: - AudioReactive Category (simulated)

let audioWaveformCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param waveFreq1 "Wave Freq 1" range(10.0, 50.0) default(20.0)
// @param waveFreq2 "Wave Freq 2" range(20.0, 60.0) default(35.0)
// @param waveFreq3 "Wave Freq 3" range(30.0, 80.0) default(50.0)
// @param amplitude1 "Amplitude 1" range(0.1, 0.5) default(0.3)
// @param amplitude2 "Amplitude 2" range(0.05, 0.3) default(0.15)
// @param amplitude3 "Amplitude 3" range(0.05, 0.2) default(0.1)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param lineThickness "Line Thickness" range(0.005, 0.05) default(0.02)
// @param fillAmount "Fill Amount" range(0.0, 1.0) default(0.5)
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
// @param waveRed "Wave Red" range(0.0, 1.0) default(0.0)
// @param waveGreen "Wave Green" range(0.0, 1.0) default(1.0)
// @param waveBlue "Wave Blue" range(0.0, 1.0) default(0.5)
// @param fillRed "Fill Red" range(0.0, 1.0) default(0.0)
// @param fillGreen "Fill Green" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle stereo "Stereo" default(false)
// @toggle fill "Fill" default(true)
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
// @toggle rainbow "Rainbow" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;
if (kaleidoscope > 0.5) {
    float2 kp = p - 0.5; float angle = atan2(kp.y, kp.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(kp) + 0.5;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float wave = sin(p.x * waveFreq1 + timeVal) * amplitude1;
wave += sin(p.x * waveFreq2 - timeVal * 0.67) * amplitude2;
wave += sin(p.x * waveFreq3 + timeVal * 1.67) * amplitude3;
wave = wave * 0.5 + 0.5;

float line = smoothstep(lineThickness, 0.0, abs(p.y - wave));
float3 waveCol = float3(waveRed, waveGreen, waveBlue);
if (rainbow > 0.5) waveCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + p.x * 3.0 + timeVal);

float3 col = line * waveCol;
if (fill > 0.5) {
    float fillMask = smoothstep(wave, wave - 0.3 * fillAmount, p.y);
    col += fillMask * float3(fillRed, fillGreen, 0.2) * 0.5;
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

let spectrumBarsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param barCount "Bar Count" range(5.0, 30.0) default(20.0)
// @param barWidth "Bar Width" range(0.01, 0.1) default(0.03)
// @param baseHeight "Base Height" range(0.1, 0.5) default(0.3)
// @param heightVariation "Height Variation" range(0.0, 0.8) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorSpeed "Color Speed" range(0.0, 3.0) default(0.3)
// @param barSpacing "Bar Spacing" range(0.0, 0.05) default(0.01)
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
// @param bgRed "BG Red" range(0.0, 0.3) default(0.05)
// @param bgGreen "BG Green" range(0.0, 0.3) default(0.05)
// @param bgBlue "BG Blue" range(0.0, 0.3) default(0.05)
// @param peakDecay "Peak Decay" range(0.0, 1.0) default(0.5)
// @param smoothness "Smoothness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle centered "Centered" default(false)
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
// @toggle peaks "Peaks" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5 && p.x < 0.5) p.x = 1.0 - p.x;

float3 col = float3(bgRed, bgGreen, bgBlue);
int numBars = int(barCount);

for (int i = 0; i < 30; i++) {
    if (i >= numBars) break;
    float fi = float(i);
    float x = fi / barCount + 0.025;
    float height = baseHeight + heightVariation * (0.5 + 0.5 * sin(timeVal + fi * 0.5));
    height *= 0.5 + 0.5 * sin(fi * colorSpeed + timeVal);
    
    float bar = step(x - barWidth * 0.5 + barSpacing, p.x) * step(p.x, x + barWidth * 0.5 - barSpacing);
    if (centered > 0.5) {
        bar *= step(0.5 - height * 0.5, p.y) * step(p.y, 0.5 + height * 0.5);
    } else {
        bar *= step(0.0, p.y) * step(p.y, height);
    }
    
    float3 barCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.3 + timeVal * colorSpeed);
    col += bar * barCol;
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

let beatPulseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 10.0) default(6.28)
// @param pulseSize "Pulse Size" range(0.3, 0.8) default(0.5)
// @param pulseRange "Pulse Range" range(0.1, 0.5) default(0.2)
// @param ringWidth "Ring Width" range(0.01, 0.1) default(0.02)
// @param pulseExponent "Pulse Exponent" range(1.0, 8.0) default(4.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param coreIntensity "Core Intensity" range(0.0, 2.0) default(1.0)
// @param coreFalloff "Core Falloff" range(1.0, 4.0) default(2.0)
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
// @param bgRed "BG Red" range(0.0, 0.5) default(0.2)
// @param bgGreen "BG Green" range(0.0, 0.5) default(0.0)
// @param bgBlue "BG Blue" range(0.0, 0.5) default(0.3)
// @param ringRed "Ring Red" range(0.0, 1.0) default(1.0)
// @param ringGreen "Ring Green" range(0.0, 1.0) default(0.0)
// @param ringBlue "Ring Blue" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showRing "Show Ring" default(true)
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
// @toggle multiRing "Multi Ring" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float beat = pow(sin(timeVal) * 0.5 + 0.5, pulseExponent);
float r = length(p);
float pulseVal = smoothstep(pulseSize + beat * pulseRange, pulseSize + beat * pulseRange - 0.02, r);
float ring = smoothstep(ringWidth, 0.0, abs(r - pulseSize - beat * pulseRange));

float3 col = pulseVal * float3(bgRed, bgGreen, bgBlue);
if (showRing > 0.5) col += ring * float3(ringRed, ringGreen, ringBlue);
if (showCore > 0.5) col += pow(max(0.0, 1.0 - r * coreFalloff), 2.0) * beat * float3(1.0, 0.5, 0.8) * coreIntensity;

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

let soundCirclesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(3.0)
// @param circleCount "Circle Count" range(2.0, 8.0) default(5.0)
// @param baseRadius "Base Radius" range(0.1, 0.4) default(0.2)
// @param radiusStep "Radius Step" range(0.05, 0.3) default(0.15)
// @param beatRange "Beat Range" range(0.1, 0.6) default(0.4)
// @param ringWidth "Ring Width" range(0.01, 0.05) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param phaseOffset "Phase Offset" range(0.0, 3.0) default(1.5)
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
// @param bgRed "BG Red" range(0.0, 0.2) default(0.02)
// @param bgGreen "BG Green" range(0.0, 0.2) default(0.02)
// @param bgBlue "BG Blue" range(0.0, 0.2) default(0.02)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param beatIntensity "Beat Intensity" range(0.5, 2.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle beatScale "Beat Scale" default(true)
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
// @toggle filled "Filled" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    angle = fmod(angle, 1.047); angle = abs(angle - 0.524);
    p = float2(cos(angle), sin(angle)) * length(p);
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float3 col = float3(bgRed, bgGreen, bgBlue);
int numCircles = int(circleCount);

for (int i = 0; i < 8; i++) {
    if (i >= numCircles) break;
    float fi = float(i);
    float r = baseRadius + fi * radiusStep;
    float beat = 0.5 + 0.5 * sin(timeVal + fi * phaseOffset);
    if (beatScale > 0.5) r *= 0.8 + beat * beatRange;
    float ring = smoothstep(ringWidth, 0.0, abs(length(p) - r));
    float3 ringCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += ring * ringCol * beat * beatIntensity;
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

let frequencyMeshCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param gridScale "Grid Scale" range(5.0, 20.0) default(10.0)
// @param lineWidth "Line Width" range(0.01, 0.15) default(0.05)
// @param distortAmount "Distort Amount" range(0.0, 2.0) default(1.0)
// @param distortFreq "Distort Freq" range(0.1, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param freqResponse "Freq Response" range(0.0, 1.0) default(0.5)
// @param intersectGlow "Intersect Glow" range(0.0, 2.0) default(1.0)
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
// @param bgRed "BG Red" range(0.0, 0.2) default(0.02)
// @param bgGreen "BG Green" range(0.0, 0.2) default(0.02)
// @param bgBlue "BG Blue" range(0.0, 0.2) default(0.02)
// @param gridRed "Grid Red" range(0.0, 1.0) default(0.0)
// @param gridGreen "Grid Green" range(0.0, 1.0) default(0.8)
// @param gridBlue "Grid Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showIntersect "Show Intersect" default(true)
// @toggle waveDistort "Wave Distort" default(true)
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
// @toggle rainbow "Rainbow" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv * gridScale;

if (pixelate > 0.5) p = floor(p / pixelSize) * pixelSize;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - gridScale * 0.5) + gridScale * 0.5;

float3 col = float3(bgRed, bgGreen, bgBlue);
float freq = sin(timeVal) * 0.5 + 0.5;
freq *= freqResponse;

float distort = 0.0;
if (waveDistort > 0.5) {
    distort = sin(p.x * distortFreq + timeVal) * sin(p.y * distortFreq + timeVal) * distortAmount * freq;
}

float gridX = smoothstep(lineWidth, 0.0, abs(fract(p.x) - 0.5));
float gridY = smoothstep(lineWidth, 0.0, abs(fract(p.y) - 0.5));
gridX *= 1.0 + distort;
gridY *= 1.0 + distort;

float3 gridCol = float3(gridRed, gridGreen, gridBlue);
if (rainbow > 0.5) gridCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal + p.x * 0.1);

col += (gridX + gridY) * 0.5 * gridCol;
if (showIntersect > 0.5) col += gridX * gridY * float3(1.0, 0.0, 0.5) * intersectGlow;

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

// MARK: - Gradient Category

let linearGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.2)
// @param angle "Angle" range(0.0, 6.28) default(0.0)
// @param gradientScale "Gradient Scale" range(0.5, 3.0) default(1.0)
// @param gradientOffset "Gradient Offset" range(-1.0, 1.0) default(0.0)
// @param sharpness "Sharpness" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
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
// @param steps "Steps" range(2.0, 20.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle stepped "Stepped" default(false)
// @toggle threeColor "Three Color" default(false)
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
// @toggle wave "Wave" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv;

if (pixelate > 0.5) p = floor(p * 100.0 / pixelSize) * pixelSize / 100.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float angleVal = angle + timeVal;
float grad = p.x * cos(angleVal) + p.y * sin(angleVal);
grad = grad * gradientScale + 0.5 + gradientOffset;

if (wave > 0.5) grad += sin(p.y * 10.0 + timeVal * 3.0) * 0.05;
if (stepped > 0.5 && steps > 1.0) grad = floor(grad * steps) / steps;

float3 col1 = float3(color1Red, color1Green, color1Blue);
float3 col2 = float3(color2Red, color2Green, color2Blue);
float3 col = mix(col1, col2, clamp(grad, 0.0, 1.0));

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

let radialGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.2)
// @param radiusInner "Radius Inner" range(0.0, 0.5) default(0.0)
// @param radiusOuter "Radius Outer" range(0.5, 1.5) default(1.0)
// @param movementX "Movement X" range(0.0, 0.5) default(0.3)
// @param movementY "Movement Y" range(0.0, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.5)
// @param color3Red "Color 3 Red" range(0.0, 1.0) default(0.2)
// @param color3Green "Color 3 Green" range(0.0, 1.0) default(0.1)
// @param color3Blue "Color 3 Blue" range(0.0, 1.0) default(0.5)
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
// @toggle threeColor "Three Color" default(true)
// @toggle moveCenter "Move Center" default(true)
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
// @toggle rings "Rings" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv * 2.0 - 1.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (moveCenter > 0.5) {
    p.x += sin(timeVal) * movementX;
    p.y += cos(timeVal) * movementY;
}

float r = length(p);

float3 col1 = float3(color1Red, color1Green, color1Blue);
float3 col2 = float3(color2Red, color2Green, color2Blue);
float3 col3 = float3(color3Red, color3Green, color3Blue);

float3 col = col1;
col = mix(col, col2, smoothstep(radiusInner, 0.5, r));
if (threeColor > 0.5) col = mix(col, col3, smoothstep(0.5, radiusOuter, r));

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

let conicGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 0.5) default(0.1)
// @param segments "Segments" range(1.0, 12.0) default(1.0)
// @param sharpness "Sharpness" range(0.0, 1.0) default(0.0)
// @param angleOffset "Angle Offset" range(0.0, 6.28) default(0.0)
// @param colorCycles "Color Cycles" range(1.0, 5.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(1.0)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.0)
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
// @toggle rainbow "Rainbow" default(true)
// @toggle twoColor "Two Color" default(false)
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
// @toggle stepped "Stepped" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float a = atan2(p.y, p.x) / 6.28 + 0.5;
a = fract(a * segments + timeVal + angleOffset / 6.28);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(a * 6.28 * colorCycles + float3(0.0, 2.0, 4.0));
} else if (twoColor > 0.5) {
    float3 col1 = float3(color1Red, color1Green, color1Blue);
    float3 col2 = float3(color2Red, color2Green, color2Blue);
    col = mix(col1, col2, a);
} else {
    col = 0.5 + 0.5 * cos(a * 6.28 * colorCycles + float3(0.0, 2.0, 4.0));
}

if (stepped > 0.5) {
    float stepCount = max(segments, 2.0);
    a = floor(a * stepCount) / stepCount;
    col = 0.5 + 0.5 * cos(a * 6.28 * colorCycles + float3(0.0, 2.0, 4.0));
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

let diamondGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 0.5) default(0.2)
// @param scale "Scale" range(0.5, 3.0) default(1.0)
// @param rings "Rings" range(1.0, 5.0) default(2.0)
// @param sharpness "Sharpness" range(0.0, 1.0) default(0.0)
// @param offsetX "Offset X" range(-0.5, 0.5) default(0.0)
// @param offsetY "Offset Y" range(-0.5, 0.5) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param colorCycles "Color Cycles" range(1.0, 5.0) default(2.0)
// @param colorOffset "Color Offset" range(0.0, 6.28) default(0.0)
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
// @param squareness "Squareness" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle roundCorners "Round Corners" default(false)
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
// @toggle stepped "Stepped" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = abs((uv - center) * 2.0);
p.x += offsetX;
p.y += offsetY;

if (pixelate > 0.5) p = floor(p * 50.0 / pixelSize) * pixelSize / 50.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float d;
if (roundCorners > 0.5) {
    d = length(p);
} else {
    d = max(p.x, p.y) * squareness + length(p) * (1.0 - squareness);
}
d = fract(d * scale - timeVal);

float3 col = 0.5 + 0.5 * cos(d * 6.28 * colorCycles + float3(0.0, 2.0, 4.0) + colorOffset);

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

let spiralGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 1.0) default(0.3)
// @param spiralTightness "Spiral Tightness" range(1.0, 10.0) default(3.0)
// @param arms "Arms" range(1.0, 8.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param colorCycles "Color Cycles" range(1.0, 5.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(1.0)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.0)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
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
// @param waveAmount "Wave Amount" range(0.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle twoColor "Two Color" default(false)
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
// @toggle hypnotic "Hypnotic" default(false)
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
float a = atan2(p.y, p.x) + rotation;
float spiral = fract(r * spiralTightness - a * arms / 6.28 + timeVal);

float3 col;
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(spiral * 6.28 * colorCycles + float3(0.0, 2.0, 4.0));
} else if (twoColor > 0.5) {
    float3 col1 = float3(color1Red, color1Green, color1Blue);
    float3 col2 = float3(color2Red, color2Green, color2Blue);
    col = mix(col1, col2, spiral);
} else {
    col = 0.5 + 0.5 * cos(spiral * 6.28 * colorCycles + float3(0.0, 2.0, 4.0));
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
