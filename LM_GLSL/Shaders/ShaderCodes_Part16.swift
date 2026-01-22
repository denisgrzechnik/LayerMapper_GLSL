//
//  ShaderCodes_Part16.swift
//  LM_GLSL
//
//  Shader codes - Part 16: Crystal & Prismatic Effects
//

import Foundation

// MARK: - Crystal Category

let crystalPrismCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Rotation Speed" range(0.0, 3.0) default(0.5)
// @param facets "Facet Count" range(3.0, 12.0) default(6.0)
// @param refraction "Refraction Index" range(1.0, 2.5) default(1.5)
// @param dispersion "Color Dispersion" range(0.0, 1.0) default(0.3)
// @param crystalSize "Crystal Size" range(0.1, 0.8) default(0.4)
// @param innerGlow "Inner Glow" range(0.0, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param prismAngle "Prism Angle" range(0.0, 6.28) default(0.0)
// @param lightAngle "Light Angle" range(0.0, 6.28) default(0.785)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param distortion "Distortion" range(0.0, 1.0) default(0.0)
// @param edgeSharpness "Edge Sharpness" range(0.001, 0.1) default(0.02)
// @param specularPower "Specular Power" range(1.0, 64.0) default(16.0)
// @param specularIntensity "Specular Intensity" range(0.0, 2.0) default(0.8)
// @param ambientLight "Ambient Light" range(0.0, 1.0) default(0.2)
// @param fresnel "Fresnel Effect" range(0.0, 2.0) default(0.5)
// @param rainbowSpread "Rainbow Spread" range(0.0, 1.0) default(0.4)
// @param crystalDepth "Crystal Depth" range(0.0, 1.0) default(0.5)
// @param facetVariation "Facet Variation" range(0.0, 1.0) default(0.2)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.5)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param noiseAmount "Surface Noise" range(0.0, 0.5) default(0.05)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showFacets "Show Facets" default(true)
// @toggle showRefraction "Show Refraction" default(true)
// @toggle showDispersion "Show Dispersion" default(true)
// @toggle radialSymmetry "Radial Symmetry" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Surface Noise" default(false)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle rainbow "Rainbow Mode" default(true)
// @toggle smooth "Smooth Edges" default(true)
// @toggle neon "Neon Glow" default(false)
// @toggle pastel "Pastel Colors" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (mirror > 0.5) p.x = abs(p.x);

// Kaleidoscope
if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float segments = facets;
    angle = fmod(angle + 3.14159, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    float radius = length(p);
    p = float2(cos(angle), sin(angle)) * radius;
}

// Crystal shape - polygon SDF
float r = length(p);
float a = atan2(p.y, p.x) + timeVal * 0.5 + prismAngle;
float sides = floor(facets);
float polygonAngle = 6.28318 / sides;
float facetAngle = fmod(a + polygonAngle * 0.5, polygonAngle) - polygonAngle * 0.5;
float crystalDist = r * cos(facetAngle) / cos(polygonAngle * 0.5);

// Facet variation
float facetVar = 1.0;
if (showFacets > 0.5) {
    float facetIndex = floor((a + 3.14159) / polygonAngle);
    facetVar = 0.9 + 0.1 * sin(facetIndex * 7.0 + timeVal);
    crystalDist *= mix(1.0, facetVar, facetVariation);
}

// Crystal mask
float crystalMask = 1.0 - smoothstep(crystalSize - edgeSharpness, crystalSize + edgeSharpness, crystalDist);

// Light direction
float2 lightDir = float2(cos(lightAngle + timeVal * 0.3), sin(lightAngle + timeVal * 0.3));

// Calculate normal (approximate)
float2 normal = normalize(p);
float ndotl = dot(normal, lightDir);

// Fresnel effect
float fresnelTerm = pow(1.0 - abs(ndotl), 2.0) * fresnel;

// Specular highlight
float specular = pow(max(ndotl, 0.0), specularPower) * specularIntensity;

// Rainbow dispersion
float3 col = float3(0.0);
if (showDispersion > 0.5 && rainbow > 0.5) {
    float dispAngle = a + timeVal * 0.2;
    col.r = 0.5 + 0.5 * sin(dispAngle * dispersion * 10.0);
    col.g = 0.5 + 0.5 * sin(dispAngle * dispersion * 10.0 + 2.094);
    col.b = 0.5 + 0.5 * sin(dispAngle * dispersion * 10.0 + 4.188);
    col = mix(float3(1.0), col, rainbowSpread);
} else {
    col = float3(0.9, 0.95, 1.0);
}

// Refraction effect
if (showRefraction > 0.5) {
    float refractionOffset = (1.0 - 1.0/refraction) * crystalDepth;
    float2 refractedUV = p + normal * refractionOffset;
    float innerPattern = sin(length(refractedUV) * 20.0 - timeVal * 2.0);
    col *= 0.8 + 0.2 * innerPattern;
}

// Inner glow
float innerGlowVal = (1.0 - crystalDist / crystalSize) * innerGlow * crystalMask;
col += innerGlowVal * float3(0.5, 0.7, 1.0);

// Specular
col += specular * crystalMask;

// Fresnel rim
col += fresnelTerm * float3(0.8, 0.9, 1.0) * crystalMask;

// Ambient
col = col * (1.0 - ambientLight) + ambientLight;

// Apply crystal mask
col *= crystalMask;

