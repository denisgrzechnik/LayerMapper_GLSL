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
// @param meltAmount "Stopień topienia" range(0.0, 0.5) default(0.3)
// @param clockSize "Rozmiar zegara" range(0.2, 0.4) default(0.3)
// @param timeSpeed "Prędkość czasu" range(0.1, 2.0) default(1.0)
// @param distortionWave "Fala zniekształcenia" range(0.0, 1.0) default(0.5)
// @param colorSaturation "Nasycenie kolorów" range(0.0, 1.0) default(0.6)
// @toggle dali "Styl Dalí" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.9, 0.85, 0.7);
float2 clockP = p;
if (dali > 0.5) {
    float melt = sin(p.x * 3.0 + iTime * 0.5) * meltAmount;
    melt += pow(max(0.0, -p.y), 2.0) * meltAmount * 2.0;
    clockP.y += melt;
    clockP.x += sin(p.y * 5.0) * meltAmount * 0.3;
}
float r = length(clockP);
float a = atan2(clockP.y, clockP.x);
float clock = smoothstep(clockSize + 0.02, clockSize, r);
clock -= smoothstep(clockSize - 0.02, clockSize - 0.04, r);
float3 clockColor = float3(0.95, 0.92, 0.85);
col = mix(col, clockColor, smoothstep(clockSize, clockSize - 0.01, r));
col = mix(col, float3(0.6, 0.5, 0.4), clock);
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
float hourAngle = iTime * timeSpeed * 0.1;
float minAngle = iTime * timeSpeed;
float2 hourDir = float2(sin(hourAngle), cos(hourAngle));
float hourHand = step(abs(dot(clockP, float2(-hourDir.y, hourDir.x))), 0.01);
hourHand *= step(0.0, dot(clockP, hourDir)) * step(length(clockP), clockSize * 0.5);
float2 minDir = float2(sin(minAngle), cos(minAngle));
float minHand = step(abs(dot(clockP, float2(-minDir.y, minDir.x))), 0.005);
minHand *= step(0.0, dot(clockP, minDir)) * step(length(clockP), clockSize * 0.7);
col = mix(col, float3(0.2, 0.15, 0.1), hourHand * step(r, clockSize));
col = mix(col, float3(0.1, 0.1, 0.1), minHand * step(r, clockSize));
if (colorSaturation > 0.0 && dali > 0.5) {
    float3 tint = 0.5 + 0.5 * cos(p.x * 2.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, col * tint, colorSaturation * 0.3);
}
return float4(col, 1.0);
"""

/// Impossible Stairs
let impossibleStairsCode = """
// @param stairCount "Liczba schodów" range(5, 15) default(10)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 1.0) default(0.3)
// @param perspective "Perspektywa" range(0.3, 0.8) default(0.5)
// @param lineThickness "Grubość linii" range(0.005, 0.02) default(0.01)
// @param shadowDepth "Głębokość cienia" range(0.0, 0.5) default(0.3)
// @toggle animated "Animowany" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.95, 0.93, 0.9);
float rotation = animated > 0.5 ? iTime * rotationSpeed : 0.0;
float2 rp = float2(
    p.x * cos(rotation) - p.y * sin(rotation),
    p.x * sin(rotation) + p.y * cos(rotation)
);
float stairHeight = 1.5 / float(stairCount);
float stairWidth = 0.1;
float stairDepth = 0.05;
float3 lineColor = float3(0.2, 0.2, 0.25);
for (int i = 0; i < 15; i++) {
    if (i >= int(stairCount)) break;
    float fi = float(i);
    float angle = fi / float(stairCount) * 6.28318 + rotation;
    float stairY = -0.7 + fi * stairHeight;
    float stairX = sin(angle) * 0.3;
    float perspScale = 1.0 - (fi / float(stairCount)) * perspective * 0.5;
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
    col = mix(col, lineColor, stairs);
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
return float4(col, 1.0);
"""

/// Floating Islands
let floatingIslandsCode = """
// @param islandCount "Liczba wysp" range(2, 6) default(4)
// @param floatSpeed "Prędkość unoszenia" range(0.3, 1.5) default(0.7)
// @param floatAmount "Amplituda" range(0.02, 0.1) default(0.05)
// @param cloudDensity "Gęstość chmur" range(0.0, 1.0) default(0.5)
// @param mysteryGlow "Tajemnicza poświata" range(0.0, 1.0) default(0.4)
// @toggle waterfalls "Wodospady" default(true)
float2 p = uv;
float3 skyTop = float3(0.4, 0.6, 0.9);
float3 skyBottom = float3(0.7, 0.8, 0.95);
float3 col = mix(skyBottom, skyTop, p.y);
if (cloudDensity > 0.0) {
    float cloud = sin(p.x * 10.0 + iTime * 0.2) * sin(p.y * 8.0 + iTime * 0.1);
    cloud = cloud * 0.5 + 0.5;
    cloud *= smoothstep(0.4, 0.7, p.y) * cloudDensity;
    col = mix(col, float3(1.0, 1.0, 1.0), cloud * 0.3);
}
for (int i = 0; i < 6; i++) {
    if (i >= int(islandCount)) break;
    float fi = float(i);
    float islandX = fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1;
    float islandY = fract(sin(fi * 311.7) * 43758.5453) * 0.4 + 0.3;
    float islandSize = fract(sin(fi * 178.3) * 43758.5453) * 0.08 + 0.05;
    float bobOffset = sin(iTime * floatSpeed + fi * 2.0) * floatAmount;
    float2 islandPos = float2(islandX, islandY + bobOffset);
    float islandDist = length((p - islandPos) * float2(1.0, 2.0));
    float island = smoothstep(islandSize, islandSize * 0.7, islandDist);
    float3 grassColor = float3(0.3, 0.5, 0.2);
    float3 dirtColor = float3(0.4, 0.3, 0.2);
    float3 rockColor = float3(0.4, 0.35, 0.3);
    float grassMask = smoothstep(islandSize * 0.8, islandSize * 0.5, islandDist);
    float3 islandColor = mix(rockColor, grassColor, grassMask);
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
        float flowAnim = fract(p.y * 20.0 - iTime * 3.0);
        fall *= flowAnim * 0.5 + 0.5;
        col = mix(col, float3(0.7, 0.85, 1.0), fall * 0.7);
    }
    if (mysteryGlow > 0.0) {
        float glow = exp(-islandDist * 5.0) * mysteryGlow;
        col += glow * float3(0.3, 0.5, 0.7) * 0.3;
    }
}
return float4(col, 1.0);
"""

/// Dream Portal
let dreamPortalCode = """
// @param portalSize "Rozmiar portalu" range(0.2, 0.5) default(0.35)
// @param spiralSpeed "Prędkość spirali" range(0.5, 3.0) default(1.5)
// @param colorDepth "Głębokość kolorów" range(1.0, 5.0) default(3.0)
// @param distortionRipple "Fala zniekształcenia" range(0.0, 0.3) default(0.1)
// @param starDensity "Gęstość gwiazd" range(0.0, 1.0) default(0.5)
// @toggle vortex "Wir" default(true)
float2 p = uv * 2.0 - 1.0;
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
        p.x * cos(twist + iTime * spiralSpeed) - p.y * sin(twist + iTime * spiralSpeed),
        p.x * sin(twist + iTime * spiralSpeed) + p.y * cos(twist + iTime * spiralSpeed)
    );
}
if (distortionRipple > 0.0) {
    float ripple = sin(r * 30.0 - iTime * 5.0) * distortionRipple;
    portalP += portalP * ripple;
}
float portalR = length(portalP);
float portalA = atan2(portalP.y, portalP.x);
float spiral = sin(portalA * 3.0 + portalR * 10.0 - iTime * spiralSpeed * 2.0);
spiral = spiral * 0.5 + 0.5;
float3 innerColor = 0.5 + 0.5 * cos(portalR * colorDepth + iTime + float3(0.0, 2.0, 4.0));
innerColor *= 0.5 + 0.5 * cos(portalA * 2.0 + iTime * 0.5 + float3(4.0, 2.0, 0.0));
col = mix(col, innerColor * portal, portal);
col = mix(col, innerColor * spiral * 0.7, portal * spiral * 0.5);
col += portalEdge * float3(0.8, 0.5, 1.0) * 0.8;
float glow = exp(-abs(r - portalSize) * 10.0);
col += glow * float3(0.6, 0.3, 0.8) * 0.5;
if (starDensity > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float starA = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
        float starR = fract(sin(fi * 311.7) * 43758.5453) * portalSize * 0.8;
        float starTwist = (portalSize - starR) * 3.0;
        float2 starPos = float2(cos(starA + iTime * spiralSpeed + starTwist), sin(starA + iTime * spiralSpeed + starTwist)) * starR;
        float d = length(p - starPos);
        float star = smoothstep(0.01, 0.005, d) * portal;
        col += star * float3(1.0, 0.9, 0.8) * starDensity;
    }
}
return float4(col, 1.0);
"""

/// Paper Cutout
let paperCutoutCode = """
// @param layerCount "Liczba warstw" range(3, 8) default(5)
// @param layerDepth "Głębokość warstw" range(0.02, 0.1) default(0.05)
// @param colorfulness "Kolorowość" range(0.0, 1.0) default(0.7)
// @param paperTexture "Tekstura papieru" range(0.0, 0.3) default(0.1)
// @param animationSpeed "Prędkość animacji" range(0.0, 1.0) default(0.3)
// @toggle shadows "Cienie" default(true)
float2 p = uv;
float3 col = float3(0.95, 0.92, 0.88);
for (int i = int(layerCount) - 1; i >= 0; i--) {
    float fi = float(i);
    float layerY = fi / float(layerCount);
    float waveOffset = sin(p.x * 10.0 + fi * 2.0 + iTime * animationSpeed) * 0.05;
    float wave2 = sin(p.x * 20.0 - fi * 3.0 + iTime * animationSpeed * 0.7) * 0.02;
    float cutY = layerY * 0.7 + 0.15 + waveOffset + wave2;
    float layer = smoothstep(cutY + 0.01, cutY, p.y);
    float3 layerColor;
    if (colorfulness > 0.0) {
        layerColor = 0.5 + 0.5 * cos(fi * 1.5 + float3(0.0, 2.0, 4.0));
        layerColor = mix(float3(0.9), layerColor, colorfulness);
    } else {
        float shade = 0.9 - fi / float(layerCount) * 0.3;
        layerColor = float3(shade);
    }
    if (paperTexture > 0.0) {
        float texture = sin(p.x * 200.0 + fi * 50.0) * sin(p.y * 200.0 + fi * 30.0);
        texture = texture * 0.5 + 0.5;
        layerColor += (texture - 0.5) * paperTexture;
    }
    if (shadows > 0.5 && i < int(layerCount) - 1) {
        float shadowY = cutY + layerDepth * (float(layerCount) - fi) * 0.5;
        float shadow = smoothstep(shadowY, cutY, p.y) * (1.0 - layer);
        col = mix(col, col * 0.7, shadow * 0.5);
    }
    col = mix(col, layerColor, layer);
    float edge = smoothstep(cutY + 0.005, cutY, p.y) - smoothstep(cutY, cutY - 0.005, p.y);
    col = mix(col, layerColor * 0.8, edge * 0.5);
}
return float4(col, 1.0);
"""

/// Stained Glass
let stainedGlassCode = """
// @param cellCount "Liczba komórek" range(5, 20) default(12)
// @param leadWidth "Szerokość ołowiu" range(0.01, 0.05) default(0.02)
// @param colorIntensity "Intensywność koloru" range(0.5, 1.0) default(0.8)
// @param lightDirection "Kierunek światła" range(0.0, 6.28) default(0.785)
// @param glowAmount "Poświata" range(0.0, 0.5) default(0.2)
// @toggle cathedral "Katedralny" default(true)
float2 p = uv;
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
    float hue = cellSeed;
    if (cellSeed < 0.2) glassColor = float3(0.8, 0.2, 0.2);
    else if (cellSeed < 0.4) glassColor = float3(0.2, 0.3, 0.8);
    else if (cellSeed < 0.6) glassColor = float3(0.8, 0.7, 0.2);
    else if (cellSeed < 0.8) glassColor = float3(0.2, 0.6, 0.3);
    else glassColor = float3(0.6, 0.2, 0.6);
} else {
    glassColor = 0.5 + 0.5 * cos(cellSeed * 6.28 + float3(0.0, 2.0, 4.0));
}
glassColor *= colorIntensity;
float2 lightDir = float2(cos(lightDirection), sin(lightDirection));
float lightFactor = dot(normalize(cellLocal), lightDir) * 0.3 + 0.7;
glassColor *= lightFactor;
col = glassColor;
float lead = smoothstep(leadWidth, leadWidth * 0.5, minDist);
col = mix(col, float3(0.15, 0.15, 0.15), lead);
if (glowAmount > 0.0) {
    float glow = (1.0 - minDist * 2.0) * glowAmount;
    glow = max(0.0, glow);
    col += glow * glassColor * 0.5;
}
return float4(col, 1.0);
"""

/// Abstract Expressionism
let abstractExpressionismCode = """
// @param brushStrokes "Pociągnięcia pędzla" range(10, 50) default(30)
// @param strokeWidth "Szerokość pociągnięć" range(0.02, 0.1) default(0.05)
// @param colorVariety "Różnorodność kolorów" range(0.3, 1.0) default(0.8)
// @param chaosAmount "Ilość chaosu" range(0.0, 1.0) default(0.6)
// @param layering "Nakładanie warstw" range(0.3, 1.0) default(0.7)
// @toggle dripping "Ściekanie" default(true)
float2 p = uv;
float3 col = float3(0.95, 0.93, 0.9);
for (int i = 0; i < 50; i++) {
    if (i >= int(brushStrokes)) break;
    float fi = float(i);
    float seed = fract(sin(fi * 127.1) * 43758.5453);
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
    strokeMask *= smoothstep(widthVar, widthVar * 0.3, perp);
    float3 strokeColor = 0.5 + 0.5 * cos(fi * colorVariety + float3(0.0, 2.0, 4.0));
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
return float4(col, 1.0);
"""

/// Watercolor Wash
let watercolorWashCode = """
// @param bleedAmount "Rozpływanie" range(0.0, 0.5) default(0.3)
// @param pigmentDensity "Gęstość pigmentu" range(0.3, 1.0) default(0.6)
// @param wetness "Wilgotność" range(0.0, 1.0) default(0.5)
// @param colorLayers "Warstwy koloru" range(2, 6) default(4)
// @param granulation "Granulacja" range(0.0, 0.5) default(0.2)
// @toggle paperGrain "Ziarno papieru" default(true)
float2 p = uv;
float3 col = float3(0.98, 0.96, 0.93);
if (paperGrain > 0.5) {
    float grain = sin(p.x * 300.0) * sin(p.y * 300.0) * 0.02;
    col -= grain;
}
for (int i = 0; i < 6; i++) {
    if (i >= int(colorLayers)) break;
    float fi = float(i);
    float2 center = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2,
        fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2
    );
    float size = fract(sin(fi * 178.3) * 43758.5453) * 0.3 + 0.1;
    float2 toP = p - center;
    float dist = length(toP);
    float bleedNoise = sin(atan2(toP.y, toP.x) * 8.0 + fi * 5.0) * bleedAmount;
    bleedNoise += sin(dist * 30.0 + fi * 10.0) * bleedAmount * 0.5;
    float wash = smoothstep(size + bleedNoise, size * 0.3 + bleedNoise * 0.5, dist);
    float3 washColor = 0.5 + 0.5 * cos(fi * 1.8 + float3(0.0, 2.0, 4.0));
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
return float4(col, 1.0);
"""

/// Pop Art Dots
let popArtDotsCode = """
// @param dotSize "Rozmiar kropek" range(0.02, 0.08) default(0.04)
// @param dotSpacing "Odstęp" range(0.03, 0.12) default(0.06)
// @param colorScheme "Schemat kolorów" range(0.0, 4.0) default(0.0)
// @param contrast "Kontrast" range(0.5, 1.5) default(1.0)
// @param halftoneAngle "Kąt rastra" range(0.0, 1.57) default(0.26)
// @toggle outlined "Obrysowane" default(false)
float2 p = uv;
float3 col = float3(1.0);
float2 rotP = float2(
    p.x * cos(halftoneAngle) - p.y * sin(halftoneAngle),
    p.x * sin(halftoneAngle) + p.y * cos(halftoneAngle)
);
float2 gridP = rotP / dotSpacing;
float2 cellId = floor(gridP);
float2 cellCenter = (cellId + 0.5) * dotSpacing;
float2 origCenter = float2(
    cellCenter.x * cos(-halftoneAngle) - cellCenter.y * sin(-halftoneAngle),
    cellCenter.x * sin(-halftoneAngle) + cellCenter.y * cos(-halftoneAngle)
);
float zoneSeed = fract(sin(cellId.x * 127.1 + cellId.y * 311.7) * 43758.5453);
float zoneValue = pow(zoneSeed, 1.0 / contrast);
float actualDotSize = dotSize * zoneValue;
float3 bgColor;
float3 dotColor;
int scheme = int(colorScheme);
if (scheme == 0) {
    bgColor = float3(1.0, 1.0, 0.0);
    dotColor = float3(1.0, 0.0, 0.5);
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
col = bgColor;
float dist = length(p - origCenter);
float dot = smoothstep(actualDotSize, actualDotSize * 0.8, dist);
col = mix(col, dotColor, dot);
if (outlined > 0.5 && actualDotSize > dotSize * 0.3) {
    float outline = smoothstep(actualDotSize + 0.005, actualDotSize, dist);
    outline -= smoothstep(actualDotSize, actualDotSize - 0.005, dist);
    col = mix(col, float3(0.0), outline);
}
return float4(col, 1.0);
"""

/// Neon Sign Art
let neonSignArtCode = """
// @param glowIntensity "Intensywność blasku" range(0.5, 2.0) default(1.2)
// @param flickerAmount "Migotanie" range(0.0, 0.5) default(0.1)
// @param tubeWidth "Grubość rurki" range(0.01, 0.04) default(0.02)
// @param colorHue "Odcień koloru" range(0.0, 1.0) default(0.0)
// @param glowRadius "Promień poświaty" range(0.05, 0.2) default(0.1)
// @toggle broken "Uszkodzony" default(false)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float3 neonColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
neonColor = mix(neonColor, float3(1.0, 0.3, 0.5), 1.0 - colorHue);
float flicker = 1.0;
if (flickerAmount > 0.0) {
    flicker = 1.0 - flickerAmount * step(0.95, fract(sin(iTime * 20.0) * 43758.5453));
    flicker *= 1.0 - flickerAmount * 0.3 * sin(iTime * 60.0);
}
float star = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float angle = fi * 0.785;
    float2 dir = float2(cos(angle), sin(angle));
    float line = abs(dot(p, float2(-dir.y, dir.x)));
    float along = abs(dot(p, dir));
    float arm = smoothstep(tubeWidth, tubeWidth * 0.5, line);
    arm *= smoothstep(0.4, 0.0, along);
    star = max(star, arm);
}
float circle = smoothstep(tubeWidth, tubeWidth * 0.5, abs(length(p) - 0.3));
float shape = max(star, circle);
if (broken > 0.5) {
    float breakMask = step(0.7, fract(sin(p.x * 20.0 + p.y * 30.0) * 43758.5453));
    shape *= 1.0 - breakMask * 0.8;
}
col += shape * neonColor * glowIntensity * flicker;
float glow = exp(-length(p) / glowRadius) * shape;
glow += exp(-(abs(length(p) - 0.3)) / glowRadius) * 0.5;
col += glow * neonColor * glowIntensity * 0.3 * flicker;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float angle = fi * 0.785;
    float2 dir = float2(cos(angle), sin(angle));
    float armGlow = exp(-abs(dot(p, float2(-dir.y, dir.x))) / glowRadius);
    armGlow *= smoothstep(0.5, 0.0, abs(dot(p, dir)));
    col += armGlow * neonColor * glowIntensity * 0.2 * flicker;
}
return float4(col, 1.0);
"""

/// Ink Blot Art
let inkBlotArtCode = """
// @param blotCount "Liczba plam" range(1, 5) default(3)
// @param spreadAmount "Rozlewanie" range(0.1, 0.4) default(0.25)
// @param inkDensity "Gęstość tuszu" range(0.5, 1.0) default(0.8)
// @param symmetry "Symetria" range(0.0, 1.0) default(1.0)
// @param edgeBleed "Krwawienie krawędzi" range(0.0, 0.3) default(0.15)
// @toggle rorschach "Rorschach" default(true)
float2 p = uv;
float3 col = float3(0.98, 0.96, 0.93);
float3 inkColor = float3(0.1, 0.08, 0.12);
float2 sp = p;
if (rorschach > 0.5) {
    sp.x = abs(sp.x - 0.5) + 0.5;
}
for (int i = 0; i < 5; i++) {
    if (i >= int(blotCount)) break;
    float fi = float(i);
    float2 blotCenter = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.4 + 0.5,
        fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2
    );
    float blotSize = fract(sin(fi * 178.3) * 43758.5453) * spreadAmount + 0.1;
    float2 toP = sp - blotCenter;
    float dist = length(toP);
    float angle = atan2(toP.y, toP.x);
    float edgeNoise = 0.0;
    for (int j = 1; j <= 5; j++) {
        float fj = float(j);
        edgeNoise += sin(angle * fj * 3.0 + fi * 5.0) * edgeBleed / fj;
    }
    float blot = smoothstep(blotSize + edgeNoise, blotSize * 0.3 + edgeNoise * 0.5, dist);
    float densityVar = sin(sp.x * 50.0 + fi * 20.0) * sin(sp.y * 50.0 + fi * 30.0);
    densityVar = densityVar * 0.2 + 0.8;
    float3 blotColor = inkColor * (inkDensity * densityVar);
    col = mix(col, blotColor, blot * 0.8);
    float edge = smoothstep(blotSize + edgeNoise, blotSize * 0.8 + edgeNoise, dist);
    edge -= smoothstep(blotSize * 0.8 + edgeNoise, blotSize * 0.5 + edgeNoise, dist);
    col = mix(col, blotColor * 0.5, edge * 0.3);
}
if (rorschach > 0.5 && symmetry > 0.0) {
    float mirrorBlend = smoothstep(0.48, 0.5, p.x) * smoothstep(0.52, 0.5, p.x);
    col = mix(col, col * 0.95, mirrorBlend * symmetry);
}
return float4(col, 1.0);
"""

/// Oil Painting
let oilPaintingCode = """
// @param brushSize "Rozmiar pędzla" range(0.02, 0.08) default(0.04)
// @param textureDepth "Głębokość tekstury" range(0.0, 0.5) default(0.3)
// @param colorRichness "Bogactwo kolorów" range(0.5, 1.0) default(0.8)
// @param strokeDirection "Kierunek pociągnięć" range(0.0, 6.28) default(0.785)
// @param impasto "Impasto" range(0.0, 1.0) default(0.5)
// @toggle varnish "Lakier" default(true)
float2 p = uv;
float3 col = float3(0.3, 0.25, 0.2);
float2 strokeDir = float2(cos(strokeDirection), sin(strokeDirection));
float2 quantP = floor(p / brushSize) * brushSize;
float brushSeed = fract(sin(quantP.x * 127.1 + quantP.y * 311.7) * 43758.5453);
float3 baseColor = 0.5 + 0.5 * cos(brushSeed * 6.28 * colorRichness + float3(0.0, 2.0, 4.0));
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
return float4(col, 1.0);
"""

/// Kaleidoscope Dream
let kaleidoscopeDreamCode = """
// @param segments "Segmenty" range(3, 12) default(6)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 2.0) default(0.5)
// @param zoomPulse "Pulsowanie zoomu" range(0.0, 0.3) default(0.1)
// @param colorShift "Przesunięcie kolorów" range(0.0, 2.0) default(1.0)
// @param complexity "Złożoność wzoru" range(1.0, 5.0) default(3.0)
// @toggle morphing "Morfowanie" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float segmentAngle = 6.28318 / float(segments);
float ka = mod(a + 3.14159, segmentAngle);
if (mod(floor((a + 3.14159) / segmentAngle), 2.0) > 0.5) {
    ka = segmentAngle - ka;
}
ka -= segmentAngle * 0.5;
ka += iTime * rotationSpeed;
float zoom = 1.0 + sin(iTime * 2.0) * zoomPulse;
float2 kp = float2(cos(ka), sin(ka)) * r * zoom;
float3 col = float3(0.0);
float pattern = 0.0;
for (int i = 1; i <= 5; i++) {
    float fi = float(i);
    if (fi > complexity) break;
    float freq = fi * 3.0;
    float phase = iTime * (morphing > 0.5 ? fi * 0.3 : 0.0);
    pattern += sin(kp.x * freq + phase) * sin(kp.y * freq * 1.3 + phase * 0.7) / fi;
}
pattern = pattern * 0.5 + 0.5;
float3 color1 = 0.5 + 0.5 * cos(pattern * 3.0 + colorShift * iTime + float3(0.0, 2.0, 4.0));
float3 color2 = 0.5 + 0.5 * cos(r * 5.0 + colorShift * iTime + float3(4.0, 2.0, 0.0));
col = mix(color1, color2, pattern);
float radialPattern = sin(r * 20.0 - iTime * 2.0) * 0.5 + 0.5;
col = mix(col, col * 1.3, radialPattern * 0.3);
float centerGlow = exp(-r * 3.0);
col += centerGlow * float3(1.0, 0.9, 0.8) * 0.3;
return float4(col, 1.0);
"""

/// Cubist Portrait
let cubistPortraitCode = """
// @param fragmentation "Fragmentacja" range(3, 10) default(6)
// @param angleVariation "Zmienność kątów" range(0.0, 1.0) default(0.5)
// @param colorPalette "Paleta kolorów" range(0.0, 3.0) default(1.0)
// @param edgeEmphasis "Podkreślenie krawędzi" range(0.0, 0.5) default(0.2)
// @param facetDepth "Głębokość faset" range(0.0, 0.5) default(0.3)
// @toggle geometric "Geometryczny" default(true)
float2 p = uv;
float3 col = float3(0.9, 0.85, 0.8);
float cellSize = 1.0 / float(fragmentation);
float2 cellId = floor(p / cellSize);
float2 cellLocal = fract(p / cellSize);
float cellSeed = fract(sin(cellId.x * 127.1 + cellId.y * 311.7) * 43758.5453);
float angle = (cellSeed - 0.5) * angleVariation * 3.14159;
float2 rotLocal = float2(
    cellLocal.x * cos(angle) - cellLocal.y * sin(angle),
    cellLocal.x * sin(angle) + cellLocal.y * cos(angle)
);
float3 facetColor;
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
float depth = 0.0;
if (geometric > 0.5) {
    float diagonal = rotLocal.x + rotLocal.y;
    depth = step(0.5, fract(diagonal * 2.0)) * facetDepth;
}
facetColor *= 1.0 - depth;
col = facetColor;
float edge = 0.0;
edge = max(edge, smoothstep(0.05, 0.0, cellLocal.x));
edge = max(edge, smoothstep(0.05, 0.0, cellLocal.y));
edge = max(edge, smoothstep(0.95, 1.0, cellLocal.x));
edge = max(edge, smoothstep(0.95, 1.0, cellLocal.y));
col = mix(col, float3(0.1), edge * edgeEmphasis);
if (geometric > 0.5) {
    float diag1 = abs(rotLocal.x - rotLocal.y);
    float diag2 = abs(rotLocal.x + rotLocal.y - 1.0);
    float diagLine = min(smoothstep(0.02, 0.0, diag1), smoothstep(0.02, 0.0, diag2));
    col = mix(col, float3(0.2), diagLine * edgeEmphasis);
}
return float4(col, 1.0);
"""

/// Pointillism
let pointillismCode = """
// @param dotDensity "Gęstość kropek" range(20, 60) default(40)
// @param dotVariation "Zróżnicowanie" range(0.0, 0.5) default(0.2)
// @param colorMixing "Mieszanie kolorów" range(0.0, 1.0) default(0.6)
// @param brightness "Jasność" range(0.5, 1.5) default(1.0)
// @param warmth "Ciepłota" range(0.0, 1.0) default(0.5)
// @toggle impressionist "Impresjonistyczny" default(true)
float2 p = uv;
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
        float dotSize = cellSize * 0.3 * (0.8 + cellSeed * 0.4);
        float dist = length(p - dotPos);
        float dot = smoothstep(dotSize, dotSize * 0.3, dist);
        float3 dotColor;
        if (impressionist > 0.5) {
            float hue = cellSeed + (cellId.x + cellId.y) * 0.02;
            dotColor = 0.5 + 0.5 * cos(hue * 6.28 + float3(0.0, 2.0, 4.0));
            dotColor = mix(dotColor, dotColor * float3(1.1, 1.0, 0.9), warmth);
        } else {
            dotColor = float3(cellSeed, fract(cellSeed * 2.0), fract(cellSeed * 3.0));
        }
        dotColor *= brightness;
        col = mix(col, dotColor, dot * colorMixing);
    }
}
return float4(col, 1.0);
"""

/// Art Nouveau
let artNouveauCode = """
// @param curveComplexity "Złożoność krzywych" range(2.0, 6.0) default(4.0)
// @param flowSpeed "Prędkość przepływu" range(0.0, 1.0) default(0.3)
// @param lineWeight "Grubość linii" range(0.005, 0.02) default(0.01)
// @param fillOpacity "Wypełnienie" range(0.0, 0.5) default(0.3)
// @param goldAccent "Akcent złoty" range(0.0, 1.0) default(0.5)
// @toggle organic "Organiczny" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.95, 0.93, 0.88);
float3 lineColor = float3(0.15, 0.12, 0.1);
float3 goldColor = float3(0.85, 0.65, 0.2);
float3 fillColor = float3(0.4, 0.55, 0.35);
float pattern = 0.0;
float fill = 0.0;
for (int i = 1; i <= 6; i++) {
    float fi = float(i);
    if (fi > curveComplexity) break;
    float freq = fi * 2.0;
    float phase = organic > 0.5 ? iTime * flowSpeed * fi * 0.3 : 0.0;
    float wave1 = sin(p.x * freq + phase) * cos(p.y * freq * 0.7 + phase * 0.5);
    float wave2 = sin(p.y * freq * 1.2 + phase * 0.8) * cos(p.x * freq * 0.8 + phase);
    float curve = wave1 + wave2;
    float line = smoothstep(lineWeight, 0.0, abs(curve) / fi);
    pattern = max(pattern, line);
    fill += step(0.0, curve) / (curveComplexity * 2.0);
}
col = mix(col, fillColor, fill * fillOpacity);
col = mix(col, lineColor, pattern);
float2 cp = p;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float angle = fi * 1.5708;
    float2 cornerPos = float2(cos(angle), sin(angle)) * 0.6;
    float2 toCorner = cp - cornerPos;
    float spiralAngle = atan2(toCorner.y, toCorner.x);
    float spiralDist = length(toCorner);
    float spiral = sin(spiralAngle * 3.0 + spiralDist * 10.0 + iTime * flowSpeed);
    spiral = smoothstep(lineWeight * 2.0, 0.0, abs(spiral) * spiralDist);
    spiral *= smoothstep(0.4, 0.1, spiralDist);
    if (goldAccent > 0.0) {
        col = mix(col, goldColor, spiral * goldAccent);
    } else {
        col = mix(col, lineColor, spiral);
    }
}
return float4(col, 1.0);
"""

/// Graffiti Tag
let graffitiTagCode = """
// @param sprayDensity "Gęstość sprayu" range(0.3, 1.0) default(0.7)
// @param dripAmount "Ściekanie" range(0.0, 0.5) default(0.3)
// @param colorVibrancy "Żywość kolorów" range(0.5, 1.5) default(1.2)
// @param outlineThickness "Grubość obrysu" range(0.01, 0.05) default(0.02)
// @param tagScale "Skala tagu" range(0.5, 1.5) default(1.0)
// @toggle chrome "Chromowany" default(false)
float2 p = (uv - 0.5) * 2.0 / tagScale + 0.5;
float3 col = float3(0.7, 0.65, 0.6);
float brickX = floor(p.x * 8.0);
float brickY = floor(p.y * 16.0);
float brickOffset = mod(brickY, 2.0) * 0.5;
float brick = step(0.05, fract((p.x + brickOffset * 0.125) * 8.0));
brick *= step(0.1, fract(p.y * 16.0));
col = mix(col * 0.9, col, brick);
float tag = 0.0;
float2 tp = p - float2(0.5, 0.5);
float curve1 = sin(tp.x * 10.0) * 0.15;
tag = max(tag, smoothstep(0.08, 0.05, abs(tp.y - curve1) - abs(tp.x) * 0.1));
tag *= step(-0.3, tp.x) * step(tp.x, 0.3);
float curve2 = cos(tp.x * 8.0 + 1.0) * 0.1;
float line2 = smoothstep(0.06, 0.03, abs(tp.y - curve2 - 0.1));
line2 *= step(-0.2, tp.x) * step(tp.x, 0.35);
tag = max(tag, line2);
float3 tagColor;
if (chrome > 0.5) {
    float chrome = tp.y * 5.0 + 0.5;
    tagColor = mix(float3(0.3, 0.3, 0.35), float3(0.9, 0.9, 0.95), chrome);
} else {
    tagColor = float3(0.9, 0.2, 0.3) * colorVibrancy;
}
if (sprayDensity < 1.0) {
    float spray = fract(sin(p.x * 500.0 + p.y * 700.0) * 43758.5453);
    tag *= step(1.0 - sprayDensity, spray);
    float overspray = step(0.95, spray) * step(0.03, abs(tp.y - curve1) - abs(tp.x) * 0.1);
    overspray *= step(abs(tp.y - curve1), 0.15);
    tag = max(tag, overspray * 0.3);
}
float outline = smoothstep(0.1, 0.08, abs(tp.y - curve1) - abs(tp.x) * 0.1);
outline -= smoothstep(0.08 - outlineThickness, 0.05, abs(tp.y - curve1) - abs(tp.x) * 0.1);
outline *= step(-0.32, tp.x) * step(tp.x, 0.32);
col = mix(col, float3(0.1), outline);
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
return float4(col, 1.0);
"""

/// Zen Garden
let zenGardenCode = """
// @param rakeLineCount "Linie grabienia" range(10, 30) default(20)
// @param stoneCount "Liczba kamieni" range(0, 5) default(3)
// @param waveAmplitude "Amplituda fal" range(0.0, 0.1) default(0.03)
// @param sandColor "Kolor piasku" range(0.0, 1.0) default(0.5)
// @param peacefulness "Spokój" range(0.0, 1.0) default(0.7)
// @toggle ripples "Kręgi" default(true)
float2 p = uv;
float3 sandLight = mix(float3(0.9, 0.85, 0.75), float3(0.85, 0.8, 0.7), sandColor);
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
            float ripple = smoothstep(lineSpacing * 0.3, 0.0, abs(rippleDist - rippleR));
            ripple *= smoothstep(rippleR + lineSpacing * 3.0, rippleR, rippleDist);
            col = mix(col, sandDark, ripple * 0.5);
        }
    }
}
float rakeY = p.y;
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
float rake = smoothstep(0.3, 0.5, rakeLine) - smoothstep(0.5, 0.7, rakeLine);
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
    float stone = smoothstep(stoneSize, stoneSize * 0.7, stoneDist);
    float3 stoneColor = float3(0.35, 0.33, 0.3);
    float stoneShade = 1.0 - (p.x - stonePos.x + p.y - stonePos.y) * 2.0;
    stoneColor *= 0.8 + stoneShade * 0.4;
    col = mix(col, stoneColor, stone);
}
if (peacefulness > 0.0) {
    float peace = sin(p.x * 3.0 + iTime * 0.1 * (1.0 - peacefulness)) * 0.02;
    peace += sin(p.y * 2.0 + iTime * 0.05 * (1.0 - peacefulness)) * 0.02;
    col += peace * peacefulness;
}
return float4(col, 1.0);
"""

/// Mosaic
let mosaicCode = """
// @param tileSize "Rozmiar kafelków" range(0.02, 0.1) default(0.05)
// @param groutWidth "Szerokość fugi" range(0.0, 0.3) default(0.1)
// @param colorVariation "Zmienność kolorów" range(0.0, 0.5) default(0.2)
// @param irregularity "Nieregularność" range(0.0, 0.3) default(0.1)
// @param shininess "Połysk" range(0.0, 0.5) default(0.2)
// @toggle roman "Rzymski" default(false)
float2 p = uv;
float3 col = float3(0.3, 0.28, 0.25);
float2 tileId = floor(p / tileSize);
float tileSeed = fract(sin(tileId.x * 127.1 + tileId.y * 311.7) * 43758.5453);
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
if (roman > 0.5) {
    if (tileSeed < 0.3) tileColor = float3(0.85, 0.8, 0.7);
    else if (tileSeed < 0.5) tileColor = float3(0.7, 0.5, 0.4);
    else if (tileSeed < 0.7) tileColor = float3(0.3, 0.35, 0.4);
    else if (tileSeed < 0.85) tileColor = float3(0.8, 0.75, 0.6);
    else tileColor = float3(0.5, 0.45, 0.4);
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
return float4(col, 1.0);
"""

