//
//  ShaderCodes_Part11.swift
//  LM_GLSL
//
//  Shader codes - Part 11: Hypnotic & Optical Illusions (20 shaders)
//

import Foundation

// MARK: - Hypnotic & Optical Illusions

/// Rotating Illusion
let rotatingIllusionCode = """
// @param rotationSpeed "Prędkość rotacji" range(0.1, 3.0) default(1.0)
// @param ringCount "Liczba pierścieni" range(3, 15) default(8)
// @param colorShift "Przesunięcie koloru" range(0.0, 6.28) default(0.0)
// @param thickness "Grubość" range(0.02, 0.15) default(0.05)
// @param waveAmount "Falowanie" range(0.0, 0.3) default(0.1)
// @toggle alternateDirection "Naprzemienne kierunki" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
for (int i = 0; i < 15; i++) {
    if (i >= int(ringCount)) break;
    float fi = float(i);
    float ringR = 0.1 + fi * 0.08;
    float dir = (alternateDirection > 0.5 && int(fi) % 2 == 1) ? -1.0 : 1.0;
    float wave = sin(a * 6.0 + iTime * 2.0) * waveAmount;
    float ringAngle = a + iTime * rotationSpeed * dir + fi * 0.5;
    float pattern = sin(ringAngle * 8.0) * 0.5 + 0.5;
    float ring = smoothstep(thickness, 0.0, abs(r - ringR - wave));
    float3 ringColor = 0.5 + 0.5 * cos(fi * 0.8 + colorShift + pattern * 2.0 + float3(0.0, 2.0, 4.0));
    col += ring * ringColor * pattern;
}
return float4(col, 1.0);
"""

/// Breathing Mandala
let breathingMandalaCode = """
// @param petalCount "Liczba płatków" range(4, 16) default(8)
// @param layers "Warstwy" range(2, 8) default(5)
// @param breathSpeed "Prędkość oddychania" range(0.2, 2.0) default(0.5)
// @param colorCycle "Cykl kolorów" range(0.0, 2.0) default(1.0)
// @param complexity "Złożoność" range(1.0, 5.0) default(2.0)
// @toggle innerGlow "Wewnętrzna poświata" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float breath = sin(iTime * breathSpeed) * 0.2 + 1.0;
float3 col = float3(0.02, 0.02, 0.05);
for (int layer = 0; layer < 8; layer++) {
    if (layer >= int(layers)) break;
    float fl = float(layer);
    float layerR = (0.15 + fl * 0.12) * breath;
    float layerPetals = float(petalCount) + fl * 2.0;
    float petal = cos(a * layerPetals + iTime * (fl * 0.2 + 0.5)) * 0.5 + 0.5;
    petal = pow(petal, complexity);
    float mask = smoothstep(layerR + 0.05, layerR, r) * smoothstep(layerR - 0.08, layerR - 0.03, r);
    float3 layerColor = 0.5 + 0.5 * cos(fl * colorCycle + iTime * 0.3 + float3(0.0, 2.0, 4.0));
    col += mask * petal * layerColor * 0.7;
}
if (innerGlow > 0.5) {
    float glow = exp(-r * 3.0 / breath);
    col += glow * float3(1.0, 0.8, 0.5) * 0.3;
}
return float4(col, 1.0);
"""

