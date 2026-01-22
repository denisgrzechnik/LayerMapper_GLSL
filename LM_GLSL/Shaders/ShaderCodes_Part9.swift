//
//  ShaderCodes_Part9.swift
//  LM_GLSL
//
//  Shader codes - Part 9: Organic, Nature & Biological Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Organic & Nature Parametric Shaders

/// Living Cells
let livingCellsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param cellCount "Cell Count" range(3.0, 15.0) default(8.0)
// @param membraneThickness "Membrane Thickness" range(0.01, 0.1) default(0.03)
// @param nucleusSize "Nucleus Size" range(0.1, 0.4) default(0.25)
// @param motility "Motility" range(0.0, 1.0) default(0.5)
// @param divisionRate "Division Rate" range(0.0, 1.0) default(0.3)
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
// @param glowIntensity "Glow Intensity" range(0.0, 1.0) default(0.2)
// @param bloomThreshold "Bloom Threshold" range(0.0, 1.0) default(0.5)
// @param bloomIntensity "Bloom Intensity" range(0.0, 1.0) default(0.0)
// @param shadowIntensity "Shadow Intensity" range(0.0, 1.0) default(0.0)
// @param highlightIntensity "Highlight Intensity" range(0.0, 1.0) default(0.0)
// @param colorBalance "Color Balance" range(-1.0, 1.0) default(0.0)
// @param gamma "Gamma" range(0.5, 2.0) default(1.0)
// @param hueShift "Hue Shift" range(0.0, 1.0) default(0.0)
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.8)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.85)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.5)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.6)
// @toggle animated "Animated" default(true)
// @toggle organelles "Organelles" default(true)
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
float2 p = uv * cellCount;
float2 id = floor(p);
float2 f = fract(p) - 0.5;
float3 cytoplasmColor = float3(color1Red, color1Green, color1Blue);
float3 nucleusColor = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.9, 0.95, 1.0);

float minDist = 10.0;
float2 closestId = float2(0.0);
for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 cellId = id + neighbor;
        float2 cellOffset = float2(
            fract(sin(dot(cellId, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(cellId, float2(269.5, 183.3))) * 43758.5453)
        );
        cellOffset = 0.5 + motility * 0.4 * sin(timeVal * 0.5 + 6.28 * cellOffset);
        float2 cellPos = neighbor + cellOffset - f - 0.5;
        float d = length(cellPos);
        if (d < minDist) {
            minDist = d;
            closestId = cellId;
        }
    }
}

float cell = smoothstep(0.5, 0.5 - membraneThickness, minDist);
float membrane = smoothstep(membraneThickness, 0.0, abs(minDist - 0.45));
float nucleus = smoothstep(nucleusSize + 0.02, nucleusSize, minDist);
float3 membraneColor = mix(cytoplasmColor, nucleusColor, 0.5);

col = mix(col, cytoplasmColor, cell);
col = mix(col, membraneColor, membrane);
col = mix(col, nucleusColor, nucleus);

if (organelles > 0.5 && cell > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float angle = fi * 1.256 + timeVal * 0.3;
        float radius = 0.15 + fi * 0.05;
        float2 orgPos = float2(cos(angle), sin(angle)) * radius;
        float org = smoothstep(0.03, 0.02, length(f - orgPos));
        col = mix(col, float3(0.7, 0.5, 0.6), org * 0.5);
    }
}

