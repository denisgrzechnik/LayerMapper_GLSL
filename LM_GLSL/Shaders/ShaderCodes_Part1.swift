//
//  ShaderCodes.swift
//  LM_GLSL
//
//  All shader fragment codes - Part 1: Basic, Tunnels, Nature, Geometric
//

import Foundation

// MARK: - Basic Category

let rainbowGradientCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.2)
// @param frequency "Frequency" range(0.5, 10.0) default(6.28318)
// @param saturation "Saturation" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 1.0) default(0.5)
// @param phaseR "Phase Red" range(0.0, 1.0) default(0.0)
// @param phaseG "Phase Green" range(0.0, 1.0) default(0.33)
// @param phaseB "Phase Blue" range(0.0, 1.0) default(0.67)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param scale "Scale" range(0.1, 5.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param blendAmount "Blend Amount" range(0.0, 1.0) default(0.5)
// @param noiseScale "Noise Scale" range(0.1, 5.0) default(1.0)
// @param noiseSpeed "Noise Speed" range(0.0, 2.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @toggle horizontal "Horizontal" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle diagonal "Diagonal" default(false)
// @toggle radial "Radial" default(false)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle rainbow "Rainbow" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle neon "Neon" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 100.0 / pxSize) * pxSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + iTime), cos(p.x * 10.0 + iTime)) * distortion * 0.1;
}