/// Zoetrope Animation
let zoetropeCode = """
// @param frameCount "Liczba klatek" range(4, 16) default(8)
// @param spinSpeed "Prędkość obrotu" range(0.5, 5.0) default(2.0)
// @param slitWidth "Szerokość szczeliny" range(0.02, 0.1) default(0.05)
// @param figureSize "Rozmiar figury" range(0.1, 0.3) default(0.15)
// @param animationPhase "Faza animacji" range(0.0, 1.0) default(0.0)
// @toggle showSlits "Pokaż szczeliny" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.1, 0.08, 0.06);
float spinAngle = iTime * spinSpeed;
float slitAngle = 6.28318 / float(frameCount);
float currentSlit = floor((a + 3.14159 + spinAngle) / slitAngle);
float slitPos = fmod(a + 3.14159 + spinAngle, slitAngle) - slitAngle * 0.5;
float slit = smoothstep(slitWidth, slitWidth * 0.5, abs(slitPos));
if (showSlits > 0.5) {
    float slitMark = smoothstep(0.005, 0.0, abs(slitPos));
    col += slitMark * float3(0.2) * step(0.7, r) * step(r, 0.9);
}
float framePhase = currentSlit / float(frameCount) + animationPhase;
float figureY = sin(framePhase * 6.28318) * 0.1;
float figureX = cos(framePhase * 6.28318 * 2.0) * 0.05;
float2 figureCenter = float2(0.0, 0.5 + figureY);
float2 rotP = float2(
    p.x * cos(-spinAngle) - p.y * sin(-spinAngle),
    p.x * sin(-spinAngle) + p.y * cos(-spinAngle)
);
float figure = smoothstep(figureSize, figureSize - 0.02, length(rotP - figureCenter - float2(figureX, 0.0)));
float3 figureColor = float3(0.9, 0.7, 0.3);
col = mix(col, figureColor, figure * slit * step(0.3, r) * step(r, 0.85));
float rim = smoothstep(0.02, 0.0, abs(r - 0.9));
col += rim * float3(0.4, 0.3, 0.2);
return float4(col, 1.0);
"""

/// Op Art Waves
let opArtWavesCode = """
// @param waveCount "Liczba fal" range(5, 30) default(15)
// @param waveSpeed "Prędkość fal" range(0.0, 3.0) default(1.0)
// @param amplitude "Amplituda" range(0.0, 0.3) default(0.1)
// @param perspective "Perspektywa" range(0.0, 1.0) default(0.5)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle colorMode "Tryb kolorowy" default(false)
float2 p = uv;
p.y = pow(p.y, 1.0 + perspective);
float wave = sin(p.y * float(waveCount) * 6.28 - iTime * waveSpeed);
wave *= amplitude * (1.0 - p.y * perspective);
float stripe = sin((p.x + wave) * float(waveCount) * 3.14159);
stripe = stripe * 0.5 + 0.5;
stripe = pow(stripe, 1.0 / contrast);
float3 col;
if (colorMode > 0.5) {
    float3 color1 = 0.5 + 0.5 * cos(iTime + float3(0.0, 2.0, 4.0));
    float3 color2 = 0.5 + 0.5 * cos(iTime + 3.14 + float3(0.0, 2.0, 4.0));
    col = mix(color1, color2, stripe);
} else {
    col = float3(stripe);
}
return float4(col, 1.0);
"""

/// Spirograph Pattern
let spirographCode = """
// @param outerRadius "Promień zewnętrzny" range(0.5, 1.0) default(0.8)
// @param innerRadius "Promień wewnętrzny" range(0.1, 0.5) default(0.3)
// @param penOffset "Odsunięcie pióra" range(0.1, 0.5) default(0.25)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 2.0) default(0.5)
// @param lineThickness "Grubość linii" range(0.005, 0.03) default(0.01)
// @toggle multiColor "Wielokolorowy" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float R = outerRadius;
float r = innerRadius;
float d = penOffset;
float ratio = R / r;
float totalAngle = iTime * rotationSpeed;
float minDist = 10.0;
float closestT = 0.0;
for (int i = 0; i < 500; i++) {
    float t = float(i) * 0.05;
    if (t > totalAngle) break;
    float x = (R - r) * cos(t) + d * cos((R - r) / r * t);
    float y = (R - r) * sin(t) - d * sin((R - r) / r * t);
    float dist = length(p - float2(x, y));
    if (dist < minDist) {
        minDist = dist;
        closestT = t;
    }
}
float line = smoothstep(lineThickness, 0.0, minDist);
float3 lineColor;
if (multiColor > 0.5) {
    lineColor = 0.5 + 0.5 * cos(closestT * 0.5 + float3(0.0, 2.0, 4.0));
} else {
    lineColor = float3(0.0, 0.8, 1.0);
}
col += line * lineColor;
float glow = exp(-minDist * 20.0) * 0.3;
col += glow * lineColor;
return float4(col, 1.0);
"""