// Surface noise
if (noise > 0.5) {
    float n = fract(sin(dot(p * 50.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * crystalMask;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Hue shift
if (colorShift > 0.5) {
    float hue = hueShift * 6.28318;
    float cosH = cos(hue); float sinH = sin(hue);
    float3 weights = float3(0.299, 0.587, 0.114);
    float lum = dot(col, weights);
    col = float3(
        lum + (col.r - lum) * cosH + (col.r - lum) * sinH * 0.5,
        lum + (col.g - lum) * cosH - (col.g - lum) * sinH * 0.5,
        lum + (col.b - lum) * cosH - (col.b - lum) * sinH
    );
}

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    float glowMask = smoothstep(crystalSize, crystalSize + 0.2, crystalDist);
    glowMask *= 1.0 - smoothstep(crystalSize + 0.2, crystalSize + 0.5, crystalDist);
    col += glowMask * float3(0.3, 0.5, 0.8) * glowIntensity;
}

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
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
    col += (grain - 0.5) * 0.05;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.3) + highlightIntensity * 0.2 * crystalMask;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let diamondSparkleCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Sparkle Speed" range(0.0, 5.0) default(2.0)
// @param sparkleCount "Sparkle Count" range(10.0, 100.0) default(50.0)
// @param sparkleSize "Sparkle Size" range(0.01, 0.1) default(0.03)
// @param sparkleIntensity "Sparkle Intensity" range(0.0, 3.0) default(1.5)
// @param diamondSize "Diamond Size" range(0.1, 0.6) default(0.35)
// @param facetCount "Facet Count" range(4.0, 16.0) default(8.0)
// @param brilliance "Brilliance" range(0.0, 2.0) default(1.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.8)
// @param fireAmount "Fire Amount" range(0.0, 1.0) default(0.4)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.2)
// @param cutQuality "Cut Quality" range(0.5, 1.5) default(1.0)
// @param tableSize "Table Size" range(0.2, 0.6) default(0.4)
// @param crownHeight "Crown Height" range(0.1, 0.4) default(0.2)
// @param pavilionDepth "Pavilion Depth" range(0.3, 0.6) default(0.45)
// @param girdleWidth "Girdle Width" range(0.01, 0.1) default(0.03)
// @param lightAngle "Light Angle" range(0.0, 6.28) default(0.785)
// @param dispersionStrength "Dispersion Strength" range(0.0, 1.0) default(0.3)
// @param scintillation "Scintillation" range(0.0, 1.0) default(0.5)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.4)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.7)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.01)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param backgroundDarkness "Background Darkness" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showSparkles "Show Sparkles" default(true)
// @toggle showFire "Show Fire" default(true)
// @toggle showBrilliance "Show Brilliance" default(true)
// @toggle rotatingLight "Rotating Light" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle rainbow "Rainbow Fire" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation with animation
float rotAngle = rotation + (animated > 0.5 ? iTime * rotationSpeed : 0.0);
float cosR = cos(rotAngle); float sinR = sin(rotAngle);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Diamond shape
float r = length(p);
float a = atan2(p.y, p.x);
float sides = floor(facetCount);
float polygonAngle = 6.28318 / sides;
float facetAngle = fmod(a + polygonAngle * 0.5, polygonAngle) - polygonAngle * 0.5;
float diamondDist = r * cos(facetAngle) / cos(polygonAngle * 0.5);

float diamondMask = 1.0 - smoothstep(diamondSize - 0.01, diamondSize + 0.01, diamondDist);

// Background
float3 col = float3(1.0 - backgroundDarkness);

// Light direction
float lightA = lightAngle + (rotatingLight > 0.5 ? timeVal * 0.5 : 0.0);
float2 lightDir = float2(cos(lightA), sin(lightA));

// Facet reflections
float facetIndex = floor((a + 3.14159) / polygonAngle);
float facetPhase = facetIndex * 1.618 + timeVal;
float facetBrightness = 0.5 + 0.5 * sin(facetPhase);

// Brilliance
float3 diamondCol = float3(0.95, 0.97, 1.0);
if (showBrilliance > 0.5) {
    float brillianceVal = pow(facetBrightness, 2.0) * brilliance;
    diamondCol += brillianceVal * 0.5;
}

// Fire (color dispersion)
if (showFire > 0.5 && rainbow > 0.5) {
    float firePhase = a * dispersionStrength * 10.0 + timeVal;
    float3 fireCol = float3(
        0.5 + 0.5 * sin(firePhase),
        0.5 + 0.5 * sin(firePhase + 2.094),
        0.5 + 0.5 * sin(firePhase + 4.188)
    );
    diamondCol = mix(diamondCol, fireCol, fireAmount * facetBrightness);
}

// Scintillation (random sparkle per facet)
float scintVal = fract(sin(facetIndex * 127.1 + floor(timeVal * 10.0) * 0.1) * 43758.5453);
if (scintVal > 1.0 - scintillation) {
    diamondCol += 0.5 * scintillation;
}

// Sparkles
if (showSparkles > 0.5) {
    for (float i = 0.0; i < 20.0; i++) {
        if (i >= sparkleCount / 5.0) break;
        float sparklePhase = fract(sin(i * 127.1) * 43758.5453);
        float sparkleAngle = sparklePhase * 6.28318;
        float sparkleRadius = 0.1 + sparklePhase * 0.3;
        float2 sparklePos = float2(cos(sparkleAngle), sin(sparkleAngle)) * sparkleRadius * diamondSize;
        
        float sparkleDist = length(p - sparklePos);
        float sparkleTime = fract(timeVal * (0.5 + sparklePhase) + sparklePhase);
        float sparkleFlash = pow(1.0 - abs(sparkleTime - 0.5) * 2.0, 4.0);
        
        if (sparkleDist < sparkleSize) {
            float sparkle = (1.0 - sparkleDist / sparkleSize) * sparkleFlash * sparkleIntensity;
            diamondCol += sparkle;
        }
    }
}

// Apply diamond
col = mix(col, diamondCol, diamondMask);

// Glow around diamond
if (glow > 0.5) {
    float glowDist = diamondDist - diamondSize;
    float glowVal = exp(-glowDist * 10.0) * glowIntensity * 0.5;
    col += glowVal * float3(0.8, 0.9, 1.0);
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 3.0;
    col.b *= 1.0 - chromaticAmount * 3.0;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Flicker (for sparkle effect)
if (flicker > 0.5) {
    float flickerVal = 0.97 + 0.03 * fract(sin(floor(timeVal * 60.0) * 43.758) * 43758.5453);
    col *= flickerVal;
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.2) + highlightIntensity * 0.3 * diamondMask;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let iceFormationCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Growth Speed" range(0.0, 2.0) default(0.3)
// @param branchCount "Branch Count" range(4.0, 12.0) default(6.0)
// @param branchDepth "Branch Depth" range(1.0, 5.0) default(3.0)
// @param iceThickness "Ice Thickness" range(0.01, 0.1) default(0.03)
// @param crystalScale "Crystal Scale" range(0.5, 2.0) default(1.0)
// @param frostAmount "Frost Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.6)
// @param iceBlue "Ice Blue Tint" range(0.0, 1.0) default(0.4)
// @param transparency "Transparency" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param rotationSpeed "Rotation Speed" range(0.0, 1.0) default(0.05)
// @param noiseScale "Noise Scale" range(1.0, 10.0) default(5.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.2)
// @param subBranchAngle "Sub-Branch Angle" range(0.3, 1.2) default(0.6)
// @param growthPhase "Growth Phase" range(0.0, 1.0) default(1.0)
// @param meltAmount "Melt Amount" range(0.0, 1.0) default(0.0)
// @param refraction "Refraction" range(0.0, 0.5) default(0.1)
// @param innerGlow "Inner Glow" range(0.0, 1.0) default(0.2)
// @param rimLight "Rim Light" range(0.0, 2.0) default(0.5)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.4)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.01)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showFrost "Show Frost" default(true)
// @toggle showBranches "Show Branches" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle hexagonal "Hexagonal Symmetry" default(true)
// @toggle glow "Outer Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle snowflake "Snowflake Mode" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float rotAngle = rotation + (animated > 0.5 ? iTime * rotationSpeed : 0.0);
float cosR = cos(rotAngle); float sinR = sin(rotAngle);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Hexagonal/radial symmetry for ice crystal
float a = atan2(p.y, p.x);
float r = length(p);
float branches = floor(branchCount);

if (hexagonal > 0.5) {
    float sectorAngle = 6.28318 / branches;
    a = fmod(a + sectorAngle * 0.5, sectorAngle) - sectorAngle * 0.5;
    a = abs(a);
}

// Ice crystal branch pattern
float ice = 0.0;

if (showBranches > 0.5) {
    // Main branch
    float branchLine = abs(sin(a * branches * 0.5));
    float mainBranch = 1.0 - smoothstep(0.0, iceThickness * 2.0, branchLine * r);
    
    // Growth animation
    float growthMask = smoothstep(0.0, growthPhase, 1.0 - r / crystalScale);
    mainBranch *= growthMask;
    
    // Sub-branches
    for (float i = 1.0; i <= 4.0; i++) {
        if (i > branchDepth) break;
        float subR = r - i * 0.15;
        if (subR > 0.0) {
            float subAngle = subBranchAngle * (1.0 - i * 0.15);
            float subBranch1 = abs(sin((a - subAngle) * branches * 0.5));
            float subBranch2 = abs(sin((a + subAngle) * branches * 0.5));
            float subMask = smoothstep(i * 0.15 - 0.05, i * 0.15 + 0.05, r);
            subMask *= smoothstep(i * 0.15 + 0.2, i * 0.15, r);
            mainBranch += (1.0 - smoothstep(0.0, iceThickness, subBranch1 * subR * 0.5)) * subMask * 0.5;
            mainBranch += (1.0 - smoothstep(0.0, iceThickness, subBranch2 * subR * 0.5)) * subMask * 0.5;
        }
    }
    
    ice = mainBranch;
}

// Frost effect
if (showFrost > 0.5) {
    float frostNoise = fract(sin(dot(p * noiseScale + timeVal * 0.1, float2(12.9898, 78.233))) * 43758.5453);
    frostNoise += fract(sin(dot(p * noiseScale * 2.0 + timeVal * 0.15, float2(45.233, 12.989))) * 23421.631) * 0.5;
    frostNoise /= 1.5;
    float frostMask = smoothstep(0.5, 0.7, frostNoise) * frostAmount;
    frostMask *= (1.0 - r * 0.5); // Fade with distance
    ice = max(ice, frostMask);
}

// Melt effect
ice *= 1.0 - meltAmount * (0.5 + 0.5 * sin(r * 10.0 + timeVal));

// Ice color
float3 col = float3(0.0);
float3 iceColor = mix(float3(0.9, 0.95, 1.0), float3(0.7, 0.85, 1.0), iceBlue);

// Transparency effect
iceColor = mix(iceColor, float3(1.0), transparency * 0.5);

// Inner glow
iceColor += innerGlow * float3(0.5, 0.7, 1.0) * (1.0 - r);

// Rim light
float rim = pow(r, 2.0) * rimLight;
iceColor += rim * float3(0.8, 0.9, 1.0);

col = iceColor * ice;

// Glow
if (glow > 0.5 && showGlow > 0.5) {
    float glowVal = ice * exp(-r * 3.0) * glowIntensity;
    col += glowVal * float3(0.6, 0.8, 1.0);
}

// Noise texture
if (noise > 0.5) {
    float n = fract(sin(dot(p * 20.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * noiseAmount * 0.1 * ice;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 3.0;
    col.b *= 1.0 - chromaticAmount * 3.0;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 20.0) * 43.758) * 43758.5453);
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.2) + highlightIntensity * 0.2 * ice;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let gemCutCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.3)
// @param gemType "Gem Type" range(0.0, 4.0) default(0.0)
// @param facetCount "Facet Count" range(4.0, 16.0) default(8.0)
// @param gemSize "Gem Size" range(0.2, 0.7) default(0.4)
// @param tableRatio "Table Ratio" range(0.3, 0.7) default(0.5)
// @param crownAngle "Crown Angle" range(20.0, 45.0) default(34.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.3)
// @param gemHue "Gem Hue" range(0.0, 1.0) default(0.6)
// @param gemLightness "Gem Lightness" range(0.3, 0.9) default(0.6)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param lightAngle "Light Angle" range(0.0, 6.28) default(0.785)
// @param lightElevation "Light Elevation" range(0.2, 0.8) default(0.5)
// @param refractiveIndex "Refractive Index" range(1.4, 2.5) default(1.77)
// @param dispersion "Dispersion" range(0.0, 0.5) default(0.15)
// @param brilliance "Brilliance" range(0.0, 2.0) default(1.0)
// @param fire "Fire" range(0.0, 1.0) default(0.4)
// @param scintillation "Scintillation" range(0.0, 1.0) default(0.3)
// @param extinction "Extinction" range(0.0, 1.0) default(0.2)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.15)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.6)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param depthEffect "Depth Effect" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showTable "Show Table" default(true)
// @toggle showCrown "Show Crown" default(true)
// @toggle showPavilion "Show Pavilion" default(true)
// @toggle rotatingLight "Rotating Light" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle rainbow "Rainbow Fire" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Gem shape
float r = length(p);
float a = atan2(p.y, p.x);
float sides = floor(facetCount);
float polygonAngle = 6.28318 / sides;
float facetAngle = fmod(a + polygonAngle * 0.5, polygonAngle) - polygonAngle * 0.5;
float gemDist = r * cos(facetAngle) / cos(polygonAngle * 0.5);

float gemMask = 1.0 - smoothstep(gemSize - 0.01, gemSize + 0.01, gemDist);

// Table (top flat surface)
float tableSize = gemSize * tableRatio;
float tableMask = 1.0 - smoothstep(tableSize - 0.01, tableSize + 0.01, gemDist);

// Light calculations
float lightA = lightAngle + (rotatingLight > 0.5 ? timeVal * 0.5 : 0.0);
float3 lightDir = normalize(float3(cos(lightA), sin(lightA), lightElevation));

// Base gem color from hue
float3 gemColor;
{
    float h = gemHue * 6.0;
    float c = colorSaturation;
    float l = gemLightness;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    float3 rgb;
    if (h < 1.0) rgb = float3(c, x, 0.0);
    else if (h < 2.0) rgb = float3(x, c, 0.0);
    else if (h < 3.0) rgb = float3(0.0, c, x);
    else if (h < 4.0) rgb = float3(0.0, x, c);
    else if (h < 5.0) rgb = float3(x, 0.0, c);
    else rgb = float3(c, 0.0, x);
    gemColor = rgb + (l - 0.5);
}

// Facet index for variation
float facetIndex = floor((a + 3.14159) / polygonAngle);

// Brilliance - white light return
float facetNormal = cos(facetAngle * 2.0 + timeVal);
float brillianceVal = pow(max(facetNormal, 0.0), 2.0) * brilliance;

// Fire - spectral dispersion
float3 fireColor = float3(0.0);
if (fire > 0.0 && colorShift > 0.5) {
    float firePhase = a * dispersion * 20.0 + facetIndex * 0.5 + timeVal;
    fireColor = float3(
        0.5 + 0.5 * sin(firePhase),
        0.5 + 0.5 * sin(firePhase + 2.094),
        0.5 + 0.5 * sin(firePhase + 4.188)
    ) * fire;
}

// Scintillation - sparkle
float scintVal = 0.0;
if (scintillation > 0.0) {
    float sparklePhase = fract(sin(facetIndex * 127.1 + floor(timeVal * 15.0) * 0.1) * 43758.5453);
    if (sparklePhase > 0.7) {
        scintVal = (sparklePhase - 0.7) / 0.3 * scintillation;
    }
}

// Extinction - dark areas
float extinctionVal = 1.0 - extinction * (0.5 + 0.5 * sin(facetIndex * 2.0 + timeVal * 0.5));

// Combine gem appearance
float3 col = gemColor;
col *= extinctionVal;
col += brillianceVal * float3(1.0);
col += fireColor;
col += scintVal * float3(1.0);

// Table is brighter
if (showTable > 0.5) {
    col = mix(col, col * 1.2, tableMask);
}

// Depth effect
col *= 1.0 - depthEffect * (gemDist / gemSize) * 0.3;

// Apply gem mask
col *= gemMask;

// Glow
if (glow > 0.5) {
    float glowDist = gemDist - gemSize;
    float glowVal = exp(-glowDist * 8.0) * glowIntensity * 0.3;
    col += glowVal * gemColor;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.2) + highlightIntensity * 0.3 * gemMask;

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let stainedGlassWindowCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.2)
// @param cellCount "Cell Count" range(3.0, 20.0) default(8.0)
// @param leadWidth "Lead Width" range(0.01, 0.1) default(0.03)
// @param glassOpacity "Glass Opacity" range(0.3, 1.0) default(0.8)
// @param lightIntensity "Light Intensity" range(0.5, 2.0) default(1.2)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.7)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param warmth "Color Warmth" range(-1.0, 1.0) default(0.2)
// @param patternStyle "Pattern Style" range(0.0, 3.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param lightAngle "Light Angle" range(0.0, 6.28) default(0.785)
// @param textureAmount "Texture Amount" range(0.0, 1.0) default(0.3)
// @param leadColor "Lead Darkness" range(0.0, 1.0) default(0.9)
// @param glossiness "Glossiness" range(0.0, 1.0) default(0.3)
// @param irregularity "Irregularity" range(0.0, 1.0) default(0.2)
// @param colorPalette "Color Palette" range(0.0, 5.0) default(0.0)
// @param sunburstAmount "Sunburst Amount" range(0.0, 1.0) default(0.0)
// @param ageEffect "Age Effect" range(0.0, 1.0) default(0.1)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.7)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.3)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param dustAmount "Dust Amount" range(0.0, 1.0) default(0.05)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showLead "Show Lead" default(true)
// @toggle showTexture "Show Texture" default(true)
// @toggle showLight "Backlight" default(true)
// @toggle radialPattern "Radial Pattern" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle cathedral "Cathedral Style" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Voronoi for glass cells
float2 cellP = p * cellCount;
float2 cellI = floor(cellP);
float2 cellF = fract(cellP);

float minDist = 1.0;
float secondDist = 1.0;
float2 nearestCell = float2(0.0);
float cellId = 0.0;

for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 cellOffset = cellI + neighbor;
        
        // Random point in cell with irregularity
        float2 randOffset = float2(
            fract(sin(dot(cellOffset, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(cellOffset, float2(269.5, 183.3))) * 43758.5453)
        );
        randOffset = 0.5 + (randOffset - 0.5) * irregularity;
        
        float2 cellPoint = neighbor + randOffset - cellF;
        float dist = length(cellPoint);
        
        if (dist < minDist) {
            secondDist = minDist;
            minDist = dist;
            nearestCell = cellOffset;
            cellId = fract(sin(dot(cellOffset, float2(127.1, 311.7))) * 43758.5453);
        } else if (dist < secondDist) {
            secondDist = dist;
        }
    }
}

// Lead lines between cells
float edge = secondDist - minDist;
float leadMask = smoothstep(leadWidth, leadWidth * 0.5, edge);

// Glass color based on cell ID
float3 glassColor;
float hue = fract(cellId * colorVariation + hueShift);
{
    float h = hue * 6.0;
    float c = colorSaturation;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) glassColor = float3(c, x, 0.0);
    else if (h < 2.0) glassColor = float3(x, c, 0.0);
    else if (h < 3.0) glassColor = float3(0.0, c, x);
    else if (h < 4.0) glassColor = float3(0.0, x, c);
    else if (h < 5.0) glassColor = float3(x, 0.0, c);
    else glassColor = float3(c, 0.0, x);
    glassColor += 0.5;
}

// Warmth adjustment
glassColor.r += warmth * 0.2;
glassColor.b -= warmth * 0.2;

// Light effect
if (showLight > 0.5) {
    float lightDir = atan2(p.y, p.x);
    float lightDist = length(p);
    float sunlight = 0.7 + 0.3 * cos(lightDir - lightAngle);
    glassColor *= lightIntensity * sunlight;
}

// Glass texture
if (showTexture > 0.5) {
    float tex = fract(sin(dot(p * 50.0 + timeVal * 0.1, float2(12.9898, 78.233))) * 43758.5453);
    glassColor *= 0.9 + 0.1 * tex * textureAmount;
}

// Glossy highlights
float gloss = pow(max(1.0 - minDist * 2.0, 0.0), 4.0) * glossiness;
glassColor += gloss * 0.3;

// Lead color
float3 leadCol = float3(1.0 - leadColor) * 0.2;

// Combine glass and lead
float3 col = mix(glassColor, leadCol, leadMask);

// Apply glass opacity
col *= glassOpacity;

// Age effect (yellowish tint + dust)
if (ageEffect > 0.0) {
    col = mix(col, col * float3(1.0, 0.95, 0.85), ageEffect * 0.5);
    float dust = fract(sin(dot(p * 30.0, float2(12.9898, 78.233))) * 43758.5453);
    col *= 1.0 - dust * dustAmount * ageEffect;
}

// Glow through glass
if (glow > 0.5) {
    col += (1.0 - leadMask) * glassColor * glowIntensity * 0.2;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);

// Flicker (subtle light flicker)
if (flicker > 0.5) {
    col *= 0.98 + 0.02 * sin(iTime * 10.0 + cellId * 20.0);
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

// Shadow and highlight
col = col * (1.0 - shadowIntensity * 0.2) + highlightIntensity * 0.2 * (1.0 - leadMask);

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let hologramProjectionCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Scan Speed" range(0.0, 3.0) default(1.0)
// @param scanlineCount "Scanline Count" range(10.0, 200.0) default(80.0)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.3)
// @param flickerAmount "Flicker Amount" range(0.0, 1.0) default(0.2)
// @param glitchAmount "Glitch Amount" range(0.0, 1.0) default(0.1)
// @param holoColor "Holo Hue" range(0.0, 1.0) default(0.55)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.8)
// @param edgeGlow "Edge Glow" range(0.0, 2.0) default(0.5)
// @param projectionAngle "Projection Angle" range(0.0, 1.0) default(0.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param waveDistortion "Wave Distortion" range(0.0, 0.1) default(0.02)
// @param waveFrequency "Wave Frequency" range(1.0, 20.0) default(8.0)
// @param noiseScale "Noise Scale" range(1.0, 50.0) default(20.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.5) default(0.1)
// @param fadeHeight "Fade Height" range(0.0, 1.0) default(0.3)
// @param baseGlow "Base Glow" range(0.0, 1.0) default(0.4)
// @param convergence "RGB Convergence" range(0.0, 0.05) default(0.01)
// @param interlace "Interlace Amount" range(0.0, 1.0) default(0.2)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.5)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param dataStream "Data Stream" range(0.0, 1.0) default(0.2)
// @param signalStrength "Signal Strength" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showScanlines "Show Scanlines" default(true)
// @toggle showGlitch "Show Glitch" default(true)
// @toggle showNoise "Show Noise" default(true)
// @toggle cylindrical "Cylindrical Projection" default(false)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Static Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "CRT Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle retro "Retro CRT" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Projection distortion
if (cylindrical > 0.5) {
    float curve = projectionAngle * p.y;
    p.x *= 1.0 + curve * curve * 0.5;
}

// Wave distortion
p.x += sin(p.y * waveFrequency + timeVal * 2.0) * waveDistortion;
p.y += sin(p.x * waveFrequency * 0.7 + timeVal * 1.5) * waveDistortion * 0.5;

// Glitch offset
float2 glitchP = p;
if (showGlitch > 0.5 && glitchAmount > 0.0) {
    float glitchLine = floor(p.y * 50.0 + timeVal * 10.0);
    float glitchRand = fract(sin(glitchLine * 127.1 + floor(timeVal * 5.0)) * 43758.5453);
    if (glitchRand > 1.0 - glitchAmount * 0.3) {
        glitchP.x += (glitchRand - 0.5) * 0.2 * glitchAmount;
    }
}

// Base hologram pattern (grid/geometric)
float r = length(glitchP);
float a = atan2(glitchP.y, glitchP.x);

// Create holographic form
float holoShape = 1.0 - smoothstep(0.3, 0.5, r);
holoShape *= 0.5 + 0.5 * sin(a * 6.0 + timeVal);
holoShape *= 0.5 + 0.5 * sin(r * 20.0 - timeVal * 3.0);

// Scanlines
float scanline = 1.0;
if (showScanlines > 0.5) {
    float scanY = fract(uv.y * scanlineCount + timeVal * 0.5);
    scanline = 0.8 + 0.2 * sin(scanY * 3.14159);
    scanline = mix(1.0, scanline, scanlineIntensity);
}

// Interlace effect
if (interlace > 0.0) {
    float interlaceY = fmod(floor(uv.y * scanlineCount) + floor(timeVal * 30.0), 2.0);
    holoShape *= mix(1.0, 0.8 + 0.2 * interlaceY, interlace);
}

// Base holo color
float3 holoCol;
{
    float h = holoColor * 6.0;
    float c = 0.8;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) holoCol = float3(c, x, 0.0);
    else if (h < 2.0) holoCol = float3(x, c, 0.0);
    else if (h < 3.0) holoCol = float3(0.0, c, x);
    else if (h < 4.0) holoCol = float3(0.0, x, c);
    else if (h < 5.0) holoCol = float3(x, 0.0, c);
    else holoCol = float3(c, 0.0, x);
    holoCol = holoCol * 0.7 + 0.3;
}

