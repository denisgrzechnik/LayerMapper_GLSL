//
//  ShaderCodes_Part10.swift
//  LM_GLSL
//
//  Shader codes - Part 10: Energy, Motion & Experimental Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Energy & Motion Parametric Shaders

/// Electric Arc Advanced
let electricArcAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param arcCount "Arc Count" range(1, 8) default(3)
// @param arcThickness "Arc Thickness" range(0.01, 0.05) default(0.02)
// @param jitterAmount "Jitter Amount" range(0.0, 0.2) default(0.1)
// @param branchChance "Branch Chance" range(0.0, 0.5) default(0.2)
// @param energyLevel "Energy Level" range(0.0, 1.0) default(0.7)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.7)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.7)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle reactive "Reactive" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * radius;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

// Base color
float3 col = float3(0.02, 0.02, 0.05);
float3 arcColor1 = float3(color1R, color1G, color1B);
float3 arcColor2 = float3(color2R, color2G, color2B);

// Electric arcs
for (int arc = 0; arc < 8; arc++) {
    if (arc >= int(arcCount)) break;
    float fa = float(arc);
    float2 start = float2(-0.8, (fa / arcCount - 0.5) * 1.5);
    float2 end = float2(0.8, (fa / arcCount - 0.5) * 1.5 + sin(timeVal + fa) * 0.2);
    float t = (p.x - start.x) / (end.x - start.x);
    if (t >= 0.0 && t <= 1.0) {
        float baseY = mix(start.y, end.y, t);
        float jitter = 0.0;
        for (int j = 1; j < 8; j++) {
            float fj = float(j);
            float freq = pow(2.0, fj);
            float timeOffset = timeVal * (5.0 + fj);
            jitter += sin(t * freq * 10.0 + timeOffset) * jitterAmount / freq;
        }
        float arcY = baseY + jitter;
        float d = abs(p.y - arcY);
        float arcLine = smoothstep(arcThickness, 0.0, d);
        
        // Rainbow color option
        float3 currentArcColor = rainbow > 0.5 ? 
            0.5 + 0.5 * cos(timeVal + t * 6.28 + float3(0.0, 2.0, 4.0)) :
            mix(arcColor1, arcColor2, t);
        
        col += arcLine * currentArcColor * energyLevel;
        
        // Glow effect
        if (glow > 0.5) {
            float glowVal = exp(-d * 20.0) * glowIntensity;
            col += glowVal * currentArcColor * 0.5;
        }
        
        // Branch effect
        if (branchChance > 0.0) {
            float branchSeed = fract(sin(t * 100.0 + fa) * 43758.5453);
            if (branchSeed < branchChance) {
                float branchY = arcY + (branchSeed - branchChance * 0.5) * 0.3;
                float branchD = abs(p.y - branchY) + abs(p.x - (start.x + t * (end.x - start.x))) * 2.0;
                float branchLine = smoothstep(arcThickness * 0.5, 0.0, branchD);
                col += branchLine * currentArcColor * 0.5;
            }
        }
    }
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (1.0 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.5), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edge = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edge));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Reactive effect
if (reactive > 0.5) {
    col *= 1.0 + sin(timeVal * 10.0) * 0.2;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    float3 shifted = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
    col = shifted;
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma correction
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon effect
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel effect
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth/clamp
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

// Master opacity
col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Plasma Ball
let plasmaBallCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param streamCount "Stream Count" range(3, 12) default(6)
// @param streamWidth "Stream Width" range(0.02, 0.1) default(0.04)
// @param coreSize "Core Size" range(0.1, 0.3) default(0.15)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.5)
// @param rotationSpeed "Rotation Speed" range(0.0, 3.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.7)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.8)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.4)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.4)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.6)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle touchPoint "Touch Point" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
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
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(true)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Distortion
if (distortion > 0.0) {
    p += float2(sin(p.y * 10.0 + timeVal), cos(p.x * 10.0 + timeVal)) * distortion * 0.1;
}

float r = length(p);
float a = atan2(p.y, p.x);

// Colors from params
float3 plasmaColor1 = float3(color1R, color1G, color1B);
float3 plasmaColor2 = float3(color2R, color2G, color2B);

// Base color
float3 col = float3(0.02, 0.0, 0.03);

// Sphere boundary
float sphere = smoothstep(0.95, 0.9, r);
col = mix(col, float3(0.05, 0.02, 0.08), sphere);

// Sphere edge glow
float sphereEdge = smoothstep(0.02, 0.0, abs(r - 0.9));
col += sphereEdge * float3(0.3, 0.2, 0.4);

// Plasma streams
for (int i = 0; i < 12; i++) {
    if (i >= int(streamCount)) break;
    float fi = float(i);
    float streamAngle = fi * 6.28318 / streamCount + timeVal * rotationSpeed;
    float2 streamDir = float2(cos(streamAngle), sin(streamAngle));
    float2 touchPos = touchPoint > 0.5 ? float2(0.5, 0.3) : streamDir * 0.8;
    float2 toP = p;
    float streamT = dot(toP, streamDir);
    if (streamT > 0.0) {
        float perpDist = length(toP - streamDir * streamT);
        float noiseVal = sin(streamT * 20.0 + timeVal * 5.0 + fi * 10.0) * turbulence * 0.05;
        perpDist += noiseVal;
        float streamD = smoothstep(streamWidth, 0.0, perpDist);
        streamD *= smoothstep(0.9, coreSize, streamT);
        
        // Rainbow or custom colors
        float3 streamColor = rainbow > 0.5 ?
            0.5 + 0.5 * cos(timeVal + streamT * 6.28 + float3(0.0, 2.0, 4.0)) :
            mix(plasmaColor1, plasmaColor2, streamT);
        
        col += streamD * streamColor * 0.4;
        
        // Glow
        if (glow > 0.5) {
            float glowVal = exp(-perpDist * 10.0) * glowIntensity * 0.3;
            col += glowVal * streamColor * sphere;
        }
    }
}

// Core
float core = smoothstep(coreSize + 0.02, coreSize, r);
float corePulse = pulse > 0.5 ? 0.8 + 0.2 * sin(timeVal * 3.0) : 1.0;
col += core * plasmaColor1 * corePulse;

// Core glow
float coreGlow = exp(-r / coreSize * 2.0);
col += coreGlow * plasmaColor2 * 0.3;

// Radial effect
if (radial > 0.5) {
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(r * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Shockwave
let shockwaveCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param waveCount "Wave Count" range(1, 5) default(3)
// @param waveSpeed "Wave Speed" range(0.5, 3.0) default(1.5)
// @param waveThickness "Wave Thickness" range(0.02, 0.15) default(0.05)
// @param distortionAmount "Distortion Amount" range(0.0, 0.3) default(0.1)
// @param fadeDistance "Fade Distance" range(0.5, 1.5) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.9)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.8)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.5)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.7)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle colorful "Colorful" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
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
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Colors from params
float3 waveColor1 = float3(color1R, color1G, color1B);
float3 waveColor2 = float3(color2R, color2G, color2B);

// Base color
float3 col = float3(0.05, 0.05, 0.08);
float3 background = 0.5 + 0.5 * cos(uv.xyx * 3.0 + float3(0.0, 2.0, 4.0));
col = mix(col, background * 0.2, 0.3);

// Shockwaves
for (int w = 0; w < 5; w++) {
    if (w >= int(waveCount)) break;
    float fw = float(w);
    float waveTime = fract(timeVal * waveSpeed * 0.3 + fw * 0.3);
    float waveRadius = waveTime * fadeDistance * 1.5;
    float2 waveCenter = float2(sin(fw * 2.0) * 0.2, cos(fw * 3.0) * 0.2);
    float r = length(p - waveCenter);
    float wave = abs(r - waveRadius);
    float waveMask = smoothstep(waveThickness, 0.0, wave);
    waveMask *= 1.0 - waveTime;
    
    // Distortion
    if (distortionAmount > 0.0) {
        float2 distortedUV = uv;
        float distort = smoothstep(waveThickness * 2.0, 0.0, wave) * distortionAmount;
        distortedUV += normalize(p - waveCenter) * distort * (1.0 - waveTime);
        float3 distortedBg = 0.5 + 0.5 * cos(distortedUV.xyx * 3.0 + float3(0.0, 2.0, 4.0));
        col = mix(col, distortedBg * 0.5, distort * 2.0);
    }
    
    // Wave color
    float3 currentWaveColor;
    if (rainbow > 0.5) {
        currentWaveColor = 0.5 + 0.5 * cos(timeVal + fw * 2.0 + float3(0.0, 2.0, 4.0));
    } else if (colorful > 0.5) {
        currentWaveColor = 0.5 + 0.5 * cos(fw * 1.5 + waveTime * 3.0 + float3(0.0, 2.0, 4.0));
    } else {
        currentWaveColor = mix(waveColor1, waveColor2, waveTime);
    }
    
    col += waveMask * currentWaveColor;
    
    // Glow
    if (glow > 0.5) {
        float glowVal = exp(-wave * 10.0) * (1.0 - waveTime) * glowIntensity * 0.5;
        col += glowVal * currentWaveColor;
    }
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Tornado Vortex
let tornadoVortexCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param vortexIntensity "Vortex Intensity" range(1.0, 5.0) default(3.0)
// @param debrisAmount "Debris Amount" range(0.0, 1.0) default(0.5)
// @param funnelWidth "Funnel Width" range(0.1, 0.4) default(0.2)
// @param rotationSpeed "Rotation Speed" range(1.0, 5.0) default(2.0)
// @param dustOpacity "Dust Opacity" range(0.0, 1.0) default(0.4)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.4)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.35)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.3)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.15)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.12)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle lightning "Lightning" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
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
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Colors from params
float3 tornadoColor1 = float3(color1R, color1G, color1B);
float3 tornadoColor2 = float3(color2R, color2G, color2B);

// Base sky color
float3 col = tornadoColor1;

// Cloud noise
float cloudNoise = sin(uv.x * 5.0 + timeVal * 0.2) * sin(uv.y * 3.0) * 0.1;
if (noise > 0.5) {
    col += cloudNoise * noiseAmount;
}

// Funnel calculations
float funnelY = (p.y + 1.0) * 0.5;
float funnelRadius = funnelWidth * (1.0 - funnelY * 0.7);
float funnelDist = abs(p.x) - funnelRadius;
float funnel = smoothstep(0.05, 0.0, funnelDist);
funnel *= step(p.y, 0.8);

// Spiral twist
float twist = atan2(p.x, funnelY + 0.1) + timeVal * rotationSpeed;
float spiral = sin(twist * vortexIntensity + funnelY * 10.0) * 0.5 + 0.5;

// Rainbow or custom colors for funnel
float3 funnelColor;
if (rainbow > 0.5) {
    funnelColor = 0.5 + 0.5 * cos(timeVal + spiral * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    funnelColor = mix(tornadoColor1, tornadoColor2, spiral);
}
col = mix(col, funnelColor, funnel * 0.8);

// Debris particles
if (debrisAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float debrisAngle = fi * 0.5 + timeVal * rotationSpeed * (0.8 + fract(sin(fi) * 0.4));
        float debrisY = fract(fi * 0.123 + timeVal * 0.3) * 1.5 - 0.5;
        float debrisRadius = funnelWidth * (1.0 - (debrisY + 0.5) * 0.4) * (1.0 + sin(fi) * 0.3);
        float2 debrisPos = float2(sin(debrisAngle) * debrisRadius, debrisY);
        float d = length(p - debrisPos);
        float debris = smoothstep(0.02, 0.01, d) * debrisAmount;
        col = mix(col, tornadoColor2, debris);
    }
}

// Dust effect
float dust = smoothstep(funnelRadius + 0.2, funnelRadius, abs(p.x)) * dustOpacity;
dust *= step(p.y, 0.5) * (1.0 - funnelY);
col = mix(col, tornadoColor1 * 1.2, dust * 0.5);

// Lightning flash
if (lightning > 0.5) {
    float flash = step(0.98, sin(timeVal * 10.0 + sin(timeVal * 50.0) * 5.0));
    col += flash * float3(1.0, 0.95, 0.9) * 0.3;
}

// Glow effect
if (glow > 0.5) {
    float glowVal = exp(-abs(funnelDist) * 5.0) * glowIntensity;
    col += glowVal * funnelColor * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Magnetic Field
let magneticFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param fieldStrength "Field Strength" range(1.0, 5.0) default(2.5)
// @param lineCount "Line Count" range(10, 50) default(25)
// @param particleSpeed "Particle Speed" range(0.5, 3.0) default(1.5)
// @param poleDistance "Pole Distance" range(0.3, 0.8) default(0.5)
// @param lineThickness "Line Thickness" range(0.005, 0.02) default(0.008)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.3)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.3)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.3)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle particles "Particles" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Colors from params
float3 poleColor1 = float3(color1R, color1G, color1B);
float3 poleColor2 = float3(color2R, color2G, color2B);

// Base color
float3 col = float3(0.02, 0.02, 0.05);

// Pole positions
float2 pole1 = float2(-poleDistance, 0.0);
float2 pole2 = float2(poleDistance, 0.0);

// Field lines
for (int i = 0; i < 50; i++) {
    if (i >= int(lineCount)) break;
    float fi = float(i);
    float startAngle = (fi / lineCount) * 3.14159;
    float2 fieldPos = pole1 + float2(cos(startAngle), sin(startAngle)) * 0.1;
    for (int stepIdx = 0; stepIdx < 50; stepIdx++) {
        float2 dir1 = normalize(fieldPos - pole1);
        float2 dir2 = normalize(pole2 - fieldPos);
        float dist1 = length(fieldPos - pole1);
        float dist2 = length(fieldPos - pole2);
        float2 fieldDir = dir1 / (dist1 * dist1) * fieldStrength + dir2 / (dist2 * dist2) * fieldStrength;
        fieldDir = normalize(fieldDir);
        float2 nextPos = fieldPos + fieldDir * 0.03;
        float d = length(p - fieldPos);
        float lineVal = smoothstep(lineThickness, 0.0, d);
        
        // Rainbow or gradient color
        float3 lineColor = rainbow > 0.5 ?
            0.5 + 0.5 * cos(timeVal + fi * 0.3 + float3(0.0, 2.0, 4.0)) :
            mix(poleColor1, poleColor2, float(stepIdx) / 50.0);
        
        col += lineVal * lineColor * 0.1;
        fieldPos = nextPos;
        if (length(fieldPos - pole2) < 0.1) break;
        if (length(fieldPos) > 1.5) break;
    }
}

// Pole glows
if (glow > 0.5) {
    float poleGlow1 = exp(-length(p - pole1) * 5.0) * glowIntensity;
    float poleGlow2 = exp(-length(p - pole2) * 5.0) * glowIntensity;
    col += poleGlow1 * poleColor1;
    col += poleGlow2 * poleColor2;
}

// Particles
if (particles > 0.5) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float particleT = fract(timeVal * particleSpeed * 0.1 + fi * 0.05);
        float particleAngle = (fi / 20.0) * 3.14159;
        float2 particlePos = mix(
            pole1 + float2(cos(particleAngle), sin(particleAngle)) * 0.1,
            pole2 + float2(-cos(particleAngle), sin(particleAngle)) * 0.1,
            particleT
        );
        particlePos.y += sin(particleT * 3.14159) * 0.3 * sin(particleAngle);
        float d = length(p - particlePos);
        float particle = smoothstep(0.02, 0.01, d);
        col += particle * float3(0.8, 0.9, 1.0);
    }
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Energy Beam
let energyBeamCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param beamWidth "Beam Width" range(0.05, 0.3) default(0.15)
// @param beamIntensity "Beam Intensity" range(0.5, 2.0) default(1.0)
// @param noiseAmountBeam "Beam Noise" range(0.0, 0.2) default(0.05)
// @param pulseFrequency "Pulse Frequency" range(1.0, 10.0) default(5.0)
// @param coreRatio "Core Ratio" range(0.1, 0.5) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.3)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.5)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.8)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.9)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle horizontal "Horizontal" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Horizontal/vertical orientation
if (horizontal < 0.5) {
    p = p.yx;
}

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Colors from params
float3 outerColor = float3(color1R, color1G, color1B);
float3 innerColor = float3(color2R, color2G, color2B);

// Base color
float3 col = float3(0.02, 0.02, 0.05);

// Beam calculations
float beamY = 0.0;
float beamNoise = sin(p.x * 30.0 + timeVal * 5.0) * sin(p.x * 50.0 + timeVal * 8.0) * noiseAmountBeam;
float distToBeam = abs(p.y - beamY - beamNoise);
float beam = smoothstep(beamWidth, 0.0, distToBeam);
float core = smoothstep(beamWidth * coreRatio, 0.0, distToBeam);

// Pulse effect
float pulseVal = pulse > 0.5 ? 0.7 + 0.3 * sin(p.x * 10.0 - timeVal * pulseFrequency) : 1.0;

// Rainbow or custom colors
float3 beamOuterColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(timeVal + p.x * 2.0 + float3(0.0, 2.0, 4.0)) :
    outerColor;
float3 beamInnerColor = rainbow > 0.5 ?
    0.7 + 0.3 * cos(timeVal + p.x * 2.0 + float3(1.0, 3.0, 5.0)) :
    innerColor;

col += beam * beamOuterColor * pulseVal * beamIntensity;
col += core * beamInnerColor * beamIntensity;

// Glow
if (glow > 0.5) {
    float glowVal = exp(-distToBeam * 5.0) * glowIntensity;
    col += glowVal * beamOuterColor * beamIntensity * 0.5;
}

// Sparkles
float sparkle = step(0.99, fract(sin(dot(floor(p * 50.0 + timeVal * 10.0), float2(12.9898, 78.233))) * 43758.5453));
sparkle *= beam;
col += sparkle * float3(1.0);

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Quantum Fluctuation
let quantumFluctuationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param fluctuationScale "Fluctuation Scale" range(5.0, 30.0) default(15.0)
// @param probabilityDensity "Probability Density" range(0.3, 1.0) default(0.6)
// @param waveFunctionSpeed "Wave Function Speed" range(0.5, 3.0) default(1.5)
// @param entanglementStrength "Entanglement Strength" range(0.0, 1.0) default(0.5)
// @param colorPhase "Color Phase" range(0.0, 6.28) default(0.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.3)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.8)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.8)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle interference "Interference" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(true)
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

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 baseP = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
baseP = float2(baseP.x * cosR - baseP.y * sinR, baseP.x * sinR + baseP.y * cosR);

// Mirror effect
if (mirror > 0.5) baseP.x = abs(baseP.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    baseP = floor(baseP / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(baseP.y, baseP.x);
    float rad = length(baseP);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    baseP = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
float waveTime = timeVal * waveFunctionSpeed;

// Scale for fluctuation
float2 p = baseP * fluctuationScale;

// Colors from params
float3 quantumColor1 = float3(color1R, color1G, color1B);
float3 quantumColor2 = float3(color2R, color2G, color2B);

// Base color
float3 col = float3(0.02, 0.02, 0.05);

// Wave functions
float psi1 = sin(p.x + waveTime) * sin(p.y * 1.3 + waveTime * 0.7);
float psi2 = sin(p.x * 1.5 - waveTime * 0.8) * sin(p.y * 0.8 - waveTime);

// Probability calculation
float probability = psi1 * psi1 + psi2 * psi2;
probability = probability * 0.25 * probabilityDensity;

// Interference
if (interference > 0.5) {
    float interf = psi1 * psi2;
    probability += interf * 0.3;
}

// Entanglement
if (entanglementStrength > 0.0) {
    float entangle = sin(p.x * 2.0 + p.y * 2.0 + waveTime * 2.0);
    entangle *= sin(fluctuationScale - p.x * 2.0 + fluctuationScale - p.y * 2.0 + waveTime * 2.0);
    probability += entangle * entanglementStrength * 0.2;
}

// Color mixing
float3 waveColor1, waveColor2;
if (rainbow > 0.5) {
    waveColor1 = 0.5 + 0.5 * cos(probability * 5.0 + waveTime + float3(0.0, 2.0, 4.0));
    waveColor2 = 0.5 + 0.5 * cos(probability * 7.0 + waveTime + float3(4.0, 2.0, 0.0));
} else {
    waveColor1 = mix(quantumColor1, quantumColor2, probability);
    waveColor2 = mix(quantumColor2, quantumColor1, probability);
}

col = mix(waveColor1, waveColor2, sin(waveTime + p.x * 0.1) * 0.5 + 0.5);
col *= probability * 2.0 + 0.1;

// Uncertainty sparkles
float uncertainty = fract(sin(dot(p + waveTime, float2(12.9898, 78.233))) * 43758.5453);
col += step(0.997, uncertainty) * float3(1.0, 0.9, 0.8);

// Glow
if (glow > 0.5) {
    col += probability * glowIntensity * quantumColor1 * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(baseP);
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + baseP.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(probability * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(waveTime * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(waveTime * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Fire Whirl
let fireWhirlCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param whirlSpeed "Whirl Speed" range(0.5, 4.0) default(2.0)
// @param flameHeight "Flame Height" range(0.5, 1.5) default(1.0)
// @param spiralTightness "Spiral Tightness" range(1.0, 5.0) default(2.5)
// @param emberCount "Ember Count" range(0.0, 1.0) default(0.5)
// @param heatDistortion "Heat Distortion" range(0.0, 0.1) default(0.03)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.3)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(1.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.9)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle smokeTrail "Smoke Trail" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(true)
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

// Setup coordinates with center, zoom, rotation
float2 center = float2(centerX, centerY);
float2 p = (uv - 0.5) * 2.0 / zoom - center;
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) p.x = abs(p.x);

// Pixelate effect
if (pixelate > 0.5) {
    float pxSize = max(1.0, pixelSize) / 100.0;
    p = floor(p / pxSize) * pxSize;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float rad = length(p);
    angle = fmod(angle, 3.14159 / 3.0);
    angle = abs(angle - 3.14159 / 6.0);
    p = float2(cos(angle), sin(angle)) * rad;
}

// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Colors from params
float3 fireColor1 = float3(color1R, color1G, color1B);
float3 fireColor2 = float3(color2R, color2G, color2B);

float r = length(p);
float a = atan2(p.y, p.x);

// Base color
float3 col = float3(0.05, 0.02, 0.01);

// Heat distortion
float distortVal = sin(a * 5.0 + timeVal * 3.0) * heatDistortion;
float2 dp = p + float2(distortVal, distortVal * 0.5);

// Spiral flame
float spiral = a + r * spiralTightness - timeVal * whirlSpeed;
float flame = sin(spiral * 3.0) * 0.5 + 0.5;
flame *= smoothstep(0.6, 0.0, r);
flame *= (1.0 - dp.y * 0.5 / flameHeight);
flame = max(0.0, flame);

// Height-based color
float height = 1.0 - r * 0.5 - (1.0 - dp.y) * 0.3;
height = clamp(height, 0.0, 1.0);

// Rainbow or custom fire colors
float3 currentFireColor;
if (rainbow > 0.5) {
    currentFireColor = 0.5 + 0.5 * cos(timeVal + height * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    currentFireColor = mix(fireColor2, fireColor1, height);
    currentFireColor = mix(currentFireColor, fireColor1 * 0.8, pow(1.0 - height, 2.0));
}

col = mix(col, currentFireColor, flame);

// Smoke trail
if (smokeTrail > 0.5) {
    float smoke = smoothstep(0.3, 0.8, dp.y + r * 0.5);
    smoke *= smoothstep(0.8, 0.3, r);
    float smokeNoise = sin(dp.x * 10.0 + timeVal * 2.0) * sin(dp.y * 8.0 + timeVal) * 0.5 + 0.5;
    col = mix(col, float3(0.2, 0.18, 0.15) * smokeNoise, smoke * 0.5);
}

// Embers
if (emberCount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float emberA = fi * 0.5 + timeVal * whirlSpeed;
        float emberR = fract(sin(fi * 43.758) * 43758.5453) * 0.5;
        float emberY = fract(fi * 0.123 + timeVal * 0.5) * flameHeight * 1.5;
        float2 emberPos = float2(sin(emberA) * emberR, emberY - 0.5);
        float d = length(p - emberPos);
        float ember = smoothstep(0.015, 0.005, d) * emberCount;
        col += ember * fireColor2;
    }
}

// Glow
if (glow > 0.5) {
    col += flame * glowIntensity * fireColor1 * 0.3;
}

// Radial effect
if (radial > 0.5) {
    col *= 1.0 + (1.0 - r) * 0.3;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(r * 5.0) - 0.5) * 2.0;
    col = mix(col, float3(1.0), smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, float3(1.0), smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.2;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.1;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 10.0;
    col.b *= 1.0 - chromaticAmount * 10.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Cyberpunk Grid
let cyberpunkGridCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param gridSize "Grid Size" range(5.0, 20.0) default(10.0)
// @param perspectiveStrength "Perspective Strength" range(0.0, 1.0) default(0.5)
// @param scanlineSpeed "Scanline Speed" range(0.0, 3.0) default(1.0)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param chromaShift "Chroma Shift" range(0.0, 0.02) default(0.005)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.0)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.5)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(1.0)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle neonPulse "Neon Pulse" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert" default(false)
// @toggle chromatic "Chromatic" default(true)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 cyberColor1 = float3(color1R, color1G, color1B);
float3 cyberColor2 = float3(color2R, color2G, color2B);

// Perspective grid
float2 gridP = p + center;
gridP.y = pow(max(gridP.y, 0.001), 1.0 + perspectiveStrength);
gridP *= gridSize;

// Dark background
float3 col = float3(0.02, 0.01, 0.05);

// Grid lines
float2 gridF = fract(gridP);
float gridLineX = smoothstep(0.05, 0.0, abs(gridF.x - 0.5) - 0.45);
float gridLineY = smoothstep(0.05, 0.0, abs(gridF.y - 0.5) - 0.45);
float grid = max(gridLineX, gridLineY);

// Depth fade
float depth = 1.0 - (uv.y + centerY * 0.5);
grid *= clamp(depth, 0.0, 1.0);

// Grid color
float3 gridColor = rainbow > 0.5 ? 
    0.5 + 0.5 * cos(timeVal + gridP.y * 0.5 + float3(0.0, 2.0, 4.0)) :
    mix(cyberColor1, cyberColor2, fract(gridP.y * 0.1 + timeVal * 0.5));

// Neon pulse
if (neonPulse > 0.5) {
    float pulseVal = 0.7 + 0.3 * sin(timeVal * 3.0 + gridP.y * 0.5);
    gridColor *= pulseVal;
}

col += grid * gridColor;

// Glow effect around grid
if (glow > 0.5) {
    col += grid * glowAmount * gridColor * glowIntensity;
}

// Chromatic shift on grid
if (chromaShift > 0.0) {
    float2 pR = (uv - float2(chromaShift, 0.0) - center) / zoom;
    float2 pB = (uv + float2(chromaShift, 0.0) - center) / zoom;
    pR.y = pow(max(pR.y + center.y, 0.001), 1.0 + perspectiveStrength);
    pB.y = pow(max(pB.y + center.y, 0.001), 1.0 + perspectiveStrength);
    pR *= gridSize;
    pB *= gridSize;
    float gridR = max(
        smoothstep(0.05, 0.0, abs(fract(pR.x) - 0.5) - 0.45),
        smoothstep(0.05, 0.0, abs(fract(pR.y) - 0.5) - 0.45)
    );
    float gridB = max(
        smoothstep(0.05, 0.0, abs(fract(pB.x) - 0.5) - 0.45),
        smoothstep(0.05, 0.0, abs(fract(pB.y) - 0.5) - 0.45)
    );
    col.r += gridR * depth * 0.3;
    col.b += gridB * depth * 0.3;
}

// Scanline sweep
if (scanlineSpeed > 0.0) {
    float scanline = fract(uv.y * 50.0 - timeVal * scanlineSpeed);
    scanline = smoothstep(0.0, 0.1, scanline) * smoothstep(0.2, 0.1, scanline);
    col += scanline * cyberColor2 * 0.15;
}

// Horizon glow
float horizon = smoothstep(0.02, 0.0, abs(uv.y - 0.3 + centerY * 0.5));
col += horizon * cyberColor1 * 0.5;

// Data particles
for (int i = 0; i < 15; i++) {
    float fi = float(i);
    float px = fract(fi * 0.372 + timeVal * 0.1) * 2.0 - 1.0;
    float py = fract(fi * 0.519 - timeVal * 0.3) * 2.0 - 1.0;
    float d = length(p - float2(px, py));
    float particle = smoothstep(0.03, 0.01, d);
    col += particle * gridColor * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.5), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, cyberColor1, smoothstep(0.4, 0.5, edge) * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, cyberColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Holographic Display
let holographicDisplayCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param scanSpeed "Scan Speed" range(0.5, 3.0) default(1.5)
// @param flickerAmount "Flicker Amount" range(0.0, 0.5) default(0.1)
// @param staticNoise "Static Noise" range(0.0, 0.3) default(0.1)
// @param transparency "Transparency" range(0.3, 1.0) default(0.7)
// @param colorShiftHolo "Color Shift" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.8)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(1.0)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle dataStreams "Data Streams" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Noise" default(true)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 holoColor1 = float3(color1R, color1G, color1B);
float3 holoColor2 = float3(color2R, color2G, color2B);

// Background
float3 col = float3(0.0);

// Holographic panel shape
float2 panelP = p + float2(0.5);
float shape = smoothstep(0.35, 0.30, abs(panelP.x - 0.5)) * smoothstep(0.45, 0.40, abs(panelP.y - 0.5));

// Hologram color with shift
float3 currentHoloColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(timeVal + panelP.y * 6.28 + float3(0.0, 2.0, 4.0)) :
    mix(holoColor1, holoColor2, panelP.y * colorShiftHolo);

// Scan line sweep
float scanLine = fract(panelP.y * 100.0 - timeVal * scanSpeed * 10.0);
scanLine = step(0.5, scanLine) * 0.15;

// Flicker effect
float flickVal = 1.0 - flickerAmount * step(0.95, fract(sin(timeVal * 50.0) * 43758.5453));

// Static noise
float staticVal = fract(sin(dot(panelP + timeVal, float2(12.9898, 78.233))) * 43758.5453);
staticVal = step(1.0 - staticNoise, staticVal) * staticNoise;

// Combine hologram
col = currentHoloColor * shape * transparency * flickVal;
col += scanLine * currentHoloColor * shape;
col += staticVal * holoColor2 * 0.5;

// Data streams
if (dataStreams > 0.5) {
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float streamX = fract(fi * 0.2 + 0.1);
        float streamY = fract(timeVal * 0.5 + fi * 0.3);
        float2 streamPos = float2(streamX, streamY);
        float d = length((panelP - streamPos) * float2(1.0, 10.0));
        float stream = smoothstep(0.05, 0.02, d);
        col += stream * holoColor2 * 0.25;
    }
}

// Horizontal data bars
for (int j = 0; j < 5; j++) {
    float fj = float(j);
    float barY = fract(fj * 0.15 + 0.2);
    float barWidth = 0.1 + 0.1 * sin(timeVal + fj);
    float barX = fract(timeVal * 0.3 + fj * 0.3);
    float bar = smoothstep(0.01, 0.0, abs(panelP.y - barY));
    bar *= step(barX - barWidth, panelP.x) * step(panelP.x, barX);
    col += bar * currentHoloColor * 0.4;
}

// Panel edge glow
float edge = smoothstep(0.33, 0.30, abs(panelP.x - 0.5)) - smoothstep(0.30, 0.27, abs(panelP.x - 0.5));
edge += smoothstep(0.43, 0.40, abs(panelP.y - 0.5)) - smoothstep(0.40, 0.37, abs(panelP.y - 0.5));
col += edge * currentHoloColor * 0.5;

// Glow effect
if (glow > 0.5) {
    col += shape * glowIntensity * currentHoloColor * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + panelP.y * 0.5), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edgeVis = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, currentHoloColor, smoothstep(0.4, 0.5, edgeVis) * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, holoColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 4.0);
}

// Flicker toggle
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - Experimental Shaders

/// Dimensional Rift
let dimensionalRiftCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param riftWidth "Rift Width" range(0.05, 0.3) default(0.1)
// @param edgeDistortion "Edge Distortion" range(0.0, 0.2) default(0.08)
// @param innerGlow "Inner Glow" range(0.0, 1.0) default(0.7)
// @param dimensionBleed "Dimension Bleed" range(0.0, 0.5) default(0.2)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.0)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.8)
// @param color2R "Color2 R" range(0.0, 1.0) default(1.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle alternateReality "Alternate Reality" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(true)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 riftColor = float3(color1R, color1G, color1B);
float3 edgeColor = float3(color2R, color2G, color2B);

// Dark background
float3 col = float3(0.02, 0.02, 0.05);

// Rift position with turbulence
float riftY = sin(p.y * 5.0 + timeVal) * edgeDistortion;
float riftDist = abs(p.x - riftY) - riftWidth;
riftDist += sin(p.y * 20.0 + timeVal * 3.0) * turbulence * 0.03;

// Rainbow rift color
if (rainbow > 0.5) {
    riftColor = 0.5 + 0.5 * cos(timeVal + p.y * 3.0 + float3(0.0, 2.0, 4.0));
    edgeColor = 0.5 + 0.5 * cos(timeVal + p.y * 3.0 + float3(2.0, 4.0, 0.0));
}

// Rift shape
float rift = smoothstep(0.0, -0.05, riftDist);
float edge = smoothstep(0.05, 0.0, abs(riftDist));

// Inner pulse
float innerPulse = 0.5 + 0.5 * sin(timeVal * 2.0 + p.y * 3.0);

// Rift glow
col += rift * riftColor * innerGlow * innerPulse;
col += edge * edgeColor;

// Atmospheric glow
if (glow > 0.5) {
    float glowVal = exp(-abs(riftDist) * 5.0) * glowIntensity;
    col += glowVal * riftColor;
}

// Alternate reality view through rift
if (alternateReality > 0.5 && rift > 0.0) {
    float2 altP = p;
    altP.x = -altP.x;
    altP.y += timeVal * 0.2;
    float3 altWorld = 0.5 + 0.5 * cos(altP.xyx * 3.0 + timeVal + float3(0.0, 2.0, 4.0));
    altWorld = 1.0 - altWorld;
    col = mix(col, altWorld, rift * 0.7);
}

// Dimension bleed effect
if (dimensionBleed > 0.0) {
    float bleed = smoothstep(riftWidth + dimensionBleed, riftWidth, abs(p.x - riftY));
    float3 bleedColor = 0.5 + 0.5 * cos(p.y * 5.0 + timeVal + float3(2.0, 0.0, 4.0));
    col = mix(col, bleedColor * 0.3, bleed * dimensionBleed);
}

// Reality fragments
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float fragX = sin(fi * 1.5 + timeVal * 0.5) * 0.3;
    float fragY = fract(fi * 0.35 + timeVal * 0.2) * 2.0 - 1.0;
    float2 fragPos = float2(fragX + riftY, fragY);
    float d = length(p - fragPos);
    float frag = smoothstep(0.05, 0.02, d) * rift;
    col += frag * edgeColor * 0.5;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edgeVis = abs(fract(riftDist * 10.0) - 0.5) * 2.0;
    col = mix(col, edgeColor, smoothstep(0.4, 0.5, edgeVis) * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, edgeColor, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Neural Synapse
let neuralSynapseCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param synapseCount "Synapse Count" range(5, 20) default(10)
// @param signalSpeed "Signal Speed" range(0.5, 3.0) default(1.5)
// @param dendriteBranching "Dendrite Branching" range(2, 6) default(4)
// @param neurotransmitterDensity "Neurotransmitter Density" range(0.0, 1.0) default(0.5)
// @param potentialThreshold "Potential Threshold" range(0.3, 0.8) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(1.0)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.8)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.8)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle actionPotential "Action Potential" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 neuronColor1 = float3(color1R, color1G, color1B);
float3 neuronColor2 = float3(color2R, color2G, color2B);

// Dark background
float3 col = float3(0.02, 0.03, 0.05);

// Neural network with synapses
for (int s = 0; s < 20; s++) {
    if (s >= int(synapseCount)) break;
    float fs = float(s);
    
    // Neuron positions
    float2 neuron1 = float2(
        sin(fs * 1.7) * 0.4 - 0.3,
        cos(fs * 2.3) * 0.4
    );
    float2 neuron2 = float2(
        sin(fs * 1.7 + 1.0) * 0.4 + 0.3,
        cos(fs * 2.3 + 1.0) * 0.4
    );
    
    // Axon connection
    float2 dir = normalize(neuron2 - neuron1);
    float len = length(neuron2 - neuron1);
    float2 toP = p - neuron1;
    float t = clamp(dot(toP, dir) / len, 0.0, 1.0);
    float2 closest = neuron1 + dir * t * len;
    float d = length(p - closest);
    
    // Axon rendering
    float axon = smoothstep(0.015, 0.008, d);
    float3 axonColor = rainbow > 0.5 ? 
        0.5 + 0.5 * cos(timeVal + fs * 0.5 + float3(0.0, 2.0, 4.0)) :
        mix(neuronColor1, neuronColor2, t);
    col += axon * axonColor * 0.5;
    
    // Action potential signal
    if (actionPotential > 0.5) {
        float signal = fract(t - timeVal * signalSpeed + fs * 0.2);
        float potential = step(potentialThreshold, sin(timeVal * 5.0 + fs * 2.0) * 0.5 + 0.5);
        signal = smoothstep(0.0, 0.1, signal) * smoothstep(0.2, 0.1, signal);
        col += axon * signal * potential * neuronColor1 * 1.5;
    }
    
    // Dendrite branches
    for (int b = 0; b < 6; b++) {
        if (b >= int(dendriteBranching)) break;
        float fb = float(b);
        float branchAngle = (fb / float(dendriteBranching) - 0.5) * 2.0;
        float2 branchDir = float2(
            dir.x * cos(branchAngle) - dir.y * sin(branchAngle),
            dir.x * sin(branchAngle) + dir.y * cos(branchAngle)
        );
        float2 branchStart = neuron2;
        float2 branchEnd = branchStart + branchDir * 0.1;
        float2 toBranch = p - branchStart;
        float bt = clamp(dot(toBranch, branchDir) / 0.1, 0.0, 1.0);
        float branchD = length(p - (branchStart + branchDir * bt * 0.1));
        float branch = smoothstep(0.008, 0.004, branchD);
        col += branch * neuronColor2 * 0.4;
    }
    
    // Neuron bodies
    float n1Dist = length(p - neuron1);
    float n2Dist = length(p - neuron2);
    col += smoothstep(0.03, 0.02, n1Dist) * neuronColor1 * 0.8;
    col += smoothstep(0.03, 0.02, n2Dist) * neuronColor2 * 0.8;
}

// Neurotransmitters
if (neurotransmitterDensity > 0.0) {
    for (int n = 0; n < 50; n++) {
        float fn = float(n);
        float2 ntPos = float2(
            fract(sin(fn * 127.1 + timeVal * 0.5) * 43758.5453) * 2.0 - 1.0,
            fract(sin(fn * 311.7 + timeVal * 0.3) * 43758.5453) * 2.0 - 1.0
        );
        ntPos *= 0.5;
        float d = length(p - ntPos);
        float nt = smoothstep(0.01, 0.005, d) * neurotransmitterDensity;
        col += nt * neuronColor1 * 0.8;
    }
}

// Glow effect
if (glow > 0.5) {
    col += col * glowIntensity * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(length(p) * 5.0) - 0.5) * 2.0;
    col = mix(col, neuronColor1, smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, neuronColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Data Visualization
let dataVisualizationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param barCount "Bar Count" range(5, 30) default(15)
// @param dataSpeed "Data Speed" range(0.5, 3.0) default(1.0)
// @param smoothness "Smoothness" range(0.0, 1.0) default(0.5)
// @param colorScheme "Color Scheme" range(0.0, 6.28) default(0.0)
// @param barWidth "Bar Width" range(0.5, 0.95) default(0.8)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.3)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.7)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(1.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reflection "Reflection" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 dataColor1 = float3(color1R, color1G, color1B);
float3 dataColor2 = float3(color2R, color2G, color2B);

// Transform back to 0-1 space for bars
float2 barP = p + float2(0.5);

// Dark background
float3 col = float3(0.05, 0.05, 0.08);

// Bar visualization
float barW = 1.0 / float(int(barCount));
int barIndex = int(barP.x / barW);
float barX = (float(barIndex) + 0.5) * barW;
float barLocalX = (barP.x - float(barIndex) * barW) / barW;

// Animated bar heights
float hash = fract(sin(float(barIndex) * 127.1 + floor(timeVal * dataSpeed) * 43.758) * 43758.5453);
float nextHash = fract(sin(float(barIndex) * 127.1 + floor(timeVal * dataSpeed + 1.0) * 43.758) * 43758.5453);
float barHeight = mix(hash, nextHash, smoothstep(0.0, 1.0, fract(timeVal * dataSpeed) * smoothness + (1.0 - smoothness) * step(0.5, fract(timeVal * dataSpeed))));
barHeight = barHeight * 0.7 + 0.1;

// Bar mask
float barMask = step(abs(barLocalX - 0.5), barWidth * 0.5);
barMask *= step(barP.y, barHeight);
barMask *= step(0.0, barP.y);

// Bar color
float3 barColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(float(barIndex) * 0.5 + colorScheme + timeVal + float3(0.0, 2.0, 4.0)) :
    mix(dataColor1, dataColor2, float(barIndex) / float(int(barCount)));

col = mix(col, barColor, barMask);

// Top glow
float topGlow = smoothstep(0.02, 0.0, abs(barP.y - barHeight)) * barMask;
col += topGlow * dataColor2 * 0.4;

// Reflection
if (reflection > 0.5) {
    float refY = -barP.y;
    float refMask = step(abs(barLocalX - 0.5), barWidth * 0.5);
    refMask *= step(refY, barHeight);
    refMask *= step(0.0, refY);
    refMask *= step(barP.y, 0.0);
    float refFade = 1.0 + barP.y * 3.0;
    col += barColor * refMask * refFade * 0.3;
}

// Grid lines
float grid = step(0.98, fract(barP.y * 10.0));
grid += step(0.98, fract(barP.x * float(int(barCount))));
col += grid * float3(0.1, 0.1, 0.15);

// Glow effect
if (glow > 0.5) {
    col += barMask * barColor * glowIntensity * 0.2;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + barP.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(barP.x * float(int(barCount))) - 0.5) * 2.0;
    col = mix(col, dataColor1, smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, dataColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Time Warp
let timeWarpCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param warpIntensity "Warp Intensity" range(0.0, 1.0) default(0.5)
// @param spiralSpeed "Spiral Speed" range(0.5, 3.0) default(1.0)
// @param colorCycles "Color Cycles" range(1.0, 5.0) default(2.0)
// @param centerPull "Center Pull" range(0.0, 1.0) default(0.3)
// @param echoCount "Echo Count" range(1, 5) default(3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(1.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.8)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.5)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
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
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 warpColor1 = float3(color1R, color1G, color1B);
float3 warpColor2 = float3(color2R, color2G, color2B);

// Polar coordinates
float r = length(p);
float a = atan2(p.y, p.x);

// Dark background
float3 col = float3(0.02, 0.02, 0.05);

// Direction control
float direction = reverse > 0.5 ? -1.0 : 1.0;
float timeOffset = timeVal * spiralSpeed * direction;

// Time echoes
for (int echo = 0; echo < 5; echo++) {
    if (echo >= int(echoCount)) break;
    float fe = float(echo);
    float echoDelay = fe * 0.3;
    
    // Warped coordinates
    float warpedR = r + sin(a * 3.0 + timeOffset - echoDelay) * warpIntensity * 0.2;
    warpedR += sin(r * 10.0 - timeOffset + echoDelay) * warpIntensity * 0.1;
    float warpedA = a + sin(r * 5.0 + timeOffset - echoDelay) * warpIntensity * 0.5;
    warpedA += centerPull * (1.0 - r) * sin(timeOffset);
    
    // Pattern
    float pattern = sin(warpedA * colorCycles + warpedR * 10.0 - timeOffset);
    pattern = pattern * 0.5 + 0.5;
    
    // Echo color
    float3 echoColor = rainbow > 0.5 ?
        0.5 + 0.5 * cos(pattern * 6.28 + fe * 1.5 + timeVal + float3(0.0, 2.0, 4.0)) :
        mix(warpColor1, warpColor2, pattern);
    
    float echoFade = 1.0 / (1.0 + fe * 0.5);
    col += echoColor * pattern * echoFade * 0.3;
}

// Center glow
float centerVal = exp(-r * 3.0) * centerPull;
float centerPulse = 0.5 + 0.5 * sin(timeOffset * 2.0);
col += centerVal * warpColor1 * centerPulse;

// Time trails
float trail = sin(a * 10.0 - r * 20.0 + timeOffset * 3.0);
trail = smoothstep(0.8, 1.0, trail) * (1.0 - r);
col += trail * warpColor2 * 0.4;

// Glow effect
if (glow > 0.5) {
    col += centerVal * glowIntensity * warpColor1;
}

// Radial effect
if (radial > 0.5) {
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(r * 5.0) - 0.5) * 2.0;
    col = mix(col, warpColor2, smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, warpColor1, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.8 + 0.2 * sin(timeVal * 3.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Pixel Sorting
let pixelSortingCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param sortThreshold "Sort Threshold" range(0.0, 1.0) default(0.5)
// @param sortDirection "Sort Direction" range(0.0, 1.0) default(0.0)
// @param glitchAmount "Glitch Amount" range(0.0, 1.0) default(0.3)
// @param colorBands "Color Bands" range(2.0, 10.0) default(5.0)
// @param animationSpeed "Animation Speed" range(0.0, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.8)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.3)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.5)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.3)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.8)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle vertical "Vertical" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(true)
// @toggle radial "Radial" default(false)
// @toggle glow "Glow" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
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
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 sortColor1 = float3(color1R, color1G, color1B);
float3 sortColor2 = float3(color2R, color2G, color2B);

// Vertical sort option
float2 sortP = p + float2(0.5);
if (vertical > 0.5) {
    sortP = sortP.yx;
}

// Base color pattern
float3 baseColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(sortP.xyx * 3.0 + timeVal * 0.5 + float3(0.0, 2.0, 4.0)) :
    mix(sortColor1, sortColor2, sortP.y);

// Luminance for sorting
float luminance = dot(baseColor, float3(0.299, 0.587, 0.114));

// Animated threshold
float threshold = sortThreshold + sin(timeVal * animationSpeed + sortP.y * 5.0) * 0.1;
float sorted = step(threshold, luminance);

// Sort offset
float sortOffset = sorted * (sortP.x - threshold) * sortDirection;

// Sorted coordinates
float2 sortedP = sortP;
sortedP.x = fract(sortedP.x + sortOffset + timeVal * animationSpeed * 0.1);

// Sorted color
float3 sortedColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(sortedP.xyx * colorBands + timeVal + float3(0.0, 2.0, 4.0)) :
    mix(sortColor1, sortColor2, fract(sortedP.x * colorBands));

// Combine
float3 col = mix(baseColor, sortedColor, sorted * 0.7);

// Color banding
float band = floor(sortP.y * colorBands) / colorBands;
float bandColor = fract(band + timeVal * animationSpeed * 0.2);
float3 bandCol = 0.5 + 0.5 * cos(bandColor * 6.28 + float3(0.0, 2.0, 4.0));
col = mix(col, bandCol, sorted * 0.3);

// Glitch effect
if (glitchAmount > 0.0) {
    float glitchLine = step(0.98, fract(sin(floor(sortP.y * 50.0) * 43.758 + floor(timeVal * 10.0)) * 43758.5453));
    float glitchOffset = (fract(sin(floor(sortP.y * 50.0) * 127.1) * 43758.5453) - 0.5) * glitchAmount;
    float2 glitchP = sortP;
    glitchP.x = fract(glitchP.x + glitchOffset * glitchLine);
    float3 glitchColor = 0.5 + 0.5 * cos(glitchP.xyx * 5.0 + float3(2.0, 0.0, 4.0));
    col = mix(col, glitchColor, glitchLine * glitchAmount);
}

// Glow effect
if (glow > 0.5) {
    col += sorted * sortColor1 * glowIntensity * 0.2;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + sortP.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(sortP.y * colorBands) - 0.5) * 2.0;
    col = mix(col, sortColor1, smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, sortColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Morphing Geometry
let morphingGeometryCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param shapeCount "Shape Count" range(3, 8) default(5)
// @param morphSpeed "Morph Speed" range(0.2, 2.0) default(0.5)
// @param blendSoftness "Blend Softness" range(0.1, 0.5) default(0.2)
// @param rotationSpeedShape "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param scaleOscillation "Scale Oscillation" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.7)
// @param color1B "Color1 B" range(0.0, 1.0) default(1.0)
// @param color2R "Color2 R" range(0.0, 1.0) default(1.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle fillShapes "Fill Shapes" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(true)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 shapeColor1 = float3(color1R, color1G, color1B);
float3 shapeColor2 = float3(color2R, color2G, color2B);

// Shape rotation
float shapeAngle = timeVal * rotationSpeedShape;
float c = cos(shapeAngle);
float s = sin(shapeAngle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

// Scale oscillation
float scale = 1.0 + sin(timeVal * 1.5) * scaleOscillation;
p *= scale;

// Background
float3 col = float3(0.05, 0.05, 0.08);

// Morph phase
float morphPhase = fract(timeVal * morphSpeed);
int currentShape = int(fmod(floor(timeVal * morphSpeed), shapeCount));
int nextShape = int(fmod(float(currentShape) + 1.0, shapeCount));

// Calculate distances to shapes
float currentDist = 10.0;
float nextDist = 10.0;
float r = length(p);
float a = atan2(p.y, p.x);

// Current shape
if (currentShape == 0) {
    currentDist = r - 0.5;
} else if (currentShape == 1) {
    float sides = 4.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    currentDist = r * cos(amod) - 0.4;
} else if (currentShape == 2) {
    float sides = 3.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    currentDist = r * cos(amod) - 0.4;
} else if (currentShape == 3) {
    float sides = 5.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    currentDist = r * cos(amod) - 0.4;
} else if (currentShape == 4) {
    float sides = 6.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    currentDist = r * cos(amod) - 0.4;
} else {
    currentDist = max(abs(p.x), abs(p.y)) - 0.4;
}

// Next shape
if (nextShape == 0) {
    nextDist = r - 0.5;
} else if (nextShape == 1) {
    float sides = 4.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    nextDist = r * cos(amod) - 0.4;
} else if (nextShape == 2) {
    float sides = 3.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    nextDist = r * cos(amod) - 0.4;
} else if (nextShape == 3) {
    float sides = 5.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    nextDist = r * cos(amod) - 0.4;
} else if (nextShape == 4) {
    float sides = 6.0;
    float amod = fmod(a + 3.14159 / sides, 6.28318 / sides) - 3.14159 / sides;
    nextDist = r * cos(amod) - 0.4;
} else {
    nextDist = max(abs(p.x), abs(p.y)) - 0.4;
}

// Blend shapes
float dist = mix(currentDist, nextDist, smoothstep(0.0, 1.0, morphPhase));

// Shape rendering
float shape;
if (fillShapes > 0.5) {
    shape = smoothstep(blendSoftness, -blendSoftness, dist);
} else {
    shape = smoothstep(blendSoftness, 0.0, abs(dist));
}

// Shape color
float3 currentShapeColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(timeVal + float(currentShape) + float3(0.0, 2.0, 4.0)) :
    mix(shapeColor1, shapeColor2, morphPhase);

col = mix(col, currentShapeColor, shape);

// Glow effect
if (glow > 0.5) {
    float glowVal = exp(-abs(dist) * 5.0) * glowIntensity;
    col += glowVal * currentShapeColor;
}

// Show edges
if (showEdges > 0.5) {
    float edge = smoothstep(blendSoftness * 0.5, 0.0, abs(dist));
    col = mix(col, shapeColor2, edge * 0.5);
}

// Radial effect
if (radial > 0.5) {
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, shapeColor1, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Audio Spectrum
let audioSpectrumCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param barCountSpectrum "Bar Count" range(8, 64) default(32)
// @param barSpacing "Bar Spacing" range(0.0, 0.5) default(0.2)
// @param reactivity "Reactivity" range(0.5, 2.0) default(1.0)
// @param peakHold "Peak Hold" range(0.0, 1.0) default(0.5)
// @param glowAmountSpectrum "Glow Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.0)
// @param color1G "Color1 G" range(0.0, 1.0) default(1.0)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.5)
// @param color2R "Color2 R" range(0.0, 1.0) default(1.0)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.0)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle mirrored "Mirrored" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(true)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 specColor1 = float3(color1R, color1G, color1B);
float3 specColor2 = float3(color2R, color2G, color2B);

// Transform back to 0-1 space
float2 specP = p + float2(0.5);

// Mirrored mode
if (mirrored > 0.5) {
    specP.y = abs(specP.y - 0.5) * 2.0;
}

// Background
float3 col = float3(0.02, 0.02, 0.05);

// Bar calculations
float barW = 1.0 / float(int(barCountSpectrum));
int barIndex = int(specP.x / barW);
float barLocalX = fract(specP.x / barW);
float freq = float(barIndex) / float(int(barCountSpectrum));

// Simulated audio amplitude
float amplitude = sin(freq * 10.0 + timeVal * 3.0) * 0.3 + 0.3;
amplitude += sin(freq * 5.0 - timeVal * 2.0) * 0.2;
amplitude += sin(freq * 15.0 + timeVal * 5.0) * 0.1;
amplitude *= reactivity;
amplitude = clamp(amplitude, 0.0, 0.9);

// Bar mask
float barMask = step(barSpacing * 0.5, barLocalX) * step(barLocalX, 1.0 - barSpacing * 0.5);
barMask *= step(specP.y, amplitude);

// Bar color
float3 barColor = rainbow > 0.5 ?
    0.5 + 0.5 * cos(freq * 6.28 + timeVal + float3(0.0, 2.0, 4.0)) :
    mix(specColor1, specColor2, freq);
    
// Hot color at peaks
barColor = mix(barColor, specColor2 * 1.5, step(0.7, specP.y / max(amplitude, 0.01)));

col = mix(col, barColor, barMask);

// Peak hold indicator
if (peakHold > 0.0) {
    float peakY = amplitude + 0.02;
    float peak = smoothstep(0.01, 0.0, abs(specP.y - peakY)) * barMask;
    col += peak * float3(1.0) * peakHold;
}

// Bar glow
if (glow > 0.5 && glowAmountSpectrum > 0.0) {
    float glowVal = barMask * glowAmountSpectrum * glowIntensity * 0.5;
    col += glowVal * barColor;
}

// Grid overlay
float grid = step(0.99, fract(specP.y * 20.0)) * 0.1;
grid += step(0.99, fract(specP.x * float(int(barCountSpectrum)))) * 0.05;
col += grid * float3(0.2, 0.2, 0.3);

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + specP.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(specP.y * 10.0) - 0.5) * 2.0;
    col = mix(col, specColor1, smoothstep(0.4, 0.5, edge) * 0.2);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, specColor2, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Fractal Tree Advanced
let fractalTreeAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param branchDepth "Branch Depth" range(3, 10) default(7)
// @param branchAngle "Branch Angle" range(0.2, 0.8) default(0.4)
// @param branchRatio "Branch Ratio" range(0.5, 0.8) default(0.67)
// @param windSpeed "Wind Speed" range(0.0, 1.0) default(0.2)
// @param leafDensity "Leaf Density" range(0.0, 1.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.3)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.2)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.1)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.2)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle autumn "Autumn" default(false)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(false)
// @toggle showEdges "Edges" default(false)
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
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    angle = fmod(angle, 0.523599) - 0.261799;
    p = float2(cos(angle), sin(angle)) * radius;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 trunkColor = float3(color1R, color1G, color1B);
float3 leafColor = float3(color2R, color2G, color2B);

// Adjust to tree coordinate space
p.y = -p.y + 0.3;

// Background (sky)
float3 col = float3(0.6, 0.8, 0.95);

// Rainbow or autumn colors
if (rainbow > 0.5) {
    leafColor = 0.5 + 0.5 * cos(timeVal + p.y * 3.0 + float3(0.0, 2.0, 4.0));
} else if (autumn > 0.5) {
    leafColor = float3(0.9, 0.4, 0.1);
}

// Tree variables
float tree = 0.0;
float leaves = 0.0;
float wind = sin(timeVal * windSpeed * 2.0) * windSpeed;
float thickness = 0.02;

// Draw fractal tree branches
for (int depth = 0; depth < 10; depth++) {
    if (depth >= int(branchDepth)) break;
    float fd = float(depth);
    int branches = int(pow(2.0, fd));
    for (int b = 0; b < 512; b++) {
        if (b >= branches) break;
        float fb = float(b);
        float branchPath = fb;
        float2 branchPos = float2(0.0, 0.0);
        float branchAngleTotal = 1.5708;
        float branchLen = 0.25;
        for (int d = 0; d < 10; d++) {
            if (d >= depth) break;
            float direction = fmod(floor(branchPath / pow(2.0, float(depth - d - 1))), 2.0);
            branchAngleTotal += (direction * 2.0 - 1.0) * branchAngle;
            branchAngleTotal += wind * float(d) * 0.1;
            branchPos += float2(sin(branchAngleTotal), cos(branchAngleTotal)) * branchLen;
            branchLen *= branchRatio;
        }
        float2 endPos = branchPos + float2(sin(branchAngleTotal), cos(branchAngleTotal)) * branchLen;
        float2 toP = p - branchPos;
        float2 branchDir = normalize(endPos - branchPos);
        float t = clamp(dot(toP, branchDir), 0.0, branchLen);
        float2 closest = branchPos + branchDir * t;
        float d = length(p - closest);
        float branchThickness = thickness * pow(branchRatio, fd);
        float branch = smoothstep(branchThickness, branchThickness * 0.5, d);
        tree = max(tree, branch);
        if (depth >= int(branchDepth) - 2 && leafDensity > 0.0) {
            float leafD = length(p - endPos);
            float leaf = smoothstep(0.03, 0.02, leafD) * leafDensity;
            leaves = max(leaves, leaf);
        }
    }
}

// Apply tree and leaves
col = mix(col, trunkColor, tree);
col = mix(col, leafColor, leaves);

// Glow effect
if (glow > 0.5) {
    col += leaves * glowIntensity * leafColor * 0.3;
}

// Radial effect
if (radial > 0.5) {
    float r = length(p);
    col *= 1.0 + (0.5 - r) * 0.3;
}

// Gradient overlay (sky gradient)
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + (uv.y - 0.5) * 0.4), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(tree - leaves);
    col = mix(col, float3(1.0), edge * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, trunkColor * 0.5, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.9 + 0.1 * sin(timeVal * 2.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.95 + 0.05 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.1;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.05;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.95 + 0.05 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Kaleidoscope Advanced
let kaleidoscopeAdvancedCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.0, 3.0) default(1.0)
// @param segments "Segments" range(3, 16) default(8)
// @param rotationSpeedKal "Rotation Speed" range(0.0, 2.0) default(0.5)
// @param zoomSpeed "Zoom Speed" range(0.0, 1.0) default(0.3)
// @param colorCyclesKal "Color Cycles" range(1.0, 5.0) default(2.0)
// @param patternComplexity "Pattern Complexity" range(1.0, 5.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.0, 2.0) default(1.0)
// @param colorSaturation "Saturation" range(0.0, 2.0) default(1.0)
// @param centerX "Center X" range(-1.0, 1.0) default(0.0)
// @param centerY "Center Y" range(-1.0, 1.0) default(0.0)
// @param zoom "Zoom" range(0.1, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28318) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param noiseAmount "Noise" range(0.0, 1.0) default(0.0)
// @param pixelSize "Pixel Size" range(1.0, 64.0) default(1.0)
// @param vignetteSize "Vignette" range(0.0, 1.0) default(0.0)
// @param chromaticAmount "Chromatic" range(0.0, 0.1) default(0.0)
// @param scanlineIntensity "Scanlines" range(0.0, 1.0) default(0.0)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 2.0) default(0.5)
// @param shadowIntensity "Shadow" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.2, 2.2) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 6.28318) default(0.0)
// @param color1R "Color1 R" range(0.0, 1.0) default(0.5)
// @param color1G "Color1 G" range(0.0, 1.0) default(0.3)
// @param color1B "Color1 B" range(0.0, 1.0) default(0.8)
// @param color2R "Color2 R" range(0.0, 1.0) default(0.8)
// @param color2G "Color2 G" range(0.0, 1.0) default(0.5)
// @param color2B "Color2 B" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle animate "Animate" default(true)
// @toggle rainbow "Rainbow" default(false)
// @toggle mirror "Mirror" default(true)
// @toggle showEdges "Edges" default(false)
// @toggle gradient "Gradient" default(false)
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
// @toggle kaleidoscope "Kaleidoscope" default(true)
// @toggle bloom "Bloom" default(false)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Outline" default(false)
// @toggle smooth "Smooth" default(true)
// @toggle neon "Neon" default(false)
// @toggle pastel "Pastel" default(false)
// @toggle highContrast "High Contrast" default(false)
// Time calculation
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

// Coordinate setup
float2 center = float2(0.5 + centerX, 0.5 + centerY);
float2 p = (uv - center) / zoom;

// Rotation
float cosR = cos(rotation);
float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

// Mirror effect
if (mirror > 0.5) {
    p = abs(p);
}

// Pixelate
if (pixelate > 0.5) {
    p = floor(p * pixelSize) / pixelSize;
}

// Distortion
if (distortion > 0.0) {
    p += sin(p.yx * 10.0 + timeVal) * distortion * 0.1;
}

// Colors from params
float3 kalColor1 = float3(color1R, color1G, color1B);
float3 kalColor2 = float3(color2R, color2G, color2B);

// Polar coordinates
float r = length(p);
float a = atan2(p.y, p.x);

// Animate rotation
if (animate > 0.5) {
    a += timeVal * rotationSpeedKal;
}

// Kaleidoscope effect
if (kaleidoscope > 0.5) {
    float segmentAngle = 6.28318 / float(int(segments));
    a = fmod(a + segmentAngle * 0.5, segmentAngle) - segmentAngle * 0.5;
    a = abs(a);
}

// Kaleidoscope coordinates
float2 kp = float2(cos(a), sin(a)) * r;

// Zoom animation
if (animate > 0.5) {
    float zoomAnim = 1.0 + sin(timeVal * zoomSpeed) * 0.3;
    kp *= zoomAnim;
}

// Pattern generation
float pattern1 = sin(kp.x * patternComplexity * 10.0 + timeVal) * sin(kp.y * patternComplexity * 8.0 + timeVal * 0.7);
float pattern2 = sin(length(kp) * patternComplexity * 15.0 - timeVal * 1.5);
float pattern3 = sin(atan2(kp.y, kp.x) * patternComplexity * 3.0 + timeVal * 0.5);
float combined = (pattern1 + pattern2 + pattern3) / 3.0;
combined = combined * 0.5 + 0.5;

// Color
float3 col = rainbow > 0.5 ?
    0.5 + 0.5 * cos(combined * colorCyclesKal * 6.28 + timeVal + float3(0.0, 2.0, 4.0)) :
    mix(kalColor1, kalColor2, combined);

// Mandala rings
float mandala = smoothstep(0.5, 0.48, fract(r * 5.0 - timeVal * 0.2));
col = mix(col, col * 1.3, mandala * 0.3);

// Center glow
float centerVal = exp(-r * 3.0);
col = mix(col, float3(1.0), centerVal * 0.3);

// Glow effect
if (glow > 0.5) {
    col += centerVal * glowIntensity * kalColor1;
}

// Radial effect
if (radial > 0.5) {
    col *= 1.0 + (0.5 - r) * 0.5;
}

// Gradient overlay
if (gradient > 0.5) {
    col = mix(col, col * (1.0 + p.y * 0.3), 0.5);
}

// Show edges
if (showEdges > 0.5) {
    float edge = abs(fract(a * float(int(segments)) / 6.28318) - 0.5) * 2.0;
    col = mix(col, kalColor2, smoothstep(0.4, 0.5, edge) * 0.3);
}

// Outline effect
if (outline > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    float edgeVal = length(float2(dfdx(lum), dfdy(lum)));
    col = mix(col, kalColor1, smoothstep(0.0, 0.1, edgeVal));
}

// Pulse effect
if (pulse > 0.5) {
    col *= 0.85 + 0.15 * sin(timeVal * 4.0);
}

// Flicker effect
if (flicker > 0.5) {
    float flick = fract(sin(floor(timeVal * 25.0) * 43.758) * 43758.5453);
    col *= 0.9 + 0.1 * flick;
}

// Bloom effect
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Color shift
if (colorShift > 0.5) {
    col.rgb = col.gbr * 0.5 + col.rgb * 0.5;
}

// Noise effect
if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.15;
}

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.08;
}

// Scanlines
if (scanlines > 0.5) {
    col *= 0.9 + 0.1 * sin(uv.y * 500.0 * scanlineIntensity);
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 8.0;
    col.b *= 1.0 - chromaticAmount * 8.0;
}

// Shadow and highlight
col = mix(col, col * col, shadowIntensity);
col = mix(col, sqrt(col), highlightIntensity);

// Color balance
col.r *= 1.0 + colorBalance * 0.5;
col.b *= 1.0 - colorBalance * 0.5;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Hue shift
if (hueShift > 0.0) {
    float cosH = cos(hueShift);
    float sinH = sin(hueShift);
    col = float3(
        col.r * cosH + col.g * sinH * 0.5,
        col.g * cosH - col.r * sinH * 0.5,
        col.b
    );
}

// Contrast and brightness
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Gamma
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

// Neon
if (neon > 0.5) {
    col = pow(max(col, float3(0.0)), float3(0.6)) * 1.5;
}

// Pastel
if (pastel > 0.5) {
    col = mix(col, float3(1.0), 0.3);
}

// High contrast
if (highContrast > 0.5) {
    col = smoothstep(0.2, 0.8, col);
}

// Invert
if (invert > 0.5) {
    col = 1.0 - col;
}

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Smooth
if (smooth > 0.5) {
    col = clamp(col, 0.0, 1.0);
}

col *= masterOpacity;
return float4(col, masterOpacity);
"""