/// Moiré Circles
let moireCirclesCode = """
// @param circleSpacing "Odstęp kół" range(0.02, 0.1) default(0.04)
// @param offsetSpeed "Prędkość przesunięcia" range(0.0, 2.0) default(0.5)
// @param offsetAmount "Wielkość przesunięcia" range(0.0, 0.3) default(0.15)
// @param lineWidth "Szerokość linii" range(0.3, 0.7) default(0.5)
// @param centerCount "Liczba centrów" range(1, 4) default(2)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float offset = animate > 0.5 ? sin(iTime * offsetSpeed) * offsetAmount : offsetAmount;
float pattern = 0.0;
for (int c = 0; c < 4; c++) {
    if (c >= int(centerCount)) break;
    float fc = float(c);
    float2 center;
    if (c == 0) center = float2(-offset, 0.0);
    else if (c == 1) center = float2(offset, 0.0);
    else if (c == 2) center = float2(0.0, -offset);
    else center = float2(0.0, offset);
    float r = length(p - center);
    float circles = sin(r / circleSpacing * 6.28318);
    circles = step(lineWidth - 0.5, circles * 0.5 + 0.5);
    pattern += circles;
}
pattern = fract(pattern * 0.5);
float3 col = float3(pattern);
return float4(col, 1.0);
"""

/// Infinity Mirror
let infinityMirrorCode = """
// @param tunnelDepth "Głębokość tunelu" range(3, 15) default(8)
// @param shrinkRate "Współczynnik zmniejszania" range(0.6, 0.9) default(0.75)
// @param rotationPerLevel "Rotacja na poziom" range(0.0, 0.5) default(0.1)
// @param colorFade "Zanikanie koloru" range(0.5, 1.0) default(0.85)
// @param pulseSpeed "Prędkość pulsu" range(0.0, 3.0) default(1.0)
// @toggle neonFrame "Neonowa ramka" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float scale = 1.0;
float rotation = 0.0;
for (int i = 0; i < 15; i++) {
    if (i >= int(tunnelDepth)) break;
    float fi = float(i);
    float c = cos(rotation);
    float s = sin(rotation);
    float2 rp = float2(p.x * c - p.y * s, p.x * s + p.y * c) / scale;
    float frameSize = 0.8;
    float frame = max(abs(rp.x), abs(rp.y));
    float frameMask = smoothstep(frameSize + 0.02, frameSize, frame) - smoothstep(frameSize - 0.02, frameSize - 0.04, frame);
    float pulse = 0.7 + 0.3 * sin(iTime * pulseSpeed - fi * 0.5);
    float fade = pow(colorFade, fi);
    float3 frameColor;
    if (neonFrame > 0.5) {
        frameColor = 0.5 + 0.5 * cos(fi * 0.8 + iTime + float3(0.0, 2.0, 4.0));
    } else {
        frameColor = float3(0.8, 0.7, 0.6);
    }
    col += frameMask * frameColor * fade * pulse;
    scale *= shrinkRate;
    rotation += rotationPerLevel;
}
return float4(col, 1.0);
"""

/// Checkerboard Warp
let checkerboardWarpCode = """
// @param checkSize "Rozmiar pól" range(2.0, 20.0) default(8.0)
// @param warpStrength "Siła zniekształcenia" range(0.0, 1.0) default(0.3)
// @param warpSpeed "Prędkość zniekształcenia" range(0.0, 3.0) default(1.0)
// @param warpFrequency "Częstotliwość" range(1.0, 5.0) default(2.0)
// @param edgeSoftness "Miękkość krawędzi" range(0.0, 0.5) default(0.1)
// @toggle colorful "Kolorowy" default(false)
float2 p = uv * 2.0 - 1.0;
float2 warp = float2(
    sin(p.y * warpFrequency * 3.14 + iTime * warpSpeed),
    sin(p.x * warpFrequency * 3.14 + iTime * warpSpeed * 1.3)
) * warpStrength;
float2 wp = p + warp;
float2 checkP = floor(wp * checkSize);
float checker = fmod(checkP.x + checkP.y, 2.0);
float2 cellP = fract(wp * checkSize);
float edge = min(min(cellP.x, 1.0 - cellP.x), min(cellP.y, 1.0 - cellP.y));
float softChecker = mix(checker, 1.0 - checker, smoothstep(edgeSoftness, 0.0, edge));
float3 col;
if (colorful > 0.5) {
    float3 color1 = 0.5 + 0.5 * cos(iTime + float3(0.0, 2.0, 4.0));
    float3 color2 = 0.5 + 0.5 * cos(iTime + 3.14 + float3(0.0, 2.0, 4.0));
    col = mix(color1, color2, softChecker);
} else {
    col = float3(softChecker);
}
return float4(col, 1.0);
"""