// Apply color shift
if (colorShift > 0.5) {
    holoCol.r += 0.1 * sin(timeVal * 2.0);
    holoCol.b += 0.1 * cos(timeVal * 2.5);
}

float3 col = holoCol * holoShape;

// Edge glow
float edge = smoothstep(0.4, 0.5, r) * (1.0 - smoothstep(0.5, 0.6, r));
col += holoCol * edge * edgeGlow;

// Scanlines apply
col *= scanline;

// Static noise
if (showNoise > 0.5 && noise > 0.5) {
    float staticNoise = fract(sin(dot(uv * noiseScale + timeVal * 100.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (staticNoise - 0.5) * noiseAmount;
}

// Signal degradation
col *= signalStrength;

// Fade at base
float baseFade = smoothstep(0.0, fadeHeight, uv.y);
col *= mix(1.0, baseFade, 0.5);

// Base glow
col += holoCol * baseGlow * 0.2 * (1.0 - uv.y);

// Data stream effect
if (dataStream > 0.0) {
    float stream = fract(sin(floor(p.x * 20.0) * 127.1) * 43758.5453);
    stream *= fract(uv.y * 50.0 - timeVal * 5.0);
    col += stream * dataStream * holoCol * 0.3;
}

// RGB convergence (chromatic separation)
if (chromatic > 0.5) {
    col.r *= 1.0 + convergence * 10.0 * sin(uv.x * 100.0);
    col.b *= 1.0 - convergence * 10.0 * sin(uv.x * 100.0 + 1.0);
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Glow
if (glow > 0.5) {
    col += col * glowIntensity * 0.5;
}

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Pulse
if (pulse > 0.5) col *= 0.85 + 0.15 * sin(iTime * 4.0);

// Flicker
if (flicker > 0.5) {
    float flickerVal = 0.9 + 0.1 * fract(sin(floor(timeVal * 20.0) * 43.758) * 43758.5453);
    col *= flickerVal;
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.4;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.05;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let laserGridMatrixCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.5)
// @param gridSizeX "Grid Size X" range(2.0, 20.0) default(8.0)
// @param gridSizeY "Grid Size Y" range(2.0, 20.0) default(8.0)
// @param lineWidth "Line Width" range(0.005, 0.1) default(0.02)
// @param glowRadius "Glow Radius" range(0.0, 0.2) default(0.05)
// @param laserHue "Laser Hue" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 3.0) default(1.5)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param pulseSpeed "Pulse Speed" range(0.0, 10.0) default(3.0)
// @param pulseAmount "Pulse Amount" range(0.0, 1.0) default(0.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param perspective "Perspective" range(0.0, 1.0) default(0.5)
// @param horizonY "Horizon Y" range(0.0, 1.0) default(0.3)
// @param scrollSpeed "Scroll Speed" range(0.0, 5.0) default(1.0)
// @param waveAmount "Wave Amount" range(0.0, 0.5) default(0.0)
// @param waveFrequency "Wave Frequency" range(1.0, 10.0) default(3.0)
// @param scanlinePos "Scanline Position" range(0.0, 1.0) default(0.0)
// @param scanlineWidth "Scanline Width" range(0.01, 0.2) default(0.05)
// @param nodeSize "Node Size" range(0.0, 0.1) default(0.02)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.8)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.5)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.01)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param fogAmount "Fog Amount" range(0.0, 1.0) default(0.3)
// @param fadeDistance "Fade Distance" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showHorizontal "Horizontal Lines" default(true)
// @toggle showVertical "Vertical Lines" default(true)
// @toggle showNodes "Show Nodes" default(true)
// @toggle perspective3D "3D Perspective" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle retrowave "Retrowave Style" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = uv - center;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// 3D Perspective transformation
float2 gridP = p;
if (perspective3D > 0.5) {
    float depth = (uv.y - horizonY) / (1.0 - horizonY);
    depth = max(depth, 0.001);
    gridP.x = p.x / (depth * perspective + (1.0 - perspective));
    gridP.y = 1.0 / depth;
    
    // Scrolling
    gridP.y += timeVal * scrollSpeed;
}

gridP *= zoom;

// Wave distortion
if (waveAmount > 0.0) {
    gridP.x += sin(gridP.y * waveFrequency + timeVal) * waveAmount;
    gridP.y += sin(gridP.x * waveFrequency * 0.7 + timeVal * 0.8) * waveAmount * 0.5;
}

// Grid calculation
float2 gridCell = fract(gridP * float2(gridSizeX, gridSizeY));
float2 gridId = floor(gridP * float2(gridSizeX, gridSizeY));

// Line distances
float hLine = 0.0;
if (showHorizontal > 0.5) {
    hLine = 1.0 - smoothstep(0.0, lineWidth, abs(gridCell.y - 0.5) * 2.0);
}

float vLine = 0.0;
if (showVertical > 0.5) {
    vLine = 1.0 - smoothstep(0.0, lineWidth, abs(gridCell.x - 0.5) * 2.0);
}

float grid = max(hLine, vLine);

// Nodes at intersections
float node = 0.0;
if (showNodes > 0.5) {
    float2 nodePos = abs(gridCell - 0.5) * 2.0;
    float nodeDist = length(nodePos);
    node = 1.0 - smoothstep(0.0, nodeSize * 5.0, nodeDist);
}

// Glow around lines
float glowH = exp(-abs(gridCell.y - 0.5) * 2.0 / glowRadius) * 0.5;
float glowV = exp(-abs(gridCell.x - 0.5) * 2.0 / glowRadius) * 0.5;
float lineGlow = max(glowH, glowV);

// Combine
float intensity = grid + lineGlow * glowIntensity + node * 2.0;

// Laser color
float3 laserCol;
float hue = laserHue + (colorShift > 0.5 ? sin(timeVal * 0.5) * 0.1 : 0.0);
{
    float h = fract(hue) * 6.0;
    float c = 1.0;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) laserCol = float3(c, x, 0.0);
    else if (h < 2.0) laserCol = float3(x, c, 0.0);
    else if (h < 3.0) laserCol = float3(0.0, c, x);
    else if (h < 4.0) laserCol = float3(0.0, x, c);
    else if (h < 5.0) laserCol = float3(x, 0.0, c);
    else laserCol = float3(c, 0.0, x);
}

float3 col = laserCol * intensity;

// Pulse effect
if (pulse > 0.5) {
    float pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed + gridId.x * 0.5 + gridId.y * 0.7);
    col *= mix(1.0, pulseVal, pulseAmount);
}

// Distance fade for perspective
if (perspective3D > 0.5) {
    float depthFade = (uv.y - horizonY) / (1.0 - horizonY);
    depthFade = clamp(depthFade, 0.0, 1.0);
    col *= mix(fadeDistance, 1.0, depthFade);
    
    // Fog
    col = mix(col, laserCol * 0.1, (1.0 - depthFade) * fogAmount);
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 30.0) * 43.758) * 43758.5453);
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let auroraWaveCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Wave Speed" range(0.0, 2.0) default(0.3)
// @param waveCount "Wave Count" range(2.0, 10.0) default(5.0)
// @param waveHeight "Wave Height" range(0.1, 0.5) default(0.25)
// @param waveWidth "Wave Width" range(0.05, 0.3) default(0.1)
// @param shimmerSpeed "Shimmer Speed" range(0.0, 5.0) default(2.0)
// @param shimmerAmount "Shimmer Amount" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param colorSpeed "Color Speed" range(0.0, 2.0) default(0.2)
// @param colorSpread "Color Spread" range(0.0, 1.0) default(0.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.7)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param noiseScale "Noise Scale" range(1.0, 20.0) default(5.0)
// @param noiseAmount "Noise Amount" range(0.0, 1.0) default(0.3)
// @param verticalStretch "Vertical Stretch" range(0.5, 3.0) default(1.5)
// @param curtainFold "Curtain Fold" range(0.0, 1.0) default(0.4)
// @param edgeFade "Edge Fade" range(0.0, 1.0) default(0.3)
// @param baseColor1 "Base Color 1 Hue" range(0.0, 1.0) default(0.3)
// @param baseColor2 "Base Color 2 Hue" range(0.0, 1.0) default(0.55)
// @param baseColor3 "Base Color 3 Hue" range(0.0, 1.0) default(0.8)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.1)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.4)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.3)
// @param starBrightness "Star Brightness" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(true)
// @toggle showStars "Show Stars" default(true)
// @toggle showShimmer "Show Shimmer" default(true)
// @toggle showCurtain "Curtain Effect" default(true)
// @toggle multiColor "Multi Color" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(false)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle vertical "Vertical Aurora" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Background - dark sky
float3 col = float3(0.02, 0.02, 0.05);

// Stars
if (showStars > 0.5) {
    float2 starP = uv * 100.0;
    float starVal = fract(sin(dot(floor(starP), float2(127.1, 311.7))) * 43758.5453);
    if (starVal > 1.0 - starDensity * 0.1) {
        float starTwinkle = 0.5 + 0.5 * sin(timeVal * 5.0 + starVal * 100.0);
        float starSize = fract(starVal * 100.0);
        float2 starCenter = fract(starP) - 0.5;
        float starDist = length(starCenter);
        if (starDist < 0.1 * starSize) {
            col += starBrightness * starTwinkle * (1.0 - starDist / (0.1 * starSize));
        }
    }
}

// Aurora waves
float aurora = 0.0;
float3 auroraColor = float3(0.0);

for (float i = 0.0; i < 8.0; i++) {
    if (i >= waveCount) break;
    
    float wavePhase = i / waveCount;
    float waveOffset = i * 0.15;
    
    // Wave shape
    float waveX = p.x + waveOffset;
    float waveNoise = sin(waveX * noiseScale + timeVal + i * 1.5) * noiseAmount;
    waveNoise += sin(waveX * noiseScale * 2.0 + timeVal * 1.5 + i) * noiseAmount * 0.5;
    
    // Curtain fold effect
    if (showCurtain > 0.5) {
        waveNoise += sin(waveX * 3.0 + timeVal * 0.5) * curtainFold * 0.2;
    }
    
    float waveY = sin(waveX * 2.0 + timeVal * 0.7 + i * 0.5) * waveHeight + waveNoise;
    waveY *= verticalStretch;
    
    // Distance from wave
    float dist = abs(p.y - waveY);
    float waveMask = exp(-dist * dist / (waveWidth * waveWidth));
    
    // Shimmer
    if (showShimmer > 0.5) {
        float shimmer = sin(waveX * 20.0 + timeVal * shimmerSpeed + i * 3.0);
        shimmer = shimmer * 0.5 + 0.5;
        waveMask *= mix(1.0, shimmer, shimmerAmount);
    }
    
    aurora += waveMask;
    
    // Wave color
    float3 waveCol;
    if (multiColor > 0.5) {
        float hue = mix(mix(baseColor1, baseColor2, wavePhase), baseColor3, wavePhase * wavePhase);
        hue = fract(hue + (colorShift > 0.5 ? timeVal * colorSpeed : 0.0) + hueShift);
        float h = hue * 6.0;
        float c = 1.0;
        float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
        if (h < 1.0) waveCol = float3(c, x, 0.0);
        else if (h < 2.0) waveCol = float3(x, c, 0.0);
        else if (h < 3.0) waveCol = float3(0.0, c, x);
        else if (h < 4.0) waveCol = float3(0.0, x, c);
        else if (h < 5.0) waveCol = float3(x, 0.0, c);
        else waveCol = float3(c, 0.0, x);
    } else {
        waveCol = float3(0.3, 0.8, 0.4);
    }
    
    auroraColor += waveCol * waveMask * (1.0 - wavePhase * 0.3);
}

// Normalize aurora
aurora = min(aurora, 1.0);
auroraColor = auroraColor / max(waveCount * 0.5, 1.0);

// Edge fade
float edgeMask = 1.0 - smoothstep(0.3, 0.5 + edgeFade, abs(p.x));
aurora *= edgeMask;
auroraColor *= edgeMask;

// Combine with background
col = mix(col, auroraColor, aurora * 0.8);
col += auroraColor * aurora * glowIntensity * 0.5;

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);