if (divisionRate > 0.0) {
    float phase = fract(timeVal * divisionRate * 0.1 + fract(sin(dot(closestId, float2(12.9898, 78.233))) * 43758.5453));
    if (phase > 0.8) {
        float split = smoothstep(0.01, 0.0, abs(f.x));
        col = mix(col, membraneColor, split * (phase - 0.8) * 5.0);
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Neural Network
let neuralNetworkCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param neuronCount "Neuron Count" range(5, 20) default(10)
// @param connectionDensity "Connection Density" range(0.3, 1.0) default(0.6)
// @param signalSpeed "Signal Speed" range(0.5, 3.0) default(1.5)
// @param pulseIntensity "Pulse Intensity" range(0.0, 1.0) default(0.7)
// @param axonThickness "Axon Thickness" range(0.005, 0.02) default(0.008)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(1.0)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(1.0)
// @toggle animated "Animated" default(true)
// @toggle synapticFire "Synaptic Fire" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 signalColor = float3(color1Red, color1Green, color1Blue);
float3 neuronColor = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.02, 0.03, 0.05);

float2 neurons[20];
for (int i = 0; i < 20; i++) {
    if (i >= int(neuronCount)) break;
    float fi = float(i);
    float angle = fi * 6.28 / float(neuronCount);
    float radius = 0.5 + sin(fi * 2.0) * 0.2;
    neurons[i] = float2(cos(angle), sin(angle)) * radius;
}

for (int i = 0; i < 20; i++) {
    if (i >= int(neuronCount)) break;
    for (int j = i + 1; j < 20; j++) {
        if (j >= int(neuronCount)) break;
        float connChance = fract(sin(float(i * 20 + j) * 43.758) * 43758.5453);
        if (connChance > connectionDensity) continue;
        float2 n1 = neurons[i];
        float2 n2 = neurons[j];
        float2 dir = n2 - n1;
        float len = length(dir);
        dir = dir / len;
        float2 toP = p - n1;
        float t = clamp(dot(toP, dir), 0.0, len);
        float2 closest = n1 + dir * t;
        float d = length(p - closest);
        float axon = smoothstep(axonThickness, 0.0, d);
        float signal = fract(t / len - timeVal * signalSpeed + float(i) * 0.1);
        signal = pow(signal, 3.0) * pulseIntensity;
        col += axon * float3(0.2, 0.3, 0.4);
        col += axon * signal * signalColor;
    }
}

for (int i = 0; i < 20; i++) {
    if (i >= int(neuronCount)) break;
    float2 n = neurons[i];
    float d = length(p - n);
    float neuron = smoothstep(0.04, 0.02, d);
    float glowVal = exp(-d * 10.0) * glowIntensity;
    col += neuron * neuronColor;
    col += glowVal * float3(0.3, 0.5, 0.7);
    if (synapticFire > 0.5) {
        float fire = step(0.95, sin(timeVal * 5.0 + float(i) * 1.5));
        col += neuron * fire * float3(1.0, 0.8, 0.3);
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * 0.2;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// DNA Helix
let dnaHelixCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param helixTwist "Helix Twist" range(1.0, 5.0) default(2.0)
// @param helixWidth "Helix Width" range(0.1, 0.4) default(0.25)
// @param baseCount "Base Pairs" range(5, 20) default(10)
// @param rotationSpeed "Rotation Speed" range(0.1, 2.0) default(0.5)
// @param strandThickness "Strand Thickness" range(0.01, 0.05) default(0.02)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle showBases "Show Bases" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 strand1Color = float3(color1Red, color1Green, color1Blue);
float3 strand2Color = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.02, 0.02, 0.05);

float y = p.y;
float twist = y * helixTwist * 6.28 + timeVal * rotationSpeed;
float strand1X = sin(twist) * helixWidth;
float strand2X = sin(twist + 3.14159) * helixWidth;
float z1 = cos(twist);
float z2 = cos(twist + 3.14159);
float d1 = abs(p.x - strand1X);
float d2 = abs(p.x - strand2X);
float depth1 = z1 * 0.5 + 0.5;
float depth2 = z2 * 0.5 + 0.5;
float strand1 = smoothstep(strandThickness, 0.0, d1) * depth1;
float strand2 = smoothstep(strandThickness, 0.0, d2) * depth2;

col += strand1 * strand1Color;
col += strand2 * strand2Color;

if (showBases > 0.5) {
    for (int i = 0; i < 20; i++) {
        if (i >= int(baseCount)) break;
        float fi = float(i);
        float baseY = (fi / float(baseCount)) * 2.0 - 1.0;
        if (abs(y - baseY) < 0.03) {
            float baseTwist = baseY * helixTwist * 6.28 + timeVal * rotationSpeed;
            float baseX1 = sin(baseTwist) * helixWidth;
            float baseX2 = sin(baseTwist + 3.14159) * helixWidth;
            float baseZ = cos(baseTwist);
            if (baseZ > 0.0) {
                float baseT = (p.x - baseX1) / (baseX2 - baseX1);
                if (baseT > 0.0 && baseT < 1.0) {
                    float baseD = abs(y - baseY);
                    float base = smoothstep(0.02, 0.01, baseD);
                    float3 baseColor = (baseT < 0.5) ? float3(0.2, 0.8, 0.3) : float3(0.8, 0.8, 0.2);
                    col += base * baseColor * baseZ * 0.7;
                }
            }
        }
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Blood Vessels
let bloodVesselsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param vesselScale "Vessel Scale" range(2.0, 10.0) default(5.0)
// @param branchDepth "Branch Depth" range(1, 5) default(3)
// @param bloodFlow "Blood Flow" range(0.0, 2.0) default(1.0)
// @param vesselWidth "Vessel Width" range(0.02, 0.1) default(0.05)
// @param oxygenLevel "Oxygen Level" range(0.0, 1.0) default(0.8)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.2)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.4)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.2)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle pulsate "Pulsate" default(true)
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
float2 p = uv * vesselScale;
float3 venousColor = float3(color2Red, color2Green, color2Blue);
float3 arterialColor = float3(color1Red, color1Green, color1Blue);
float3 col = float3(0.95, 0.9, 0.85);
float vessels = 0.0;
float bloodPulse = 0.0;

for (int depth = 0; depth < 5; depth++) {
    if (depth >= int(branchDepth)) break;
    float fd = float(depth);
    float scale = pow(2.0, fd);
    float width = vesselWidth / scale;
    float2 vp = p * scale;
    float2 id = floor(vp);
    float2 f = fract(vp) - 0.5;
    float hash = fract(sin(dot(id, float2(127.1, 311.7))) * 43758.5453);
    float angle = hash * 3.14159;
    float2 dir = float2(cos(angle), sin(angle));
    float d = abs(dot(f, float2(-dir.y, dir.x)));
    float vessel = smoothstep(width, width * 0.5, d);
    vessel *= step(abs(dot(f, dir)), 0.4);
    vessels += vessel / scale;
    if (bloodFlow > 0.0) {
        float flowPos = fract(dot(f, dir) + timeVal * bloodFlow / scale);
        float flow = smoothstep(0.1, 0.0, abs(flowPos - 0.5));
        bloodPulse += flow * vessel / scale;
    }
}

float pulseVal = 1.0;
if (pulsate > 0.5) {
    pulseVal = 0.9 + 0.1 * sin(timeVal * 3.0);
}
float3 vesselColor = mix(venousColor, arterialColor, oxygenLevel);
col = mix(col, vesselColor * pulseVal, vessels * 0.8);
col += bloodPulse * float3(0.2, 0.0, 0.0) * bloodFlow;

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Coral Reef
let coralReefCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param coralDensity "Coral Density" range(3.0, 10.0) default(6.0)
// @param branchComplexity "Branch Complexity" range(2, 8) default(5)
// @param swayAmount "Sway Amount" range(0.0, 0.2) default(0.05)
// @param waterDepth "Water Depth" range(0.0, 1.0) default(0.3)
// @param colorVariety "Color Variety" range(0.5, 2.0) default(1.0)
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
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.6)
// @toggle animated "Animated" default(true)
// @toggle fish "Fish" default(true)
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
p.x += sin(p.y * 5.0 + timeVal) * swayAmount;
float3 waterColor1 = float3(color2Red, color2Green, color2Blue);
float3 waterColor2 = float3(color2Red, color2Green + 0.2, color2Blue + 0.2);
float3 col = mix(waterColor1, waterColor2, p.y);
col *= (1.0 - waterDepth * 0.5);

for (int i = 0; i < 10; i++) {
    float fi = float(i);
    if (fi >= coralDensity) break;
    float cx = fract(sin(fi * 127.1) * 43758.5453);
    float coralHeight = fract(sin(fi * 311.7) * 43758.5453) * 0.4 + 0.2;
    float2 coralBase = float2(cx, 0.0);
    for (int branch = 0; branch < 8; branch++) {
        if (branch >= int(branchComplexity)) break;
        float fb = float(branch);
        float angle = (fb / float(branchComplexity) - 0.5) * 1.5 + sin(timeVal + fi) * swayAmount * 3.0;
        float2 dir = float2(sin(angle), cos(angle));
        float len = coralHeight * (1.0 - fb * 0.1);
        float2 branchEnd = coralBase + dir * len;
        float2 toP = p - coralBase;
        float t = clamp(dot(toP, dir), 0.0, len);
        float2 closest = coralBase + dir * t;
        float d = length(p - closest);
        float thickness = 0.02 * (1.0 - t / len * 0.5);
        float coral = smoothstep(thickness, thickness * 0.5, d);
        float3 coralColor = 0.5 + 0.5 * cos(fi * colorVariety + float3(0.0, 2.0, 4.0));
        coralColor = mix(coralColor, float3(color1Red, color1Green, color1Blue), 0.3);
        col = mix(col, coralColor, coral);
    }
}

if (fish > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float fx = fract(sin(fi * 43.758) * 43758.5453 + timeVal * 0.1 * (0.5 + fi * 0.1));
        float fy = fract(sin(fi * 78.233) * 43758.5453) * 0.6 + 0.2;
        float2 fishPos = float2(fx, fy);
        float fishD = length(p - fishPos);
        float fishBody = smoothstep(0.02, 0.01, fishD);
        float3 fishColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 1.0, 2.0));
        col = mix(col, fishColor, fishBody);
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Mushroom Forest
let mushroomForestCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param mushroomCount "Mushroom Count" range(3, 15) default(8)
// @param capSize "Cap Size" range(0.05, 0.15) default(0.08)
// @param stemHeight "Stem Height" range(0.1, 0.3) default(0.15)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param sporeAmount "Spore Amount" range(0.0, 1.0) default(0.3)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.8)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.3)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle bioluminescent "Bioluminescent" default(true)
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
float3 glowColor = float3(color1Red, color1Green, color1Blue);
float3 col = float3(0.02, 0.03, 0.02);

for (int i = 0; i < 15; i++) {
    if (i >= int(mushroomCount)) break;
    float fi = float(i);
    float mx = fract(sin(fi * 127.1) * 43758.5453);
    float mScale = 0.7 + fract(sin(fi * 311.7) * 43758.5453) * 0.6;
    float2 mushBase = float2(mx, 0.0);
    float2 stemTop = mushBase + float2(0.0, stemHeight * mScale);
    float stemD = abs(p.x - mushBase.x);
    float stem = smoothstep(0.015, 0.01, stemD);
    stem *= step(mushBase.y, p.y) * step(p.y, stemTop.y);
    float3 stemColor = float3(0.8, 0.75, 0.7);
    col = mix(col, stemColor, stem);
    
    float2 capCenter = stemTop + float2(0.0, capSize * 0.3 * mScale);
    float capD = length((p - capCenter) * float2(1.0, 2.0));
    float cap = smoothstep(capSize * mScale, capSize * mScale - 0.01, capD);
    cap *= step(capCenter.y - capSize * 0.5 * mScale, p.y);
    float3 capColor = 0.5 + 0.5 * cos(fi * 1.5 + float3(0.0, 2.0, 4.0));
    capColor = mix(capColor, float3(color2Red, color2Green, color2Blue), 0.3);
    col = mix(col, capColor, cap);
    
    if (bioluminescent > 0.5) {
        float glowVal = exp(-capD / (capSize * mScale * 2.0)) * glowAmount;
        float pulseVal = 0.7 + 0.3 * sin(timeVal * 2.0 + fi);
        col += glowVal * pulseVal * glowColor;
    }
}

if (sporeAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float2 sporePos = float2(
            fract(sin(fi * 43.758) * 43758.5453),
            fract(fract(sin(fi * 78.233) * 43758.5453) + timeVal * 0.05)
        );
        float sporeD = length(p - sporePos);
        float spore = smoothstep(0.005, 0.0, sporeD) * sporeAmount;
        col += spore * float3(0.5, 1.0, 0.5);
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Butterfly Wings
let butterflyWingsCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param wingScale "Wing Scale" range(0.5, 2.0) default(1.0)
// @param patternComplexity "Pattern Complexity" range(2, 8) default(5)
// @param flapSpeed "Flap Speed" range(0.0, 5.0) default(2.0)
// @param saturation "Saturation" range(0.5, 1.5) default(1.0)
// @param eyespotSize "Eyespot Size" range(0.0, 0.15) default(0.08)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.9)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.1)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.1)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.05)
// @toggle animated "Animated" default(true)
// @toggle symmetry "Symmetry" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 baseColor = float3(color1Red, color1Green, color1Blue);
float3 tipColor = float3(color2Red, color2Green, color2Blue);

if (symmetry > 0.5) {
    p.x = abs(p.x);
}

float flapAngle = sin(timeVal * flapSpeed) * 0.3;
p.x = p.x * cos(flapAngle) - p.y * sin(flapAngle) * 0.2;
p *= wingScale;
float3 col = float3(0.1, 0.1, 0.15);

float2 wingCenter = float2(0.3, 0.0);
float wingR = length(p - wingCenter);
float wingA = atan2(p.y - wingCenter.y, p.x - wingCenter.x);
float wingShape = 0.3 + 0.2 * cos(wingA * 2.0) + 0.1 * cos(wingA * 4.0);
float wing = smoothstep(wingShape + 0.02, wingShape, wingR);

float3 wingColor = mix(baseColor, tipColor, wingR / wingShape);
wingColor = mix(float3(0.5), wingColor, saturation);
col = mix(col, wingColor, wing);

for (int i = 0; i < 8; i++) {
    if (i >= int(patternComplexity)) break;
    float fi = float(i);
    float patternAngle = fi * 0.5 - 0.5;
    float patternR = 0.1 + fi * 0.04;
    float2 patternPos = wingCenter + float2(cos(patternAngle), sin(patternAngle)) * patternR;
    float patternD = length(p - patternPos);
    float pattern = smoothstep(0.03, 0.02, patternD);
    float3 patternColor = 0.5 + 0.5 * cos(fi * 1.2 + float3(0.0, 2.0, 4.0));
    col = mix(col, patternColor * saturation, pattern * wing);
}

if (eyespotSize > 0.0) {
    float2 eyePos = wingCenter + float2(0.15, 0.05);
    float eyeD = length(p - eyePos);
    float eyeOuter = smoothstep(eyespotSize, eyespotSize - 0.02, eyeD);
    float eyeInner = smoothstep(eyespotSize * 0.5, eyespotSize * 0.3, eyeD);
    col = mix(col, float3(0.1, 0.1, 0.3), eyeOuter * wing);
    col = mix(col, float3(0.9, 0.9, 1.0), eyeInner * wing);
}

float veins = sin(wingA * 20.0 + wingR * 30.0) * 0.5 + 0.5;
veins = smoothstep(0.4, 0.6, veins);
col = mix(col, col * 0.7, veins * wing * 0.3);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Fern Fractal
let fernFractalCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param iterations "Iterations" range(10, 100) default(50)
// @param fernScale "Fern Scale" range(0.5, 2.0) default(1.0)
// @param windSway "Wind Sway" range(0.0, 0.3) default(0.1)
// @param leafDensity "Leaf Density" range(0.5, 1.5) default(1.0)
// @param greenVariation "Green Variation" range(0.0, 1.0) default(0.3)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle autumn "Autumn Colors" default(false)
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
float2 p = uv * 2.0 - 1.0;
p.x += sin(p.y * 3.0 + timeVal) * windSway;
p = p / fernScale + float2(0.0, 0.5);
float3 greenColor = float3(color1Red, color1Green, color1Blue);
float3 autumnColor = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.05, 0.08, 0.05);

float fern = 0.0;
float2 fernP = float2(0.0, 0.0);
for (int i = 0; i < 100; i++) {
    if (i >= int(iterations)) break;
    float r = fract(sin(float(i) * 43.758 + timeVal * 0.01) * 43758.5453);
    float2 newP;
    if (r < 0.01) {
        newP = float2(0.0, 0.16 * fernP.y);
    } else if (r < 0.86) {
        newP = float2(0.85 * fernP.x + 0.04 * fernP.y,
                      -0.04 * fernP.x + 0.85 * fernP.y + 1.6);
    } else if (r < 0.93) {
        newP = float2(0.2 * fernP.x - 0.26 * fernP.y,
                      0.23 * fernP.x + 0.22 * fernP.y + 1.6);
    } else {
        newP = float2(-0.15 * fernP.x + 0.28 * fernP.y,
                      0.26 * fernP.x + 0.24 * fernP.y + 0.44);
    }
    fernP = newP;
    float2 plotP = fernP * 0.1;
    float d = length(p - plotP);
    float point = smoothstep(0.02 * leafDensity, 0.0, d);
    fern = max(fern, point);
}

float3 fernColor;
if (autumn > 0.5) {
    fernColor = mix(autumnColor, float3(0.9, 0.3, 0.1), fract(sin(p.y * 10.0) * 43758.5453) * greenVariation);
} else {
    fernColor = mix(greenColor, float3(0.1, 0.4, 0.1), fract(sin(p.y * 10.0) * 43758.5453) * greenVariation);
}
col = mix(col, fernColor, fern);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Peacock Feather
let peacockFeatherCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param featherCount "Feather Count" range(1, 5) default(3)
// @param eyeSize "Eye Size" range(0.05, 0.2) default(0.1)
// @param barbDensity "Barb Density" range(20.0, 60.0) default(40.0)
// @param shimmerSpeed "Shimmer Speed" range(0.0, 3.0) default(1.0)
// @param iridescence "Iridescence" range(0.5, 2.0) default(1.0)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.6)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.2)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.9)
// @toggle animated "Animated" default(true)
// @toggle animate "Animate Feathers" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 eyeColor1 = float3(color1Red, color1Green, color1Blue);
float3 eyeColor2 = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.02, 0.03, 0.02);

for (int f = 0; f < 5; f++) {
    if (f >= int(featherCount)) break;
    float ff = float(f);
    float2 featherBase = float2(-0.3 + ff * 0.3, -0.8);
    float2 featherDir = normalize(float2(sin(ff * 0.5), 1.0));
    if (animate > 0.5) {
        featherDir = normalize(float2(sin(timeVal * 0.5 + ff), 1.0));
    }
    float2 toP = p - featherBase;
    float along = dot(toP, featherDir);
    float perp = abs(dot(toP, float2(-featherDir.y, featherDir.x)));
    float rachis = smoothstep(0.01, 0.005, perp) * step(0.0, along) * step(along, 1.2);
    col = mix(col, float3(0.2, 0.15, 0.1), rachis);
    
    float barbWidth = 0.3 * (1.0 - along * 0.5);
    float barb = step(perp, barbWidth) * step(0.0, along) * step(along, 1.0);
    float barbPattern = sin(perp * barbDensity) * 0.5 + 0.5;
    barbPattern *= barb;
    float3 barbColor = 0.5 + 0.5 * cos((along + perp * 2.0) * iridescence + timeVal * shimmerSpeed + float3(0.0, 2.0, 4.0));
    barbColor = mix(float3(0.1, 0.3, 0.2), barbColor, 0.7);
    col = mix(col, barbColor, barbPattern * 0.7);
    
    float2 eyeCenter = featherBase + featherDir * 0.8;
    float eyeD = length(p - eyeCenter);
    float eyeOuter = smoothstep(eyeSize, eyeSize - 0.02, eyeD);
    float eyeMiddle = smoothstep(eyeSize * 0.7, eyeSize * 0.5, eyeD);
    float eyeInner = smoothstep(eyeSize * 0.4, eyeSize * 0.2, eyeD);
    float shimmer = 0.8 + 0.2 * sin(timeVal * shimmerSpeed * 3.0 + ff);
    col = mix(col, eyeColor1 * shimmer, eyeOuter);
    col = mix(col, eyeColor2 * shimmer, eyeMiddle);
    col = mix(col, float3(0.1, 0.1, 0.3), eyeInner);
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Spider Web
let spiderWebCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param radialLines "Radial Lines" range(6, 24) default(12)
// @param spiralTurns "Spiral Turns" range(3, 15) default(8)
// @param webThickness "Web Thickness" range(0.005, 0.02) default(0.008)
// @param dewDrops "Dew Drops" range(0.0, 1.0) default(0.5)
// @param swayAmount "Sway Amount" range(0.0, 0.1) default(0.02)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.85)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.9)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.8)
// @toggle animated "Animated" default(true)
// @toggle broken "Broken Web" default(false)
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
float2 p = uv * 2.0 - 1.0;
p += sin(timeVal + p.yx * 5.0) * swayAmount;
float3 webColor = float3(color1Red, color1Green, color1Blue);
float3 dropColor = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.05, 0.08, 0.12);

float r = length(p);
float a = atan2(p.y, p.x);

for (int i = 0; i < 24; i++) {
    if (i >= int(radialLines)) break;
    float fi = float(i);
    float lineAngle = fi * 6.28318 / float(radialLines);
    if (broken > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.7) continue;
    float angleDiff = abs(fmod(a - lineAngle + 3.14159, 6.28318) - 3.14159);
    float radialLine = smoothstep(webThickness / r, 0.0, angleDiff);
    radialLine *= step(0.05, r) * step(r, 0.9);
    col += radialLine * webColor * 0.5;
}

for (int i = 0; i < 15; i++) {
    if (i >= int(spiralTurns)) break;
    float fi = float(i);
    float spiralR = 0.1 + fi * 0.06;
    if (broken > 0.5 && fract(sin(fi * 78.233) * 43758.5453) > 0.8) continue;
    float spiralD = abs(r - spiralR);
    float spiral = smoothstep(webThickness, 0.0, spiralD);
    col += spiral * webColor * 0.4;
}

if (dewDrops > 0.0) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float dropR = fract(sin(fi * 127.1) * 43758.5453) * 0.7 + 0.1;
        float dropA = fract(sin(fi * 311.7) * 43758.5453) * 6.28318;
        float2 dropPos = float2(cos(dropA), sin(dropA)) * dropR;
        float dropD = length(p - dropPos);
        float drop = smoothstep(0.015, 0.01, dropD) * dewDrops;
        float highlight = smoothstep(0.01, 0.005, length(p - dropPos - float2(0.003)));
        col += drop * dropColor;
        col += highlight * float3(1.0) * dewDrops;
    }
}