/// Penrose Impossible
let penroseImpossibleCode = """
// @param triSize "Rozmiar trójkąta" range(0.3, 0.8) default(0.5)
// @param barWidth "Szerokość belek" range(0.05, 0.15) default(0.08)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 2.0) default(0.3)
// @param shadingDepth "Głębokość cieniowania" range(0.0, 0.5) default(0.3)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.3)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float angle = animate > 0.5 ? iTime * rotationSpeed : 0.0;
float c = cos(angle);
float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float3 col = float3(0.1, 0.1, 0.12);
float2 v1 = float2(0.0, triSize);
float2 v2 = float2(-triSize * 0.866, -triSize * 0.5);
float2 v3 = float2(triSize * 0.866, -triSize * 0.5);
float bar1 = 10.0, bar2 = 10.0, bar3 = 10.0;
float2 d1 = v2 - v1;
float t1 = clamp(dot(p - v1, d1) / dot(d1, d1), 0.0, 1.0);
bar1 = length(p - v1 - d1 * t1);
float2 d2 = v3 - v2;
float t2 = clamp(dot(p - v2, d2) / dot(d2, d2), 0.0, 1.0);
bar2 = length(p - v2 - d2 * t2);
float2 d3 = v1 - v3;
float t3 = clamp(dot(p - v3, d3) / dot(d3, d3), 0.0, 1.0);
bar3 = length(p - v3 - d3 * t3);
float3 barColor1 = float3(0.9, 0.3, 0.3) * (1.0 - t1 * shadingDepth);
float3 barColor2 = float3(0.3, 0.9, 0.3) * (1.0 - t2 * shadingDepth);
float3 barColor3 = float3(0.3, 0.3, 0.9) * (1.0 - t3 * shadingDepth);
float mask1 = smoothstep(barWidth, barWidth - 0.02, bar1);
float mask2 = smoothstep(barWidth, barWidth - 0.02, bar2);
float mask3 = smoothstep(barWidth, barWidth - 0.02, bar3);
col = mix(col, barColor1, mask1);
col = mix(col, barColor2, mask2 * step(t2, 0.7));
col = mix(col, barColor3, mask3 * step(0.3, t3));
col = mix(col, barColor2, mask2 * step(0.7, t2));
if (glowAmount > 0.0) {
    float glow = exp(-min(min(bar1, bar2), bar3) * 10.0) * glowAmount;
    col += glow * float3(0.5, 0.5, 0.6);
}
return float4(col, 1.0);
"""

/// Escher Stairs
let escherStairsCode = """
// @param stairCount "Liczba schodów" range(3, 12) default(6)
// @param perspectiveAngle "Kąt perspektywy" range(0.0, 1.0) default(0.5)
// @param loopSpeed "Prędkość pętli" range(0.0, 2.0) default(0.5)
// @param shadowDepth "Głębokość cienia" range(0.0, 0.5) default(0.3)
// @param colorVariation "Wariacja kolorów" range(0.0, 1.0) default(0.3)
// @toggle infinite "Nieskończone" default(true)
float2 p = uv;
float time = iTime * loopSpeed;
float3 col = float3(0.9, 0.88, 0.85);
float stairHeight = 1.0 / float(stairCount);
float stairPhase = infinite > 0.5 ? fract(p.y + time) : p.y;
float stairIndex = floor(stairPhase / stairHeight);
float localY = fract(stairPhase / stairHeight);
float stairX = fract(stairIndex * 0.3 + perspectiveAngle * 0.5);
float tread = step(stairX, p.x) * step(p.x, stairX + 0.4);
float riser = step(0.0, localY) * step(localY, 0.3);
float3 treadColor = float3(0.7, 0.68, 0.65) * (1.0 - stairIndex * colorVariation * 0.1);
float3 riserColor = treadColor * (1.0 - shadowDepth);
col = mix(col, treadColor, tread * (1.0 - riser));
col = mix(col, riserColor, tread * riser);
float shadow = smoothstep(stairX + 0.4, stairX + 0.45, p.x) * tread;
col *= (1.0 - shadow * shadowDepth);
return float4(col, 1.0);
"""