// Flicker
if (flicker > 0.5) {
    float flickerVal = 0.95 + 0.05 * sin(timeVal * 10.0 + p.x * 20.0);
    col *= flickerVal;
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let neonTubeSignCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Flicker Speed" range(0.0, 5.0) default(1.0)
// @param tubeWidth "Tube Width" range(0.01, 0.1) default(0.03)
// @param glowSize "Glow Size" range(0.0, 0.3) default(0.1)
// @param glowIntensity "Glow Intensity" range(0.0, 3.0) default(1.5)
// @param flickerAmount "Flicker Amount" range(0.0, 1.0) default(0.2)
// @param neonHue "Neon Hue" range(0.0, 1.0) default(0.0)
// @param brightness "Brightness" range(0.0, 3.0) default(1.5)
// @param contrast "Contrast" range(0.5, 2.0) default(1.0)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param secondHue "Second Hue" range(0.0, 1.0) default(0.55)
// @param shapeType "Shape Type" range(0.0, 5.0) default(0.0)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param shapeSize "Shape Size" range(0.1, 0.5) default(0.3)
// @param shapeAspect "Shape Aspect" range(0.5, 2.0) default(1.0)
// @param bendAmount "Bend Amount" range(0.0, 1.0) default(0.0)
// @param breakAmount "Break Amount" range(0.0, 1.0) default(0.0)
// @param buzzing "Buzzing" range(0.0, 1.0) default(0.1)
// @param warmGlow "Warm Glow" range(0.0, 1.0) default(0.2)
// @param reflectionAmount "Reflection Amount" range(0.0, 1.0) default(0.3)
// @param wallColor "Wall Darkness" range(0.0, 1.0) default(0.9)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.3)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.6)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.5)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.01)
// @param gamma "Gamma" range(0.5, 2.0) default(0.9)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param gasFlicker "Gas Flicker" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror Mode" default(false)
// @toggle showGlow "Show Glow" default(true)
// @toggle showReflection "Show Reflection" default(true)
// @toggle showSecondColor "Two Colors" default(true)
// @toggle randomFlicker "Random Flicker" default(true)
// @toggle glow "Outer Glow" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle outline "Show Outline" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Extra Neon" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Aspect ratio adjustment
p.x *= shapeAspect;

// Shape distance function
float shapeDist = 1000.0;
int shapeIdx = int(fmod(shapeType, 6.0));

if (shapeIdx == 0) {
    // Circle
    shapeDist = abs(length(p) - shapeSize);
} else if (shapeIdx == 1) {
    // Heart
    float2 q = p;
    q.y -= shapeSize * 0.5;
    q.x = abs(q.x);
    float a = atan2(q.x, q.y) / 3.14159;
    float r = length(q);
    float h = abs(a);
    float d = (13.0 * h - 22.0 * h * h + 10.0 * h * h * h) / (6.0 - 5.0 * h);
    shapeDist = abs(r - shapeSize * d * 0.5);
} else if (shapeIdx == 2) {
    // Star
    float a = atan2(p.y, p.x);
    float r = length(p);
    float star = shapeSize * (0.5 + 0.5 * cos(a * 5.0));
    shapeDist = abs(r - star);
} else if (shapeIdx == 3) {
    // Triangle
    float2 q = p;
    q.y += shapeSize * 0.3;
    float d1 = abs(q.x) - shapeSize * (1.0 - q.y / shapeSize * 0.5);
    float d2 = q.y + shapeSize * 0.5;
    shapeDist = max(d1, -d2) * 0.5;
} else if (shapeIdx == 4) {
    // Diamond
    float2 q = abs(p);
    shapeDist = abs((q.x + q.y) / 1.414 - shapeSize * 0.7);
} else {
    // Infinity
    float2 q = p;
    q.x = abs(q.x) - shapeSize * 0.5;
    float r = length(q);
    shapeDist = abs(r - shapeSize * 0.4);
}

// Tube mask
float tube = 1.0 - smoothstep(0.0, tubeWidth, shapeDist);

// Glow around tube
float glowDist = shapeDist;
float glowMask = exp(-glowDist / glowSize) * glowIntensity;

// Neon color 1
float3 neonCol1;
{
    float h = fract(neonHue + hueShift) * 6.0;
    float c = 1.0;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) neonCol1 = float3(c, x, 0.0);
    else if (h < 2.0) neonCol1 = float3(x, c, 0.0);
    else if (h < 3.0) neonCol1 = float3(0.0, c, x);
    else if (h < 4.0) neonCol1 = float3(0.0, x, c);
    else if (h < 5.0) neonCol1 = float3(x, 0.0, c);
    else neonCol1 = float3(c, 0.0, x);
}

// Neon color 2
float3 neonCol2;
{
    float h = fract(secondHue + hueShift) * 6.0;
    float c = 1.0;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) neonCol2 = float3(c, x, 0.0);
    else if (h < 2.0) neonCol2 = float3(x, c, 0.0);
    else if (h < 3.0) neonCol2 = float3(0.0, c, x);
    else if (h < 4.0) neonCol2 = float3(0.0, x, c);
    else if (h < 5.0) neonCol2 = float3(x, 0.0, c);
    else neonCol2 = float3(c, 0.0, x);
}

// Mix colors based on position
float3 neonCol = neonCol1;
if (showSecondColor > 0.5) {
    float colorMix = 0.5 + 0.5 * sin(atan2(p.y, p.x) * 2.0 + timeVal * 0.5);
    neonCol = mix(neonCol1, neonCol2, colorMix);
}

// Flicker effect
float flickerVal = 1.0;
if (randomFlicker > 0.5 && flicker > 0.5) {
    float flickerRand = fract(sin(floor(timeVal * 10.0) * 43.758) * 43758.5453);
    if (flickerRand > 0.9 - flickerAmount * 0.3) {
        flickerVal = 0.3 + flickerRand * 0.7;
    }
    // Gas flicker variation
    flickerVal *= 0.9 + 0.1 * sin(timeVal * 30.0) * gasFlicker;
}

// Background (wall)
float3 col = float3(1.0 - wallColor) * 0.1;

// Warm glow on wall
if (warmGlow > 0.0) {
    float warmDist = shapeDist;
    float warm = exp(-warmDist / 0.5) * warmGlow * 0.3;
    col += warm * float3(1.0, 0.8, 0.6);
}

// Add glow
if (showGlow > 0.5 && glow > 0.5) {
    col += glowMask * neonCol * flickerVal;
}

// Add tube (bright center)
col += tube * neonCol * 2.0 * flickerVal;

// Add inner white hot
col += tube * pow(1.0 - shapeDist / tubeWidth, 4.0) * 0.5;

// Reflection below
if (showReflection > 0.5) {
    float reflY = -p.y - 0.3;
    float2 reflP = float2(p.x, reflY);
    float reflDist = 1000.0;
    
    if (shapeIdx == 0) {
        reflDist = abs(length(reflP) - shapeSize);
    } else if (shapeIdx == 1) {
        float2 q = reflP;
        q.y -= shapeSize * 0.5;
        q.x = abs(q.x);
        float a = atan2(q.x, q.y) / 3.14159;
        float r = length(q);
        float h = abs(a);
        float d = (13.0 * h - 22.0 * h * h + 10.0 * h * h * h) / (6.0 - 5.0 * h);
        reflDist = abs(r - shapeSize * d * 0.5);
    }
    
    float reflGlow = exp(-reflDist / (glowSize * 2.0)) * reflectionAmount * 0.3;
    col += reflGlow * neonCol * flickerVal * (1.0 - uv.y);
}

// Buzzing displacement
if (buzzing > 0.0 && noise > 0.5) {
    float buzz = sin(timeVal * 60.0) * buzzing * 0.01;
    col *= 1.0 + buzz;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0;
    col.b *= 1.0 - chromaticAmount * 5.0;
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);

// Neon boost
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * noiseAmount;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""

let mirrorHallCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 2.0) default(0.3)
// @param tunnelDepth "Tunnel Depth" range(1.0, 20.0) default(8.0)
// @param mirrorCount "Mirror Count" range(2.0, 8.0) default(4.0)
// @param reflectionDecay "Reflection Decay" range(0.5, 1.0) default(0.85)
// @param distortion "Distortion" range(0.0, 0.5) default(0.1)
// @param lightHue "Light Hue" range(0.0, 1.0) default(0.6)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.0)
// @param frameWidth "Frame Width" range(0.0, 0.2) default(0.05)
// @param frameColor "Frame Darkness" range(0.0, 1.0) default(0.8)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param perspectiveShift "Perspective Shift" range(-0.5, 0.5) default(0.0)
// @param tiltAmount "Tilt Amount" range(0.0, 0.5) default(0.0)
// @param scaleRatio "Scale Ratio" range(0.3, 0.9) default(0.7)
// @param offsetX "Offset X" range(-0.3, 0.3) default(0.0)
// @param offsetY "Offset Y" range(-0.3, 0.3) default(0.0)
// @param chromaticShift "Chromatic Shift" range(0.0, 0.05) default(0.01)
// @param dustAmount "Dust Amount" range(0.0, 1.0) default(0.1)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.3)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.2)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.4)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param colorDepthShift "Color Depth Shift" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showFrames "Show Frames" default(true)
// @toggle showReflections "Show Reflections" default(true)
// @toggle showDust "Show Dust" default(true)
// @toggle infiniteHall "Infinite Hall" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle spiralEffect "Spiral Effect" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

// Rotation
float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);

if (mirror > 0.5) p.x = abs(p.x);

// Base color
float3 col = float3(0.0);

// Light color
float3 lightCol;
{
    float h = fract(lightHue + hueShift) * 6.0;
    float c = 0.7;
    float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
    if (h < 1.0) lightCol = float3(c, x, 0.0);
    else if (h < 2.0) lightCol = float3(x, c, 0.0);
    else if (h < 3.0) lightCol = float3(0.0, c, x);
    else if (h < 4.0) lightCol = float3(0.0, x, c);
    else if (h < 5.0) lightCol = float3(x, 0.0, c);
    else lightCol = float3(c, 0.0, x);
    lightCol = lightCol * 0.6 + 0.4;
}

// Recursive mirror reflections
float2 currentP = p;
float currentScale = 1.0;
float reflectionStrength = 1.0;

for (float i = 0.0; i < 15.0; i++) {
    if (i >= tunnelDepth) break;
    if (reflectionStrength < 0.05) break;
    
    // Frame boundary
    float2 absP = abs(currentP);
    float maxCoord = max(absP.x, absP.y);
    
    // Inside frame
    if (maxCoord < 1.0 - frameWidth * currentScale) {
        // Reflection content
        float depth = i / tunnelDepth;
        
        // Color shift with depth
        float3 reflColor = lightCol;
        if (colorShift > 0.5) {
            float hueOffset = depth * colorDepthShift;
            float h = fract(lightHue + hueShift + hueOffset) * 6.0;
            float c = 0.7 * (1.0 - depth * 0.3);
            float x = c * (1.0 - abs(fmod(h, 2.0) - 1.0));
            if (h < 1.0) reflColor = float3(c, x, 0.0);
            else if (h < 2.0) reflColor = float3(x, c, 0.0);
            else if (h < 3.0) reflColor = float3(0.0, c, x);
            else if (h < 4.0) reflColor = float3(0.0, x, c);
            else if (h < 5.0) reflColor = float3(x, 0.0, c);
            else reflColor = float3(c, 0.0, x);
            reflColor = reflColor * 0.6 + 0.4;
        }
        
        // Add glow at center
        float centerGlow = exp(-length(currentP) * 3.0);
        col += reflColor * reflectionStrength * (0.1 + centerGlow * 0.2);
    }
    
    // Frame
    if (showFrames > 0.5 && maxCoord >= 1.0 - frameWidth * currentScale && maxCoord < 1.0) {
        col += float3(1.0 - frameColor) * 0.2 * reflectionStrength;
    }
    
    // Transform for next iteration
    currentP = (currentP + float2(offsetX, offsetY) + sin(timeVal + i) * distortion * 0.1) / scaleRatio;
    
    // Spiral effect
    if (spiralEffect > 0.5) {
        float spiralAngle = timeVal * 0.2 + i * 0.1;
        float cosSp = cos(spiralAngle); float sinSp = sin(spiralAngle);
        currentP = float2(currentP.x * cosSp - currentP.y * sinSp, currentP.x * sinSp + currentP.y * cosSp);
    }
    
    currentScale *= scaleRatio;
    reflectionStrength *= reflectionDecay;
}

// Dust particles
if (showDust > 0.5 && dustAmount > 0.0) {
    float dust = fract(sin(dot(p * 20.0 + timeVal * 0.5, float2(12.9898, 78.233))) * 43758.5453);
    if (dust > 1.0 - dustAmount * 0.1) {
        col += 0.3 * dustAmount;
    }
}

// Glow effect
if (glow > 0.5) {
    float centerDist = length(p);
    float glowVal = exp(-centerDist * 2.0) * glowIntensity;
    col += lightCol * glowVal;
}

// Color adjustments
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));
col = (col - 0.5) * contrast + 0.5;
col *= brightness;

// Saturation
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

// Bloom
if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) {
        col += (col - bloomThreshold) * bloomIntensity;
    }
}

// Chromatic aberration
if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

// Pulse
if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);

// Flicker
if (flicker > 0.5) {
    col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 20.0) * 43.758) * 43758.5453);
}

// Neon
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;

// Pastel
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);

// High contrast
if (highContrast > 0.5) col = smoothstep(0.2, 0.8, col);

// Film grain
if (filmGrain > 0.5) {
    float grain = fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
}

// Invert
if (invert > 0.5) col = 1.0 - col;

// Vignette
if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * vignetteSize * 2.0;
    col *= max(vig, 0.0);
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""



// MARK: - Holographic Interference
let holographicInterferenceCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.6)
// @param frequency "Wave Frequency" range(5.0, 50.0) default(20.0)
// @param gratingAngle "Grating Angle" range(0.0, 6.28) default(0.5)
// @param secondaryAngle "Secondary Grating" range(0.0, 6.28) default(2.5)
// @param wavePhase "Wave Phase" range(0.0, 6.28) default(0.0)
// @param colorSpread "Color Spread" range(0.0, 2.0) default(1.0)
// @param rainbowSpeed "Rainbow Speed" range(0.0, 2.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param gratingDensity "Grating Density" range(1.0, 10.0) default(3.0)
// @param interferenceDepth "Interference Depth" range(0.0, 1.0) default(0.7)
// @param shimmerAmount "Shimmer Amount" range(0.0, 1.0) default(0.5)
// @param filmThickness "Film Thickness" range(0.0, 2.0) default(1.0)
// @param viewAngle "View Angle" range(0.0, 1.0) default(0.5)
// @param noiseAmount "Noise Amount" range(0.0, 0.2) default(0.02)
// @param fringeScale "Fringe Scale" range(0.5, 3.0) default(1.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param refractionIndex "Refraction Index" range(1.0, 2.5) default(1.5)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hologramHue "Hologram Hue" range(0.0, 1.0) default(0.5)
// @param metalness "Metalness" range(0.0, 1.0) default(0.6)
// @param warpAmount "Warp Amount" range(0.0, 0.5) default(0.1)
// @param flickerSpeed "Flicker Speed" range(0.0, 5.0) default(2.0)
// @param secondaryBlend "Secondary Blend" range(0.0, 1.0) default(0.5)
// @param patternComplexity "Pattern Complexity" range(1.0, 5.0) default(2.0)
// @param edgeGlow "Edge Glow" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle dualGrating "Dual Grating" default(true)
// @toggle thinFilm "Thin Film Mode" default(true)
// @toggle angleShift "Angle Shift" default(true)
// @toggle iridescent "Iridescent" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