float center = smoothstep(0.08, 0.05, r);
col = mix(col, float3(0.3, 0.25, 0.2), center);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

// MARK: - More Organic Effects

/// Mitosis Cell Division
let mitosisCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param divisionPhase "Division Phase" range(0.0, 1.0) default(0.5)
// @param chromosomeCount "Chromosome Count" range(4, 12) default(8)
// @param spindleVisibility "Spindle Visibility" range(0.0, 1.0) default(0.5)
// @param cellSize "Cell Size" range(0.3, 0.6) default(0.4)
// @param membraneWobble "Membrane Wobble" range(0.0, 0.1) default(0.02)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.75)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.85)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.5)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.55)
// @toggle animated "Animated" default(true)
// @toggle animatePhase "Animate Phase" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 cytoColor = float3(color1Red, color1Green, color1Blue);
float3 membraneColor = float3(color2Red, color2Green, color2Blue);

float phase = divisionPhase;
if (animatePhase > 0.5) {
    phase = fract(timeVal * 0.1);
}
float3 col = float3(0.9, 0.92, 0.95);

float separation = phase * 0.4;
float2 cell1Center = float2(-separation, 0.0);
float2 cell2Center = float2(separation, 0.0);

float wobble = sin(atan2(p.y, p.x - cell1Center.x) * 8.0 + timeVal) * membraneWobble;
float cell1D = length(p - cell1Center);
float cell1 = smoothstep(cellSize + wobble + 0.02, cellSize + wobble, cell1D);
float wobble2 = sin(atan2(p.y, p.x - cell2Center.x) * 8.0 + timeVal) * membraneWobble;
float cell2D = length(p - cell2Center);
float cell2 = smoothstep(cellSize + wobble2 + 0.02, cellSize + wobble2, cell2D);
float cell = max(cell1, cell2);