/// Pulsing Hypnosis
let pulsingHypnosisCode = """
// @param ringCount "Liczba pierścieni" range(5, 30) default(15)
// @param pulseSpeed "Prędkość pulsu" range(0.5, 4.0) default(2.0)
// @param wavePhase "Faza fali" range(0.0, 6.28) default(0.0)
// @param colorIntensity "Intensywność koloru" range(0.0, 1.0) default(0.5)
// @param spiralTwist "Skręt spiralny" range(0.0, 3.0) default(1.0)
// @toggle invert "Inwersja" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = a * spiralTwist / 6.28;
float rings = sin((r + spiral) * float(ringCount) * 3.14159 - iTime * pulseSpeed + wavePhase);
rings = rings * 0.5 + 0.5;
if (invert > 0.5) {
    rings = 1.0 - rings;
}
float3 col;
if (colorIntensity > 0.0) {
    float3 color1 = float3(0.1, 0.0, 0.2);
    float3 color2 = 0.5 + 0.5 * cos(r * 3.0 + iTime + float3(0.0, 2.0, 4.0));
    col = mix(color1, color2 * colorIntensity + float3(1.0) * (1.0 - colorIntensity), rings);
} else {
    col = float3(rings);
}
return float4(col, 1.0);
"""

/// Impossible Cube
let impossibleCubeCode = """
// @param cubeSize "Rozmiar sześcianu" range(0.2, 0.5) default(0.35)
// @param lineWidth "Szerokość linii" range(0.01, 0.05) default(0.02)
// @param rotationX "Rotacja X" range(0.0, 6.28) default(0.5)
// @param rotationY "Rotacja Y" range(0.0, 6.28) default(0.3)
// @param animationSpeed "Prędkość animacji" range(0.0, 2.0) default(0.5)
// @toggle autoRotate "Auto-rotacja" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.95, 0.95, 0.98);
float rx = rotationX + (autoRotate > 0.5 ? iTime * animationSpeed : 0.0);
float ry = rotationY + (autoRotate > 0.5 ? iTime * animationSpeed * 0.7 : 0.0);
float3 vertices[8];
for (int i = 0; i < 8; i++) {
    float x = (i & 1) != 0 ? cubeSize : -cubeSize;
    float y = (i & 2) != 0 ? cubeSize : -cubeSize;
    float z = (i & 4) != 0 ? cubeSize : -cubeSize;
    float cy = cos(rx); float sy = sin(rx);
    float temp = y * cy - z * sy;
    z = y * sy + z * cy;
    y = temp;
    float cx = cos(ry); float sx = sin(ry);
    temp = x * cx - z * sx;
    z = x * sx + z * cx;
    x = temp;
    vertices[i] = float3(x, y, z);
}
int edges[24] = int[24](0,1, 1,3, 3,2, 2,0, 4,5, 5,7, 7,6, 6,4, 0,4, 1,5, 2,6, 3,7);
for (int e = 0; e < 12; e++) {
    int i1 = edges[e * 2];
    int i2 = edges[e * 2 + 1];
    float2 v1 = vertices[i1].xy;
    float2 v2 = vertices[i2].xy;
    float2 d = v2 - v1;
    float len = length(d);
    d = d / len;
    float2 toP = p - v1;
    float t = clamp(dot(toP, d), 0.0, len);
    float dist = length(toP - d * t);
    float line = smoothstep(lineWidth, lineWidth * 0.5, dist);
    float depth = mix(vertices[i1].z, vertices[i2].z, t / len);
    float3 lineColor = float3(0.2, 0.2, 0.3) * (1.0 + depth);
    col = mix(col, lineColor, line);
}
return float4(col, 1.0);
"""