float grating1 = sin((p.x * cos(gratingAngle) + p.y * sin(gratingAngle)) * frequency + timeVal * 2.0);
float grating2 = sin((p.x * cos(secondaryAngle) + p.y * sin(secondaryAngle)) * frequency * gratingDensity + timeVal * 1.5);
float interference = grating1;
if (dualGrating > 0.5) interference = mix(grating1, grating1 * grating2, secondaryBlend);

float filmPhase = 0.0;
if (thinFilm > 0.5) {
    float viewDot = 1.0 - abs(dot(normalize(float3(p, 1.0)), float3(0.0, 0.0, 1.0)));
    filmPhase = viewDot * filmThickness * 10.0 + timeVal;
}

float angleEffect = 0.0;
if (angleShift > 0.5) angleEffect = length(p) * viewAngle * 2.0;

float3 col = float3(0.0);
float phase = interference * colorSpread + filmPhase + angleEffect + timeVal * rainbowSpeed;

if (iridescent > 0.5) {
    col.r = sin(phase * 3.14159) * 0.5 + 0.5;
    col.g = sin(phase * 3.14159 + 2.094) * 0.5 + 0.5;
    col.b = sin(phase * 3.14159 + 4.189) * 0.5 + 0.5;
} else {
    float hue = fmod(phase * 0.1 + hologramHue, 1.0);
    col.r = abs(hue * 6.0 - 3.0) - 1.0;
    col.g = 2.0 - abs(hue * 6.0 - 2.0);
    col.b = 2.0 - abs(hue * 6.0 - 4.0);
    col = clamp(col, 0.0, 1.0);
}

col = mix(col, col * (0.5 + 0.5 * col), metalness);
col *= interferenceDepth + (1.0 - interferenceDepth) * (0.5 + 0.5 * interference);

float fringes = sin(length(p) * fringeScale * 30.0 - timeVal * 3.0);
col *= 0.8 + 0.2 * fringes;

if (glow > 0.5) col += float3(0.3, 0.5, 0.7) * edgeGlow * max(0.0, 1.0 - abs(interference));

if (shimmerAmount > 0.0) {
    float shimmer = sin(timeVal * flickerSpeed * 10.0 + p.x * 50.0) * sin(timeVal * flickerSpeed * 8.0 + p.y * 50.0);
    col += shimmer * shimmerAmount * 0.2;
}

if (warpAmount > 0.0) col *= 1.0 + sin(timeVal * 2.0 + length(p) * 10.0) * warpAmount;

for (int i = 1; i < int(patternComplexity); i++) {
    float fi = float(i);
    col += sin((p.x * fi + p.y * (patternComplexity - fi)) * frequency * 0.5 + timeVal * fi) * 0.05;
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * flickerSpeed * 5.0) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Liquid Metal
let liquidMetalFlowCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Flow Speed" range(0.0, 2.0) default(0.4)
// @param blobScale "Blob Scale" range(0.5, 5.0) default(2.0)
// @param metalHue "Metal Hue" range(0.0, 1.0) default(0.1)
// @param reflectivity "Reflectivity" range(0.0, 1.0) default(0.8)
// @param viscosity "Viscosity" range(0.1, 2.0) default(0.5)
// @param surfaceTension "Surface Tension" range(0.0, 1.0) default(0.6)
// @param brightness "Brightness" range(0.0, 2.0) default(1.3)
// @param contrast "Contrast" range(0.5, 2.0) default(1.4)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.8)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param specularPower "Specular Power" range(1.0, 50.0) default(20.0)
// @param specularIntensity "Specular Intensity" range(0.0, 2.0) default(0.8)
// @param rippleFreq "Ripple Frequency" range(1.0, 20.0) default(8.0)
// @param rippleAmp "Ripple Amplitude" range(0.0, 0.3) default(0.1)
// @param distortAmount "Distortion Amount" range(0.0, 0.5) default(0.15)
// @param envMapStrength "Environment Map" range(0.0, 1.0) default(0.5)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param fresnelPower "Fresnel Power" range(1.0, 5.0) default(2.5)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param waveCount "Wave Count" range(1.0, 8.0) default(3.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.015)
// @param gamma "Gamma" range(0.5, 2.0) default(1.1)
// @param goldTint "Gold Tint" range(0.0, 1.0) default(0.3)
// @param silverTint "Silver Tint" range(0.0, 1.0) default(0.5)
// @param copperTint "Copper Tint" range(0.0, 1.0) default(0.2)
// @param poolDepth "Pool Depth" range(0.0, 1.0) default(0.5)
// @param causticIntensity "Caustic Intensity" range(0.0, 1.0) default(0.3)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.4)
// @param smoothness "Surface Smoothness" range(0.0, 1.0) default(0.7)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle goldMode "Gold Mode" default(false)
// @toggle silverMode "Silver Mode" default(true)
// @toggle copperMode "Copper Mode" default(false)
// @toggle showCaustics "Show Caustics" default(true)
// @toggle showRipples "Show Ripples" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

// Liquid metal surface
float surface = 0.0;
for (int i = 0; i < int(waveCount); i++) {
    float fi = float(i) + 1.0;
    float2 offset = float2(sin(timeVal * viscosity * fi), cos(timeVal * viscosity * fi * 0.7));
    surface += sin(length(p * blobScale + offset) * rippleFreq / fi + timeVal * fi) / fi;
}
surface = surface * rippleAmp + 0.5;

// Distortion
float2 distP = p;
if (distortAmount > 0.0) {
    distP.x += sin(p.y * 10.0 + timeVal) * distortAmount * turbulence;
    distP.y += cos(p.x * 10.0 + timeVal) * distortAmount * turbulence;
}

// Normal calculation for lighting
float eps = 0.01;
float surfaceX = sin(length((distP + float2(eps, 0.0)) * blobScale) * rippleFreq + timeVal);
float surfaceY = sin(length((distP + float2(0.0, eps)) * blobScale) * rippleFreq + timeVal);
float3 normal = normalize(float3(surface - surfaceX, surface - surfaceY, surfaceTension));

// Fresnel effect
float fresnel = pow(1.0 - abs(dot(normal, float3(0.0, 0.0, 1.0))), fresnelPower);

// Specular highlight
float3 lightDir = normalize(float3(0.5, 0.5, 1.0));
float3 viewDir = float3(0.0, 0.0, 1.0);
float3 halfVec = normalize(lightDir + viewDir);
float spec = pow(max(dot(normal, halfVec), 0.0), specularPower) * specularIntensity;

// Metal base color
float3 metalColor = float3(0.8, 0.8, 0.85);
if (goldMode > 0.5) metalColor = float3(1.0, 0.84, 0.0) * (1.0 + goldTint);
else if (copperMode > 0.5) metalColor = float3(0.72, 0.45, 0.2) * (1.0 + copperTint);
else if (silverMode > 0.5) metalColor = float3(0.75, 0.75, 0.8) * (1.0 + silverTint);

// Apply hue shift
float h = metalHue * 6.0;
float3 hueColor = float3(
    abs(h - 3.0) - 1.0,
    2.0 - abs(h - 2.0),
    2.0 - abs(h - 4.0)
);
hueColor = clamp(hueColor, 0.0, 1.0);
metalColor = mix(metalColor, metalColor * hueColor, 0.3);

// Environment reflection
float envRefl = sin(distP.x * 5.0 + timeVal) * cos(distP.y * 5.0 - timeVal) * 0.5 + 0.5;
metalColor = mix(metalColor, metalColor * (1.0 + envRefl * 0.3), envMapStrength);

// Caustics
if (showCaustics > 0.5) {
    float caustic = sin(distP.x * 20.0 + timeVal * 2.0) * sin(distP.y * 20.0 - timeVal * 1.5);
    caustic = pow(abs(caustic), 3.0) * causticIntensity;
    metalColor += caustic * float3(1.0, 0.95, 0.9);
}

// Ripples
if (showRipples > 0.5) {
    float ripple = sin(length(distP) * rippleFreq * 2.0 - timeVal * 3.0) * 0.5 + 0.5;
    metalColor *= 0.9 + ripple * 0.2;
}

float3 col = metalColor * reflectivity;
col += spec * float3(1.0, 0.98, 0.95);
col = mix(col, col * (1.0 + fresnel * 0.5), reflectivity);

// Pool depth darkening
col *= 1.0 - poolDepth * (1.0 - surface) * 0.3;

// Apply surface modulation
col *= 0.7 + surface * smoothness * 0.6;

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.5);
if (flicker > 0.5) col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 15.0) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Plasma Orb
let plasmaOrbCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.8)
// @param orbRadius "Orb Radius" range(0.2, 1.0) default(0.6)
// @param plasmaFreq "Plasma Frequency" range(2.0, 20.0) default(8.0)
// @param plasmaLayers "Plasma Layers" range(1.0, 6.0) default(3.0)
// @param coreGlow "Core Glow" range(0.0, 2.0) default(1.0)
// @param rimPower "Rim Power" range(1.0, 8.0) default(3.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.4)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.6)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.85)
// @param colorMix "Color Mix" range(0.0, 1.0) default(0.5)
// @param turbulence "Turbulence" range(0.0, 2.0) default(1.0)
// @param arcCount "Arc Count" range(1.0, 10.0) default(5.0)
// @param arcIntensity "Arc Intensity" range(0.0, 1.0) default(0.6)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param flickerRate "Flicker Rate" range(0.0, 10.0) default(3.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param sphereShading "Sphere Shading" range(0.0, 1.0) default(0.7)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param coronaSize "Corona Size" range(0.0, 0.5) default(0.15)
// @param coronaIntensity "Corona Intensity" range(0.0, 1.0) default(0.6)
// @param pulseDepth "Pulse Depth" range(0.0, 0.5) default(0.1)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.3)
// @param surfaceDetail "Surface Detail" range(0.0, 1.0) default(0.5)
// @param innerGlow "Inner Glow" range(0.0, 1.0) default(0.4)
// @param energyFlow "Energy Flow" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showArcs "Show Electric Arcs" default(true)
// @toggle showCorona "Show Corona" default(true)
// @toggle sphereMode "Sphere Mode" default(true)
// @toggle dualColor "Dual Color Mode" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation + timeVal * rotationSpeed);
float sinR = sin(rotation + timeVal * rotationSpeed);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

float dist = length(p);
float angle = atan2(p.y, p.x);

// Sphere mask
float sphereMask = 1.0 - smoothstep(orbRadius - 0.05, orbRadius, dist);

// Plasma calculation
float plasma = 0.0;
for (int i = 0; i < int(plasmaLayers); i++) {
    float fi = float(i) + 1.0;
    float freq = plasmaFreq * fi * 0.5;
    plasma += sin(p.x * freq + timeVal * fi) * sin(p.y * freq * 0.8 - timeVal * fi * 0.7);
    plasma += sin(dist * freq * 2.0 - timeVal * fi * 1.3) * turbulence / fi;
}
plasma = plasma / plasmaLayers * 0.5 + 0.5;

// Colors
float3 col1 = float3(0.0);
float3 col2 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = float3(0.0);
if (dualColor > 0.5) {
    col = mix(col1, col2, plasma * colorMix + 0.5 * (1.0 - colorMix));
} else {
    col = col1 * plasma;
}

// Core glow
float core = exp(-dist * 3.0 / orbRadius) * coreGlow;
col += core * mix(col1, float3(1.0), 0.5);

// Inner glow
col += exp(-dist * 5.0 / orbRadius) * innerGlow * col1;

// Sphere shading
if (sphereMode > 0.5) {
    float shade = sqrt(max(1.0 - (dist / orbRadius) * (dist / orbRadius), 0.0));
    col *= mix(1.0, shade, sphereShading);
}

// Rim lighting
float rim = pow(smoothstep(orbRadius * 0.5, orbRadius, dist), rimPower);
col += rim * col2 * 0.5;

// Electric arcs
if (showArcs > 0.5) {
    for (int i = 0; i < int(arcCount); i++) {
        float fi = float(i);
        float arcAngle = fi * 6.28 / arcCount + timeVal * 0.5;
        float arcDist = abs(angle - arcAngle);
        arcDist = min(arcDist, 6.28 - arcDist);
        float arc = exp(-arcDist * 10.0) * sin(dist * 20.0 - timeVal * 5.0 + fi) * arcIntensity;
        col += max(arc, 0.0) * col2;
    }
}

// Corona
if (showCorona > 0.5 && dist > orbRadius) {
    float corona = exp(-(dist - orbRadius) / coronaSize) * coronaIntensity;
    col += corona * mix(col1, col2, 0.5);
}

// Energy flow
if (energyFlow > 0.0) {
    float flow = sin(angle * 8.0 + dist * 10.0 - timeVal * 3.0) * 0.5 + 0.5;
    col += flow * energyFlow * 0.2 * col1 * sphereMask;
}

// Surface detail
col *= 1.0 - surfaceDetail * 0.3 * sin(dist * 50.0 + angle * 10.0 + timeVal) * sphereMask;

// Apply sphere mask
col *= sphereMask;

// Glow outside orb
if (glow > 0.5) {
    float outerGlow = exp(-max(dist - orbRadius, 0.0) * 5.0) * 0.5;
    col += outerGlow * mix(col1, col2, 0.3);
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + pulseDepth * sin(iTime * 3.0);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * flickerRate) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Neon Grid City
let neonCityScapeCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Scroll Speed" range(0.0, 3.0) default(0.5)
// @param gridSize "Grid Size" range(5.0, 50.0) default(20.0)
// @param perspective "Perspective" range(0.1, 2.0) default(0.8)
// @param horizonLine "Horizon Line" range(0.2, 0.8) default(0.4)
// @param buildingHeight "Building Height" range(0.1, 1.0) default(0.5)
// @param lineWidth "Line Width" range(0.01, 0.1) default(0.03)
// @param brightness "Brightness" range(0.0, 2.0) default(1.3)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.5)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Grid Hue" range(0.0, 1.0) default(0.85)
// @param hue2 "Building Hue" range(0.0, 1.0) default(0.55)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.8)
// @param sunSize "Sun Size" range(0.0, 0.5) default(0.15)
// @param sunGlow "Sun Glow" range(0.0, 1.0) default(0.6)
// @param fogDensity "Fog Density" range(0.0, 1.0) default(0.3)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param flickerRate "Flicker Rate" range(0.0, 10.0) default(5.0)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.2)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param starDensity "Star Density" range(0.0, 1.0) default(0.3)
// @param buildingDensity "Building Density" range(0.0, 1.0) default(0.6)
// @param reflectionStrength "Reflection Strength" range(0.0, 1.0) default(0.4)
// @param skyGradient "Sky Gradient" range(0.0, 1.0) default(0.5)
// @param neonFlicker "Neon Flicker" range(0.0, 1.0) default(0.3)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @param windowDensity "Window Density" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showSun "Show Sun" default(true)
// @toggle showStars "Show Stars" default(true)
// @toggle showBuildings "Show Buildings" default(true)
// @toggle showReflection "Show Reflection" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = float3(0.0);