if (phase < 0.5) {
    float bridge = step(abs(p.y), 0.1) * step(cell1Center.x, p.x) * step(p.x, cell2Center.x);
    bridge *= step(length(p), cellSize);
    cell = max(cell, bridge);
}
col = mix(col, cytoColor, cell);

float membrane = smoothstep(0.02, 0.0, abs(cell1D - cellSize - wobble));
membrane += smoothstep(0.02, 0.0, abs(cell2D - cellSize - wobble2));
col = mix(col, membraneColor, membrane * 0.8);

if (spindleVisibility > 0.0 && phase > 0.2 && phase < 0.8) {
    float spindle = smoothstep(0.01, 0.0, abs(p.y));
    spindle *= step(-separation - 0.1, p.x) * step(p.x, separation + 0.1);
    col = mix(col, float3(0.4, 0.5, 0.6), spindle * spindleVisibility * 0.3);
}

for (int i = 0; i < 12; i++) {
    if (i >= int(chromosomeCount)) break;
    float fi = float(i);
    float chromoX = (fi / float(chromosomeCount) - 0.5) * 0.2;
    float chromoY = (fract(sin(fi * 43.758) * 43758.5453) - 0.5) * 0.1;
    float chromoSep = phase * separation;
    float2 chromo1Pos = float2(chromoX - chromoSep, chromoY);
    float2 chromo2Pos = float2(chromoX + chromoSep, chromoY);
    float chromo1 = smoothstep(0.02, 0.01, length(p - chromo1Pos));
    float chromo2 = smoothstep(0.02, 0.01, length(p - chromo2Pos));
    float3 chromoColor = 0.5 + 0.5 * cos(fi * 0.5 + float3(0.0, 2.0, 4.0));
    col = mix(col, chromoColor, (chromo1 + chromo2) * cell);
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Jellyfish Swarm
let jellyfishSwarmCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param jellyfishCount "Jellyfish Count" range(1, 8) default(4)
// @param pulseSpeed "Pulse Speed" range(0.5, 3.0) default(1.5)
// @param tentacleLength "Tentacle Length" range(0.1, 0.4) default(0.25)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.6)
// @param driftSpeed "Drift Speed" range(0.0, 0.5) default(0.2)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.5)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.9)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.05)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.1)
// @toggle animated "Animated" default(true)
// @toggle bioluminescence "Bioluminescence" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 bgColor = float3(color2Red, color2Green, color2Blue);
float3 col = bgColor;

for (int i = 0; i < 8; i++) {
    if (i >= int(jellyfishCount)) break;
    float fi = float(i);
    float2 jellyCenter = float2(
        sin(timeVal * driftSpeed + fi * 2.0) * 0.5,
        cos(timeVal * driftSpeed * 0.7 + fi * 1.5) * 0.3 + fi * 0.2 - 0.3
    );
    float pulseVal = sin(timeVal * pulseSpeed + fi) * 0.5 + 0.5;
    float bellWidth = 0.12 + pulseVal * 0.03;
    float bellHeight = 0.08 + pulseVal * 0.02;
    float2 bellP = (p - jellyCenter) / float2(bellWidth, bellHeight);
    float bellD = length(bellP);
    float bell = smoothstep(1.1, 0.9, bellD) * step(bellP.y, 0.5);
    
    float3 jellyColor = 0.5 + 0.5 * cos(fi * 1.2 + float3(0.0, 1.0, 2.0));
    jellyColor = mix(jellyColor, float3(color1Red, color1Green, color1Blue), 0.3);
    col = mix(col, jellyColor * 0.7, bell);
    
    for (int t = 0; t < 5; t++) {
        float ft = float(t);
        float tentX = jellyCenter.x + (ft / 4.0 - 0.5) * bellWidth * 1.5;
        float tentWave = sin(p.y * 15.0 + timeVal * 2.0 + ft) * 0.02;
        float tentD = abs(p.x - tentX - tentWave);
        float tentacle = smoothstep(0.01, 0.005, tentD);
        tentacle *= step(jellyCenter.y - bellHeight - tentacleLength, p.y);
        tentacle *= step(p.y, jellyCenter.y - bellHeight * 0.5);
        col = mix(col, jellyColor * 0.5, tentacle * 0.5);
    }
    
    if (bioluminescence > 0.5) {
        float glowVal = exp(-bellD * 3.0) * glowAmount;
        float glowPulse = 0.7 + 0.3 * sin(timeVal * 3.0 + fi * 2.0);
        col += glowVal * jellyColor * glowPulse;
    }
}

float particles = step(0.997, fract(sin(dot(floor(uv * 100.0 + timeVal * 10.0), float2(12.9898, 78.233))) * 43758.5453));
col += particles * 0.2;

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Flower Bloom
let flowerBloomCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param petalCount "Petal Count" range(4, 12) default(6)
// @param bloomPhase "Bloom Phase" range(0.0, 1.0) default(0.8)
// @param petalCurl "Petal Curl" range(0.0, 0.5) default(0.1)
// @param colorGradient "Color Gradient" range(0.0, 1.0) default(0.5)
// @param centerSize "Center Size" range(0.05, 0.2) default(0.1)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.5)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(1.0)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.9)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle showAnimation "Show Animation" default(true)
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
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 innerColor = float3(color1Red, color1Green, color1Blue);
float3 outerColor = float3(color1Red * 1.0, color1Green + 0.5, color1Blue + 0.4);
float3 centerColor = float3(color2Red, color2Green, color2Blue);

float bloomVal = bloomPhase;
if (showAnimation > 0.5) {
    bloomVal = sin(timeVal * 0.5) * 0.3 + 0.7;
}
float3 col = float3(0.1, 0.15, 0.1);

float petalAngle = 6.28318 / float(petalCount);
float petal = 0.0;
for (int i = 0; i < 12; i++) {
    if (i >= int(petalCount)) break;
    float fi = float(i);
    float pa = fi * petalAngle;
    float angleDiff = a - pa;
    angleDiff = fmod(angleDiff + 3.14159, petalAngle) - petalAngle * 0.5;
    float petalWidth = 0.4 * bloomVal;
    float petalShape = cos(angleDiff / petalWidth * 1.57);
    petalShape = max(0.0, petalShape);
    float petalLength = 0.4 * bloomVal * (1.0 - petalCurl * (1.0 - petalShape));
    float petalMask = step(r, petalLength) * petalShape;
    petalMask *= step(centerSize, r);
    petal = max(petal, petalMask);
    
    float3 petalColor = mix(innerColor, outerColor, r / petalLength * colorGradient);
    petalColor = mix(petalColor, float3(1.0, 0.5, 0.6), petalShape * 0.3);
    col = mix(col, petalColor, petalMask);
}

float center = smoothstep(centerSize + 0.02, centerSize, r);
float centerPattern = sin(a * 20.0) * sin(r * 50.0) * 0.5 + 0.5;
float3 centerCol = mix(centerColor, float3(0.8, 0.6, 0.1), centerPattern);
col = mix(col, centerCol, center);

float stamen = step(0.98, sin(a * 30.0)) * center * 0.5;
col = mix(col, float3(0.6, 0.4, 0.1), stamen);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Lichen Growth
let lichenGrowthCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param growthScale "Growth Scale" range(3.0, 15.0) default(8.0)
// @param layerCount "Layer Count" range(1, 5) default(3)
// @param edgeDetail "Edge Detail" range(1.0, 5.0) default(2.5)
// @param growthSpeed "Growth Speed" range(0.0, 1.0) default(0.2)
// @param colorVariation "Color Variation" range(0.0, 1.0) default(0.5)
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
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.6)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.25)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle crusty "Crusty Texture" default(true)
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
float2 p = uv * growthScale;
float time = timeVal * growthSpeed;
float3 bgColor = float3(color2Red, color2Green, color2Blue);
float3 lichenBaseColor = float3(color1Red, color1Green, color1Blue);
float3 col = bgColor;