/// Tunnel Zoom
let tunnelZoomCode = """
// @param zoomSpeed "Prędkość zoomu" range(0.5, 5.0) default(2.0)
// @param tunnelSegments "Segmenty tunelu" range(4, 16) default(8)
// @param twistAmount "Skręt" range(0.0, 2.0) default(0.5)
// @param colorSpeed "Prędkość kolorów" range(0.0, 3.0) default(1.0)
// @param brightness "Jasność" range(0.5, 2.0) default(1.0)
// @toggle psychedelic "Psychodeliczny" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float zoom = fract(log(r + 0.001) * 0.5 - iTime * zoomSpeed * 0.1);
float twist = a + zoom * twistAmount * 6.28;
float segment = floor(twist / (6.28 / float(tunnelSegments)));
float segmentLocal = fract(twist / (6.28 / float(tunnelSegments)));
float pattern = step(0.5, segmentLocal);
float3 col;
if (psychedelic > 0.5) {
    col = 0.5 + 0.5 * cos(zoom * 10.0 + segment + iTime * colorSpeed + float3(0.0, 2.0, 4.0));
    col *= pattern * 0.5 + 0.5;
} else {
    float bw = mix(0.2, 0.9, pattern);
    bw *= (1.0 - zoom * 0.5);
    col = float3(bw);
}
col *= brightness;
col *= smoothstep(0.0, 0.1, r);
return float4(col, 1.0);
"""

/// Necker Cube
let neckerCubeCode = """
// @param cubeSize "Rozmiar sześcianu" range(0.2, 0.5) default(0.3)
// @param flipSpeed "Prędkość przeskoku" range(0.1, 2.0) default(0.5)
// @param lineThickness "Grubość linii" range(0.005, 0.02) default(0.008)
// @param perspective "Perspektywa" range(0.0, 0.5) default(0.2)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.3)
// @toggle showVertices "Pokaż wierzchołki" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.95, 0.95, 0.98);
float flip = sin(iTime * flipSpeed) * 0.5 + 0.5;
float frontZ = mix(-1.0, 1.0, flip);
float s = cubeSize;
float pers = perspective;
float2 frontCorners[4];
float2 backCorners[4];
for (int i = 0; i < 4; i++) {
    float x = (i == 1 || i == 2) ? s : -s;
    float y = (i >= 2) ? s : -s;
    float frontScale = 1.0 + frontZ * pers;
    float backScale = 1.0 - frontZ * pers;
    frontCorners[i] = float2(x, y) * frontScale;
    backCorners[i] = float2(x, y) * backScale;
}
for (int i = 0; i < 4; i++) {
    int next = (i + 1) % 4;
    float2 v1 = frontCorners[i];
    float2 v2 = frontCorners[next];
    float2 d = v2 - v1;
    float t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    float dist = length(p - v1 - d * t);
    col = mix(col, float3(0.1, 0.1, 0.2), smoothstep(lineThickness, 0.0, dist));
    v1 = backCorners[i];
    v2 = backCorners[next];
    d = v2 - v1;
    t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    dist = length(p - v1 - d * t);
    col = mix(col, float3(0.4, 0.4, 0.5), smoothstep(lineThickness, 0.0, dist));
    v1 = frontCorners[i];
    v2 = backCorners[i];
    d = v2 - v1;
    t = clamp(dot(p - v1, d) / dot(d, d), 0.0, 1.0);
    dist = length(p - v1 - d * t);
    col = mix(col, float3(0.2, 0.2, 0.3), smoothstep(lineThickness, 0.0, dist));
}
if (showVertices > 0.5) {
    for (int i = 0; i < 4; i++) {
        float d1 = length(p - frontCorners[i]);
        float d2 = length(p - backCorners[i]);
        col = mix(col, float3(0.9, 0.3, 0.3), smoothstep(0.02, 0.01, d1));
        col = mix(col, float3(0.3, 0.3, 0.9), smoothstep(0.02, 0.01, d2));
    }
}
return float4(col, 1.0);
"""