// Sky gradient
float skyY = (p.y + 1.0) * 0.5;
col = mix(float3(0.0, 0.0, 0.1), float3(0.1, 0.0, 0.2), skyY * skyGradient);

// Stars
if (showStars > 0.5 && skyY > horizonLine) {
    float stars = fract(sin(dot(floor(p * 100.0), float2(12.9898, 78.233))) * 43758.5453);
    if (stars > 1.0 - starDensity * 0.1) {
        col += 0.8 * fract(sin(dot(p * 50.0 + timeVal * 0.1, float2(12.9898, 78.233))) * 43758.5453);
    }
}

// Sun
if (showSun > 0.5) {
    float2 sunPos = float2(0.0, horizonLine * 2.0 - 1.0 + 0.3);
    float sunDist = length(p - sunPos);
    float sun = 1.0 - smoothstep(sunSize * 0.8, sunSize, sunDist);
    col += sun * float3(1.0, 0.3, 0.5);
    col += exp(-sunDist / (sunSize * 3.0)) * sunGlow * float3(1.0, 0.5, 0.3);
}

// Ground grid
float groundY = horizonLine * 2.0 - 1.0;
if (p.y < groundY) {
    float depth = (groundY - p.y) * perspective;
    float gridX = fmod(abs(p.x * gridSize / depth + timeVal * 0.5), 1.0);
    float gridZ = fmod(abs(depth * gridSize + timeVal * 2.0), 1.0);
    
    float lineX = smoothstep(lineWidth, 0.0, abs(gridX - 0.5) - 0.5 + lineWidth);
    float lineZ = smoothstep(lineWidth, 0.0, abs(gridZ - 0.5) - 0.5 + lineWidth);
    
    float grid = max(lineX, lineZ);
    float fade = exp(-depth * depthFade * 2.0);
    
    col += grid * col1 * glowIntensity * fade;
    
    if (glow > 0.5) {
        col += grid * col1 * 0.3 * fade;
    }
}

// Buildings silhouette
if (showBuildings > 0.5 && p.y < groundY + buildingHeight && p.y > groundY - 0.1) {
    float buildingX = floor(p.x * 10.0);
    float bHeight = fract(sin(buildingX * 12.9898) * 43758.5453) * buildingHeight;
    
    if (p.y < groundY + bHeight * buildingDensity) {
        float buildingSil = 0.1;
        col = mix(col, float3(0.02, 0.02, 0.05), 0.9);
        
        // Windows
        float winX = fract(p.x * 30.0);
        float winY = fract((p.y - groundY) * 20.0);
        if (winX > 0.2 && winX < 0.8 && winY > 0.2 && winY < 0.8) {
            float winOn = step(0.5 - windowDensity * 0.5, fract(sin(dot(floor(float2(p.x * 30.0, (p.y - groundY) * 20.0)), float2(12.9898, 78.233))) * 43758.5453));
            float winFlicker = 1.0;
            if (neonFlicker > 0.0) {
                winFlicker = 0.7 + 0.3 * sin(timeVal * flickerRate + buildingX);
            }
            col += winOn * col2 * 0.5 * winFlicker;
        }
    }
}

// Reflection
if (showReflection > 0.5 && p.y < groundY) {
    float reflY = groundY - p.y;
    float refl = exp(-reflY * 3.0) * reflectionStrength;
    col += col1 * refl * 0.2;
}

// Fog
col = mix(col, float3(0.1, 0.05, 0.15), fogDensity * (1.0 - abs(p.y - groundY)));

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);
if (flicker > 0.5) col *= 0.95 + 0.05 * fract(sin(floor(timeVal * flickerRate) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 1.0 - scanlineIntensity * 0.5 * sin(uv.y * 400.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Morphing Shapes
let morphingPolygonsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Morph Speed" range(0.0, 2.0) default(0.4)
// @param shapeCount "Shape Count" range(1.0, 8.0) default(4.0)
// @param morphPhase "Morph Phase" range(0.0, 6.28) default(0.0)
// @param edgeSoftness "Edge Softness" range(0.01, 0.3) default(0.05)
// @param shapeSize "Shape Size" range(0.1, 1.0) default(0.4)
// @param cornerRounding "Corner Rounding" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Shape Hue 1" range(0.0, 1.0) default(0.0)
// @param hue2 "Shape Hue 2" range(0.0, 1.0) default(0.33)
// @param hue3 "Shape Hue 3" range(0.0, 1.0) default(0.66)
// @param rotationSpeed "Rotation Speed" range(0.0, 2.0) default(0.2)
// @param scaleOscillation "Scale Oscillation" range(0.0, 0.5) default(0.1)
// @param layerOffset "Layer Offset" range(0.0, 0.3) default(0.1)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param glowSize "Glow Size" range(0.0, 0.3) default(0.1)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param shadowOffset "Shadow Offset" range(0.0, 0.2) default(0.05)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.015)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param morphStyle "Morph Style" range(0.0, 3.0) default(1.0)
// @param blendMode "Blend Mode" range(0.0, 2.0) default(0.0)
// @param outlineWidth "Outline Width" range(0.0, 0.1) default(0.02)
// @param fillOpacity "Fill Opacity" range(0.0, 1.0) default(0.8)
// @param backgroundHue "Background Hue" range(0.0, 1.0) default(0.7)
// @param depthEffect "Depth Effect" range(0.0, 1.0) default(0.3)
// @param wobbleAmount "Wobble Amount" range(0.0, 0.3) default(0.05)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle multiColor "Multi-Color Mode" default(true)
// @toggle showOutline "Show Outline" default(true)
// @toggle showShadow "Show Shadow" default(true)
// @toggle layered "Layered Mode" default(true)
// @toggle glow "Glow Effect" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(false)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation + timeVal * rotationSpeed);
float sinR = sin(rotation + timeVal * rotationSpeed);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

// Morphing SDF functions
float morphT = sin(timeVal + morphPhase) * 0.5 + 0.5;

// Circle SDF
float circle = length(p) - shapeSize;

// Square SDF with rounding
float2 d = abs(p) - float2(shapeSize * 0.8);
float square = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - cornerRounding * 0.2;

// Triangle SDF
float2 tp = p;
tp.y += shapeSize * 0.3;
float triangle = max(abs(tp.x) * 0.866 + tp.y * 0.5, -tp.y) - shapeSize * 0.5;

// Star SDF (approximation)
float starAngle = atan2(p.y, p.x);
float starR = length(p);
float star = starR - shapeSize * (0.5 + 0.3 * cos(starAngle * 5.0));

// Choose morph based on style
float shape = circle;
float morphStyle2 = fmod(morphStyle, 4.0);
if (morphStyle2 < 1.0) {
    shape = mix(circle, square, morphT);
} else if (morphStyle2 < 2.0) {
    shape = mix(square, triangle, morphT);
} else if (morphStyle2 < 3.0) {
    shape = mix(triangle, star, morphT);
} else {
    shape = mix(star, circle, morphT);
}

// Wobble
if (wobbleAmount > 0.0) {
    float wobble = sin(atan2(p.y, p.x) * 6.0 + timeVal * 3.0) * wobbleAmount;
    shape += wobble;
}

// Scale oscillation
float scale = 1.0 + sin(timeVal * 2.0) * scaleOscillation;
shape /= scale;

// Color setup
float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col3 = float3(0.0);
float h3 = hue3 * 6.0;
col3.r = abs(h3 - 3.0) - 1.0;
col3.g = 2.0 - abs(h3 - 2.0);
col3.b = 2.0 - abs(h3 - 4.0);
col3 = clamp(col3, 0.0, 1.0);

float3 bgCol = float3(0.0);
float hBg = backgroundHue * 6.0;
bgCol.r = abs(hBg - 3.0) - 1.0;
bgCol.g = 2.0 - abs(hBg - 2.0);
bgCol.b = 2.0 - abs(hBg - 4.0);
bgCol = clamp(bgCol, 0.0, 1.0) * 0.1;

float3 col = bgCol;

// Shadow
if (showShadow > 0.5) {
    float2 shadowP = p + float2(shadowOffset);
    float shadowShape = length(shadowP) - shapeSize * scale;
    float shadow = 1.0 - smoothstep(-0.1, 0.1, shadowShape);
    col = mix(col, float3(0.0), shadow * 0.3);
}

// Main shape
float fillMask = 1.0 - smoothstep(-edgeSoftness, edgeSoftness, shape);
float3 shapeColor = col1;
if (multiColor > 0.5) {
    shapeColor = mix(col1, col2, morphT);
    shapeColor = mix(shapeColor, col3, sin(timeVal * 0.5) * 0.5 + 0.5);
}
col = mix(col, shapeColor * fillOpacity, fillMask);

// Layered shapes
if (layered > 0.5) {
    for (int i = 1; i < int(shapeCount); i++) {
        float fi = float(i);
        float layerShape = shape + fi * layerOffset;
        float layerMask = 1.0 - smoothstep(-edgeSoftness, edgeSoftness, layerShape);
        float3 layerCol = mix(col1, col2, fi / shapeCount);
        col = mix(col, layerCol * (1.0 - fi * depthEffect / shapeCount), layerMask * 0.3);
    }
}

// Outline
if (showOutline > 0.5) {
    float outline = abs(shape) - outlineWidth;
    float outlineMask = 1.0 - smoothstep(-edgeSoftness * 0.5, edgeSoftness * 0.5, outline);
    col = mix(col, float3(1.0), outlineMask);
}

// Glow
if (glow > 0.5 && shape < glowSize) {
    float glowMask = 1.0 - shape / glowSize;
    col += shapeColor * glowMask * 0.3;
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.5);
if (flicker > 0.5) col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 10.0) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Digital Rain
let digitalRainCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Fall Speed" range(0.0, 5.0) default(1.5)
// @param columnWidth "Column Width" range(10.0, 100.0) default(30.0)
// @param charHeight "Character Height" range(5.0, 30.0) default(15.0)
// @param trailLength "Trail Length" range(5.0, 30.0) default(15.0)
// @param density "Rain Density" range(0.1, 1.0) default(0.7)
// @param brightness "Brightness" range(0.0, 2.0) default(1.3)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.35)
// @param hue2 "Head Hue" range(0.0, 1.0) default(0.4)
// @param glowIntensity "Glow Intensity" range(0.0, 2.0) default(0.8)
// @param flickerRate "Flicker Rate" range(0.0, 20.0) default(10.0)
// @param depthLayers "Depth Layers" range(1.0, 5.0) default(3.0)
// @param depthFade "Depth Fade" range(0.0, 1.0) default(0.5)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param scanlineIntensity "Scanline Intensity" range(0.0, 1.0) default(0.1)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param charVariation "Character Variation" range(0.0, 1.0) default(0.5)
// @param columnOffset "Column Offset" range(0.0, 1.0) default(0.7)
// @param headBrightness "Head Brightness" range(1.0, 3.0) default(2.0)
// @param fadeSpeed "Fade Speed" range(0.5, 3.0) default(1.5)
// @param backgroundBrightness "Background" range(0.0, 0.3) default(0.05)
// @param waveEffect "Wave Effect" range(0.0, 0.5) default(0.1)
// @param speedVariation "Speed Variation" range(0.0, 1.0) default(0.3)
// @param glitchAmount "Glitch Amount" range(0.0, 0.5) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle multiLayer "Multi-Layer" default(true)
// @toggle showHeads "Show Bright Heads" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle waveMotion "Wave Motion" default(true)
// @toggle glitch "Glitch Effect" default(false)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = float3(0.0, backgroundBrightness * 0.3, 0.0) * col1;

// Process layers
int layers = multiLayer > 0.5 ? int(depthLayers) : 1;
for (int layer = 0; layer < layers; layer++) {
    float layerDepth = 1.0 - float(layer) * depthFade / float(layers);
    float layerSpeed = speed * (1.0 + float(layer) * speedVariation * 0.3);
    float layerTime = iTime * layerSpeed;
    
    float2 lp = p * (1.0 + float(layer) * 0.2);
    
    // Wave effect
    if (waveMotion > 0.5) {
        lp.x += sin(lp.y * 3.0 + timeVal) * waveEffect;
    }
    
    // Column calculation
    float colId = floor(lp.x * columnWidth);
    float colOffset = fract(sin(colId * 12.9898) * 43758.5453) * columnOffset * 10.0;
    float colSpeed = 1.0 + fract(sin(colId * 78.233) * 43758.5453) * speedVariation;
    
    // Skip some columns based on density
    float colDensity = fract(sin(colId * 45.678) * 43758.5453);
    if (colDensity > density) continue;
    
    // Character position in column
    float charY = fmod(lp.y * charHeight + layerTime * colSpeed + colOffset, trailLength);
    
    // Character cell
    float charX = fract(lp.x * columnWidth);
    float charCell = floor(charY);
    float charFract = fract(charY);
    
    // Random character value (simulated)
    float charVal = fract(sin(dot(float2(colId, charCell + floor(layerTime * flickerRate)), float2(12.9898, 78.233))) * 43758.5453);
    
    // Character brightness based on position in trail
    float headPos = fmod(layerTime * colSpeed + colOffset, trailLength);
    float distFromHead = charY;
    
    // Fade based on distance from head
    float fade = 1.0 - (distFromHead / trailLength);
    fade = pow(max(fade, 0.0), fadeSpeed);
    
    // Character visibility
    float charBright = 0.0;
    if (charVal > charVariation) {
        charBright = fade;
        
        // Bright head
        if (showHeads > 0.5 && distFromHead < 1.0) {
            charBright = headBrightness;
        }
        
        // Character flicker
        if (flicker > 0.5) {
            float flick = fract(sin(dot(float2(colId, floor(timeVal * flickerRate)), float2(12.9898, 78.233))) * 43758.5453);
            charBright *= 0.8 + 0.2 * flick;
        }
    }
    
    // Add character
    float3 charCol = col1;
    if (showHeads > 0.5 && distFromHead < 1.0) {
        charCol = mix(col2, float3(1.0), 0.5);
    }
    
    col += charCol * charBright * layerDepth * 0.5;
    
    // Glow
    if (showGlow > 0.5) {
        float glow = exp(-distFromHead * 0.3) * glowIntensity * 0.1;
        col += col1 * glow * layerDepth;
    }
}

// Glitch
if (glitch > 0.5 && glitchAmount > 0.0) {
    float glitchLine = step(0.98, fract(sin(floor(uv.y * 50.0 + timeVal * 5.0) * 12.9898) * 43758.5453));
    col += glitchLine * glitchAmount * col1;
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal * 0.5) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 3.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 3.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);
if (scanlines > 0.5) col *= 1.0 - scanlineIntensity * 0.3 * sin(uv.y * 500.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Cellular Automata
let cellularAutomataCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Evolution Speed" range(0.0, 10.0) default(3.0)
// @param cellSize "Cell Size" range(5.0, 50.0) default(20.0)
// @param birthThreshold "Birth Threshold" range(0.0, 1.0) default(0.4)
// @param deathThreshold "Death Threshold" range(0.0, 1.0) default(0.6)
// @param neighborWeight "Neighbor Weight" range(0.0, 1.0) default(0.5)
// @param noiseScale "Noise Scale" range(1.0, 20.0) default(5.0)
// @param brightness "Brightness" range(0.0, 2.0) default(1.2)
// @param contrast "Contrast" range(0.5, 2.0) default(1.2)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.3)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Alive Color Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Dead Color Hue" range(0.0, 1.0) default(0.7)
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.4)
// @param transitionSpeed "Transition Speed" range(0.1, 2.0) default(0.5)
// @param patternSeed "Pattern Seed" range(0.0, 100.0) default(42.0)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param borderWidth "Border Width" range(0.0, 0.3) default(0.1)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.015)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param mutationRate "Mutation Rate" range(0.0, 0.5) default(0.1)
// @param symmetry "Symmetry" range(1.0, 8.0) default(1.0)
// @param gridOpacity "Grid Opacity" range(0.0, 1.0) default(0.2)
// @param pulseRate "Pulse Rate" range(0.0, 5.0) default(1.0)
// @param colorCycle "Color Cycle" range(0.0, 2.0) default(0.3)
// @param fadeTrail "Fade Trail" range(0.0, 1.0) default(0.3)
// @param evolutionComplexity "Evolution Complexity" range(1.0, 5.0) default(2.0)
// @param cellRounding "Cell Rounding" range(0.0, 0.5) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showGrid "Show Grid" default(true)
// @toggle showGlow "Show Glow" default(true)
// @toggle smoothTransition "Smooth Transition" default(true)
// @toggle colorByAge "Color By Age" default(true)
// @toggle symmetricPattern "Symmetric Pattern" default(false)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

// Apply symmetry
if (symmetricPattern > 0.5) {
    float symAngle = atan2(p.y, p.x);
    float symR = length(p);
    symAngle = fmod(abs(symAngle), 6.28 / symmetry);
    p = float2(cos(symAngle), sin(symAngle)) * symR;
}

// Cell coordinates
float2 cellCoord = floor(p * cellSize);
float2 cellUV = fract(p * cellSize);

// Generation based on time
float generation = floor(timeVal);
float genFract = fract(timeVal);

// Pseudo-random function for cell state
float cellState = 0.0;
float prevState = 0.0;

// Calculate cell state based on neighbors (simplified Game of Life-like)
float aliveCount = 0.0;
for (int dy = -1; dy <= 1; dy++) {
    for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        float2 neighborCoord = cellCoord + float2(float(dx), float(dy));
        float neighborSeed = fract(sin(dot(neighborCoord + patternSeed + generation * 0.1, float2(12.9898, 78.233))) * 43758.5453);
        
        // Add some noise-based pattern
        float noiseVal = sin(neighborCoord.x * noiseScale * 0.1 + generation) * sin(neighborCoord.y * noiseScale * 0.1 + generation * 0.7);
        neighborSeed = fract(neighborSeed + noiseVal * 0.5);
        
        aliveCount += step(deathThreshold, neighborSeed);
    }
}