for (int layer = 0; layer < 5; layer++) {
    if (layer >= int(layerCount)) break;
    float fl = float(layer);
    float2 offset = float2(sin(fl * 2.0), cos(fl * 3.0)) * 2.0;
    float2 lp = p + offset;
    float growth = 0.0;
    float amp = 1.0;
    for (int o = 0; o < 4; o++) {
        float fo = float(o);
        float freq = pow(2.0, fo) * edgeDetail;
        growth += sin(lp.x * freq + time + fl) * sin(lp.y * freq * 0.7 + time * 0.8) * amp;
        amp *= 0.5;
    }
    growth = smoothstep(-0.2, 0.3, growth);
    
    float3 lichenColor;
    if (colorVariation > 0.0) {
        lichenColor = 0.5 + 0.5 * cos(fl * colorVariation + float3(1.0, 2.0, 3.0));
        lichenColor = mix(lichenBaseColor, lichenColor, 0.5);
    } else {
        lichenColor = lichenBaseColor;
    }
    lichenColor *= (1.0 - fl * 0.15);
    col = mix(col, lichenColor, growth * 0.7);
    
    if (crusty > 0.5) {
        float crust = fract(sin(dot(floor(lp * 10.0), float2(12.9898, 78.233))) * 43758.5453);
        crust = step(0.7, crust) * growth;
        col += crust * 0.1;
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Heartbeat Monitor
let heartbeatMonitorCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param heartRate "Heart Rate BPM" range(40.0, 180.0) default(72.0)
// @param lineThickness "Line Thickness" range(0.005, 0.02) default(0.008)
// @param glowAmount "Glow Amount" range(0.0, 1.0) default(0.5)
// @param gridOpacity "Grid Opacity" range(0.0, 0.5) default(0.2)
// @param traceSpeed "Trace Speed" range(0.5, 2.0) default(1.0)
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
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.3)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.02)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.05)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.02)
// @toggle animated "Animated" default(true)
// @toggle flatline "Flatline" default(false)
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
float3 bgColor = float3(color2Red, color2Green, color2Blue);
float3 lineColor = float3(color1Red, color1Green, color1Blue);
float3 col = bgColor;