/// Ames Room
let amesRoomCode = """
// @param distortion "Zniekształcenie" range(0.0, 1.0) default(0.5)
// @param floorTiles "Kafelki podłogi" range(3, 15) default(8)
// @param wallPattern "Wzór ścian" range(1.0, 5.0) default(2.0)
// @param figureSize "Rozmiar postaci" range(0.05, 0.2) default(0.1)
// @param animationSpeed "Prędkość animacji" range(0.0, 2.0) default(0.5)
// @toggle showFigures "Pokaż postacie" default(true)
float2 p = uv;
float dist = mix(1.0, 0.5 + p.x * 0.5, distortion);
float2 dp = float2(p.x, (p.y - 0.5) * dist + 0.5);
float3 col = float3(0.9, 0.88, 0.85);
float floorY = 0.3;
if (dp.y < floorY) {
    float2 floorP = float2(dp.x, (floorY - dp.y) * 3.0 / dist);
    float2 tile = floor(floorP * float(floorTiles));
    float checker = fmod(tile.x + tile.y, 2.0);
    col = mix(float3(0.3, 0.25, 0.2), float3(0.8, 0.75, 0.7), checker);
}
if (dp.y >= floorY) {
    float wallX = dp.x * wallPattern;
    float wallY = (dp.y - floorY) * wallPattern / dist;
    float pattern = sin(wallX * 6.28) * sin(wallY * 6.28) * 0.1;
    col = float3(0.85, 0.82, 0.75) + pattern;
}
if (showFigures > 0.5) {
    float figX = fract(iTime * animationSpeed * 0.2);
    float figScale = mix(1.0, 0.4, figX * distortion);
    float2 figPos = float2(figX, floorY);
    float2 toFig = p - figPos;
    float figD = length(toFig * float2(1.0, 2.0)) / (figureSize * figScale);
    float figure = smoothstep(1.0, 0.8, figD);
    col = mix(col, float3(0.2, 0.3, 0.5), figure);
}
return float4(col, 1.0);
"""

/// Rubin Vase
let rubinVaseCode = """
// @param vaseWidth "Szerokość wazy" range(0.1, 0.4) default(0.25)
// @param neckWidth "Szerokość szyjki" range(0.05, 0.2) default(0.1)
// @param transitionSpeed "Prędkość przejścia" range(0.1, 2.0) default(0.5)
// @param edgeSoftness "Miękkość krawędzi" range(0.0, 0.1) default(0.02)
// @param colorContrast "Kontrast kolorów" range(0.5, 1.0) default(0.9)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float profile = vaseWidth;
float y = p.y;
if (y > 0.3) {
    profile = mix(vaseWidth, neckWidth, (y - 0.3) / 0.4);
} else if (y < -0.3) {
    profile = mix(vaseWidth, vaseWidth * 1.2, (-0.3 - y) / 0.3);
}
profile += sin(y * 5.0) * 0.02;
float vase = smoothstep(profile + edgeSoftness, profile - edgeSoftness, abs(p.x));
float transition = animate > 0.5 ? sin(iTime * transitionSpeed) * 0.5 + 0.5 : 0.5;
float3 vaseColor = float3(0.1, 0.1, 0.15) * colorContrast;
float3 faceColor = float3(0.95, 0.9, 0.85) * colorContrast;
float3 col = mix(faceColor, vaseColor, vase);
float leftEye = smoothstep(0.03, 0.02, length(p - float2(-0.5, 0.1)));
float rightEye = smoothstep(0.03, 0.02, length(p - float2(0.5, 0.1)));
float leftNose = smoothstep(0.02, 0.01, abs(p.x + 0.35 + p.y * 0.1)) * step(-0.1, p.y) * step(p.y, 0.1);
float rightNose = smoothstep(0.02, 0.01, abs(p.x - 0.35 - p.y * 0.1)) * step(-0.1, p.y) * step(p.y, 0.1);
float faceDetail = max(max(leftEye, rightEye), max(leftNose, rightNose));
faceDetail *= (1.0 - vase);
col = mix(col, vaseColor, faceDetail * transition);
return float4(col, 1.0);
"""