// Current cell seed
float currentSeed = fract(sin(dot(cellCoord + patternSeed + generation * 0.1, float2(12.9898, 78.233))) * 43758.5453);
float noiseVal = sin(cellCoord.x * noiseScale * 0.1 + generation) * sin(cellCoord.y * noiseScale * 0.1 + generation * 0.7);
currentSeed = fract(currentSeed + noiseVal * 0.5);

// Apply birth/death rules (simplified)
float neighborRatio = aliveCount / 8.0 * neighborWeight + currentSeed * (1.0 - neighborWeight);

// Evolution complexity adds more rules
for (int i = 0; i < int(evolutionComplexity); i++) {
    float fi = float(i);
    neighborRatio = fract(neighborRatio + sin(neighborRatio * 10.0 + fi) * 0.1);
}

cellState = smoothstep(birthThreshold - 0.1, birthThreshold + 0.1, neighborRatio);

// Mutation
if (mutationRate > 0.0) {
    float mutation = fract(sin(dot(cellCoord + generation, float2(45.678, 89.012))) * 43758.5453);
    if (mutation < mutationRate) {
        cellState = 1.0 - cellState;
    }
}

// Previous generation state for transition
float prevSeed = fract(sin(dot(cellCoord + patternSeed + (generation - 1.0) * 0.1, float2(12.9898, 78.233))) * 43758.5453);
prevState = step(birthThreshold, prevSeed);

// Smooth transition
if (smoothTransition > 0.5) {
    cellState = mix(prevState, cellState, genFract * transitionSpeed);
}

// Fade trail
cellState = max(cellState, prevState * fadeTrail);

// Colors
float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = col2 * 0.1;

// Cell shape (rounded square)
float2 cellCenter = cellUV - 0.5;
float cellDist = max(abs(cellCenter.x), abs(cellCenter.y));
float cellMask = 1.0 - smoothstep(0.4 - cellRounding, 0.5 - cellRounding, cellDist);

// Color by age
float3 cellColor = col1;
if (colorByAge > 0.5) {
    float age = fract(generation * 0.1 + cellCoord.x * 0.01 + cellCoord.y * 0.01);
    cellColor = mix(col1, col2, age);
}

// Color cycle
if (colorShift > 0.5) {
    float cycle = sin(timeVal * colorCycle + cellCoord.x * 0.1 + cellCoord.y * 0.1) * 0.5 + 0.5;
    cellColor = mix(cellColor, col2, cycle * 0.3);
}

col = mix(col, cellColor, cellState * cellMask);

// Grid
if (showGrid > 0.5) {
    float grid = max(
        smoothstep(borderWidth, 0.0, cellUV.x) + smoothstep(1.0 - borderWidth, 1.0, cellUV.x),
        smoothstep(borderWidth, 0.0, cellUV.y) + smoothstep(1.0 - borderWidth, 1.0, cellUV.y)
    );
    col = mix(col, col2 * 0.3, grid * gridOpacity);
}

// Glow
if (showGlow > 0.5) {
    float glow = cellState * exp(-cellDist * 3.0) * glowIntensity;
    col += cellColor * glow * 0.5;
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * pulseRate * 2.0);
if (flicker > 0.5) col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 10.0) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Energy Field
let energyFieldCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Animation Speed" range(0.0, 3.0) default(0.6)
// @param fieldFrequency "Field Frequency" range(2.0, 20.0) default(8.0)
// @param fieldLayers "Field Layers" range(1.0, 8.0) default(4.0)
// @param fieldIntensity "Field Intensity" range(0.0, 2.0) default(1.0)
// @param pulseRate "Pulse Rate" range(0.0, 5.0) default(1.5)
// @param distortionAmount "Distortion" range(0.0, 0.5) default(0.2)
// @param brightness "Brightness" range(0.0, 2.0) default(1.3)
// @param contrast "Contrast" range(0.5, 2.0) default(1.3)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.4)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Core Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Edge Hue" range(0.0, 1.0) default(0.7)
// @param coreRadius "Core Radius" range(0.0, 0.5) default(0.15)
// @param coreGlow "Core Glow" range(0.0, 2.0) default(1.2)
// @param arcCount "Arc Count" range(1.0, 12.0) default(6.0)
// @param arcWidth "Arc Width" range(0.01, 0.2) default(0.05)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.03)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.4)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.5)
// @param flickerSpeed "Flicker Speed" range(0.0, 10.0) default(5.0)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.02)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param spiralTwist "Spiral Twist" range(0.0, 5.0) default(1.0)
// @param expansionRate "Expansion Rate" range(0.0, 2.0) default(0.5)
// @param waveAmplitude "Wave Amplitude" range(0.0, 0.5) default(0.15)
// @param particleDensity "Particle Density" range(0.0, 1.0) default(0.3)
// @param ringCount "Ring Count" range(1.0, 10.0) default(5.0)
// @param ringWidth "Ring Width" range(0.01, 0.1) default(0.03)
// @param turbulence "Turbulence" range(0.0, 1.0) default(0.4)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showCore "Show Core" default(true)
// @toggle showArcs "Show Arcs" default(true)
// @toggle showRings "Show Rings" default(true)
// @toggle showParticles "Show Particles" default(true)
// @toggle spiralMode "Spiral Mode" default(true)
// @toggle pulse "Pulse" default(true)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(true)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

if (kaleidoscope > 0.5) {
    float angle = atan2(p.y, p.x);
    float r = length(p);
    angle = fmod(angle + 3.14159, 3.14159 / 3.0) - 3.14159 / 6.0;
    p = float2(cos(angle), sin(angle)) * r;
}

float dist = length(p);
float angle = atan2(p.y, p.x);

// Colors
float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = float3(0.0);

// Core
if (showCore > 0.5) {
    float core = exp(-dist / coreRadius) * coreGlow;
    col += mix(col1, float3(1.0), 0.5) * core;
}

// Spiral field
if (spiralMode > 0.5) {
    float spiral = angle + dist * spiralTwist - timeVal * 2.0;
    float spiralField = sin(spiral * fieldFrequency) * 0.5 + 0.5;
    spiralField *= exp(-dist * 2.0);
    col += col1 * spiralField * fieldIntensity * 0.3;
}

// Energy arcs
if (showArcs > 0.5) {
    for (int i = 0; i < int(arcCount); i++) {
        float fi = float(i);
        float arcAngle = fi * 6.28 / arcCount + timeVal;
        float arcPhase = sin(dist * 10.0 - timeVal * 3.0 + fi);
        float arcDist = abs(angle - arcAngle);
        arcDist = min(arcDist, 6.28 - arcDist);
        float arc = exp(-arcDist / arcWidth) * exp(-dist * 1.5);
        arc *= 0.5 + 0.5 * arcPhase;
        col += col2 * arc * 0.3;
    }
}

// Rings
if (showRings > 0.5) {
    for (int i = 0; i < int(ringCount); i++) {
        float fi = float(i);
        float ringR = (fi + 1.0) / ringCount * (0.5 + expansionRate * sin(timeVal + fi));
        float ring = exp(-abs(dist - ringR) / ringWidth);
        float wave = sin(angle * waveAmplitude * 10.0 + timeVal * 2.0 - fi) * 0.3 + 0.7;
        col += mix(col1, col2, fi / ringCount) * ring * wave * 0.2;
    }
}

// Field layers
for (int i = 0; i < int(fieldLayers); i++) {
    float fi = float(i) + 1.0;
    float layerDist = distortionAmount * sin(angle * fi * 3.0 + timeVal * fi);
    float field = sin((dist + layerDist) * fieldFrequency * fi - timeVal * fi * 0.5);
    field = pow(abs(field), 3.0) * turbulence;
    col += mix(col1, col2, fi / fieldLayers) * field * 0.1 / fi;
}

// Particles
if (showParticles > 0.5) {
    float2 particleGrid = floor(p * 20.0);
    float particleRand = fract(sin(dot(particleGrid + floor(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    if (particleRand > 1.0 - particleDensity) {
        float2 particlePos = (particleGrid + 0.5) / 20.0;
        float particleDist = length(p - particlePos);
        float particle = exp(-particleDist * 50.0) * (0.5 + 0.5 * sin(timeVal * 5.0 + particleRand * 10.0));
        col += float3(1.0) * particle * 0.5;
    }
}

// Pulse
if (pulse > 0.5) {
    float pulseMod = 0.8 + 0.2 * sin(iTime * pulseRate * 2.0);
    col *= pulseMod;
}

// Color shift
if (colorShift > 0.5) {
    float shift = sin(timeVal * 0.5) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * dist;
    col.b *= 1.0 - chromaticAmount * 5.0 * dist;
}

if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * flickerSpeed) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.6)) * 1.4;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Smoke Simulation
let smokeSimCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Flow Speed" range(0.0, 2.0) default(0.4)
// @param smokeScale "Smoke Scale" range(1.0, 10.0) default(4.0)
// @param smokeLayers "Smoke Layers" range(1.0, 8.0) default(5.0)
// @param smokeDensity "Smoke Density" range(0.0, 2.0) default(1.0)
// @param turbulence "Turbulence" range(0.0, 2.0) default(0.8)
// @param riseSpeed "Rise Speed" range(0.0, 2.0) default(0.5)
// @param brightness "Brightness" range(0.0, 2.0) default(1.0)
// @param contrast "Contrast" range(0.5, 2.0) default(1.1)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(0.8)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Smoke Hue" range(0.0, 1.0) default(0.6)
// @param hue2 "Highlight Hue" range(0.0, 1.0) default(0.55)
// @param sourceX "Source X" range(0.0, 1.0) default(0.5)
// @param sourceY "Source Y" range(0.0, 1.0) default(0.8)
// @param sourceWidth "Source Width" range(0.05, 0.5) default(0.2)
// @param windX "Wind X" range(-1.0, 1.0) default(0.1)
// @param noiseAmount "Noise Amount" range(0.0, 0.1) default(0.02)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.6)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.3)
// @param fadeHeight "Fade Height" range(0.0, 1.0) default(0.7)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.2)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.1) default(0.01)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param dissipation "Dissipation" range(0.0, 1.0) default(0.4)
// @param swirl "Swirl" range(0.0, 2.0) default(0.3)
// @param wispiness "Wispiness" range(0.0, 1.0) default(0.5)
// @param edgeSoftness "Edge Softness" range(0.0, 1.0) default(0.6)
// @param lightAngle "Light Angle" range(0.0, 6.28) default(0.8)
// @param lightIntensity "Light Intensity" range(0.0, 1.0) default(0.4)
// @param volumetricDepth "Volumetric Depth" range(0.0, 1.0) default(0.5)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle showSource "Show Source" default(true)
// @toggle volumetric "Volumetric Mode" default(true)
// @toggle showLighting "Show Lighting" default(true)
// @toggle coloredSmoke "Colored Smoke" default(true)
// @toggle wispy "Wispy Mode" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(false)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(false)
// @toggle scanlines "Scanlines" default(false)
// @toggle pixelate "Pixelate" default(false)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(false)
// @toggle colorShift "Color Shift" default(false)
// @toggle smooth "Smooth Rendering" default(true)
// @toggle neon "Neon Mode" default(false)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

// Colors
float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col = float3(0.0);

// Smoke source position
float2 sourcePos = float2(sourceX - 0.5, sourceY - 0.5) * 2.0;

// Multi-octave smoke noise
float smoke = 0.0;
float amplitude = 1.0;
float frequency = 1.0;

for (int i = 0; i < int(smokeLayers); i++) {
    float fi = float(i);
    
    // Rising motion with wind
    float2 smokeP = p;
    smokeP.y += timeVal * riseSpeed * (1.0 + fi * 0.2);
    smokeP.x += timeVal * windX * (1.0 + fi * 0.1);
    
    // Turbulence distortion
    smokeP.x += sin(smokeP.y * 5.0 + timeVal * 2.0 + fi) * turbulence * 0.1;
    smokeP.y += cos(smokeP.x * 5.0 + timeVal * 1.5 + fi) * turbulence * 0.1;
    
    // Swirl
    if (swirl > 0.0) {
        float swirlAngle = length(smokeP - sourcePos) * swirl - timeVal;
        float cs = cos(swirlAngle); float ss = sin(swirlAngle);
        smokeP = float2(smokeP.x * cs - smokeP.y * ss, smokeP.x * ss + smokeP.y * cs);
    }
    
    // Noise calculation
    float n = sin(smokeP.x * smokeScale * frequency + fi * 1.7) * 
              sin(smokeP.y * smokeScale * frequency + fi * 2.3);
    n += sin((smokeP.x + smokeP.y) * smokeScale * frequency * 0.7 + timeVal + fi) * 0.5;
    
    smoke += n * amplitude;
    amplitude *= 0.5;
    frequency *= 2.0;
}

smoke = smoke * 0.5 + 0.5;

// Distance from source
float distFromSource = length(p - sourcePos);
float sourceInfluence = exp(-distFromSource / sourceWidth);

// Rising fade
float riseFade = 1.0 - smoothstep(0.0, fadeHeight * 2.0, p.y - sourcePos.y);
riseFade = max(riseFade, 0.0);

// Dissipation based on height
float diss = 1.0 - (p.y - sourcePos.y) * dissipation;
diss = max(diss, 0.0);

// Combine smoke
float finalSmoke = smoke * sourceInfluence * riseFade * diss * smokeDensity;

// Wispiness
if (wispy > 0.5) {
    float wisp = sin(p.x * 20.0 + timeVal * 3.0) * sin(p.y * 15.0 - timeVal * 2.0);
    finalSmoke *= 0.7 + 0.3 * wisp * wispiness;
}

// Edge softness
finalSmoke = smoothstep(0.0, edgeSoftness, finalSmoke);

// Volumetric layers
float3 smokeColor = float3(0.7, 0.7, 0.75);
if (coloredSmoke > 0.5) {
    smokeColor = mix(col1, col2, finalSmoke);
}

// Volumetric depth
if (volumetric > 0.5) {
    float depth = finalSmoke * volumetricDepth;
    smokeColor *= 0.8 + 0.4 * depth;
}

// Lighting
if (showLighting > 0.5) {
    float2 lightDir = float2(cos(lightAngle), sin(lightAngle));
    float lighting = dot(normalize(float2(smoke - 0.5, 0.5)), lightDir) * 0.5 + 0.5;
    smokeColor *= 0.7 + 0.6 * lighting * lightIntensity;
}

col = smokeColor * finalSmoke;

// Source glow
if (showSource > 0.5) {
    float sourceGlow = exp(-distFromSource * 5.0) * 0.3;
    col += col2 * sourceGlow;
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal * 0.5) * 0.1;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 5.0 * length(p);
    col.b *= 1.0 - chromaticAmount * 5.0 * length(p);
}