float gridX = smoothstep(0.02, 0.0, abs(fract(p.x * 10.0) - 0.5));
float gridY = smoothstep(0.02, 0.0, abs(fract(p.y * 8.0) - 0.5));
col += (gridX + gridY) * float3(0.0, 0.2, 0.0) * gridOpacity;

float beatPeriod = 60.0 / heartRate;
float x = fract(p.x - timeVal * traceSpeed / beatPeriod * 0.2);
float wave = 0.5;

if (flatline < 0.5) {
    float phase = fract(x * 2.0);
    if (phase < 0.1) {
        wave = 0.5;
    } else if (phase < 0.15) {
        wave = 0.5 + (phase - 0.1) * 4.0 * 0.1;
    } else if (phase < 0.2) {
        wave = 0.55 - (phase - 0.15) * 4.0 * 0.15;
    } else if (phase < 0.25) {
        wave = 0.4 + (phase - 0.2) * 20.0 * 0.35;
    } else if (phase < 0.3) {
        wave = 0.75 - (phase - 0.25) * 20.0 * 0.5;
    } else if (phase < 0.35) {
        wave = 0.25 + (phase - 0.3) * 20.0 * 0.25;
    } else if (phase < 0.5) {
        wave = 0.5 + sin((phase - 0.35) * 6.28 * 2.0) * 0.05;
    } else {
        wave = 0.5;
    }
}