p = (p + float2(offsetX, offsetY)) * scale;
float c = cos(rotation); float s = sin(rotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
p += 0.5;

float t = 0.0;
if (horizontal > 0.5) t += p.x;
if (vertical > 0.5) t += p.y;
if (diagonal > 0.5) t += (p.x + p.y) * 0.5;
if (radial > 0.5) t += length(p - 0.5);
if (t == 0.0) t = p.x;

if (mirror > 0.5) t = abs(t - 0.5) * 2.0;
if (waveAmplitude > 0.0) t += sin(p.y * waveFrequency + iTime * noiseSpeed) * waveAmplitude;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
t = t + timeVal;

if (stripes > 0.5) t = floor(t * 10.0) / 10.0;

float3 phase = float3(phaseR, phaseG, phaseB);
if (colorShift > 0.5) phase += iTime * colorSpeed;

// Hue shift
phase += hueShift * 6.28;

float3 col = saturation + brightness * cos(frequency * (t + phase));

// Apply contrast
col = (col - 0.5) * contrast + 0.5;

// Apply gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Glow effect
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom effect
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

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float2 dir = normalize(uv - center);
    col.r = saturation + brightness * cos(frequency * (t + 0.02 * chromaticAmount + phase.r));
    col.b = saturation + brightness * cos(frequency * (t - 0.02 * chromaticAmount + phase.b));
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
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

let plasmaCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(1.0, 20.0) default(8.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param complexity "Complexity" range(1.0, 5.0) default(1.0)
// @param colorShift "Color Shift" range(0.0, 6.28) default(0.0)
// @param redAmount "Red Amount" range(0.0, 2.0) default(1.0)
// @param greenAmount "Green Amount" range(0.0, 2.0) default(1.0)
// @param blueAmount "Blue Amount" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param blendMode "Blend Mode" range(0.0, 1.0) default(0.5)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueOffset "Hue Offset" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowDepth "Shadow Depth" range(0.0, 1.0) default(0.0)
// @param highlightPower "Highlight Power" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle radial "Radial" default(false)
// @toggle spiral "Spiral" default(false)
// @toggle waves "Waves" default(true)
// @toggle colorCycle "Color Cycle" default(false)
// @toggle invert "Invert" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle highContrast "High Contrast" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle grid "Grid" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle glow "Glow" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle fractal "Fractal" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * scale;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize);
    p = floor(p * 10.0 / pxSize) * pxSize / 10.0;
}

if (mirror > 0.5) p = abs(p);
if (kaleidoscope > 0.5) {
    float a = atan2(p.y, p.x);
    a = fmod(a, 0.785) - 0.393;
    float r = length(p);
    p = float2(cos(a), sin(a)) * r;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float morphTime = timeVal * morphSpeed;

float v = 0.0;
if (waves > 0.5) {
    v += sin(p.x * waveFrequency / 3.0 + timeVal) * waveAmplitude;
    v += sin(p.y * waveFrequency / 3.0 + timeVal * 0.5) * waveAmplitude;
    v += sin((p.x + p.y) * waveFrequency / 3.0 + timeVal * 0.3) * waveAmplitude;
}
if (radial > 0.5) v += sin(length(p) * complexity + timeVal);
if (spiral > 0.5) v += sin(atan2(p.y, p.x) * 3.0 + length(p) * 2.0 - timeVal);

// Fractal layers
if (fractal > 0.5) {
    float amp = 0.5;
    for (int i = 0; i < int(layers); i++) {
        v += sin(p.x * float(i + 1) + timeVal) * amp;
        v += sin(p.y * float(i + 1) * 1.3 + timeVal * 0.7) * amp;
        amp *= 0.5;
    }
}

v *= complexity;
if (turbulence > 0.0) v = abs(sin(v * 3.14159 * turbulence));
if (distortion > 0.0) v += sin(v * distortion * 10.0) * distortion;

float3 phase = float3(0.0, 2.0, 4.0) + colorShift + hueOffset * 6.28;
if (colorCycle > 0.5) phase += iTime * colorSpeed;

float3 col = 0.5 + 0.5 * cos(v + phase);
col *= float3(redAmount, greenAmount, blueAmount);

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 4.0);
if (invert > 0.5) col = 1.0 - col;
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.4;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Apply gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Glow effect
if (glow > 0.5) {
    float glowVal = exp(-length(uv - center) * 3.0) * glowIntensity;
    col += glowVal;
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 50.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float2 dir = uv - center;
    float3 colR = 0.5 + 0.5 * cos(v + phase + chromaticAmount * 10.0);
    float3 colB = 0.5 + 0.5 * cos(v + phase - chromaticAmount * 10.0);
    col.r = colR.r * redAmount;
    col.b = colB.b * blueAmount;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
}

// Shadow and highlight
col = col * (1.0 - shadowDepth * 0.5) + highlightPower * 0.2;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

if (grid > 0.5) {
    float2 g = abs(fract(uv * 10.0) - 0.5);
    col *= 0.8 + 0.2 * step(0.45, min(g.x, g.y));
}

if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 1.2;
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let noiseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(1.0, 50.0) default(10.0)
// @param speed "Speed" range(0.0, 5.0) default(1.0)
// @param grainSize "Grain Size" range(0.1, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 3.0) default(1.0)
// @param redTint "Red Tint" range(0.0, 2.0) default(1.0)
// @param greenTint "Green Tint" range(0.0, 2.0) default(1.0)
// @param blueTint "Blue Tint" range(0.0, 2.0) default(1.0)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(10.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param blendFactor "Blend Factor" range(0.0, 1.0) default(0.5)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param noiseOctaves "Noise Octaves" range(1.0, 8.0) default(3.0)
// @param lacunarity "Lacunarity" range(1.0, 4.0) default(2.0)
// @param persistence "Persistence" range(0.0, 1.0) default(0.5)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colored "Colored" default(false)
// @toggle smooth "Smooth" default(false)
// @toggle fractal "Fractal" default(false)
// @toggle cellular "Cellular" default(false)
// @toggle invert "Invert" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelated "Pixelated" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle film "Film Effect" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle waves "Waves" default(false)
// @toggle vortex "Vortex" default(false)
// @toggle grid "Grid" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle glow "Glow" default(false)
// @toggle neon "Neon" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle edgeGlow "Edge Glow" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// === NOWE EFEKTY - PRE-PROCESSING ===

// Pixelate (używa pixelSize zamiast pixelated toggle)
if (pixelated > 0.5) {
    float pxSize = max(pixelSize / 100.0, 0.01);
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float segments = 6.0;
    kAngle = fmod(kAngle, 6.28318 / segments);
    kAngle = abs(kAngle - 3.14159 / segments);
    float kRadius = length(kp);
    pos = float2(cos(kAngle), sin(kAngle)) * kRadius + 0.5;
}

// Mirror effect
if (mirror > 0.5) {
    pos = abs(pos - 0.5) + 0.5;
}

// Zoom and rotation around center
float2 center = float2(centerX, centerY);
float2 centered = pos - center;
float rotAngle = rotation + morphSpeed * timeVal;
float cosR = cos(rotAngle);
float sinR = sin(rotAngle);
centered = float2(centered.x * cosR - centered.y * sinR, centered.x * sinR + centered.y * cosR);
centered *= zoom;
pos = centered + center;

// === ORYGINALNA LOGIKA NOISE ===
float2 p = (pos + float2(offsetX, offsetY)) * scale;

if (vortex > 0.5) {
    float vAngle = atan2(p.y - scale * 0.5, p.x - scale * 0.5);
    p += float2(cos(vAngle), sin(vAngle)) * timeVal;
}

float n = 0.0;
float amplitude = 1.0;
float freq = 1.0;

int numLayers = int(layers);
for (int i = 0; i < 5; i++) {
    if (i >= numLayers) break;
    float2 noiseP = floor(p * freq * grainSize + timeVal);
    float layerNoise = fract(sin(dot(noiseP, float2(12.9898, 78.233))) * 43758.5453);
    
    if (smooth > 0.5) {
        float2 f = fract(p * freq * grainSize + timeVal);
        f = f * f * (3.0 - 2.0 * f);
        float2 noiseP2 = floor(p * freq * grainSize + timeVal);
        float nA = fract(sin(dot(noiseP2, float2(12.9898, 78.233))) * 43758.5453);
        float nB = fract(sin(dot(noiseP2 + float2(1.0, 0.0), float2(12.9898, 78.233))) * 43758.5453);
        float nC = fract(sin(dot(noiseP2 + float2(0.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
        float nD = fract(sin(dot(noiseP2 + float2(1.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
        layerNoise = mix(mix(nA, nB, f.x), mix(nC, nD, f.x), f.y);
    }
    
    n += layerNoise * amplitude;
    if (fractal < 0.5) break;
    amplitude *= 0.5;
    freq *= 2.0;
}

if (fractal > 0.5) n /= (2.0 - pow(0.5, float(numLayers)));
if (turbulence > 0.0) n = abs(n * 2.0 - 1.0) * turbulence + n * (1.0 - turbulence);

// Wave effect (używa waveFrequency i waveAmplitude)
if (waves > 0.5 || waveAmplitude > 0.01) {
    n += sin(pos.y * waveFrequency + timeVal * 2.0) * waveAmplitude;
}

n = (n - 0.5) * contrast + 0.5;
n *= brightness;

if (pulse > 0.5) n *= 0.8 + 0.2 * sin(timeVal * 3.0);

float3 col = float3(n);

if (colored > 0.5) {
    col = 0.5 + 0.5 * cos(n * 6.28 + float3(0.0, 2.0, 4.0) + timeVal * colorSpeed);
}
if (gradient > 0.5) {
    col *= mix(float3(0.2, 0.3, 0.8), float3(1.0, 0.5, 0.2), pos.y);
}

col *= float3(redTint, greenTint, blueTint);

// === NOWE EFEKTY - POST-PROCESSING ===

// Color shift (RGB → GBR)
if (colorShift > 0.5) {
    col = col.gbr;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift (Rodrigues rotation formula)
if (hueShift > 0.01) {
    float hAngle = hueShift * 6.28318;
    float3 k = float3(0.57735, 0.57735, 0.57735);
    float cosH = cos(hAngle);
    float sinH = sin(hAngle);
    col = col * cosH + cross(k, col) * sinH + k * dot(k, col) * (1.0 - cosH);
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.001) {
    float2 chromDir = (pos - 0.5) * chromaticAmount;
    col.r = col.r + chromDir.x * 2.0;
    col.b = col.b - chromDir.x * 2.0;
}

// Glow effect
if (glow > 0.5 && glowIntensity > 0.01) {
    col += col * glowIntensity;
}

// Neon effect
if (neon > 0.5) {
    float neonVal = pow(max(col.r, max(col.g, col.b)), 2.0);
    col += col * neonVal * 0.5;
}

if (invert > 0.5) col = 1.0 - col;

// Scanlines (używa scanlineIntensity)
if (scanlines > 0.5) {
    float scanVal = sin(pos.y * 500.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.5 * scanVal;
}

if (film > 0.5) {
    col = mix(col, float3(gray), 0.3);
    col *= float3(1.1, 1.0, 0.9);
}

// Bloom effect
if (bloom > 0.5 && bloomIntensity > 0.01) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    if (luma > bloomThreshold) {
        col += col * (luma - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

if (grid > 0.5) {
    float2 g = abs(fract(pos * 20.0) - 0.5);
    col *= 0.9 + 0.1 * step(0.4, min(g.x, g.y));
}

// Vignette (używa vignetteSize)
if (vignette > 0.5) {
    float vigDist = length(uv - 0.5);
    col *= 1.0 - vigDist * vignetteSize * 1.4;
}

// Edge fade
if (edgeFade > 0.01) {
    float2 edgeDist = min(uv, 1.0 - uv);
    float edgeVal = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= edgeVal;
}

// Gamma correction
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

// MARK: - Tunnels Category

let warpTunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(2.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 3.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param twistAmount "Twist Amount" range(0.0, 10.0) default(3.0)
// @param colorSpeed "Color Speed" range(0.0, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param fadeStart "Fade Start" range(0.0, 0.5) default(0.0)
// @param fadeEnd "Fade End" range(0.1, 1.0) default(0.3)
// @param ringWidth "Ring Width" range(0.1, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param depthIntensity "Depth Intensity" range(0.0, 2.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param colorIntensity "Color Intensity" range(0.0, 2.0) default(1.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param spiralTightness "Spiral Tightness" range(0.0, 2.0) default(1.0)
// @param tunnelDepth "Tunnel Depth" range(0.5, 3.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle rings "Rings" default(false)
// @toggle spiral "Spiral" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle fractal "Fractal" default(false)
// @toggle radialBlur "Radial Blur" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x);

// Apply rotation
float rot = timeVal * rotationSpeed + morphSpeed * sin(timeVal);
a += rot;

float v = (1.0 / (r * tunnelDepth + 0.001)) * patternScale + timeVal * speed;
if (spiral > 0.5) v += a * twistAmount * spiralTightness;

// Wave distortion
if (waveAmplitude > 0.0) {
    v += sin(a * waveFrequency + timeVal) * waveAmplitude;
}

// Distortion
if (distortAmount > 0.0) {
    v += sin(v * 5.0 + timeVal) * distortAmount;
}

if (rings > 0.5) v = floor(v * ringWidth * 5.0) / 5.0;
if (stripes > 0.5) v = floor(v * 10.0) / 10.0;

// Fractal layers
float fractalVal = 0.0;
if (fractal > 0.5) {
    for (int i = 0; i < int(layers); i++) {
        float layerV = v * pow(2.0, float(i));
        fractalVal += sin(layerV) / pow(2.0, float(i));
    }
    v = mix(v, fractalVal, 0.5);
}

float3 col;
if (colorful > 0.5) {
    float colorTime = timeVal * colorSpeed;
    col = 0.5 + 0.5 * cos(v + a * twistAmount + float3(0.0, 2.0, 4.0) + colorTime);
    col *= colorIntensity;
} else {
    col = float3(fract(v));
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.03;
    float vR = (1.0 / (r + offset + 0.001)) * patternScale + timeVal * speed;
    float vB = (1.0 / (r - offset + 0.001)) * patternScale + timeVal * speed;
    if (spiral > 0.5) {
        vR += a * twistAmount;
        vB += a * twistAmount;
    }
    col.r = 0.5 + 0.5 * cos(vR);
    col.b = 0.5 + 0.5 * cos(vB);
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 4.0);

// Glow effect
if (glow > 0.5) {
    float glowAmount = exp(-r * 3.0) * glowIntensity;
    col += glowAmount * float3(0.5, 0.5, 1.0);
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.5;

if (invert > 0.5) col = 1.0 - col;

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness * depthIntensity;
col *= smoothstep(fadeStart, fadeEnd, r);

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Radial blur effect
if (radialBlur > 0.5) {
    float blur = 0.0;
    for (int i = 0; i < 5; i++) {
        float scale = 1.0 - float(i) * 0.02;
        float2 blurP = pos * scale * 2.0 * zoom;
        float blurR = length(blurP);
        blur += 1.0 / (blurR + 0.001);
    }
    col *= 0.7 + 0.3 * (blur / 5.0);
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - r * vignetteSize * 0.6;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let starTunnelCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 5.0) default(1.0)
// @param starPoints "Star Points" range(3.0, 12.0) default(5.0)
// @param starSharpness "Star Sharpness" range(0.1, 2.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param colorR "Color R" range(0.0, 1.0) default(1.0)
// @param colorG "Color G" range(0.0, 1.0) default(0.8)
// @param colorB "Color B" range(0.0, 1.0) default(0.3)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param depthIntensity "Depth Intensity" range(0.0, 2.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.0)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param spiralTightness "Spiral Tightness" range(0.0, 2.0) default(1.0)
// @param tunnelDepth "Tunnel Depth" range(0.5, 3.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(false)
// @toggle reverse "Reverse" default(false)
// @toggle spiral "Spiral" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle glow "Glow" default(true)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle twinkle "Twinkle" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle fractal "Fractal" default(false)
// @toggle radialBlur "Radial Blur" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    float segments = 8.0;
    ka = fmod(ka, 6.28318 / segments);
    ka = abs(ka - 3.14159 / segments);
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x);

a += timeVal * rotationSpeed + morphSpeed * sin(timeVal);

float star = abs(cos(a * starPoints)) * starSharpness;
float tunnel = (1.0 / (r * tunnelDepth + 0.001)) * patternScale + timeVal * speed;

if (spiral > 0.5) tunnel += a * spiralTightness * 2.0;

// Wave distortion
if (waveAmplitude > 0.0) {
    tunnel += sin(a * waveFrequency + timeVal) * waveAmplitude;
}

// Distortion
if (distortAmount > 0.0) {
    tunnel += sin(tunnel * 5.0 + timeVal) * distortAmount;
}

float v = star * tunnel;
if (stripes > 0.5) v = floor(v * 8.0) / 8.0;

// Fractal layers
if (fractal > 0.5) {
    for (int i = 1; i < int(layers); i++) {
        float layerStar = abs(cos(a * starPoints * float(i + 1))) * starSharpness;
        v += layerStar * tunnel * 0.3 / float(i + 1);
    }
}

float3 baseColor = float3(colorR, colorG, colorB);
float3 col;

if (colorful > 0.5) {
    col = 0.5 + 0.5 * cos(v * 0.5 + timeVal * colorSpeed + float3(0.0, 2.0, 4.0));
} else {
    col = baseColor * fract(v);
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.1;
    float starR = abs(cos(a * starPoints + offset)) * starSharpness;
    float starB = abs(cos(a * starPoints - offset)) * starSharpness;
    col.r = fract(starR * tunnel) * baseColor.r;
    col.b = fract(starB * tunnel) * baseColor.b;
}

if (twinkle > 0.5) {
    float tw = sin(timeVal * 10.0 + a * 5.0) * 0.3 + 0.7;
    col *= tw;
}
if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);

// Glow effect
if (glow > 0.5) {
    float glowAmount = exp(-r * 2.0) * glowIntensity;
    col += glowAmount * baseColor;
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness * depthIntensity;

// Radial blur
if (radialBlur > 0.5) {
    float blur = 0.0;
    for (int i = 0; i < 5; i++) {
        float scale = 1.0 - float(i) * 0.02;
        float2 blurP = pos * scale * 2.0 * zoom;
        float blurR = length(blurP);
        blur += abs(cos(atan2(blurP.y, blurP.x) * starPoints)) / (blurR + 0.001);
    }
    col *= 0.7 + 0.3 * (blur / 5.0);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - r * vignetteSize * 0.8;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let hypnoticSpiralCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 10.0) default(3.0)
// @param spiralDensity "Spiral Density" range(1.0, 30.0) default(10.0)
// @param armCount "Arm Count" range(1.0, 10.0) default(3.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param colorIntensity "Color Intensity" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param waveAmount "Wave Amount" range(0.0, 5.0) default(5.0)
// @param pulseSpeed "Pulse Speed" range(0.0, 5.0) default(0.0)
// @param rotationOffset "Rotation Offset" range(0.0, 6.28) default(0.0)
// @param depthIntensity "Depth Intensity" range(0.0, 2.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param spiralTightness "Spiral Tightness" range(0.0, 2.0) default(1.0)
// @param tunnelDepth "Tunnel Depth" range(0.5, 3.0) default(1.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param twistIntensity "Twist Intensity" range(0.0, 2.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle inward "Inward" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle blackWhite "Black White" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle fractal "Fractal" default(false)
// @toggle radialBlur "Radial Blur" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    float segments = 6.0;
    ka = fmod(ka, 6.28318 / segments);
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x) + rotationOffset + morphSpeed * sin(timeVal);

float spiral = sin(r * spiralDensity * spiralTightness * patternScale - a * armCount * twistIntensity - timeVal * speed);
if (inward > 0.5) spiral = sin(r * spiralDensity * spiralTightness * patternScale + a * armCount * twistIntensity + timeVal * speed);

// Wave distortion
if (distortAmount > 0.0) {
    spiral += sin(r * waveFrequency + timeVal) * distortAmount;
}

if (stripes > 0.5) spiral = step(0.0, spiral);

// Fractal layers
if (fractal > 0.5) {
    for (int i = 1; i < int(layers); i++) {
        float layerSpiral = sin(r * spiralDensity * float(i + 1) - a * armCount - timeVal * speed);
        spiral += layerSpiral * 0.3 / float(i + 1);
    }
}

float pulseVal = 1.0;
if (pulse > 0.5) pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed);
if (pulseSpeed > 0.0) pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed);

float3 col;
if (blackWhite > 0.5) {
    col = float3(0.5 + 0.5 * spiral);
} else {
    col = float3(0.5 + 0.5 * spiral);
    if (colorful > 0.5) {
        float3 colorPhase = float3(0.0, 2.0, 4.0) + r * waveAmount + timeVal * colorSpeed;
        col *= colorIntensity + (1.0 - colorIntensity) * (0.5 + 0.5 * cos(colorPhase));
    }
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.1;
    float spiralR = sin(r * spiralDensity - a * armCount - timeVal * speed + offset);
    float spiralB = sin(r * spiralDensity - a * armCount - timeVal * speed - offset);
    col.r = 0.5 + 0.5 * spiralR;
    col.b = 0.5 + 0.5 * spiralB;
}

col *= pulseVal * depthIntensity;

// Glow effect
if (glow > 0.5) {
    float glowAmount = exp(-r * 2.0) * glowIntensity;
    col += glowAmount;
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Radial blur
if (radialBlur > 0.5) {
    float blur = 0.0;
    for (int i = 0; i < 5; i++) {
        float scale = 1.0 - float(i) * 0.02;
        float2 blurP = pos * scale * 2.0 * zoom;
        float blurR = length(blurP);
        float blurA = atan2(blurP.y, blurP.x);
        blur += sin(blurR * spiralDensity - blurA * armCount - timeVal * speed);
    }
    col *= 0.8 + 0.2 * (blur / 5.0 + 0.5);
}

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - r * vignetteSize * 0.6;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

// MARK: - Nature Category

let fireCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.5)
// @param intensity "Intensity" range(0.5, 3.0) default(1.0)
// @param turbulence "Turbulence" range(1.0, 10.0) default(3.0)
// @param height "Flame Height" range(0.5, 3.0) default(2.0)
// @param colorTemp "Color Temperature" range(0.0, 1.0) default(0.5)
// @param flameWidth "Flame Width" range(0.5, 2.0) default(1.0)
// @param noiseScale "Noise Scale" range(0.5, 5.0) default(1.0)
// @param flickerSpeed "Flicker Speed" range(0.0, 5.0) default(1.0)
// @param baseY "Base Y" range(0.0, 0.5) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param smokeAmount "Smoke Amount" range(0.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param emberSize "Ember Size" range(0.0, 1.0) default(0.5)
// @param emberDensity "Ember Density" range(0.0, 1.0) default(0.5)
// @param layers "Layers" range(1.0, 5.0) default(3.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param smokeDensity "Smoke Density" range(0.0, 1.0) default(0.3)
// @param smokeSpeed "Smoke Speed" range(0.0, 2.0) default(0.5)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle blueFlame "Blue Flame" default(false)
// @toggle greenFlame "Green Flame" default(false)
// @toggle purpleFlame "Purple Flame" default(false)
// @toggle embers "Embers" default(false)
// @toggle smoke "Smoke" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle intense "Intense" default(false)
// @toggle soft "Soft" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Extra Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle glow "Glow" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle radialBlur "Radial Blur" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * zoom + center;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

p.y += timeVal * speed + morphSpeed * sin(timeVal);

float n = 0.0;
float amp = intensity;
float2 freq = float2(turbulence, turbulence) * noiseScale * patternScale;

int numLayers = int(layers);
for (int i = 0; i < 5; i++) {
    if (i >= numLayers) break;
    float noiseVal = sin(p.x * freq.x * flameWidth + p.y * freq.y + timeVal * flickerSpeed);
    n += amp * (0.5 + 0.5 * noiseVal);
    freq *= 2.0;
    amp *= 0.5;
}

// Distortion
if (distortAmount > 0.0) {
    n += sin(n * 5.0 + timeVal) * distortAmount;
}

float fire = pow(max(0.0, 1.0 - (uv.y - baseY)), height) * n;
if (intense > 0.5) fire = pow(fire, 0.7) * 1.3;
if (soft > 0.5) fire = pow(fire, 1.5) * 0.8;

float3 coldColor, hotColor;
if (blueFlame > 0.5) {
    coldColor = float3(0.0, 0.0, 1.0);
    hotColor = float3(0.5, 0.8, 1.0);
} else if (greenFlame > 0.5) {
    coldColor = float3(0.0, 0.5, 0.0);
    hotColor = float3(0.5, 1.0, 0.3);
} else if (purpleFlame > 0.5) {
    coldColor = float3(0.5, 0.0, 0.5);
    hotColor = float3(1.0, 0.5, 1.0);
} else {
    coldColor = mix(float3(1.0, 0.0, 0.0), float3(1.0, 0.3, 0.0), colorTemp);
    hotColor = mix(float3(1.0, 0.5, 0.0), float3(1.0, 1.0, 0.0), colorTemp);
}

float3 col = mix(coldColor, hotColor, fire);
col = mix(float3(0.0), col, fire);

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Embers effect
if (embers > 0.5) {
    float ember = fract(sin(dot(floor(uv * 50.0 * emberDensity + timeVal * 2.0), float2(12.9898, 78.233))) * 43758.5453);
    ember = step(1.0 - emberSize * 0.1, ember) * fire * 2.0;
    col += float3(1.0, 0.6, 0.2) * ember;
}

// Smoke effect
if (smoke > 0.5 || smokeAmount > 0.0) {
    float smokeVal = pow(max(0.0, uv.y - 0.5), 0.5) * smokeAmount * smokeDensity;
    float smokeNoise = fract(sin(dot(floor(uv * 20.0 - timeVal * smokeSpeed), float2(12.9898, 78.233))) * 43758.5453);
    col += float3(0.3, 0.3, 0.35) * smokeVal * smokeNoise;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    float fireR = pow(max(0.0, 1.0 - (uv.y - baseY + offset)), height) * n;
    float fireB = pow(max(0.0, 1.0 - (uv.y - baseY - offset)), height) * n;
    col.r = mix(coldColor.r, hotColor.r, fireR) * fireR;
    col.b = mix(coldColor.b, hotColor.b, fireB) * fireB;
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(timeVal * 5.0);

// Glow effect
if (glow > 0.5) {
    float glowAmount = fire * glowIntensity;
    col += glowAmount * float3(0.3, 0.15, 0.0);
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Radial blur
if (radialBlur > 0.5) {
    float blur = 0.0;
    for (int i = 0; i < 5; i++) {
        float scale = 1.0 - float(i) * 0.03;
        float2 blurP = (pos * scale * zoom + center);
        blurP.y += timeVal * speed;
        float blurN = sin(blurP.x * turbulence * flameWidth + blurP.y * turbulence + timeVal * flickerSpeed);
        blur += pow(max(0.0, 1.0 - (uv.y - baseY)), height) * (0.5 + 0.5 * blurN);
    }
    col *= 0.7 + 0.3 * (blur / 5.0);
}

// Extra noise
if (noise > 0.5) {
    float noiseVal = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * 0.05;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let oceanWavesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveHeight "Wave Height" range(0.0, 0.3) default(0.1)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveLayers "Wave Layers" range(1.0, 8.0) default(5.0)
// @param deepColorR "Deep Color R" range(0.0, 0.5) default(0.0)
// @param deepColorG "Deep Color G" range(0.0, 0.5) default(0.2)
// @param deepColorB "Deep Color B" range(0.0, 1.0) default(0.4)
// @param surfaceColorR "Surface Color R" range(0.0, 0.5) default(0.0)
// @param surfaceColorG "Surface Color G" range(0.0, 1.0) default(0.5)
// @param surfaceColorB "Surface Color B" range(0.0, 1.0) default(0.8)
// @param foamAmount "Foam Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Extra Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param sunSize "Sun Size" range(0.0, 1.0) default(0.5)
// @param sunIntensity "Sun Intensity" range(0.0, 1.0) default(0.5)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle foam "Foam" default(true)
// @toggle sunReflection "Sun Reflection" default(false)
// @toggle storm "Storm" default(false)
// @toggle calm "Calm" default(false)
// @toggle tropical "Tropical" default(false)
// @toggle arctic "Arctic" default(false)
// @toggle sunset "Sunset" default(false)
// @toggle caustics "Caustics" default(false)
// @toggle bubbles "Bubbles" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle depth "Depth" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle glow "Glow" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * zoom + center;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float heightMult = storm > 0.5 ? 2.0 : (calm > 0.5 ? 0.3 : 1.0);
float speedMult = storm > 0.5 ? 2.0 : (calm > 0.5 ? 0.5 : 1.0);

// Morph effect
float morphOffset = morphSpeed * sin(timeVal * 0.5);

float wave = 0.0;
int numLayers = int(waveLayers);
for (int i = 0; i < 8; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    float freq = (waveFrequency + fi) * patternScale;
    float spd = (1.0 + fi * 0.2) * speed * speedMult;
    wave += sin(p.x * freq + timeVal * spd + fi + morphOffset) * waveHeight * heightMult / (fi + 1.0);
}

// Distortion
if (distortAmount > 0.0) {
    wave += sin(wave * 5.0 + timeVal * colorSpeed) * distortAmount * 0.1;
}

float water = smoothstep(0.0, 0.02, wave + 0.5 - p.y);

float3 deepColor = float3(deepColorR, deepColorG, deepColorB);
float3 surfaceColor = float3(surfaceColorR, surfaceColorG, surfaceColorB);

if (tropical > 0.5) {
    deepColor = float3(0.0, 0.3, 0.4);
    surfaceColor = float3(0.0, 0.8, 0.7);
} else if (arctic > 0.5) {
    deepColor = float3(0.1, 0.2, 0.3);
    surfaceColor = float3(0.6, 0.8, 0.9);
} else if (sunset > 0.5) {
    deepColor = float3(0.2, 0.1, 0.3);
    surfaceColor = float3(1.0, 0.5, 0.3);
}

float3 col = mix(deepColor, surfaceColor, water);

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

if (depth > 0.5) {
    col += float3(0.3, 0.4, 0.5) * (1.0 - p.y) * 0.5;
}

if (foam > 0.5) {
    float foamLine = smoothstep(0.02, 0.0, abs(wave + 0.5 - p.y)) * foamAmount;
    col = mix(col, float3(1.0), foamLine);
}

if (sunReflection > 0.5) {
    float sun = exp(-pow((p.x - 0.5) * (3.0 / sunSize), 2.0)) * (1.0 - p.y) * sunIntensity;
    sun *= 0.7 + 0.3 * sin(timeVal * 2.0 + p.x * 10.0);
    col += float3(1.0, 0.9, 0.7) * sun;
}

if (caustics > 0.5) {
    float caustic = sin(p.x * 20.0 + timeVal) * sin(p.y * 20.0 + timeVal * 0.7);
    col += float3(0.1, 0.2, 0.3) * caustic * 0.2 * (1.0 - p.y);
}

if (bubbles > 0.5) {
    float bubble = fract(sin(dot(floor(p * 30.0 + timeVal), float2(12.9898, 78.233))) * 43758.5453);
    bubble = step(0.95, bubble) * (1.0 - p.y);
    col += float3(0.5, 0.7, 1.0) * bubble;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.01;
    float waveR = 0.0;
    float waveB = 0.0;
    for (int i = 0; i < numLayers; i++) {
        float fi = float(i);
        float freq = (waveFrequency + fi) * patternScale;
        float spd = (1.0 + fi * 0.2) * speed * speedMult;
        waveR += sin((p.x + offset) * freq + timeVal * spd + fi) * waveHeight * heightMult / (fi + 1.0);
        waveB += sin((p.x - offset) * freq + timeVal * spd + fi) * waveHeight * heightMult / (fi + 1.0);
    }
    float waterR = smoothstep(0.0, 0.02, waveR + 0.5 - p.y);
    float waterB = smoothstep(0.0, 0.02, waveB + 0.5 - p.y);
    col.r = mix(deepColor.r, surfaceColor.r, waterR);
    col.b = mix(deepColor.b, surfaceColor.b, waterB);
}

// Glow effect
if (glow > 0.5) {
    float glowAmount = water * glowIntensity * 0.3;
    col += glowAmount * surfaceColor;
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noiseAmount > 0.0) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 0.8;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let auroraCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveHeight "Wave Height" range(0.0, 0.3) default(0.1)
// @param layerCount "Layer Count" range(1.0, 10.0) default(5.0)
// @param glowIntensity "Glow Intensity" range(0.0, 0.5) default(0.3)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param baseY "Base Y" range(0.3, 0.7) default(0.5)
// @param layerSpacing "Layer Spacing" range(0.02, 0.15) default(0.08)
// @param skyDarkness "Sky Darkness" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param curtainWidth "Curtain Width" range(0.0, 1.0) default(0.5)
// @param curtainSpeed "Curtain Speed" range(0.0, 2.0) default(0.5)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param shimmerSpeed "Shimmer Speed" range(0.0, 5.0) default(1.0)
// @param shimmerIntensity "Shimmer Intensity" range(0.0, 1.0) default(0.3)
// @param starTwinkle "Star Twinkle" range(0.0, 1.0) default(0.5)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle greenDominant "Green Dominant" default(false)
// @toggle pinkDominant "Pink Dominant" default(false)
// @toggle blueDominant "Blue Dominant" default(false)
// @toggle stars "Stars" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle curtain "Curtain" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle shimmer "Shimmer" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle intense "Intense" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle glow "Glow" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * zoom + center;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (vertical > 0.5) p = p.yx;

float3 col = float3(0.0, skyDarkness, skyDarkness * 2.5);

// Stars
if (stars > 0.5 || starDensity > 0.0) {
    float star = fract(sin(dot(floor(uv * 200.0), float2(12.9898, 78.233))) * 43758.5453);
    float threshold = 0.99 - starDensity * 0.05;
    if (star > threshold) {
        float twinkle = 0.5 + 0.5 * sin(timeVal * 5.0 * starTwinkle + star * 100.0);
        col += float3(1.0) * twinkle * (star - threshold) * 50.0;
    }
}

int numLayers = int(layerCount);
for (int i = 0; i < 10; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    
    float wave = sin(p.x * waveFrequency * patternScale + timeVal * speed + fi + morphSpeed * sin(timeVal)) * waveHeight + baseY + fi * layerSpacing;
    
    // Distortion
    if (distortAmount > 0.0) {
        wave += sin(wave * 5.0 + timeVal) * distortAmount * 0.1;
    }
    
    if (curtain > 0.5) {
        wave += sin(p.x * 20.0 * curtainWidth + timeVal * 3.0 * curtainSpeed + fi * 2.0) * 0.02;
    }
    
    float glowWidth = 0.1;
    if (intense > 0.5) glowWidth = 0.15;
    float auroraGlow = smoothstep(glowWidth, 0.0, abs(p.y - wave));
    
    float3 auroraCol;
    if (greenDominant > 0.5) {
        auroraCol = float3(0.2, 1.0, 0.4);
    } else if (pinkDominant > 0.5) {
        auroraCol = float3(1.0, 0.3, 0.6);
    } else if (blueDominant > 0.5) {
        auroraCol = float3(0.2, 0.5, 1.0);
    } else if (colorful > 0.5) {
        auroraCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        auroraCol = float3(0.3, 0.8, 0.4);
    }
    
    // Color balance
    auroraCol.r += colorBalance * 0.2;
    auroraCol.b -= colorBalance * 0.2;
    
    if (shimmer > 0.5) {
        float shimmerVal = (1.0 - shimmerIntensity * 0.3) + shimmerIntensity * 0.3 * sin(p.x * 30.0 + timeVal * shimmerSpeed + fi * 3.0);
        auroraCol *= shimmerVal;
    }
    
    col += auroraGlow * auroraCol * glowIntensity;
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.01;
    float waveR = sin((p.x + offset) * waveFrequency + timeVal * speed) * waveHeight + baseY;
    float waveB = sin((p.x - offset) * waveFrequency + timeVal * speed) * waveHeight + baseY;
    col.r += smoothstep(0.1, 0.0, abs(p.y - waveR)) * 0.3;
    col.b += smoothstep(0.1, 0.0, abs(p.y - waveB)) * 0.3;
}

// Glow effect
if (glow > 0.5) {
    float glowAmount = (1.0 - abs(p.y - baseY)) * glowIntensity * 0.2;
    col += glowAmount * float3(0.3, 0.8, 0.4);
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 2.0);

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noiseAmount > 0.0) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize * 0.8;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let electricStormCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 10.0) default(5.0)
// @param boltCount "Bolt Count" range(1.0, 10.0) default(5.0)
// @param boltWidth "Bolt Width" range(0.01, 0.1) default(0.02)
// @param zigzagAmount "Zigzag Amount" range(0.0, 0.5) default(0.2)
// @param flashIntensity "Flash Intensity" range(0.0, 1.0) default(0.5)
// @param flashFrequency "Flash Frequency" range(1.0, 20.0) default(10.0)
// @param colorR "Color R" range(0.0, 1.0) default(0.5)
// @param colorG "Color G" range(0.0, 1.0) default(0.5)
// @param colorB "Color B" range(0.0, 1.0) default(1.0)
// @param skyDarkness "Sky Darkness" range(0.0, 0.1) default(0.02)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rainDensity "Rain Density" range(0.0, 1.0) default(0.5)
// @param rainSpeed "Rain Speed" range(0.0, 2.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param cloudDensity "Cloud Density" range(0.0, 1.0) default(0.3)
// @param cloudSpeed "Cloud Speed" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle flash "Background Flash" default(true)
// @toggle branching "Branching" default(false)
// @toggle horizontal "Horizontal" default(false)
// @toggle purple "Purple" default(false)
// @toggle orange "Orange" default(false)
// @toggle green "Green" default(false)
// @toggle rain "Rain" default(false)
// @toggle clouds "Clouds" default(false)
// @toggle glow "Glow" default(true)
// @toggle mirror "Mirror" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = pos * zoom * 2.0;
if (mirror > 0.5) p.x = abs(p.x);
if (horizontal > 0.5) p = p.yx;

float3 col = float3(skyDarkness, skyDarkness, skyDarkness * 2.5);

// Clouds
if (clouds > 0.5) {
    float cloud = fract(sin(dot(floor(uv * 10.0 + timeVal * cloudSpeed), float2(12.9898, 78.233))) * 43758.5453);
    cloud = smoothstep(0.4 - cloudDensity * 0.3, 0.6 + cloudDensity * 0.3, cloud) * 0.1;
    col += float3(cloud);
}

float flash = step(1.0 - (1.0 / flashFrequency), fract(sin(floor(timeVal * flashFrequency) * 43.758) * 43758.5453));

float3 boltColor = float3(colorR, colorG, colorB);
if (purple > 0.5) boltColor = float3(0.7, 0.3, 1.0);
if (orange > 0.5) boltColor = float3(1.0, 0.6, 0.2);
if (green > 0.5) boltColor = float3(0.3, 1.0, 0.5);

// Color shift
if (colorShift > 0.5) {
    boltColor = boltColor.gbr;
}

int numBolts = int(boltCount);
int numLayers = int(layers);
for (int i = 0; i < 10; i++) {
    if (i >= numBolts) break;
    float fi = float(i);
    float x = sin(p.y * 10.0 * patternScale + timeVal * speed + fi * 2.0 + morphSpeed * sin(timeVal)) * zigzagAmount;
    
    // Distortion
    if (distortAmount > 0.0) {
        x += sin(p.y * 20.0 + timeVal) * distortAmount * 0.1;
    }
    
    if (branching > 0.5 && i > 0) {
        x += sin(p.y * 20.0 + fi * 5.0) * zigzagAmount * 0.3;
    }
    
    float bolt = smoothstep(boltWidth, 0.0, abs(p.x - x - (fi - float(numBolts) / 2.0) * 0.3));
    
    // Glow effect
    if (glow > 0.5) {
        float glowBolt = exp(-abs(p.x - x - (fi - float(numBolts) / 2.0) * 0.3) * 10.0) * glowIntensity;
        col += glowBolt * boltColor;
    }
    
    col += bolt * boltColor * (flashIntensity + flash * (1.0 - flashIntensity));
}

if (flash > 0.5) {
    col += float3(0.2, 0.2, 0.3) * flashIntensity;
}

// Rain
if (rain > 0.5) {
    float rainDrop = fract(sin(dot(floor(uv * float2(100.0 * rainDensity, 20.0) + float2(0.0, timeVal * 10.0 * rainSpeed)), float2(12.9898, 78.233))) * 43758.5453);
    rainDrop = step(0.97, rainDrop);
    col += float3(0.3, 0.4, 0.5) * rainDrop * 0.5;
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    float xR = sin(p.y * 10.0 * patternScale + timeVal * speed + offset) * zigzagAmount;
    float xB = sin(p.y * 10.0 * patternScale + timeVal * speed - offset) * zigzagAmount;
    col.r += smoothstep(boltWidth, 0.0, abs(p.x - xR)) * boltColor.r;
    col.b += smoothstep(boltWidth, 0.0, abs(p.x - xB)) * boltColor.b;
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noiseAmount > 0.0) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

// MARK: - Geometric Category

let kaleidoscopeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param segments "Segments" range(2.0, 16.0) default(8.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param zoom "Zoom" range(0.5, 5.0) default(1.0)
// @param patternScale "Pattern Scale" range(1.0, 20.0) default(10.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param patternComplexity "Pattern Complexity" range(1.0, 5.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param spinSpeed "Spin Speed" range(0.0, 2.0) default(0.5)
// @param mirrorOffset "Mirror Offset" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param fractalDepth "Fractal Depth" range(1.0, 5.0) default(1.0)
// @param symmetryOffset "Symmetry Offset" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle spinning "Spinning" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle waves "Waves" default(false)
// @toggle circles "Circles" default(false)
// @toggle diamonds "Diamonds" default(false)
// @toggle psychedelic "Psychedelic" default(false)
// @toggle stripes "Stripes" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle fractal "Fractal" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle radialBlur "Radial Blur" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

float2 p = pos * 2.0 * zoom;

float spinAngle = spinning > 0.5 ? timeVal * spinSpeed : 0.0;
float c = cos(spinAngle + rotation + morphSpeed * sin(timeVal));
float s = sin(spinAngle + rotation + morphSpeed * sin(timeVal));
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float a = atan2(p.y, p.x);
float segmentAngle = 6.28318 / segments;
a = fmod(a + symmetryOffset * segmentAngle, segmentAngle);
if (mirror > 0.5) a = abs(a - segmentAngle * 0.5) + mirrorOffset * 0.1;

float r = length(p);
float2 np = float2(cos(a), sin(a)) * r;

// Wave distortion
if (waveAmplitude > 0.0) {
    np += sin(np * waveFrequency + timeVal) * waveAmplitude * 0.1;
}

// Distortion
if (distortAmount > 0.0) {
    np += sin(np * 5.0 + timeVal) * distortAmount * 0.1;
}

float pattern = 0.0;
if (circles > 0.5) {
    pattern = sin(r * patternScale + timeVal * speed);
} else if (diamonds > 0.5) {
    pattern = sin((abs(np.x) + abs(np.y)) * patternScale + timeVal * speed);
} else if (stripes > 0.5) {
    pattern = sin(np.x * patternScale + timeVal * speed);
} else {
    pattern = sin(np.x * patternScale + np.y * patternScale + timeVal * speed);
}

if (waves > 0.5) {
    pattern += sin(r * 5.0 - timeVal * 2.0) * 0.3;
}

// Fractal layers
if (fractal > 0.5) {
    for (int i = 1; i < int(fractalDepth); i++) {
        float layerPattern = sin(np.x * patternScale * float(i + 1) + np.y * patternScale * float(i + 1) + timeVal * speed);
        pattern += layerPattern * 0.5 / float(i + 1);
    }
}

pattern *= patternComplexity;

float3 col;
if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (psychedelic > 0.5) {
        colorPhase += pattern * 2.0;
    }
    col = 0.5 + 0.5 * cos(pattern + colorPhase);
} else {
    col = float3(0.5 + 0.5 * pattern);
}

col = mix(float3(0.5), col, colorMix + 0.5);

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    float patternR = sin((np.x + offset) * patternScale + np.y * patternScale + timeVal * speed);
    float patternB = sin((np.x - offset) * patternScale + np.y * patternScale + timeVal * speed);
    col.r = 0.5 + 0.5 * patternR;
    col.b = 0.5 + 0.5 * patternB;
}

// Glow effect
if (glow > 0.5) {
    float glowAmount = exp(-r * 2.0) * glowIntensity;
    col += glowAmount;
}

// Radial blur
if (radialBlur > 0.5) {
    float blur = 0.0;
    for (int i = 0; i < 5; i++) {
        float scale = 1.0 - float(i) * 0.02;
        float2 blurP = pos * scale * 2.0 * zoom;
        float blurR = length(blurP);
        blur += sin(blurR * patternScale + timeVal * speed);
    }
    col *= 0.8 + 0.2 * (blur / 5.0 + 0.5);
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - r * vignetteSize * 0.6;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let hexagonGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(2.0, 30.0) default(10.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.02)
// @param hexSize "Hex Size" range(0.2, 0.5) default(0.4)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.5)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param fillAmount "Fill Amount" range(0.0, 1.0) default(1.0)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param hexBorder "Hex Border" range(0.0, 0.1) default(0.02)
// @param hexSpacing "Hex Spacing" range(0.0, 0.5) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle outline "Outline Only" default(false)
// @toggle filled "Filled" default(true)
// @toggle wave "Wave" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle grid "Grid" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

float2 p = (pos * zoom + center + float2(offsetX, offsetY)) * scale;

float co = cos(rotation + morphSpeed * sin(timeVal));
float si = sin(rotation + morphSpeed * sin(timeVal));
p = float2(p.x * co - p.y * si, p.x * si + p.y * co);

if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

// Wave distortion
if (waveAmplitude > 0.0) {
    p += sin(p * waveFrequency + timeVal) * waveAmplitude;
}

// Distortion
if (distortAmount > 0.0) {
    p += sin(p * 5.0 + timeVal) * distortAmount;
}

float2 h = float2(1.0 + hexSpacing, 1.732 + hexSpacing);
float2 a = fmod(p, h) - h * 0.5;
float2 b = fmod(p + h * 0.5, h) - h * 0.5;
float2 g = length(a) < length(b) ? a : b;

float d = max(abs(g.x), abs(g.y) * 0.577 + abs(g.x) * 0.5);

float hexSizeAnim = hexSize;
if (wave > 0.5) {
    float2 hexId = floor(p / h);
    hexSizeAnim += sin(hexId.x * 0.5 + hexId.y * 0.5 + timeVal * speed) * 0.1;
}
if (pulse > 0.5) {
    hexSizeAnim += sin(timeVal * 3.0) * 0.05;
}

float hex;
float borderWidth = lineWidth + hexBorder;
if (outline > 0.5) {
    hex = smoothstep(hexSizeAnim + borderWidth, hexSizeAnim, d) - smoothstep(hexSizeAnim, hexSizeAnim - borderWidth, d);
} else if (filled > 0.5) {
    hex = smoothstep(hexSizeAnim, hexSizeAnim - borderWidth, d) * fillAmount;
} else {
    hex = smoothstep(hexSizeAnim, hexSizeAnim - borderWidth, d);
}

float2 hexId = floor(p / h);
float3 col;

if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (rainbow > 0.5) {
        colorPhase += hexId.x * 0.2 + hexId.y * 0.3;
    } else {
        colorPhase += p.x * 0.5 / scale;
    }
    col = hex * (0.5 + 0.5 * cos(colorPhase));
} else {
    col = float3(hex);
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

if (gradient > 0.5) {
    col *= mix(float3(0.5, 0.7, 1.0), float3(1.0, 0.5, 0.7), uv.y);
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    float2 pR = p + float2(offset, 0.0);
    float2 pB = p - float2(offset, 0.0);
    float2 gR = length(fmod(pR, h) - h * 0.5) < length(fmod(pR + h * 0.5, h) - h * 0.5) ? mod(pR, h) - h * 0.5 : mod(pR + h * 0.5, h) - h * 0.5;
    float2 gB = length(fmod(pB, h) - h * 0.5) < length(fmod(pB + h * 0.5, h) - h * 0.5) ? mod(pB, h) - h * 0.5 : mod(pB + h * 0.5, h) - h * 0.5;
    float dR = max(abs(gR.x), abs(gR.y) * 0.577 + abs(gR.x) * 0.5);
    float dB = max(abs(gB.x), abs(gB.y) * 0.577 + abs(gB.x) * 0.5);
    col.r = smoothstep(hexSizeAnim, hexSizeAnim - borderWidth, dR);
    col.b = smoothstep(hexSizeAnim, hexSizeAnim - borderWidth, dB);
}

// Glow effect
if (glow > 0.5 || glowAmount > 0.0) {
    float glowVal = exp(-d * 5.0) * (glow > 0.5 ? glowIntensity : glowAmount);
    col += glowVal * float3(0.3, 0.5, 1.0);
}

if (grid > 0.5) {
    float2 gridLines = abs(fract(p) - 0.5);
    float gridLine = step(0.48, min(gridLines.x, gridLines.y));
    col = mix(col, float3(0.3), gridLine * 0.5);
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let voronoiCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(1.0, 15.0) default(5.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param cellMovement "Cell Movement" range(0.0, 1.0) default(0.3)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param edgeWidth "Edge Width" range(0.0, 0.5) default(0.0)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param cellCount "Cell Count" range(1.0, 5.0) default(3.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param smoothness "Smoothness" range(0.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param cellBorder "Cell Border" range(0.0, 0.1) default(0.02)
// @param cellGrowth "Cell Growth" range(0.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle edges "Edges" default(false)
// @toggle cellColor "Cell Color" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle cracked "Cracked" default(false)
// @toggle organic "Organic" default(false)
// @toggle crystal "Crystal" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

// Rotation
float co = cos(rotation + morphSpeed * sin(timeVal));
float si = sin(rotation + morphSpeed * sin(timeVal));
pos = float2(pos.x * co - pos.y * si, pos.x * si + pos.y * co);

float2 p = (pos * zoom + center + float2(offsetX, offsetY)) * scale;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

// Wave distortion
if (waveAmplitude > 0.0) {
    p += sin(p * waveFrequency + timeVal) * waveAmplitude;
}

// Distortion
if (distortAmount > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortAmount;
}

float minDist = 1.0;
float secondMinDist = 1.0;
float2 closestCell = float2(0.0);

int cells = int(cellCount);
int gridSize = cells * cells;
for (int i = 0; i < 25; i++) {
    if (i >= gridSize) break;
    float2 cell = float2(float(i % cells), float(i / cells));
    float2 cellOffset = 0.5 + cellMovement * sin(timeVal * speed + cell * 5.0);
    
    // Cell growth animation
    if (cellGrowth > 0.0) {
        cellOffset *= 1.0 + cellGrowth * sin(timeVal * 2.0 + cell.x + cell.y);
    }
    
    if (organic > 0.5) {
        cellOffset += float2(sin(timeVal + cell.x * 3.0), cos(timeVal * 0.7 + cell.y * 2.0)) * 0.2;
    }
    float2 cellCenter = cell + cellOffset;
    float d = length(fract(p) - cellCenter + cell - floor(p));
    
    if (d < minDist) {
        secondMinDist = minDist;
        minDist = d;
        closestCell = cell;
    } else if (d < secondMinDist) {
        secondMinDist = d;
    }
}

float val = minDist;
if (smoothness > 0.0) {
    val = smoothstep(0.0, smoothness, minDist);
}

float3 col;
if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (cellColor > 0.5) {
        colorPhase += closestCell.x + closestCell.y;
    } else {
        colorPhase += val * 10.0;
    }
    col = 0.5 + 0.5 * cos(colorPhase);
} else {
    col = float3(val);
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

if (edges > 0.5 || edgeWidth > 0.0) {
    float borderWidth = edgeWidth + cellBorder;
    float edge = smoothstep(borderWidth, borderWidth + 0.02, secondMinDist - minDist);
    if (cracked > 0.5) {
        col = mix(float3(0.0), col, edge);
    } else {
        col *= edge;
    }
}

if (crystal > 0.5) {
    col *= 0.7 + 0.3 * sin(minDist * 20.0);
}

if (gradient > 0.5) {
    col *= mix(float3(0.5, 0.7, 1.0), float3(1.0, 0.5, 0.7), uv.y);
}

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    float2 pR = (pos * zoom + center + float2(offsetX + offset, offsetY)) * scale;
    float2 pB = (pos * zoom + center + float2(offsetX - offset, offsetY)) * scale;
    float minDistR = 1.0, minDistB = 1.0;
    for (int i = 0; i < gridSize && i < 25; i++) {
        float2 cell = float2(float(i % cells), float(i / cells));
        float2 cellOffset = 0.5 + cellMovement * sin(timeVal * speed + cell * 5.0);
        float2 cellCenter = cell + cellOffset;
        float dR = length(fract(pR) - cellCenter + cell - floor(pR));
        float dB = length(fract(pB) - cellCenter + cell - floor(pB));
        if (dR < minDistR) minDistR = dR;
        if (dB < minDistB) minDistB = dB;
    }
    col.r = 0.5 + 0.5 * cos(minDistR * 10.0);
    col.b = 0.5 + 0.5 * cos(minDistB * 10.0 + 4.0);
}

// Glow effect
if (glow > 0.5) {
    float glowAmount = exp(-minDist * 5.0) * glowIntensity;
    col += glowAmount;
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let fractalCirclesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param circleCount "Circle Count" range(2.0, 15.0) default(8.0)
// @param baseRadius "Base Radius" range(0.1, 1.0) default(0.5)
// @param movementRange "Movement Range" range(0.0, 0.8) default(0.3)
// @param thickness "Thickness" range(0.005, 0.1) default(0.02)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param overlap "Overlap" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param orbitSpeed "Orbit Speed" range(0.0, 2.0) default(0.5)
// @param orbitRadius "Orbit Radius" range(0.0, 1.0) default(0.3)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle filled "Filled" default(false)
// @toggle rings "Rings" default(true)
// @toggle spiral "Spiral" default(false)
// @toggle orbit "Orbit" default(false)
// @toggle random "Random" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle blend "Blend" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 center = float2(centerX, centerY);
float2 pos = uv - center;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = pixelSize / 100.0;
    pos = floor(pos / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float ka = atan2(pos.y, pos.x);
    ka = fmod(ka, 0.523) - 0.262;
    pos = float2(cos(ka), sin(ka)) * length(pos);
}

// Rotation
float co = cos(rotation + morphSpeed * sin(timeVal));
float si = sin(rotation + morphSpeed * sin(timeVal));
pos = float2(pos.x * co - pos.y * si, pos.x * si + pos.y * co);

float2 p = pos * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

// Wave distortion
if (waveAmplitude > 0.0) {
    p += sin(p * waveFrequency + timeVal) * waveAmplitude * 0.1;
}

// Distortion
if (distortAmount > 0.0) {
    p += sin(p * 5.0 + timeVal) * distortAmount * 0.1;
}

float3 col = float3(0.0);
int numCircles = int(circleCount);
int numLayers = int(layers);

for (int layer = 0; layer < 5; layer++) {
    if (layer >= numLayers) break;
    float layerOffset = float(layer) * 0.1;
    
    for (int i = 0; i < 15; i++) {
        if (i >= numCircles) break;
        float fi = float(i);
        float r = baseRadius / (fi + 1.0);
        
        float2 offset;
        if (spiral > 0.5) {
            float angle = fi * 0.7 + timeVal * speed;
            float dist = fi * 0.05 * movementRange;
            offset = float2(cos(angle), sin(angle)) * dist;
        } else if (orbit > 0.5) {
            float angle = timeVal * orbitSpeed + fi * 1.0;
            offset = float2(cos(angle), sin(angle)) * orbitRadius;
        } else if (random > 0.5) {
            float seed = fi * 123.456;
            offset = float2(
                sin(timeVal * speed + seed) * sin(seed * 2.0),
                cos(timeVal * speed * 0.7 + seed) * cos(seed * 3.0)
            ) * movementRange;
        } else {
            offset = float2(sin(timeVal * speed + fi), cos(timeVal * speed * 0.7 + fi)) * movementRange;
        }
        
        offset += float2(layerOffset);
        
        float rAnim = r;
        if (pulse > 0.5) {
            rAnim *= 0.8 + 0.2 * sin(timeVal * 3.0 + fi);
        }
        
        float d = length(p - offset);
        float circle;
        
        if (filled > 0.5) {
            circle = smoothstep(rAnim, rAnim - thickness, d);
        } else if (rings > 0.5) {
            circle = smoothstep(rAnim, rAnim - thickness, d) - smoothstep(rAnim - thickness, rAnim - thickness * 2.0, d);
        } else {
            circle = smoothstep(thickness, 0.0, abs(d - rAnim));
        }
        
        float3 circleColor;
        if (colorful > 0.5) {
            circleColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.5 + timeVal * colorSpeed + float(layer));
        } else {
            circleColor = float3(1.0);
        }
        
        // Glow effect
        if (glow > 0.5) {
            float glowVal = exp(-d * 3.0) * glowIntensity;
            circleColor += glowVal;
        }
        
        if (blend > 0.5) {
            col += circle * circleColor * overlap / float(numLayers);
        } else {
            col = mix(col, circleColor, circle);
        }
    }
}

// Color shift
if (colorShift > 0.5) {
    col = col.gbr;
}

// Color balance
col.r += colorBalance * 0.1;
col.b -= colorBalance * 0.1;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float angle = hueShift * 6.28;
    float3x3 hueMatrix = float3x3(
        0.213 + cos(angle) * 0.787 - sin(angle) * 0.213,
        0.715 - cos(angle) * 0.715 - sin(angle) * 0.715,
        0.072 - cos(angle) * 0.072 + sin(angle) * 0.928,
        0.213 - cos(angle) * 0.213 + sin(angle) * 0.143,
        0.715 + cos(angle) * 0.285 + sin(angle) * 0.140,
        0.072 - cos(angle) * 0.072 - sin(angle) * 0.283,
        0.213 - cos(angle) * 0.213 - sin(angle) * 0.787,
        0.715 - cos(angle) * 0.715 + sin(angle) * 0.715,
        0.072 + cos(angle) * 0.928 + sin(angle) * 0.072
    );
    col = col * hueMatrix;
}

// Chromatic aberration
if (chromatic > 0.5) {
    float offset = chromaticAmount + 0.02;
    col.r = col.r * (1.0 + offset);
    col.b = col.b * (1.0 - offset);
}

// Neon effect
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Noise
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines
if (scanlines > 0.5) {
    float scanline = 0.9 + 0.1 * sin(uv.y * 400.0 * scanlineIntensity);
    col *= scanline;
}

// Bloom effect
if (bloom > 0.5) {
    float luma = dot(col, float3(0.299, 0.587, 0.114));
    float bloomMask = smoothstep(bloomThreshold, 1.0, luma);
    col += col * bloomMask * bloomIntensity;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Vignette
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * vignetteSize;

// Edge fade
if (edgeFade > 0.0) {
    float edge = smoothstep(0.0, edgeFade, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    col *= edge;
}

// Gamma correction
col = pow(col, float3(1.0 / gamma));

col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let infiniteCubesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param cubeCount "Cube Count" range(3.0, 20.0) default(10.0)
// @param lineWidth "Line Width" range(0.005, 0.05) default(0.02)
// @param cubeSize "Cube Size" range(0.2, 0.8) default(0.5)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param depth "Depth" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.5)
// @param perspectiveDepth "Perspective Depth" range(0.5, 2.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle filled "Filled" default(false)
// @toggle rotating "Rotating" default(false)
// @toggle alternating "Alternating" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle circles "Circles" default(false)
// @toggle diamonds "Diamonds" default(false)
// @toggle stars "Stars" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pSize = max(pixelSize, 1.0);
    pos = floor(pos * 100.0 / pSize) * pSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float angle = atan2(kp.y, kp.x);
    float segments = 6.0;
    angle = fmod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float r = length(kp);
    pos = float2(cos(angle), sin(angle)) * r + 0.5;
}

float2 center = float2(centerX, centerY);
float2 p = (pos - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float z = fmod(timeVal * speed, 1.0);

float rotAngle = rotation;
if (rotating > 0.5) rotAngle += timeVal * rotationSpeed;
float c = cos(rotAngle);
float s = sin(rotAngle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float3 col = float3(0.0);
int numCubes = int(cubeCount);

for (int i = 0; i < 20; i++) {
    if (i >= numCubes) break;
    float fi = float(i);
    float depthVal = (fi + z) * depth;
    float dsize = 1.0 / depthVal;
    
    float sizeAnim = dsize;
    if (pulse > 0.5) {
        sizeAnim *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    float d;
    float edge;
    
    if (circles > 0.5) {
        d = length(p * sizeAnim) - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else if (diamonds > 0.5) {
        d = abs(p.x * sizeAnim) + abs(p.y * sizeAnim) - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else if (stars > 0.5) {
        float a = atan2(p.y, p.x);
        float starShape = cos(a * 5.0) * 0.3 + 0.7;
        d = length(p * sizeAnim) / starShape - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else {
        float2 box = abs(p * sizeAnim) - cubeSize;
        d = max(box.x, box.y);
        if (filled > 0.5) {
            edge = smoothstep(0.0, -lineWidth, d);
        } else {
            edge = smoothstep(lineWidth, 0.0, abs(d));
        }
    }
    
    float3 cubeColor;
    if (colorful > 0.5) {
        float3 colorPhase = float3(0.0, 2.0, 4.0) + depthVal + timeVal * colorSpeed;
        if (alternating > 0.5 && int(fi) % 2 == 0) {
            colorPhase += 3.14159;
        }
        cubeColor = 0.5 + 0.5 * cos(colorPhase);
    } else {
        cubeColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-abs(d) * sizeAnim * 10.0) * glowIntensity;
        cubeColor += glowVal;
    }
    
    col += edge * cubeColor;
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Color shift
if (colorShift > 0.5) col = col.gbr;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float hAngle = hueShift * 6.28318;
    float hCos = cos(hAngle);
    float hSin = sin(hAngle);
    float3x3 hueMatrix = float3x3(
        0.299 + 0.701 * hCos - 0.300 * hSin,
        0.587 - 0.587 * hCos - 0.588 * hSin,
        0.114 - 0.114 * hCos + 0.886 * hSin,
        0.299 - 0.299 * hCos + 0.143 * hSin,
        0.587 + 0.413 * hCos + 0.140 * hSin,
        0.114 - 0.114 * hCos - 0.283 * hSin,
        0.299 - 0.299 * hCos - 0.701 * hSin,
        0.587 - 0.587 * hCos + 0.588 * hSin,
        0.114 + 0.886 * hCos + 0.114 * hSin
    );
    col = hueMatrix * col;
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.0) {
    float2 dir = pos - 0.5;
    col.r = col.r + chromaticAmount * length(dir);
    col.b = col.b - chromaticAmount * length(dir);
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (luminance - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount * 0.3;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(pos * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines effect
if (scanlines > 0.5) {
    float scanline = sin(pos.y * 400.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.3 * scanline;
}

// Vignette effect
if (vignette > 0.5) {
    float vig = length(pos - 0.5) * vignetteSize * 2.0;
    col *= 1.0 - vig * 0.5;
}

// Edge fade
if (edgeFade > 0.0) {
    float2 edgeDist = min(pos, 1.0 - pos);
    float ef = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= ef;
}

// Gamma correction
col = pow(max(col, 0.0), float3(1.0 / gamma));
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let rotatingTrianglesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Rotation Speed" range(0.0, 5.0) default(1.0)
// @param triangleCount "Triangle Count" range(2.0, 8.0) default(3.0)
// @param size "Size" range(0.1, 0.8) default(0.3)
// @param lineWidth "Line Width" range(0.005, 0.05) default(0.01)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param spacing "Spacing" range(0.0, 1.0) default(0.0)
// @param phaseOffset "Phase Offset" range(0.0, 6.28) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.5)
// @param sideCount "Side Count" range(3.0, 8.0) default(3.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle filled "Filled" default(false)
// @toggle counterRotate "Counter Rotate" default(false)
// @toggle nested "Nested" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle squares "Squares" default(false)
// @toggle pentagons "Pentagons" default(false)
// @toggle hexagons "Hexagons" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pSize = max(pixelSize, 1.0);
    pos = floor(pos * 100.0 / pSize) * pSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float segments = 6.0;
    kAngle = fmod(kAngle, 6.28318 / segments);
    kAngle = abs(kAngle - 3.14159 / segments);
    float r = length(kp);
    pos = float2(cos(kAngle), sin(kAngle)) * r + 0.5;
}

float2 center = float2(centerX, centerY);
float2 p = (pos - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float angle = timeVal * speed + phaseOffset;

float c = cos(angle);
float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float3 col = float3(0.0);

int sides = int(sideCount);
if (squares > 0.5) sides = 4;
if (pentagons > 0.5) sides = 5;
if (hexagons > 0.5) sides = 6;

float sideAngle = 6.28318 / float(sides);

int numTriangles = int(triangleCount);
for (int i = 0; i < 8; i++) {
    if (i >= numTriangles) break;
    float fi = float(i);
    
    float layerAngle = fi * sideAngle + timeVal * rotationSpeed;
    if (counterRotate > 0.5 && i % 2 == 1) {
        layerAngle = -fi * sideAngle - timeVal * rotationSpeed;
    }
    
    float layerSize = size;
    if (nested > 0.5) {
        layerSize = size * (1.0 - fi * 0.1);
    }
    layerSize += fi * spacing * 0.1;
    
    if (pulse > 0.5) {
        layerSize *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    // Wave distortion
    if (waveAmplitude > 0.0) {
        layerSize += sin(fi * waveFrequency + timeVal) * waveAmplitude * 0.1;
    }
    
    float2 dir = float2(cos(layerAngle), sin(layerAngle));
    float d = dot(p, dir);
    
    float edge;
    if (filled > 0.5) {
        edge = smoothstep(layerSize + lineWidth, layerSize, abs(d));
    } else {
        edge = smoothstep(lineWidth, 0.0, abs(d - layerSize));
    }
    
    float3 triColor;
    if (colorful > 0.5) {
        triColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        triColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-abs(d - layerSize) * 20.0) * glowIntensity;
        triColor += glowVal;
    }
    
    col += edge * triColor;
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Color shift
if (colorShift > 0.5) col = col.gbr;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float hAngle = hueShift * 6.28318;
    float hCos = cos(hAngle);
    float hSin = sin(hAngle);
    float3x3 hueMatrix = float3x3(
        0.299 + 0.701 * hCos - 0.300 * hSin,
        0.587 - 0.587 * hCos - 0.588 * hSin,
        0.114 - 0.114 * hCos + 0.886 * hSin,
        0.299 - 0.299 * hCos + 0.143 * hSin,
        0.587 + 0.413 * hCos + 0.140 * hSin,
        0.114 - 0.114 * hCos - 0.283 * hSin,
        0.299 - 0.299 * hCos - 0.701 * hSin,
        0.587 - 0.587 * hCos + 0.588 * hSin,
        0.114 + 0.886 * hCos + 0.114 * hSin
    );
    col = hueMatrix * col;
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.0) {
    float2 dir = pos - 0.5;
    col.r = col.r + chromaticAmount * length(dir);
    col.b = col.b - chromaticAmount * length(dir);
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (luminance - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount * 0.3;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(pos * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines effect
if (scanlines > 0.5) {
    float scanline = sin(pos.y * 400.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.3 * scanline;
}

// Vignette effect
if (vignette > 0.5) {
    float vig = length(pos - 0.5) * vignetteSize * 2.0;
    col *= 1.0 - vig * 0.5;
}

// Edge fade
if (edgeFade > 0.0) {
    float2 edgeDist = min(pos, 1.0 - pos);
    float ef = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= ef;
}

// Gamma correction
col = pow(max(col, 0.0), float3(1.0 / gamma));
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let penroseTilesCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(1.0, 15.0) default(5.0)
// @param speed "Speed" range(0.0, 1.0) default(0.2)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.05)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param layers "Layers" range(3.0, 10.0) default(5.0)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param baseAngle "Base Angle" range(0.0, 1.0) default(0.628318)
// @param intensity "Intensity" range(0.1, 0.5) default(0.2)
// @param bgBrightness "Background Brightness" range(0.0, 0.5) default(0.1)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param patternLayers "Pattern Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.2)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle quasicrystal "Quasicrystal" default(false)
// @toggle islamic "Islamic Pattern" default(false)
// @toggle celtic "Celtic" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle rotation "Rotation" default(false)
// @toggle wave "Wave" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pSize = max(pixelSize, 1.0);
    pos = floor(pos * 100.0 / pSize) * pSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float segments = 6.0;
    kAngle = fmod(kAngle, 6.28318 / segments);
    kAngle = abs(kAngle - 3.14159 / segments);
    float r = length(kp);
    pos = float2(cos(kAngle), sin(kAngle)) * r + 0.5;
}

float2 center = float2(centerX, centerY);
float2 p = (pos - center + float2(offsetX, offsetY)) * scale * zoom;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

if (rotation > 0.5) {
    float angle = timeVal * rotationSpeed;
    float c = cos(angle);
    float s = sin(angle);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
}

float angleStep = baseAngle;
if (quasicrystal > 0.5) angleStep = 0.523599;
if (islamic > 0.5) angleStep = 0.785398;
if (celtic > 0.5) angleStep = 0.698132;

float3 col = float3(bgBrightness);

int numLayers = int(layers);
for (int i = 0; i < 10; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    float a = fi * angleStep + timeVal * speed;
    float2 dir = float2(cos(a), sin(a));
    float d = dot(p, dir);
    
    if (wave > 0.5) {
        d += sin(timeVal * 2.0 + fi) * waveAmplitude;
    }
    
    float grid = abs(fract(d) - 0.5);
    float line = smoothstep(lineWidth, 0.0, grid);
    
    if (pulse > 0.5) {
        line *= 0.7 + 0.3 * sin(timeVal * 3.0 + fi);
    }
    
    float3 lineColor;
    if (colorful > 0.5) {
        lineColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        lineColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-grid * 10.0) * glowIntensity;
        lineColor += glowVal;
    }
    
    col += line * intensity * lineColor;
}

if (gradient > 0.5) {
    col *= mix(float3(0.6, 0.8, 1.0), float3(1.0, 0.8, 0.6), pos.y);
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Color shift
if (colorShift > 0.5) col = col.gbr;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float hAngle = hueShift * 6.28318;
    float hCos = cos(hAngle);
    float hSin = sin(hAngle);
    float3x3 hueMatrix = float3x3(
        0.299 + 0.701 * hCos - 0.300 * hSin,
        0.587 - 0.587 * hCos - 0.588 * hSin,
        0.114 - 0.114 * hCos + 0.886 * hSin,
        0.299 - 0.299 * hCos + 0.143 * hSin,
        0.587 + 0.413 * hCos + 0.140 * hSin,
        0.114 - 0.114 * hCos - 0.283 * hSin,
        0.299 - 0.299 * hCos - 0.701 * hSin,
        0.587 - 0.587 * hCos + 0.588 * hSin,
        0.114 + 0.886 * hCos + 0.114 * hSin
    );
    col = hueMatrix * col;
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.0) {
    float2 dir = pos - 0.5;
    col.r = col.r + chromaticAmount * length(dir);
    col.b = col.b - chromaticAmount * length(dir);
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (luminance - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount * 0.3;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(pos * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines effect
if (scanlines > 0.5) {
    float scanline = sin(pos.y * 400.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.3 * scanline;
}

// Vignette effect
if (vignette > 0.5) {
    float vig = length(pos - 0.5) * vignetteSize * 2.0;
    col *= 1.0 - vig * 0.5;
}

// Edge fade
if (edgeFade > 0.0) {
    float2 edgeDist = min(pos, 1.0 - pos);
    float ef = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= ef;
}

// Gamma correction
col = pow(max(col, 0.0), float3(1.0 / gamma));
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let truchetPatternCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param scale "Scale" range(2.0, 30.0) default(10.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param lineWidth "Line Width" range(0.01, 0.15) default(0.05)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param offsetX "Offset X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Offset Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param randomSeed "Random Seed" range(0.0, 100.0) default(0.0)
// @param patternVariant "Pattern Variant" range(0.0, 1.0) default(0.5)
// @param curveSmooth "Curve Smoothness" range(0.0, 0.5) default(0.0)
// @param bgBrightness "Background Brightness" range(0.0, 0.5) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.3)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle arcs "Arcs" default(false)
// @toggle diagonal "Diagonal" default(true)
// @toggle maze "Maze" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle rotating "Rotating" default(false)
// @toggle weave "Weave" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pSize = max(pixelSize, 1.0);
    pos = floor(pos * 100.0 / pSize) * pSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float segments = 6.0;
    kAngle = fmod(kAngle, 6.28318 / segments);
    kAngle = abs(kAngle - 3.14159 / segments);
    float r = length(kp);
    pos = float2(cos(kAngle), sin(kAngle)) * r + 0.5;
}

float2 center = float2(centerX, centerY);
float2 p = (pos - center + float2(offsetX, offsetY)) * scale * zoom;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

// Rotation transform
float rotAngle = rotation;
if (rotating > 0.5) rotAngle += timeVal * rotationSpeed;
float c = cos(rotAngle);
float s = sin(rotAngle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float2 id = floor(p);
float2 f = fract(p) - 0.5;

float h = fract(sin(dot(id + randomSeed, float2(12.9898, 78.233))) * 43758.5453);

float flipThreshold = patternVariant;
if (h > flipThreshold) f.x = -f.x;

float d;
if (arcs > 0.5) {
    float2 corner1 = float2(-0.5, -0.5);
    float2 corner2 = float2(0.5, 0.5);
    if (h > flipThreshold) {
        corner1 = float2(0.5, -0.5);
        corner2 = float2(-0.5, 0.5);
    }
    float d1 = abs(length(f - corner1) - 0.5);
    float d2 = abs(length(f - corner2) - 0.5);
    d = min(d1, d2);
} else if (maze > 0.5) {
    float h2 = fract(sin(dot(id + randomSeed + 1.0, float2(78.233, 12.9898))) * 43758.5453);
    if (h2 > 0.5) {
        d = min(abs(f.x), abs(f.y));
    } else {
        d = abs(abs(f.x) + abs(f.y) - 0.5);
    }
} else if (weave > 0.5) {
    float wave = sin((f.x + f.y) * waveFrequency + timeVal * speed) * waveAmplitude;
    d = abs(abs(f.x) + abs(f.y) - 0.5 + wave);
} else {
    d = abs(abs(f.x) + abs(f.y) - 0.5);
}

if (curveSmooth > 0.0) {
    d = smoothstep(curveSmooth, 0.0, d);
} else {
    d = smoothstep(lineWidth, 0.0, d);
}

if (pulse > 0.5) {
    d *= 0.7 + 0.3 * sin(timeVal * 3.0 + id.x + id.y);
}

float3 col = float3(bgBrightness);

float3 lineColor;
if (colorful > 0.5) {
    lineColor = 0.5 + 0.5 * cos(timeVal * colorSpeed + id.x + id.y + float3(0.0, 2.0, 4.0));
} else {
    lineColor = float3(1.0);
}

if (glow > 0.5) {
    float glowVal = exp(-d * 3.0) * glowIntensity;
    lineColor += glowVal;
}

col = mix(col, lineColor, d);

if (gradient > 0.5) {
    col *= mix(float3(0.6, 0.8, 1.0), float3(1.0, 0.8, 0.6), pos.y);
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Color shift
if (colorShift > 0.5) col = col.gbr;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float hAngle = hueShift * 6.28318;
    float hCos = cos(hAngle);
    float hSin = sin(hAngle);
    float3x3 hueMatrix = float3x3(
        0.299 + 0.701 * hCos - 0.300 * hSin,
        0.587 - 0.587 * hCos - 0.588 * hSin,
        0.114 - 0.114 * hCos + 0.886 * hSin,
        0.299 - 0.299 * hCos + 0.143 * hSin,
        0.587 + 0.413 * hCos + 0.140 * hSin,
        0.114 - 0.114 * hCos - 0.283 * hSin,
        0.299 - 0.299 * hCos - 0.701 * hSin,
        0.587 - 0.587 * hCos + 0.588 * hSin,
        0.114 + 0.886 * hCos + 0.114 * hSin
    );
    col = hueMatrix * col;
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.0) {
    float2 dir = pos - 0.5;
    col.r = col.r + chromaticAmount * length(dir);
    col.b = col.b - chromaticAmount * length(dir);
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (luminance - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount * 0.3;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(pos * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines effect
if (scanlines > 0.5) {
    float scanline = sin(pos.y * 400.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.3 * scanline;
}

// Vignette effect
if (vignette > 0.5) {
    float vig = length(pos - 0.5) * vignetteSize * 2.0;
    col *= 1.0 - vig * 0.5;
}

// Edge fade
if (edgeFade > 0.0) {
    float2 edgeDist = min(pos, 1.0 - pos);
    float ef = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= ef;
}

// Gamma correction
col = pow(max(col, 0.0), float3(1.0 / gamma));
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

let sacredGeometryCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 2.0) default(0.3)
// @param circleCount "Circle Count" range(4.0, 12.0) default(6.0)
// @param circleRadius "Circle Radius" range(0.3, 0.7) default(0.5)
// @param orbitRadius "Orbit Radius" range(0.2, 0.8) default(0.5)
// @param lineWidth "Line Width" range(0.01, 0.08) default(0.04)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(1.0)
// @param centerCircleSize "Center Circle Size" range(0.3, 0.7) default(0.52)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param waveAmplitude "Wave Amplitude" range(0.0, 1.0) default(0.0)
// @param distortAmount "Distort Amount" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.0)
// @param layers "Layers" range(1.0, 5.0) default(1.0)
// @param saturation "Saturation" range(0.0, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.5)
// @param pixelSize "Pixel Size" range(1.0, 50.0) default(1.0)
// @param chromaticAmount "Chromatic Amount" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.5)
// @param patternScale "Pattern Scale" range(0.5, 3.0) default(1.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.0)
// @param morphSpeed "Morph Speed" range(0.0, 2.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle flowerOfLife "Flower of Life" default(true)
// @toggle metatron "Metatron Cube" default(false)
// @toggle sriYantra "Sri Yantra" default(false)
// @toggle rotating "Rotating" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle glow "Glow" default(false)
// @toggle invert "Invert" default(false)
// @toggle neon "Neon" default(false)
// @toggle noise "Noise" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle filled "Filled" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle chromatic "Chromatic" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle colorShift "Color Shift" default(false)

float2 pos = uv;
float timeVal = animated > 0.5 ? iTime : 0.0;

// Pixelate effect
if (pixelate > 0.5) {
    float pSize = max(pixelSize, 1.0);
    pos = floor(pos * 100.0 / pSize) * pSize / 100.0;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float2 kp = pos - 0.5;
    float kAngle = atan2(kp.y, kp.x);
    float segments = 6.0;
    kAngle = fmod(kAngle, 6.28318 / segments);
    kAngle = abs(kAngle - 3.14159 / segments);
    float r = length(kp);
    pos = float2(cos(kAngle), sin(kAngle)) * r + 0.5;
}

float2 center = float2(centerX, centerY);
float2 p = (pos - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

// Rotation
float rotAngle = rotation;
if (rotating > 0.5) rotAngle += timeVal * rotationSpeed;
float c = cos(rotAngle);
float s = sin(rotAngle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float3 col = float3(0.0);

int numCircles = int(circleCount);
for (int i = 0; i < 12; i++) {
    if (i >= numCircles) break;
    float fi = float(i);
    float a = fi * (6.28318 / float(numCircles)) + timeVal * speed;
    float2 circleCenter = float2(cos(a), sin(a)) * orbitRadius;
    
    float d = length(p - circleCenter);
    float radiusAnim = circleRadius;
    
    if (pulse > 0.5) {
        radiusAnim *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    // Wave distortion
    if (waveAmplitude > 0.0) {
        radiusAnim += sin(fi * waveFrequency + timeVal) * waveAmplitude * 0.1;
    }
    
    float circle;
    if (filled > 0.5) {
        circle = smoothstep(radiusAnim, radiusAnim - lineWidth, d);
    } else {
        circle = smoothstep(radiusAnim + lineWidth * 0.5, radiusAnim, d) * 
                 smoothstep(radiusAnim - lineWidth * 0.5, radiusAnim, d + lineWidth);
    }
    
    float3 circleColor;
    if (colorful > 0.5) {
        circleColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.5 + timeVal * colorSpeed);
    } else {
        circleColor = float3(1.0);
    }
    
    col += circle * circleColor;
}

float centerD = length(p);
float centerCircle;
if (filled > 0.5) {
    centerCircle = smoothstep(centerCircleSize, centerCircleSize - lineWidth, centerD);
} else {
    centerCircle = smoothstep(centerCircleSize + lineWidth * 0.5, centerCircleSize, centerD) *
                   smoothstep(centerCircleSize - lineWidth * 0.5, centerCircleSize, centerD + lineWidth);
}
col += centerCircle * 0.3;

if (metatron > 0.5) {
    for (int i = 0; i < 12; i++) {
        if (i >= numCircles) break;
        float fi = float(i);
        float a1 = fi * (6.28318 / float(numCircles));
        float a2 = (fi + 1.0) * (6.28318 / float(numCircles));
        float2 p1 = float2(cos(a1), sin(a1)) * orbitRadius;
        float2 p2 = float2(cos(a2), sin(a2)) * orbitRadius;
        
        float2 lineDir = normalize(p2 - p1);
        float2 toP = p - p1;
        float proj = dot(toP, lineDir);
        proj = clamp(proj, 0.0, length(p2 - p1));
        float2 closest = p1 + lineDir * proj;
        float lineDist = length(p - closest);
        float line = smoothstep(lineWidth * 0.3, 0.0, lineDist);
        col += line * 0.5;
    }
}

if (sriYantra > 0.5) {
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float triSize = 0.3 + fi * 0.15;
        float triAngle = fi * 1.047 + (fi == 1.0 ? 3.14159 : 0.0);
        for (int j = 0; j < 3; j++) {
            float a = float(j) * 2.094 + triAngle;
            float2 dir = float2(cos(a), sin(a));
            float d = abs(dot(p, dir) - triSize * 0.5);
            col += smoothstep(lineWidth * 0.3, 0.0, d) * 0.3;
        }
    }
}

if (glow > 0.5) {
    col += exp(-centerD * 2.0) * glowIntensity;
}

if (gradient > 0.5) {
    col *= mix(float3(0.7, 0.8, 1.0), float3(1.0, 0.9, 0.7), pos.y);
}

col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal);

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Color shift
if (colorShift > 0.5) col = col.gbr;

// Saturation adjustment
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, saturation);

// Hue shift
if (hueShift > 0.0) {
    float hAngle = hueShift * 6.28318;
    float hCos = cos(hAngle);
    float hSin = sin(hAngle);
    float3x3 hueMatrix = float3x3(
        0.299 + 0.701 * hCos - 0.300 * hSin,
        0.587 - 0.587 * hCos - 0.588 * hSin,
        0.114 - 0.114 * hCos + 0.886 * hSin,
        0.299 - 0.299 * hCos + 0.143 * hSin,
        0.587 + 0.413 * hCos + 0.140 * hSin,
        0.114 - 0.114 * hCos - 0.283 * hSin,
        0.299 - 0.299 * hCos - 0.701 * hSin,
        0.587 - 0.587 * hCos + 0.588 * hSin,
        0.114 + 0.886 * hCos + 0.114 * hSin
    );
    col = hueMatrix * col;
}

// Chromatic aberration
if (chromatic > 0.5 && chromaticAmount > 0.0) {
    float2 dir = pos - 0.5;
    col.r = col.r + chromaticAmount * length(dir);
    col.b = col.b - chromaticAmount * length(dir);
}

// Bloom effect
if (bloom > 0.5) {
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    if (luminance > bloomThreshold) {
        col += (luminance - bloomThreshold) * bloomIntensity;
    }
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(pos * 200.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount * 0.3;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(pos * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount;
}

// Scanlines effect
if (scanlines > 0.5) {
    float scanline = sin(pos.y * 400.0) * 0.5 + 0.5;
    col *= 1.0 - scanlineIntensity * 0.3 * scanline;
}

// Vignette effect
if (vignette > 0.5) {
    float vig = length(pos - 0.5) * vignetteSize * 2.0;
    col *= 1.0 - vig * 0.5;
}

// Edge fade
if (edgeFade > 0.0) {
    float2 edgeDist = min(pos, 1.0 - pos);
    float ef = smoothstep(0.0, edgeFade * 0.3, min(edgeDist.x, edgeDist.y));
    col *= ef;
}

// Gamma correction
col = pow(max(col, 0.0), float3(1.0 / gamma));
col = clamp(col, 0.0, 1.0);
return float4(col * masterOpacity, masterOpacity);
"""