if (pulse > 0.5) col *= 0.9 + 0.1 * sin(iTime * 2.0);
if (flicker > 0.5) col *= 0.95 + 0.05 * fract(sin(floor(timeVal * 10.0) * 12.9898) * 43758.5453);
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 800.0);
if (pixelate > 0.5) col *= 0.9 + 0.1 * fract(sin(dot(floor(uv * 100.0) / 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.5)) * 1.5;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.03;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""


// MARK: - Glitch Art
let glitchArtisticCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Glitch Speed" range(0.0, 10.0) default(3.0)
// @param glitchIntensity "Glitch Intensity" range(0.0, 1.0) default(0.5)
// @param blockSize "Block Size" range(5.0, 100.0) default(30.0)
// @param scanlineGap "Scanline Gap" range(1.0, 20.0) default(5.0)
// @param rgbShift "RGB Shift" range(0.0, 0.1) default(0.02)
// @param noiseStrength "Noise Strength" range(0.0, 1.0) default(0.3)
// @param brightness "Brightness" range(0.0, 2.0) default(1.1)
// @param contrast "Contrast" range(0.5, 2.0) default(1.3)
// @param colorSaturation "Color Saturation" range(0.0, 2.0) default(1.2)
// @param centerX "Center X" range(0.0, 1.0) default(0.5)
// @param centerY "Center Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.2, 3.0) default(1.0)
// @param rotation "Rotation" range(0.0, 6.28) default(0.0)
// @param hue1 "Primary Hue" range(0.0, 1.0) default(0.55)
// @param hue2 "Secondary Hue" range(0.0, 1.0) default(0.0)
// @param hue3 "Tertiary Hue" range(0.0, 1.0) default(0.85)
// @param flickerRate "Flicker Rate" range(0.0, 30.0) default(15.0)
// @param tearAmount "Tear Amount" range(0.0, 0.5) default(0.1)
// @param waveDistort "Wave Distortion" range(0.0, 0.2) default(0.05)
// @param noiseAmount "Noise Amount" range(0.0, 0.2) default(0.05)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.4)
// @param jitterAmount "Jitter Amount" range(0.0, 0.1) default(0.02)
// @param vignetteSize "Vignette Size" range(0.0, 1.0) default(0.3)
// @param chromaticAmount "Chromatic Aberration" range(0.0, 0.2) default(0.05)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param corruptionRate "Corruption Rate" range(0.0, 1.0) default(0.3)
// @param stripeWidth "Stripe Width" range(0.0, 0.1) default(0.02)
// @param digitalNoise "Digital Noise" range(0.0, 1.0) default(0.4)
// @param colorBleed "Color Bleed" range(0.0, 0.1) default(0.02)
// @param blockGlitch "Block Glitch" range(0.0, 1.0) default(0.3)
// @param scanIntensity "Scan Intensity" range(0.0, 1.0) default(0.3)
// @param frameSkip "Frame Skip" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle reverse "Reverse Direction" default(false)
// @toggle mirror "Mirror X" default(false)
// @toggle rgbSplit "RGB Split" default(true)
// @toggle blockCorrupt "Block Corruption" default(true)
// @toggle scanlines "Scanlines" default(true)
// @toggle digitalDistort "Digital Distortion" default(true)
// @toggle colorGlitch "Color Glitch" default(true)
// @toggle pulse "Pulse" default(false)
// @toggle flicker "Flicker" default(true)
// @toggle noise "Add Noise" default(true)
// @toggle vignette "Vignette" default(true)
// @toggle invert "Invert Colors" default(false)
// @toggle chromatic "Chromatic Aberration" default(true)
// @toggle horizontalTear "Horizontal Tear" default(true)
// @toggle pixelate "Pixelate" default(true)
// @toggle kaleidoscope "Kaleidoscope" default(false)
// @toggle bloom "Bloom" default(true)
// @toggle filmGrain "Film Grain" default(true)
// @toggle colorShift "Color Shift" default(true)
// @toggle smooth "Smooth Rendering" default(false)
// @toggle neon "Neon Mode" default(true)
// @toggle pastel "Pastel Mode" default(false)
// @toggle highContrast "High Contrast" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * zoom * 2.0;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float cosR = cos(rotation); float sinR = sin(rotation);
p = float2(p.x * cosR - p.y * sinR, p.x * sinR + p.y * cosR);
if (mirror > 0.5) p.x = abs(p.x);

// Random functions
float random = fract(sin(dot(floor(uv * blockSize + floor(timeVal * flickerRate)), float2(12.9898, 78.233))) * 43758.5453);
float lineRandom = fract(sin(floor(uv.y * 100.0 + timeVal * 5.0) * 12.9898) * 43758.5453);

float2 glitchUV = uv;

// Horizontal tear / displacement
if (horizontalTear > 0.5 && lineRandom > 1.0 - tearAmount) {
    float tearOffset = (fract(sin(floor(uv.y * 50.0) * 78.233) * 43758.5453) - 0.5) * tearAmount * 2.0;
    glitchUV.x += tearOffset;
}

// Wave distortion
if (digitalDistort > 0.5) {
    glitchUV.x += sin(glitchUV.y * 50.0 + timeVal * 10.0) * waveDistort * lineRandom;
    glitchUV.y += sin(glitchUV.x * 30.0 + timeVal * 8.0) * waveDistort * 0.5;
}

// Jitter
if (jitterAmount > 0.0) {
    float jitter = fract(sin(timeVal * 100.0) * 43758.5453);
    if (jitter > 0.9) {
        glitchUV += (float2(
            fract(sin(timeVal * 123.456) * 43758.5453),
            fract(sin(timeVal * 789.012) * 43758.5453)
        ) - 0.5) * jitterAmount;
    }
}

// Generate base colors from position
float3 col1 = float3(0.0);
float h1 = hue1 * 6.0;
col1.r = abs(h1 - 3.0) - 1.0;
col1.g = 2.0 - abs(h1 - 2.0);
col1.b = 2.0 - abs(h1 - 4.0);
col1 = clamp(col1, 0.0, 1.0);

float3 col2 = float3(0.0);
float h2 = hue2 * 6.0;
col2.r = abs(h2 - 3.0) - 1.0;
col2.g = 2.0 - abs(h2 - 2.0);
col2.b = 2.0 - abs(h2 - 4.0);
col2 = clamp(col2, 0.0, 1.0);

float3 col3 = float3(0.0);
float h3 = hue3 * 6.0;
col3.r = abs(h3 - 3.0) - 1.0;
col3.g = 2.0 - abs(h3 - 2.0);
col3.b = 2.0 - abs(h3 - 4.0);
col3 = clamp(col3, 0.0, 1.0);

// Base pattern
float pattern = sin(glitchUV.x * 20.0 + timeVal) * sin(glitchUV.y * 20.0 - timeVal * 0.7);
float3 col = mix(col1, col2, pattern * 0.5 + 0.5);

// RGB split
if (rgbSplit > 0.5) {
    float splitAmount = rgbShift * (1.0 + sin(timeVal * 5.0) * 0.5);
    float rShift = sin((glitchUV.x - splitAmount) * 20.0 + timeVal) * sin(glitchUV.y * 20.0 - timeVal * 0.7);
    float bShift = sin((glitchUV.x + splitAmount) * 20.0 + timeVal) * sin(glitchUV.y * 20.0 - timeVal * 0.7);
    col.r = mix(col1.r, col2.r, rShift * 0.5 + 0.5);
    col.b = mix(col1.b, col2.b, bShift * 0.5 + 0.5);
}

// Block corruption
if (blockCorrupt > 0.5 && random > 1.0 - blockGlitch * corruptionRate) {
    float2 blockCoord = floor(glitchUV * blockSize);
    float blockRand = fract(sin(dot(blockCoord + floor(timeVal), float2(12.9898, 78.233))) * 43758.5453);
    
    // Corrupt block color
    col = mix(col, col3, blockRand);
    
    // Offset block
    if (blockRand > 0.7) {
        col = mix(col1, col2, blockRand);
    }
}

// Color glitch
if (colorGlitch > 0.5) {
    float colorRand = fract(sin(floor(timeVal * flickerRate) * 45.678) * 43758.5453);
    if (colorRand > 0.8) {
        float3 temp = col.rgb;
        col.rgb = float3(temp.g, temp.b, temp.r);
    }
}

// Digital noise
if (digitalNoise > 0.0) {
    float dNoise = fract(sin(dot(glitchUV * 500.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    if (dNoise > 1.0 - digitalNoise * noiseStrength * 0.1) {
        col = mix(col, float3(dNoise), digitalNoise * 0.5);
    }
}

// Stripes
if (stripeWidth > 0.0) {
    float stripe = step(0.5, fract(glitchUV.y / stripeWidth + timeVal));
    if (lineRandom > 0.9) {
        col = mix(col, col * 0.5, stripe * 0.3);
    }
}

// Frame skip effect
if (frameSkip > 0.0) {
    float skipRand = fract(sin(floor(timeVal * 10.0) * 12.9898) * 43758.5453);
    if (skipRand < frameSkip) {
        col *= 0.7;
    }
}

// Scanlines
if (scanlines > 0.5) {
    float scan = sin(glitchUV.y * 200.0 / scanlineGap) * 0.5 + 0.5;
    col *= 1.0 - scan * scanIntensity * 0.3;
}

// Color bleed
if (colorBleed > 0.0) {
    col.r = mix(col.r, col.g, colorBleed * sin(timeVal * 10.0));
    col.b = mix(col.b, col.r, colorBleed * cos(timeVal * 8.0));
}

col = ((col - 0.5) * contrast + 0.5) * brightness;
float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);

if (colorShift > 0.5) {
    float shift = sin(timeVal * 2.0) * 0.2;
    col.rgb = float3(col.r * cos(shift) - col.g * sin(shift), col.r * sin(shift) + col.g * cos(shift), col.b);
}

col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (bloom > 0.5) {
    float lum = dot(col, float3(0.299, 0.587, 0.114));
    if (lum > bloomThreshold) col += (col - bloomThreshold) * bloomIntensity;
}

if (chromatic > 0.5) {
    col.r *= 1.0 + chromaticAmount * 3.0 * (0.5 + 0.5 * sin(timeVal * 10.0));
    col.b *= 1.0 - chromaticAmount * 3.0 * (0.5 + 0.5 * cos(timeVal * 8.0));
}

if (pulse > 0.5) col *= 0.8 + 0.2 * fract(sin(floor(timeVal * 5.0) * 12.9898) * 43758.5453);
if (flicker > 0.5) col *= 0.9 + 0.1 * fract(sin(floor(timeVal * flickerRate) * 12.9898) * 43758.5453);
if (pixelate > 0.5) {
    float2 pixelUV = floor(glitchUV * blockSize) / blockSize;
    col *= 0.9 + 0.1 * fract(sin(dot(pixelUV, float2(12.9898, 78.233))) * 43758.5453);
}
if (noise > 0.5) col += (fract(sin(dot(uv + timeVal, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * noiseAmount;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (highContrast > 0.5) col = smoothstep(0.1, 0.9, col);
if (filmGrain > 0.5) col += (fract(sin(dot(uv * 100.0 + iTime, float2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.05;
if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) col *= max(1.0 - length(uv - 0.5) * vignetteSize * 2.0, 0.0);
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col * masterOpacity, masterOpacity);
"""
