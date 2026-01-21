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
// @param cellCount "Liczba komórek" range(3.0, 15.0) default(8.0)
// @param membraneThickness "Grubość błony" range(0.01, 0.1) default(0.03)
// @param nucleusSize "Rozmiar jądra" range(0.1, 0.4) default(0.25)
// @param motility "Ruchliwość" range(0.0, 1.0) default(0.5)
// @param divisionRate "Tempo podziału" range(0.0, 1.0) default(0.3)
// @toggle organelles "Organella" default(true)
float2 p = uv * cellCount;
float2 id = floor(p);
float2 f = fract(p) - 0.5;
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
        cellOffset = 0.5 + motility * 0.4 * sin(iTime * 0.5 + 6.28 * cellOffset);
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
float3 cytoplasmColor = float3(0.8, 0.9, 0.85);
float3 membraneColor = float3(0.6, 0.7, 0.65);
float3 nucleusColor = float3(0.4, 0.5, 0.6);
col = mix(col, cytoplasmColor, cell);
col = mix(col, membraneColor, membrane);
col = mix(col, nucleusColor, nucleus);
if (organelles > 0.5 && cell > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float angle = fi * 1.256 + iTime * 0.3;
        float radius = 0.15 + fi * 0.05;
        float2 orgPos = float2(cos(angle), sin(angle)) * radius;
        float org = smoothstep(0.03, 0.02, length(f - orgPos));
        col = mix(col, float3(0.7, 0.5, 0.6), org * 0.5);
    }
}
if (divisionRate > 0.0) {
    float phase = fract(iTime * divisionRate * 0.1 + fract(sin(dot(closestId, float2(12.9898, 78.233))) * 43758.5453));
    if (phase > 0.8) {
        float split = smoothstep(0.01, 0.0, abs(f.x));
        col = mix(col, membraneColor, split * (phase - 0.8) * 5.0);
    }
}
return float4(col, 1.0);
"""

/// Neural Network
let neuralNetworkCode = """
// @param neuronCount "Liczba neuronów" range(5, 20) default(10)
// @param connectionDensity "Gęstość połączeń" range(0.3, 1.0) default(0.6)
// @param signalSpeed "Prędkość sygnału" range(0.5, 3.0) default(1.5)
// @param pulseIntensity "Intensywność impulsu" range(0.0, 1.0) default(0.7)
// @param axonThickness "Grubość aksonu" range(0.005, 0.02) default(0.008)
// @toggle synapticFire "Wyładowania synaptyczne" default(true)
float2 p = uv * 2.0 - 1.0;
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
        float signal = fract(t / len - iTime * signalSpeed + float(i) * 0.1);
        signal = pow(signal, 3.0) * pulseIntensity;
        col += axon * float3(0.2, 0.3, 0.4);
        col += axon * signal * float3(0.3, 0.8, 1.0);
    }
}
for (int i = 0; i < 20; i++) {
    if (i >= int(neuronCount)) break;
    float2 n = neurons[i];
    float d = length(p - n);
    float neuron = smoothstep(0.04, 0.02, d);
    float glow = exp(-d * 10.0) * 0.3;
    col += neuron * float3(0.8, 0.9, 1.0);
    col += glow * float3(0.3, 0.5, 0.7);
    if (synapticFire > 0.5) {
        float fire = step(0.95, sin(iTime * 5.0 + float(i) * 1.5));
        col += neuron * fire * float3(1.0, 0.8, 0.3);
    }
}
return float4(col, 1.0);
"""

/// DNA Helix
let dnaHelixCode = """
// @param helixTwist "Skręt helisy" range(1.0, 5.0) default(2.0)
// @param helixWidth "Szerokość helisy" range(0.1, 0.4) default(0.25)
// @param baseCount "Liczba par zasad" range(5, 20) default(10)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 2.0) default(0.5)
// @param strandThickness "Grubość nici" range(0.01, 0.05) default(0.02)
// @toggle showBases "Pokaż zasady" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float y = p.y;
float twist = y * helixTwist * 6.28 + iTime * rotationSpeed;
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
float3 strand1Color = float3(0.8, 0.3, 0.3);
float3 strand2Color = float3(0.3, 0.3, 0.8);
col += strand1 * strand1Color;
col += strand2 * strand2Color;
if (showBases > 0.5) {
    for (int i = 0; i < 20; i++) {
        if (i >= int(baseCount)) break;
        float fi = float(i);
        float baseY = (fi / float(baseCount)) * 2.0 - 1.0;
        if (abs(y - baseY) < 0.03) {
            float baseTwist = baseY * helixTwist * 6.28 + iTime * rotationSpeed;
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
return float4(col, 1.0);
"""

/// Blood Vessels
let bloodVesselsCode = """
// @param vesselScale "Skala naczyń" range(2.0, 10.0) default(5.0)
// @param branchDepth "Głębokość rozgałęzień" range(1, 5) default(3)
// @param bloodFlow "Przepływ krwi" range(0.0, 2.0) default(1.0)
// @param vesselWidth "Szerokość naczyń" range(0.02, 0.1) default(0.05)
// @param oxygenLevel "Poziom tlenu" range(0.0, 1.0) default(0.8)
// @toggle pulsate "Pulsowanie" default(true)
float2 p = uv * vesselScale;
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
        float flowPos = fract(dot(f, dir) + iTime * bloodFlow / scale);
        float flow = smoothstep(0.1, 0.0, abs(flowPos - 0.5));
        bloodPulse += flow * vessel / scale;
    }
}
float pulse = 1.0;
if (pulsate > 0.5) {
    pulse = 0.9 + 0.1 * sin(iTime * 3.0);
}
float3 venousColor = float3(0.4, 0.2, 0.3);
float3 arterialColor = float3(0.8, 0.2, 0.2);
float3 vesselColor = mix(venousColor, arterialColor, oxygenLevel);
col = mix(col, vesselColor * pulse, vessels * 0.8);
col += bloodPulse * float3(0.2, 0.0, 0.0) * bloodFlow;
return float4(col, 1.0);
"""

/// Coral Reef
let coralReefCode = """
// @param coralDensity "Gęstość korali" range(3.0, 10.0) default(6.0)
// @param branchComplexity "Złożoność gałęzi" range(2, 8) default(5)
// @param swayAmount "Kołysanie" range(0.0, 0.2) default(0.05)
// @param waterDepth "Głębokość wody" range(0.0, 1.0) default(0.3)
// @param colorVariety "Różnorodność kolorów" range(0.5, 2.0) default(1.0)
// @toggle fish "Ryby" default(true)
float2 p = uv;
p.x += sin(p.y * 5.0 + iTime) * swayAmount;
float3 col = mix(float3(0.0, 0.2, 0.4), float3(0.0, 0.4, 0.6), p.y);
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
        float angle = (fb / float(branchComplexity) - 0.5) * 1.5 + sin(iTime + fi) * swayAmount * 3.0;
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
        coralColor = mix(coralColor, float3(1.0, 0.8, 0.9), 0.3);
        col = mix(col, coralColor, coral);
    }
}
if (fish > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float fx = fract(sin(fi * 43.758) * 43758.5453 + iTime * 0.1 * (0.5 + fi * 0.1));
        float fy = fract(sin(fi * 78.233) * 43758.5453) * 0.6 + 0.2;
        float2 fishPos = float2(fx, fy);
        float fishD = length(p - fishPos);
        float fishBody = smoothstep(0.02, 0.01, fishD);
        float3 fishColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 1.0, 2.0));
        col = mix(col, fishColor, fishBody);
    }
}
return float4(col, 1.0);
"""

/// Mushroom Forest
let mushroomForestCode = """
// @param mushroomCount "Liczba grzybów" range(3, 15) default(8)
// @param capSize "Rozmiar kapelusza" range(0.05, 0.15) default(0.08)
// @param stemHeight "Wysokość trzonu" range(0.1, 0.3) default(0.15)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.5)
// @param sporeAmount "Ilość zarodników" range(0.0, 1.0) default(0.3)
// @toggle bioluminescent "Bioluminescencja" default(true)
float2 p = uv;
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
    capColor = mix(capColor, float3(0.9, 0.3, 0.2), 0.3);
    col = mix(col, capColor, cap);
    if (bioluminescent > 0.5) {
        float glow = exp(-capD / (capSize * mScale * 2.0)) * glowIntensity;
        float pulse = 0.7 + 0.3 * sin(iTime * 2.0 + fi);
        col += glow * pulse * float3(0.2, 0.8, 0.5);
    }
}
if (sporeAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float2 sporePos = float2(
            fract(sin(fi * 43.758) * 43758.5453),
            fract(fract(sin(fi * 78.233) * 43758.5453) + iTime * 0.05)
        );
        float sporeD = length(p - sporePos);
        float spore = smoothstep(0.005, 0.0, sporeD) * sporeAmount;
        col += spore * float3(0.5, 1.0, 0.5);
    }
}
return float4(col, 1.0);
"""

/// Butterfly Wings
let butterflyWingsCode = """
// @param wingScale "Skala skrzydeł" range(0.5, 2.0) default(1.0)
// @param patternComplexity "Złożoność wzoru" range(2, 8) default(5)
// @param flapSpeed "Prędkość trzepotania" range(0.0, 5.0) default(2.0)
// @param colorSaturation "Nasycenie kolorów" range(0.5, 1.5) default(1.0)
// @param eyespotSize "Rozmiar oczek" range(0.0, 0.15) default(0.08)
// @toggle symmetry "Symetria" default(true)
float2 p = uv * 2.0 - 1.0;
if (symmetry > 0.5) {
    p.x = abs(p.x);
}
float flapAngle = sin(iTime * flapSpeed) * 0.3;
p.x = p.x * cos(flapAngle) - p.y * sin(flapAngle) * 0.2;
p *= wingScale;
float3 col = float3(0.1, 0.1, 0.15);
float2 wingCenter = float2(0.3, 0.0);
float wingR = length(p - wingCenter);
float wingA = atan2(p.y - wingCenter.y, p.x - wingCenter.x);
float wingShape = 0.3 + 0.2 * cos(wingA * 2.0) + 0.1 * cos(wingA * 4.0);
float wing = smoothstep(wingShape + 0.02, wingShape, wingR);
float3 baseColor = float3(0.9, 0.4, 0.1);
float3 tipColor = float3(0.2, 0.1, 0.05);
float3 wingColor = mix(baseColor, tipColor, wingR / wingShape);
wingColor = mix(float3(0.5), wingColor, colorSaturation);
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
    col = mix(col, patternColor * colorSaturation, pattern * wing);
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
return float4(col, 1.0);
"""

/// Fern Fractal
let fernFractalCode = """
// @param iterations "Iteracje" range(10, 100) default(50)
// @param fernScale "Skala paproci" range(0.5, 2.0) default(1.0)
// @param windSway "Wiatr" range(0.0, 0.3) default(0.1)
// @param leafDensity "Gęstość liści" range(0.5, 1.5) default(1.0)
// @param greenVariation "Wariacja zieleni" range(0.0, 1.0) default(0.3)
// @toggle autumn "Jesienne kolory" default(false)
float2 p = uv * 2.0 - 1.0;
p.x += sin(p.y * 3.0 + iTime) * windSway;
p = p / fernScale + float2(0.0, 0.5);
float3 col = float3(0.05, 0.08, 0.05);
float fern = 0.0;
float2 fernP = float2(0.0, 0.0);
for (int i = 0; i < 100; i++) {
    if (i >= int(iterations)) break;
    float r = fract(sin(float(i) * 43.758 + iTime * 0.01) * 43758.5453);
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
    fernColor = mix(float3(0.8, 0.6, 0.2), float3(0.9, 0.3, 0.1), fract(sin(p.y * 10.0) * 43758.5453) * greenVariation);
} else {
    fernColor = mix(float3(0.2, 0.6, 0.2), float3(0.1, 0.4, 0.1), fract(sin(p.y * 10.0) * 43758.5453) * greenVariation);
}
col = mix(col, fernColor, fern);
return float4(col, 1.0);
"""

/// Peacock Feather
let peacockFeatherCode = """
// @param featherCount "Liczba piór" range(1, 5) default(3)
// @param eyeSize "Rozmiar oczka" range(0.05, 0.2) default(0.1)
// @param barbDensity "Gęstość promieni" range(20.0, 60.0) default(40.0)
// @param shimmerSpeed "Prędkość lśnienia" range(0.0, 3.0) default(1.0)
// @param iridescence "Opalizacja" range(0.5, 2.0) default(1.0)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.03, 0.02);
for (int f = 0; f < 5; f++) {
    if (f >= int(featherCount)) break;
    float ff = float(f);
    float2 featherBase = float2(-0.3 + ff * 0.3, -0.8);
    float2 featherDir = normalize(float2(sin(ff * 0.5), 1.0));
    if (animate > 0.5) {
        featherDir = normalize(float2(sin(iTime * 0.5 + ff), 1.0));
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
    float3 barbColor = 0.5 + 0.5 * cos((along + perp * 2.0) * iridescence + iTime * shimmerSpeed + float3(0.0, 2.0, 4.0));
    barbColor = mix(float3(0.1, 0.3, 0.2), barbColor, 0.7);
    col = mix(col, barbColor, barbPattern * 0.7);
    float2 eyeCenter = featherBase + featherDir * 0.8;
    float eyeD = length(p - eyeCenter);
    float eyeOuter = smoothstep(eyeSize, eyeSize - 0.02, eyeD);
    float eyeMiddle = smoothstep(eyeSize * 0.7, eyeSize * 0.5, eyeD);
    float eyeInner = smoothstep(eyeSize * 0.4, eyeSize * 0.2, eyeD);
    float shimmer = 0.8 + 0.2 * sin(iTime * shimmerSpeed * 3.0 + ff);
    col = mix(col, float3(0.1, 0.3, 0.6) * shimmer, eyeOuter);
    col = mix(col, float3(0.2, 0.7, 0.9) * shimmer, eyeMiddle);
    col = mix(col, float3(0.1, 0.1, 0.3), eyeInner);
}
return float4(col, 1.0);
"""

/// Spider Web
let spiderWebCode = """
// @param radialLines "Linie radialne" range(6, 24) default(12)
// @param spiralTurns "Zwoje spirali" range(3, 15) default(8)
// @param webThickness "Grubość sieci" range(0.005, 0.02) default(0.008)
// @param dewDrops "Krople rosy" range(0.0, 1.0) default(0.5)
// @param swayAmount "Kołysanie" range(0.0, 0.1) default(0.02)
// @toggle broken "Uszkodzona" default(false)
float2 p = uv * 2.0 - 1.0;
p += sin(iTime + p.yx * 5.0) * swayAmount;
float3 col = float3(0.05, 0.08, 0.12);
float r = length(p);
float a = atan2(p.y, p.x);
for (int i = 0; i < 24; i++) {
    if (i >= int(radialLines)) break;
    float fi = float(i);
    float lineAngle = fi * 6.28318 / float(radialLines);
    if (broken > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.7) continue;
    float angleDiff = abs(fmod(a - lineAngle + 3.14159, 6.28318) - 3.14159);
    float radial = smoothstep(webThickness / r, 0.0, angleDiff);
    radial *= step(0.05, r) * step(r, 0.9);
    col += radial * float3(0.8, 0.85, 0.9) * 0.5;
}
for (int i = 0; i < 15; i++) {
    if (i >= int(spiralTurns)) break;
    float fi = float(i);
    float spiralR = 0.1 + fi * 0.06;
    if (broken > 0.5 && fract(sin(fi * 78.233) * 43758.5453) > 0.8) continue;
    float spiralD = abs(r - spiralR);
    float spiral = smoothstep(webThickness, 0.0, spiralD);
    col += spiral * float3(0.8, 0.85, 0.9) * 0.4;
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
        col += drop * float3(0.5, 0.6, 0.8);
        col += highlight * float3(1.0) * dewDrops;
    }
}
float center = smoothstep(0.08, 0.05, r);
col = mix(col, float3(0.3, 0.25, 0.2), center);
return float4(col, 1.0);
"""

// MARK: - More Organic Effects

/// Mitosis Cell Division
let mitosisCode = """
// @param divisionPhase "Faza podziału" range(0.0, 1.0) default(0.5)
// @param chromosomeCount "Liczba chromosomów" range(4, 12) default(8)
// @param spindleVisibility "Widoczność wrzeciona" range(0.0, 1.0) default(0.5)
// @param cellSize "Rozmiar komórki" range(0.3, 0.6) default(0.4)
// @param membraneWobble "Falowanie błony" range(0.0, 0.1) default(0.02)
// @toggle animatePhase "Animuj fazę" default(true)
float2 p = uv * 2.0 - 1.0;
float phase = divisionPhase;
if (animatePhase > 0.5) {
    phase = fract(iTime * 0.1);
}
float3 col = float3(0.9, 0.92, 0.95);
float separation = phase * 0.4;
float2 cell1Center = float2(-separation, 0.0);
float2 cell2Center = float2(separation, 0.0);
float wobble = sin(atan2(p.y, p.x - cell1Center.x) * 8.0 + iTime) * membraneWobble;
float cell1D = length(p - cell1Center);
float cell1 = smoothstep(cellSize + wobble + 0.02, cellSize + wobble, cell1D);
float wobble2 = sin(atan2(p.y, p.x - cell2Center.x) * 8.0 + iTime) * membraneWobble;
float cell2D = length(p - cell2Center);
float cell2 = smoothstep(cellSize + wobble2 + 0.02, cellSize + wobble2, cell2D);
float cell = max(cell1, cell2);
if (phase < 0.5) {
    float bridge = step(abs(p.y), 0.1) * step(cell1Center.x, p.x) * step(p.x, cell2Center.x);
    bridge *= step(length(p), cellSize);
    cell = max(cell, bridge);
}
float3 cytoColor = float3(0.75, 0.85, 0.8);
col = mix(col, cytoColor, cell);
float membrane = smoothstep(0.02, 0.0, abs(cell1D - cellSize - wobble));
membrane += smoothstep(0.02, 0.0, abs(cell2D - cellSize - wobble2));
col = mix(col, float3(0.5, 0.6, 0.55), membrane * 0.8);
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
return float4(col, 1.0);
"""

/// Jellyfish Swarm
let jellyfishSwarmCode = """
// @param jellyfishCount "Liczba meduz" range(1, 8) default(4)
// @param pulseSpeed "Prędkość pulsowania" range(0.5, 3.0) default(1.5)
// @param tentacleLength "Długość macek" range(0.1, 0.4) default(0.25)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.6)
// @param driftSpeed "Prędkość dryfowania" range(0.0, 0.5) default(0.2)
// @toggle bioluminescence "Bioluminescencja" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0, 0.05, 0.1);
for (int i = 0; i < 8; i++) {
    if (i >= int(jellyfishCount)) break;
    float fi = float(i);
    float2 jellyCenter = float2(
        sin(iTime * driftSpeed + fi * 2.0) * 0.5,
        cos(iTime * driftSpeed * 0.7 + fi * 1.5) * 0.3 + fi * 0.2 - 0.3
    );
    float pulse = sin(iTime * pulseSpeed + fi) * 0.5 + 0.5;
    float bellWidth = 0.12 + pulse * 0.03;
    float bellHeight = 0.08 + pulse * 0.02;
    float2 bellP = (p - jellyCenter) / float2(bellWidth, bellHeight);
    float bellD = length(bellP);
    float bell = smoothstep(1.1, 0.9, bellD) * step(bellP.y, 0.5);
    float3 jellyColor = 0.5 + 0.5 * cos(fi * 1.2 + float3(0.0, 1.0, 2.0));
    jellyColor = mix(jellyColor, float3(1.0, 0.9, 0.95), 0.3);
    col = mix(col, jellyColor * 0.7, bell);
    for (int t = 0; t < 5; t++) {
        float ft = float(t);
        float tentX = jellyCenter.x + (ft / 4.0 - 0.5) * bellWidth * 1.5;
        float tentWave = sin(p.y * 15.0 + iTime * 2.0 + ft) * 0.02;
        float tentD = abs(p.x - tentX - tentWave);
        float tentacle = smoothstep(0.01, 0.005, tentD);
        tentacle *= step(jellyCenter.y - bellHeight - tentacleLength, p.y);
        tentacle *= step(p.y, jellyCenter.y - bellHeight * 0.5);
        col = mix(col, jellyColor * 0.5, tentacle * 0.5);
    }
    if (bioluminescence > 0.5) {
        float glow = exp(-bellD * 3.0) * glowIntensity;
        float glowPulse = 0.7 + 0.3 * sin(iTime * 3.0 + fi * 2.0);
        col += glow * jellyColor * glowPulse;
    }
}
float particles = step(0.997, fract(sin(dot(floor(uv * 100.0 + iTime * 10.0), float2(12.9898, 78.233))) * 43758.5453));
col += particles * 0.2;
return float4(col, 1.0);
"""

/// Flower Bloom
let flowerBloomCode = """
// @param petalCount "Liczba płatków" range(4, 12) default(6)
// @param bloomPhase "Faza kwitnienia" range(0.0, 1.0) default(0.8)
// @param petalCurl "Zwinięcie płatków" range(0.0, 0.5) default(0.1)
// @param colorGradient "Gradient kolorów" range(0.0, 1.0) default(0.5)
// @param centerSize "Rozmiar środka" range(0.05, 0.2) default(0.1)
// @toggle animated "Animowany" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float bloom = bloomPhase;
if (animated > 0.5) {
    bloom = sin(iTime * 0.5) * 0.3 + 0.7;
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
    float petalWidth = 0.4 * bloom;
    float petalShape = cos(angleDiff / petalWidth * 1.57);
    petalShape = max(0.0, petalShape);
    float petalLength = 0.4 * bloom * (1.0 - petalCurl * (1.0 - petalShape));
    float petalMask = step(r, petalLength) * petalShape;
    petalMask *= step(centerSize, r);
    petal = max(petal, petalMask);
    float3 innerColor = float3(1.0, 0.3, 0.5);
    float3 outerColor = float3(1.0, 0.8, 0.9);
    float3 petalColor = mix(innerColor, outerColor, r / petalLength * colorGradient);
    petalColor = mix(petalColor, float3(1.0, 0.5, 0.6), petalShape * 0.3);
    col = mix(col, petalColor, petalMask);
}
float center = smoothstep(centerSize + 0.02, centerSize, r);
float3 centerColor = float3(1.0, 0.9, 0.2);
float centerPattern = sin(a * 20.0) * sin(r * 50.0) * 0.5 + 0.5;
centerColor = mix(centerColor, float3(0.8, 0.6, 0.1), centerPattern);
col = mix(col, centerColor, center);
float stamen = step(0.98, sin(a * 30.0)) * center * 0.5;
col = mix(col, float3(0.6, 0.4, 0.1), stamen);
return float4(col, 1.0);
"""

/// Lichen Growth
let lichenGrowthCode = """
// @param growthScale "Skala wzrostu" range(3.0, 15.0) default(8.0)
// @param layerCount "Liczba warstw" range(1, 5) default(3)
// @param edgeDetail "Szczegół krawędzi" range(1.0, 5.0) default(2.5)
// @param growthSpeed "Prędkość wzrostu" range(0.0, 1.0) default(0.2)
// @param colorVariation "Wariacja kolorów" range(0.0, 1.0) default(0.5)
// @toggle crusty "Skorupiasta tekstura" default(true)
float2 p = uv * growthScale;
float time = iTime * growthSpeed;
float3 col = float3(0.3, 0.25, 0.2);
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
        lichenColor = mix(float3(0.5, 0.6, 0.4), lichenColor, 0.5);
    } else {
        lichenColor = float3(0.5, 0.55, 0.4);
    }
    lichenColor *= (1.0 - fl * 0.15);
    col = mix(col, lichenColor, growth * 0.7);
    if (crusty > 0.5) {
        float crust = fract(sin(dot(floor(lp * 10.0), float2(12.9898, 78.233))) * 43758.5453);
        crust = step(0.7, crust) * growth;
        col += crust * 0.1;
    }
}
return float4(col, 1.0);
"""

/// Heartbeat Monitor
let heartbeatMonitorCode = """
// @param heartRate "Tętno (BPM)" range(40.0, 180.0) default(72.0)
// @param lineThickness "Grubość linii" range(0.005, 0.02) default(0.008)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @param gridOpacity "Przezroczystość siatki" range(0.0, 0.5) default(0.2)
// @param traceSpeed "Prędkość śledzenia" range(0.5, 2.0) default(1.0)
// @toggle flatline "Linia płaska" default(false)
float2 p = uv;
float3 col = float3(0.02, 0.05, 0.02);
float gridX = smoothstep(0.02, 0.0, abs(fract(p.x * 10.0) - 0.5));
float gridY = smoothstep(0.02, 0.0, abs(fract(p.y * 8.0) - 0.5));
col += (gridX + gridY) * float3(0.0, 0.2, 0.0) * gridOpacity;
float beatPeriod = 60.0 / heartRate;
float x = fract(p.x - iTime * traceSpeed / beatPeriod * 0.2);
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
float glow = smoothstep(lineThickness * 10.0, 0.0, waveDist) * glowAmount;
float3 lineColor = float3(0.0, 1.0, 0.3);
col += line * lineColor;
col += glow * lineColor * 0.5;
float trace = smoothstep(0.0, 0.1, x);
col *= trace;
float sweepLine = smoothstep(0.01, 0.0, abs(x));
col += sweepLine * lineColor * 0.3;
return float4(col, 1.0);
"""

/// Vine Growth
let vineGrowthCode = """
// @param vineCount "Liczba pnączy" range(1, 8) default(4)
// @param growthProgress "Postęp wzrostu" range(0.0, 1.0) default(0.7)
// @param curliness "Kręcenie" range(0.5, 3.0) default(1.5)
// @param leafDensity "Gęstość liści" range(0.0, 1.0) default(0.5)
// @param thickness "Grubość" range(0.01, 0.05) default(0.02)
// @toggle flowers "Kwiaty" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.9, 0.92, 0.85);
float growth = growthProgress;
for (int v = 0; v < 8; v++) {
    if (v >= int(vineCount)) break;
    float fv = float(v);
    float2 vineStart = float2(fract(sin(fv * 127.1) * 43758.5453) * 2.0 - 1.0, -1.0);
    float vineAngle = (fv / float(vineCount) - 0.5) * 1.0 + sin(iTime * 0.3 + fv) * 0.1;
    float vineLen = growth * 1.5;
    for (int seg = 0; seg < 30; seg++) {
        float fs = float(seg) / 30.0;
        if (fs > growth) break;
        float curl = sin(fs * curliness * 6.28 + fv) * 0.2;
        float2 segPos = vineStart + float2(sin(vineAngle + curl), fs) * vineLen * fs;
        float d = length(p - segPos);
        float segThick = thickness * (1.0 - fs * 0.5);
        float vine = smoothstep(segThick, segThick * 0.5, d);
        col = mix(col, float3(0.2, 0.4, 0.2), vine);
        if (leafDensity > 0.0 && fract(sin(fs * 10.0 + fv) * 43758.5453) < leafDensity * 0.3) {
            float leafAngle = sin(fs * 5.0 + fv) * 1.57;
            float2 leafOffset = float2(cos(leafAngle), sin(leafAngle)) * 0.08;
            float2 leafPos = segPos + leafOffset;
            float2 leafP = p - leafPos;
            float leafD = length(leafP * float2(1.0, 2.0));
            float leaf = smoothstep(0.04, 0.03, leafD);
            col = mix(col, float3(0.3, 0.6, 0.3), leaf);
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
return float4(col, 1.0);
"""

/// Seashell Spiral
let seashellSpiralCode = """
// @param spiralTightness "Ciasność spirali" range(0.1, 0.3) default(0.18)
// @param ridgeCount "Liczba żeberek" range(10, 40) default(20)
// @param ridgeDepth "Głębokość żeberek" range(0.0, 0.3) default(0.15)
// @param pearlescence "Perłowość" range(0.0, 1.0) default(0.5)
// @param aperture "Ujście" range(0.0, 0.5) default(0.2)
// @toggle golden "Złota spirala" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.9, 0.85, 0.75);
float growthFactor = spiralTightness;
if (golden > 0.5) {
    growthFactor = 0.306349;
}
float spiralR = exp(growthFactor * (a + iTime * 0.5));
float normalizedR = log(r) / growthFactor - a - iTime * 0.5;
float turns = fract(normalizedR / 6.28318);
float shell = smoothstep(0.1, 0.0, abs(turns - 0.5) - 0.4);
shell *= step(0.05, r) * step(r, 0.9);
float ridge = sin(normalizedR * float(ridgeCount)) * ridgeDepth + 0.5;
float3 shellColor = mix(float3(0.95, 0.9, 0.8), float3(0.8, 0.7, 0.6), ridge);
if (pearlescence > 0.0) {
    float pearl = 0.5 + 0.5 * cos(a * 3.0 + r * 10.0 + iTime + float3(0.0, 2.0, 4.0)).x;
    shellColor = mix(shellColor, float3(1.0, 0.95, 0.98), pearl * pearlescence * 0.3);
}
col = mix(col, shellColor, shell);
float apertureAngle = -0.5;
float apertureMask = smoothstep(aperture, 0.0, abs(a - apertureAngle));
apertureMask *= step(r, 0.3);
col = mix(col, float3(0.3, 0.25, 0.2), apertureMask * 0.5);
float lip = smoothstep(0.02, 0.0, abs(r - 0.3)) * apertureMask;
col = mix(col, float3(0.95, 0.85, 0.8), lip);
return float4(col, 1.0);
"""

/// Tide Pool
let tidePoolCode = """
// @param waterClarity "Klarowność wody" range(0.3, 1.0) default(0.7)
// @param waveIntensity "Intensywność fal" range(0.0, 0.5) default(0.2)
// @param creatureCount "Liczba stworzeń" range(0, 10) default(5)
// @param algaeAmount "Ilość glonów" range(0.0, 1.0) default(0.3)
// @param rockScale "Skala skał" range(2.0, 8.0) default(4.0)
// @toggle starfish "Rozgwiazda" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.3, 0.4);
float2 rockP = p * rockScale;
float rock = sin(rockP.x * 3.0) * sin(rockP.y * 2.0) * 0.5 + 0.5;
rock += sin(rockP.x * 7.0 + rockP.y * 5.0) * 0.25;
rock = smoothstep(0.4, 0.6, rock);
float3 rockColor = mix(float3(0.3, 0.25, 0.2), float3(0.5, 0.45, 0.4), rock);
col = mix(col, rockColor, 0.3);
if (algaeAmount > 0.0) {
    float algae = sin(p.x * 30.0 + iTime) * sin(p.y * 25.0) * 0.5 + 0.5;
    algae = step(1.0 - algaeAmount * 0.5, algae);
    col = mix(col, float3(0.2, 0.4, 0.2), algae * 0.5);
}
float wave = sin(p.x * 20.0 + iTime * 2.0) * sin(p.y * 15.0 + iTime * 1.5);
wave *= waveIntensity;
col += wave * float3(0.2, 0.3, 0.4) * waterClarity;
for (int i = 0; i < 10; i++) {
    if (i >= int(creatureCount)) break;
    float fi = float(i);
    float2 creaturePos = float2(
        fract(sin(fi * 127.1) * 43758.5453),
        fract(sin(fi * 311.7) * 43758.5453)
    );
    creaturePos += sin(iTime * 0.5 + fi) * 0.02;
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
    col = mix(col, float3(0.9, 0.4, 0.2), starShape);
}
float reflection = pow(1.0 - p.y, 2.0) * waterClarity * 0.3;
col += reflection * float3(0.5, 0.6, 0.7);
return float4(col, 1.0);
"""