/// Spinning Discs
let spinningDiscsCode = """
// @param discCount "Liczba dysków" range(2, 8) default(4)
// @param rotationSpeed "Prędkość rotacji" range(0.5, 5.0) default(2.0)
// @param discSize "Rozmiar dysków" range(0.1, 0.3) default(0.2)
// @param patternDensity "Gęstość wzoru" range(4, 16) default(8)
// @param colorCycle "Cykl kolorów" range(0.0, 2.0) default(1.0)
// @toggle alternateDirection "Naprzemienne kierunki" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.9, 0.9, 0.92);
for (int i = 0; i < 8; i++) {
    if (i >= int(discCount)) break;
    float fi = float(i);
    float angle = fi * 6.28318 / float(discCount);
    float2 center = float2(cos(angle), sin(angle)) * 0.4;
    float2 toDisc = p - center;
    float r = length(toDisc);
    float a = atan2(toDisc.y, toDisc.x);
    float dir = (alternateDirection > 0.5 && int(fi) % 2 == 1) ? -1.0 : 1.0;
    a += iTime * rotationSpeed * dir;
    float pattern = sin(a * float(patternDensity)) * 0.5 + 0.5;
    float disc = smoothstep(discSize, discSize - 0.02, r);
    float3 discColor = 0.5 + 0.5 * cos(fi * colorCycle + float3(0.0, 2.0, 4.0));
    float3 patternColor = mix(float3(0.1), discColor, pattern);
    col = mix(col, patternColor, disc);
}
return float4(col, 1.0);
"""

/// Fraser Spiral
let fraserSpiralCode = """
// @param spiralTurns "Zwoje spirali" range(2.0, 10.0) default(5.0)
// @param tileCount "Liczba kafelków" range(8, 32) default(16)
// @param tiltAmount "Nachylenie" range(0.0, 0.5) default(0.2)
// @param animationSpeed "Prędkość animacji" range(0.0, 2.0) default(0.5)
// @param contrast "Kontrast" range(0.5, 1.0) default(0.8)
// @toggle showSpiral "Pokaż spiralę" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = r * spiralTurns - a / 6.28318 + iTime * animationSpeed;
float ring = floor(spiral);
float ringLocal = fract(spiral);
float tileAngle = a + ring * tiltAmount;
float tile = floor(tileAngle / (6.28318 / float(tileCount)));
float tileLocal = fract(tileAngle / (6.28318 / float(tileCount)));
float checker = fmod(tile + ring, 2.0);
float pattern = mix(0.1, 0.9, checker) * contrast + (1.0 - contrast) * 0.5;
float3 col = float3(pattern);
if (showSpiral > 0.5) {
    float spiralLine = smoothstep(0.02, 0.01, abs(ringLocal - 0.5));
    col = mix(col, float3(1.0, 0.0, 0.0), spiralLine * 0.5);
}
col *= smoothstep(1.0, 0.9, r);
return float4(col, 1.0);
"""

/// Droste Effect
let drosteEffectCode = """
// @param zoomFactor "Współczynnik zoomu" range(1.5, 4.0) default(2.5)
// @param spiralAmount "Ilość spirali" range(0.0, 2.0) default(0.5)
// @param iterations "Iteracje" range(1, 5) default(3)
// @param frameWidth "Szerokość ramki" range(0.02, 0.1) default(0.05)
// @param colorTint "Odcień koloru" range(0.0, 1.0) default(0.2)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float logR = log(r);
float spiral = spiralAmount * a / 6.28318;
float zoom = animate > 0.5 ? fract(logR / log(zoomFactor) + spiral - iTime * 0.2) : fract(logR / log(zoomFactor) + spiral);
float3 col = float3(0.9, 0.88, 0.85);
for (int i = 0; i < 5; i++) {
    if (i >= int(iterations)) break;
    float fi = float(i);
    float scale = pow(zoomFactor, zoom + fi);
    float2 sp = p / scale;
    float frame = max(abs(sp.x), abs(sp.y));
    float frameMask = smoothstep(0.8 + frameWidth, 0.8, frame) - smoothstep(0.8 - frameWidth, 0.8 - frameWidth * 2.0, frame);
    float3 frameColor = 0.5 + 0.5 * cos(fi * 1.5 + colorTint * 6.28 + float3(0.0, 2.0, 4.0));
    frameColor = mix(float3(0.3, 0.25, 0.2), frameColor, colorTint);
    col = mix(col, frameColor, frameMask);
    float inner = smoothstep(0.8 - frameWidth * 2.0, 0.7, frame);
    col = mix(col, col * 0.95, inner);
}
return float4(col, 1.0);
"""