float waveDist = abs(p.y - wave);
float line = smoothstep(lineThickness, 0.0, waveDist);
float glowVal = smoothstep(lineThickness * 10.0, 0.0, waveDist) * glowAmount;

col += line * lineColor;
col += glowVal * lineColor * 0.5;

float trace = smoothstep(0.0, 0.1, x);
col *= trace;

float sweepLine = smoothstep(0.01, 0.0, abs(x));
col += sweepLine * lineColor * 0.3;

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Vine Growth
let vineGrowthCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param vineCount "Vine Count" range(1, 8) default(4)
// @param growthProgress "Growth Progress" range(0.0, 1.0) default(0.7)
// @param curliness "Curliness" range(0.5, 3.0) default(1.5)
// @param leafDensity "Leaf Density" range(0.0, 1.0) default(0.5)
// @param thickness "Thickness" range(0.01, 0.05) default(0.02)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.2)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.4)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.2)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.3)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.6)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.3)
// @toggle animated "Animated" default(true)
// @toggle flowers "Flowers" default(true)
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
float2 p = uv * 2.0 - 1.0;
float3 vineColor = float3(color1Red, color1Green, color1Blue);
float3 leafColor = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.9, 0.92, 0.85);
float growth = growthProgress;

for (int v = 0; v < 8; v++) {
    if (v >= int(vineCount)) break;
    float fv = float(v);
    float2 vineStart = float2(fract(sin(fv * 127.1) * 43758.5453) * 2.0 - 1.0, -1.0);
    float vineAngle = (fv / float(vineCount) - 0.5) * 1.0 + sin(timeVal * 0.3 + fv) * 0.1;
    float vineLen = growth * 1.5;
    
    for (int seg = 0; seg < 30; seg++) {
        float fs = float(seg) / 30.0;
        if (fs > growth) break;
        float curl = sin(fs * curliness * 6.28 + fv) * 0.2;
        float2 segPos = vineStart + float2(sin(vineAngle + curl), fs) * vineLen * fs;
        float d = length(p - segPos);
        float segThick = thickness * (1.0 - fs * 0.5);
        float vine = smoothstep(segThick, segThick * 0.5, d);
        col = mix(col, vineColor, vine);
        
        if (leafDensity > 0.0 && fract(sin(fs * 10.0 + fv) * 43758.5453) < leafDensity * 0.3) {
            float leafAngle = sin(fs * 5.0 + fv) * 1.57;
            float2 leafOffset = float2(cos(leafAngle), sin(leafAngle)) * 0.08;
            float2 leafPos = segPos + leafOffset;
            float2 leafP = p - leafPos;
            float leafD = length(leafP * float2(1.0, 2.0));
            float leaf = smoothstep(0.04, 0.03, leafD);
            col = mix(col, leafColor, leaf);
        }
    }
    
    if (flowers > 0.5 && growth > 0.8) {
        float2 flowerPos = vineStart + float2(sin(vineAngle), growth) * vineLen * 0.9;
        float flowerD = length(p - flowerPos);
        float flower = smoothstep(0.04, 0.03, flowerD);
        float3 flowerColor = 0.5 + 0.5 * cos(fv * 1.5 + float3(0.0, 2.0, 4.0));
        col = mix(col, flowerColor, flower);
        float center = smoothstep(0.015, 0.01, flowerD);
        col = mix(col, float3(1.0, 0.9, 0.3), center);
    }
}

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Seashell Spiral
let seashellSpiralCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param spiralTightness "Spiral Tightness" range(0.1, 0.3) default(0.18)
// @param ridgeCount "Ridge Count" range(10, 40) default(20)
// @param ridgeDepth "Ridge Depth" range(0.0, 0.3) default(0.15)
// @param pearlescence "Pearlescence" range(0.0, 1.0) default(0.5)
// @param aperture "Aperture" range(0.0, 0.5) default(0.2)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.95)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.9)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.8)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.8)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.7)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.6)
// @toggle animated "Animated" default(true)
// @toggle golden "Golden Spiral" default(false)
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
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 shellColor1 = float3(color1Red, color1Green, color1Blue);
float3 shellColor2 = float3(color2Red, color2Green, color2Blue);
float3 col = float3(0.9, 0.85, 0.75);

float growthFactor = spiralTightness;
if (golden > 0.5) {
    growthFactor = 0.306349;
}

float spiralR = exp(growthFactor * (a + timeVal * 0.5));
float normalizedR = log(r) / growthFactor - a - timeVal * 0.5;
float turns = fract(normalizedR / 6.28318);
float shell = smoothstep(0.1, 0.0, abs(turns - 0.5) - 0.4);
shell *= step(0.05, r) * step(r, 0.9);

float ridge = sin(normalizedR * float(ridgeCount)) * ridgeDepth + 0.5;
float3 shellColor = mix(shellColor1, shellColor2, ridge);

if (pearlescence > 0.0) {
    float pearl = 0.5 + 0.5 * cos(a * 3.0 + r * 10.0 + timeVal + float3(0.0, 2.0, 4.0)).x;
    shellColor = mix(shellColor, float3(1.0, 0.95, 0.98), pearl * pearlescence * 0.3);
}
col = mix(col, shellColor, shell);

float apertureAngle = -0.5;
float apertureMask = smoothstep(aperture, 0.0, abs(a - apertureAngle));
apertureMask *= step(r, 0.3);
col = mix(col, float3(0.3, 0.25, 0.2), apertureMask * 0.5);

float lip = smoothstep(0.02, 0.0, abs(r - 0.3)) * apertureMask;
col = mix(col, float3(0.95, 0.85, 0.8), lip);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

/// Tide Pool
let tidePoolCode = """
// @param masterOpacity "Master Opacity" range(0.0, 1.0) default(1.0)
// @param speed "Speed" range(0.1, 3.0) default(1.0)
// @param waterClarity "Water Clarity" range(0.3, 1.0) default(0.7)
// @param waveIntensity "Wave Intensity" range(0.0, 0.5) default(0.2)
// @param creatureCount "Creature Count" range(0, 10) default(5)
// @param algaeAmount "Algae Amount" range(0.0, 1.0) default(0.3)
// @param rockScale "Rock Scale" range(2.0, 8.0) default(4.0)
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
// @param color1Red "Color 1 Red" range(0.0, 1.0) default(0.1)
// @param color1Green "Color 1 Green" range(0.0, 1.0) default(0.3)
// @param color1Blue "Color 1 Blue" range(0.0, 1.0) default(0.4)
// @param color2Red "Color 2 Red" range(0.0, 1.0) default(0.9)
// @param color2Green "Color 2 Green" range(0.0, 1.0) default(0.4)
// @param color2Blue "Color 2 Blue" range(0.0, 1.0) default(0.2)
// @toggle animated "Animated" default(true)
// @toggle starfish "Starfish" default(true)
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
float3 waterColor = float3(color1Red, color1Green, color1Blue);
float3 starfishColor = float3(color2Red, color2Green, color2Blue);
float3 col = waterColor;

float2 rockP = p * rockScale;
float rock = sin(rockP.x * 3.0) * sin(rockP.y * 2.0) * 0.5 + 0.5;
rock += sin(rockP.x * 7.0 + rockP.y * 5.0) * 0.25;
rock = smoothstep(0.4, 0.6, rock);
float3 rockColor = mix(float3(0.3, 0.25, 0.2), float3(0.5, 0.45, 0.4), rock);
col = mix(col, rockColor, 0.3);

if (algaeAmount > 0.0) {
    float algae = sin(p.x * 30.0 + timeVal) * sin(p.y * 25.0) * 0.5 + 0.5;
    algae = step(1.0 - algaeAmount * 0.5, algae);
    col = mix(col, float3(0.2, 0.4, 0.2), algae * 0.5);
}

float wave = sin(p.x * 20.0 + timeVal * 2.0) * sin(p.y * 15.0 + timeVal * 1.5);
wave *= waveIntensity;
col += wave * float3(0.2, 0.3, 0.4) * waterClarity;

for (int i = 0; i < 10; i++) {
    if (i >= int(creatureCount)) break;
    float fi = float(i);
    float2 creaturePos = float2(
        fract(sin(fi * 127.1) * 43758.5453),
        fract(sin(fi * 311.7) * 43758.5453)
    );
    creaturePos += sin(timeVal * 0.5 + fi) * 0.02;
    float d = length(p - creaturePos);
    float creature = smoothstep(0.02, 0.01, d);
    float3 creatureColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 1.0, 2.0));
    col = mix(col, creatureColor, creature);
}

if (starfish > 0.5) {
    float2 starPos = float2(0.7, 0.3);
    float2 sp = p - starPos;
    float sr = length(sp);
    float sa = atan2(sp.y, sp.x);
    float star = 0.05 + cos(sa * 5.0) * 0.03;
    float starShape = smoothstep(star + 0.01, star, sr);
    col = mix(col, starfishColor, starShape);
}

float reflection = pow(1.0 - p.y, 2.0) * waterClarity * 0.3;
col += reflection * float3(0.5, 0.6, 0.7);

col *= brightness;
if (glow > 0.5) col += pow(max(col, float3(0.0)), float3(2.0)) * glowIntensity;
if (neon > 0.5) col = pow(max(col, float3(0.0)), float3(0.7)) * 1.3;

float gray = dot(col, float3(0.299, 0.587, 0.114));
col = mix(float3(gray), col, colorSaturation);
col = (col - 0.5) * contrast + 0.5;
col = pow(max(col, float3(0.0)), float3(1.0 / gamma));

if (invert > 0.5) col = 1.0 - col;
if (vignette > 0.5) { float vig = 1.0 - length(uv - 0.5) * vignetteSize * 1.5; col *= max(vig, 0.0); }

col *= masterOpacity;
return float4(col, masterOpacity);
"""

