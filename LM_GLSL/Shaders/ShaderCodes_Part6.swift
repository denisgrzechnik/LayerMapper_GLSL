//
//  ShaderCodes_Part6.swift
//  LM_GLSL
//
//  Shader codes - Part 6: Parametric Geometric & Abstract Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Parametric Geometric Shaders

/// Rotating Polygon with adjustable sides and rotation
let rotatingPolygonCode = """
// @param sides "Liczba boków" range(3, 12) default(6)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 5.0) default(1.0)
// @param size "Rozmiar" range(0.1, 0.8) default(0.4)
// @param glowAmount "Intensywność poświaty" range(0.0, 2.0) default(0.5)
// @toggle rainbow "Tęczowy kolor" default(true)
float2 p = uv * 2.0 - 1.0;
float angle = atan2(p.y, p.x) + iTime * rotationSpeed;
float r = length(p);
float n = sides;
float a = 6.28318 / n;
float d = cos(floor(0.5 + angle / a) * a - angle) * r;
float polygon = smoothstep(size + 0.01, size - 0.01, d);
float glow = exp(-abs(d - size) * 5.0) * glowAmount;
float3 col = float3(0.0);
if (rainbow > 0.5) {
    col = 0.5 + 0.5 * cos(angle + iTime + float3(0.0, 2.0, 4.0));
} else {
    col = float3(0.2, 0.6, 1.0);
}
col = polygon * col + glow * col;
return float4(col, 1.0);
"""

/// Concentric Rings with customizable spacing
let concentricRingsCode = """
// @param ringCount "Liczba pierścieni" range(2, 20) default(8)
// @param ringWidth "Grubość pierścieni" range(0.01, 0.1) default(0.03)
// @param pulseSpeed "Prędkość pulsowania" range(0.0, 5.0) default(1.0)
// @param colorShift "Przesunięcie kolorów" range(0.0, 6.28) default(0.0)
// @toggle expandContract "Rozszerzanie/kurczenie" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float3 col = float3(0.02);
for (int i = 0; i < 20; i++) {
    if (float(i) >= ringCount) break;
    float fi = float(i);
    float baseRadius = (fi + 1.0) / ringCount * 0.9;
    float radius = baseRadius;
    if (expandContract > 0.5) {
        radius += sin(iTime * pulseSpeed + fi * 0.5) * 0.05;
    }
    float ring = smoothstep(ringWidth, 0.0, abs(r - radius));
    float3 ringCol = 0.5 + 0.5 * cos(fi * 0.5 + colorShift + iTime * 0.5 + float3(0.0, 2.0, 4.0));
    col += ring * ringCol;
}
return float4(col, 1.0);
"""

/// Spiral Galaxy with adjustable arms
let spiralGalaxyCode = """
// @param arms "Liczba ramion" range(1, 8) default(3)
// @param twist "Skręt" range(1.0, 10.0) default(5.0)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 3.0) default(0.5)
// @param brightness "Jasność" range(0.5, 2.0) default(1.0)
// @param coreSize "Rozmiar jądra" range(0.05, 0.3) default(0.1)
// @toggle addStars "Dodaj gwiazdy" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = sin(a * arms + r * twist - iTime * rotationSpeed);
spiral = pow(spiral * 0.5 + 0.5, 2.0);
float falloff = exp(-r * 2.0);
float3 col = spiral * falloff * float3(0.8, 0.5, 1.0) * brightness;
float core = exp(-r / coreSize);
col += core * float3(1.0, 0.9, 0.8);
if (addStars > 0.5) {
    float2 starP = uv * 50.0;
    float star = step(0.98, fract(sin(dot(floor(starP), float2(12.9898, 78.233))) * 43758.5453));
    col += star * (1.0 - r) * 0.5;
}
return float4(col, 1.0);
"""

/// Hexagonal Mosaic
let hexMosaicCode = """
// @param scale "Skala" range(2.0, 20.0) default(8.0)
// @param colorSpeed "Prędkość kolorów" range(0.0, 3.0) default(0.5)
// @param edgeWidth "Grubość krawędzi" range(0.0, 0.1) default(0.02)
// @param brightness "Jasność" range(0.5, 1.5) default(1.0)
// @toggle animate "Animuj" default(true)
float2 p = uv * scale;
float2 r = float2(1.0, 1.732);
float2 h = r * 0.5;
float2 a = fmod(p, r) - h;
float2 b = fmod(p - h, r) - h;
float2 g = length(a) < length(b) ? a : b;
float2 id = p - g;
float d = max(abs(g.x), abs(g.y) * 0.577 + abs(g.x) * 0.5);
float edge = smoothstep(0.4, 0.4 - edgeWidth, d);
float timeOffset = 0.0;
if (animate > 0.5) {
    timeOffset = iTime * colorSpeed;
}
float3 col = 0.5 + 0.5 * cos(dot(id, float2(0.1, 0.1)) + timeOffset + float3(0.0, 2.0, 4.0));
col *= edge * brightness;
return float4(col, 1.0);
"""

/// Radial Symmetry Pattern
let radialSymmetryCode = """
// @param segments "Liczba segmentów" range(2, 16) default(8)
// @param layers "Liczba warstw" range(1, 5) default(3)
// @param complexity "Złożoność" range(1.0, 10.0) default(4.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param colorVariety "Różnorodność kolorów" range(0.5, 3.0) default(1.0)
// @toggle mirrorY "Lustro Y" default(false)
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);
float segAngle = 6.28318 / segments;
a = abs(fmod(a + segAngle * 0.5, segAngle) - segAngle * 0.5);
if (mirrorY > 0.5) {
    a = abs(a);
}
float3 col = float3(0.02);
for (int i = 0; i < 5; i++) {
    if (float(i) >= layers) break;
    float fi = float(i);
    float layerR = (fi + 1.0) * 0.2;
    float pattern = sin(a * complexity + r * 10.0 - iTime * speed + fi);
    pattern = smoothstep(0.0, 0.1, pattern);
    float mask = smoothstep(layerR + 0.15, layerR, r) * smoothstep(layerR - 0.1, layerR, r);
    float3 layerCol = 0.5 + 0.5 * cos(fi * colorVariety + float3(0.0, 2.0, 4.0));
    col += pattern * mask * layerCol;
}
return float4(col, 1.0);
"""

/// Geometric Flower
let geometricFlowerCode = """
// @param petals "Liczba płatków" range(3, 12) default(6)
// @param petalLength "Długość płatków" range(0.2, 0.8) default(0.5)
// @param petalWidth "Szerokość płatków" range(0.1, 0.5) default(0.25)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 3.0) default(0.5)
// @param pulseAmount "Pulsowanie" range(0.0, 0.2) default(0.05)
// @toggle centerGlow "Świecące centrum" default(true)
float2 p = uv * 2.0 - 1.0;
float angle = atan2(p.y, p.x) + iTime * rotationSpeed;
float r = length(p);
float petalAngle = 6.28318 / petals;
float a = fmod(angle + petalAngle * 0.5, petalAngle) - petalAngle * 0.5;
float pulse = sin(iTime * 3.0) * pulseAmount;
float petalShape = cos(a / petalWidth) * (petalLength + pulse);
float petal = smoothstep(0.01, 0.0, r - petalShape);
petal *= smoothstep(petalWidth, 0.0, abs(a));
float3 col = petal * (0.5 + 0.5 * cos(angle + float3(0.0, 2.0, 4.0)));
if (centerGlow > 0.5) {
    float center = exp(-r * 8.0);
    col += center * float3(1.0, 0.9, 0.5);
}
return float4(col, 1.0);
"""

/// Wave Interference Pattern
let waveInterferenceCode = """
// @param sources "Liczba źródeł" range(2, 8) default(4)
// @param waveLength "Długość fali" range(5.0, 30.0) default(15.0)
// @param speed "Prędkość" range(0.5, 5.0) default(2.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param colorMode "Tryb kolorów" range(0.0, 2.0) default(1.0)
// @toggle animate "Animuj źródła" default(true)
float2 p = uv * 2.0 - 1.0;
float wave = 0.0;
for (int i = 0; i < 8; i++) {
    if (float(i) >= sources) break;
    float fi = float(i);
    float angle = fi * 6.28318 / sources;
    float2 source = float2(cos(angle), sin(angle)) * 0.5;
    if (animate > 0.5) {
        source *= 0.5 + 0.3 * sin(iTime + fi);
    }
    float d = length(p - source);
    wave += sin(d * waveLength - iTime * speed);
}
wave = wave / sources;
wave = pow(wave * 0.5 + 0.5, contrast);
float3 col;
if (colorMode < 1.0) {
    col = float3(wave);
} else if (colorMode < 2.0) {
    col = 0.5 + 0.5 * cos(wave * 6.28 + float3(0.0, 2.0, 4.0));
} else {
    col = mix(float3(0.0, 0.2, 0.4), float3(1.0, 0.8, 0.4), wave);
}
return float4(col, 1.0);
"""

/// Diamond Lattice
let diamondLatticeCode = """
// @param scale "Skala" range(2.0, 15.0) default(6.0)
// @param lineWidth "Grubość linii" range(0.01, 0.1) default(0.03)
// @param waveAmount "Falowanie" range(0.0, 0.5) default(0.1)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param brightness "Jasność" range(0.5, 2.0) default(1.0)
// @toggle dualColor "Podwójny kolor" default(true)
float2 p = uv * scale;
float wave = sin(iTime * speed) * waveAmount;
float d1 = abs(sin(p.x + p.y + wave));
float d2 = abs(sin(p.x - p.y + wave));
float line1 = smoothstep(lineWidth, 0.0, d1);
float line2 = smoothstep(lineWidth, 0.0, d2);
float3 col = float3(0.02);
if (dualColor > 0.5) {
    col += line1 * float3(0.2, 0.6, 1.0) * brightness;
    col += line2 * float3(1.0, 0.3, 0.5) * brightness;
} else {
    col += (line1 + line2) * float3(0.5, 0.8, 1.0) * brightness;
}
return float4(col, 1.0);
"""

/// Tessellation Grid
let tessellationGridCode = """
// @param tileSize "Rozmiar kafelka" range(2.0, 10.0) default(5.0)
// @param rotation "Rotacja" range(0.0, 1.57) default(0.0)
// @param bevelSize "Faza" range(0.0, 0.2) default(0.05)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(0.5)
// @param pattern "Wzór" range(0.0, 3.0) default(0.0)
// @toggle alternate "Naprzemienne kolory" default(true)
float2 p = uv * tileSize;
float c = cos(rotation);
float s = sin(rotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float2 id = floor(p);
float2 f = fract(p) - 0.5;
float d = max(abs(f.x), abs(f.y));
float tile = smoothstep(0.5, 0.5 - bevelSize, d);
float checker = 0.0;
if (alternate > 0.5) {
    checker = fmod(id.x + id.y, 2.0);
}
float3 col = 0.5 + 0.5 * cos(id.x * 0.5 + id.y * 0.3 + iTime * colorSpeed + checker * 3.14 + float3(0.0, 2.0, 4.0));
col *= tile;
return float4(col, 1.0);
"""

/// Voronoi Cells Advanced
let voronoiAdvancedCode = """
// @param cellCount "Liczba komórek" range(2.0, 10.0) default(5.0)
// @param borderWidth "Grubość krawędzi" range(0.0, 0.1) default(0.02)
// @param distortAmount "Zniekształcenie" range(0.0, 1.0) default(0.0)
// @param speed "Prędkość" range(0.0, 2.0) default(0.5)
// @param colorIntensity "Intensywność kolorów" range(0.5, 2.0) default(1.0)
// @toggle showCenters "Pokaż centra" default(false)
float2 p = uv * cellCount;
p += sin(p.yx * 3.0 + iTime) * distortAmount;
float2 n = floor(p);
float2 f = fract(p);
float md = 8.0;
float2 mg = float2(0.0);
float2 mc = float2(0.0);
for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
        float2 g = float2(float(i), float(j));
        float2 o = float2(fract(sin(dot(n + g, float2(127.1, 311.7))) * 43758.5453),
                         fract(sin(dot(n + g, float2(269.5, 183.3))) * 43758.5453));
        o = 0.5 + 0.5 * sin(iTime * speed + 6.2831 * o);
        float2 r = g + o - f;
        float d = dot(r, r);
        if (d < md) {
            md = d;
            mg = g;
            mc = o;
        }
    }
}
float3 col = 0.5 + 0.5 * cos(dot(mg, float2(1.0, 0.5)) * colorIntensity + float3(0.0, 2.0, 4.0));
float border = smoothstep(borderWidth, borderWidth + 0.01, sqrt(md));
col *= border;
if (showCenters > 0.5) {
    col += (1.0 - smoothstep(0.0, 0.05, sqrt(md))) * float3(1.0);
}
return float4(col, 1.0);
"""

// MARK: - Abstract Parametric Shaders

/// Morphing Blobs
let morphingBlobsCode = """
// @param blobCount "Liczba blobów" range(2, 8) default(4)
// @param blobSize "Rozmiar blobów" range(0.1, 0.4) default(0.2)
// @param morphSpeed "Prędkość morfowania" range(0.1, 3.0) default(1.0)
// @param smoothness "Gładkość" range(0.01, 0.1) default(0.03)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(0.5)
// @toggle metallic "Metaliczny efekt" default(false)
float2 p = uv * 2.0 - 1.0;
float d = 0.0;
for (int i = 0; i < 8; i++) {
    if (float(i) >= blobCount) break;
    float fi = float(i);
    float angle = fi * 6.28318 / blobCount + iTime * 0.3;
    float2 blobPos = float2(cos(angle + sin(iTime * morphSpeed + fi)), 
                            sin(angle + cos(iTime * morphSpeed + fi * 1.3))) * 0.4;
    d += blobSize / length(p - blobPos);
}
float blob = smoothstep(1.0 - smoothness, 1.0 + smoothness, d);
float3 col = 0.5 + 0.5 * cos(d * 2.0 + iTime * colorSpeed + float3(0.0, 2.0, 4.0));
if (metallic > 0.5) {
    float3 n = normalize(float3(dfdx(d), dfdy(d), 0.1));
    col = col * (0.5 + 0.5 * dot(n, normalize(float3(1.0, 1.0, 1.0))));
}
col *= blob;
return float4(col, 1.0);
"""

/// Liquid Surface
let liquidSurfaceCode = """
// @param waveScale "Skala fal" range(2.0, 15.0) default(8.0)
// @param waveHeight "Wysokość fal" range(0.1, 1.0) default(0.5)
// @param speed "Prędkość" range(0.1, 3.0) default(1.0)
// @param reflectivity "Odbicie" range(0.0, 1.0) default(0.5)
// @param depth "Głębokość" range(0.1, 1.0) default(0.3)
// @toggle ripples "Zmarszczki" default(true)
float2 p = uv * waveScale;
float wave1 = sin(p.x + iTime * speed) * sin(p.y * 1.3 + iTime * speed * 0.8);
float wave2 = sin(p.x * 1.5 - iTime * speed * 0.6) * sin(p.y + iTime * speed * 1.2);
float wave = (wave1 + wave2) * waveHeight * 0.5;
if (ripples > 0.5) {
    wave += sin(length(p - waveScale * 0.5) * 3.0 - iTime * 3.0) * 0.1;
}
float3 baseColor = float3(0.0, 0.3, 0.5);
float3 highlightColor = float3(0.6, 0.8, 1.0);
float3 col = mix(baseColor, highlightColor, wave * 0.5 + 0.5);
float fresnel = pow(1.0 - abs(wave), 3.0) * reflectivity;
col += fresnel * float3(1.0, 1.0, 1.0);
col *= depth + (1.0 - depth) * (1.0 - uv.y);
return float4(col, 1.0);
"""

/// Smoke Effect
let smokeEffectCode = """
// @param density "Gęstość" range(0.5, 3.0) default(1.5)
// @param turbulence "Turbulencja" range(1.0, 5.0) default(2.5)
// @param riseSpeed "Prędkość wznoszenia" range(0.1, 2.0) default(0.5)
// @param spreadAmount "Rozprzestrzenianie" range(0.0, 1.0) default(0.3)
// @param colorTemp "Temperatura koloru" range(0.0, 1.0) default(0.5)
// @toggle glow "Poświata" default(false)
float2 p = uv;
p.y -= iTime * riseSpeed;
p.x += sin(p.y * 3.0 + iTime) * spreadAmount;
float smoke = 0.0;
float amp = 1.0;
float2 freq = float2(3.0, 3.0);
for (int i = 0; i < 5; i++) {
    float n = sin(p.x * freq.x + iTime) * sin(p.y * freq.y);
    smoke += n * amp;
    freq *= turbulence;
    amp *= 0.5;
}
smoke = smoke * 0.5 + 0.5;
smoke *= pow(1.0 - abs(uv.x - 0.5) * 2.0, 0.5);
smoke *= pow(uv.y, 0.3);
smoke *= density;
float3 warmColor = float3(0.3, 0.25, 0.2);
float3 coolColor = float3(0.2, 0.2, 0.25);
float3 col = mix(coolColor, warmColor, colorTemp);
col *= smoke;
if (glow > 0.5) {
    col += exp(-uv.y * 3.0) * float3(1.0, 0.5, 0.2) * 0.3;
}
return float4(col, 1.0);
"""

/// Ink Drop
let inkDropCode = """
// @param dropSize "Rozmiar kropli" range(0.1, 0.5) default(0.3)
// @param spreadSpeed "Prędkość rozprzestrzeniania" range(0.1, 2.0) default(0.5)
// @param tentacles "Macki" range(0, 10) default(5)
// @param turbulence "Turbulencja" range(0.0, 0.5) default(0.15)
// @param inkDensity "Gęstość atramentu" range(0.5, 2.0) default(1.0)
// @toggle multiColor "Wielokolorowy" default(false)
float2 p = uv * 2.0 - 1.0;
float time = iTime * spreadSpeed;
float r = length(p);
float a = atan2(p.y, p.x);
float tentacle = sin(a * tentacles + time * 2.0) * turbulence;
float drop = smoothstep(dropSize + tentacle + fract(time) * 0.5, dropSize + tentacle, r);
drop *= smoothstep(1.0, dropSize, r);
float3 col;
if (multiColor > 0.5) {
    col = 0.5 + 0.5 * cos(a + time + float3(0.0, 2.0, 4.0));
} else {
    col = float3(0.05, 0.02, 0.1);
}
col *= drop * inkDensity;
float edge = smoothstep(0.01, 0.0, abs(r - dropSize - tentacle - fract(time) * 0.5));
col += edge * float3(0.1, 0.05, 0.15);
return float4(col, 1.0);
"""

/// Fabric Weave
let fabricWeaveCode = """
// @param weaveScale "Skala splotu" range(5.0, 30.0) default(15.0)
// @param threadWidth "Grubość nici" range(0.3, 0.8) default(0.5)
// @param depth "Głębokość" range(0.0, 0.5) default(0.2)
// @param warpColor "Kolor osnowy" range(0.0, 1.0) default(0.0)
// @param weftColor "Kolor wątku" range(0.0, 1.0) default(0.5)
// @toggle animate "Animuj" default(false)
float2 p = uv * weaveScale;
float time = 0.0;
if (animate > 0.5) {
    time = iTime * 0.5;
}
float2 id = floor(p);
float2 f = fract(p);
float warp = smoothstep(threadWidth, threadWidth + 0.1, abs(f.y - 0.5));
float weft = smoothstep(threadWidth, threadWidth + 0.1, abs(f.x - 0.5));
float over = fmod(id.x + id.y, 2.0);
float3 warpCol = 0.5 + 0.5 * cos(warpColor * 6.28 + float3(0.0, 2.0, 4.0));
float3 weftCol = 0.5 + 0.5 * cos(weftColor * 6.28 + float3(0.0, 2.0, 4.0));
float3 col;
if (over > 0.5) {
    col = mix(warpCol * (1.0 - depth), weftCol, weft);
} else {
    col = mix(weftCol * (1.0 - depth), warpCol, warp);
}
return float4(col, 1.0);
"""

/// Marble Texture
let marbleTextureCode = """
// @param scale "Skala" range(1.0, 10.0) default(3.0)
// @param veins "Ilość żył" range(1.0, 8.0) default(4.0)
// @param veinSharpness "Ostrość żył" range(1.0, 10.0) default(3.0)
// @param turbulence "Turbulencja" range(0.0, 2.0) default(0.5)
// @param baseColor "Kolor bazowy" range(0.0, 1.0) default(0.9)
// @toggle animated "Animowany" default(false)
float2 p = uv * scale;
float time = 0.0;
if (animated > 0.5) {
    time = iTime * 0.2;
}
float turbNoise = sin(p.x * 2.0 + time) * sin(p.y * 2.0 + time) * turbulence;
float vein = sin((p.x + p.y) * veins + turbNoise * 5.0 + 
                 sin(p.x * 3.0 + time) * turbulence * 2.0);
vein = pow(abs(vein), 1.0 / veinSharpness);
float3 marbleBase = float3(baseColor, baseColor * 0.98, baseColor * 0.95);
float3 veinColor = float3(0.2, 0.15, 0.1);
float3 col = mix(veinColor, marbleBase, vein);
return float4(col, 1.0);
"""

/// Oil Slick
let oilSlickCode = """
// @param thickness "Grubość filmu" range(1.0, 5.0) default(2.0)
// @param flowSpeed "Prędkość przepływu" range(0.0, 2.0) default(0.5)
// @param iridescence "Opalizacja" range(0.5, 3.0) default(1.5)
// @param swirl "Zawirowanie" range(0.0, 1.0) default(0.3)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle darkBase "Ciemna baza" default(true)
float2 p = uv;
p += sin(p.yx * 5.0 + iTime * flowSpeed) * swirl * 0.1;
float n = sin(p.x * 10.0 * thickness + iTime * flowSpeed) + 
          sin(p.y * 8.0 * thickness + iTime * flowSpeed * 0.8);
n = n * 0.5 + 0.5;
float3 col = 0.5 + 0.5 * cos(n * 6.28 * iridescence + float3(0.0, 2.0, 4.0));
col = pow(col, float3(contrast));
if (darkBase > 0.5) {
    float3 dark = float3(0.05, 0.03, 0.08);
    col = mix(dark, col, 0.7 + 0.3 * sin(n * 3.14));
}
return float4(col, 1.0);
"""

/// Crystal Formation
let crystalFormationCode = """
// @param crystalCount "Liczba kryształów" range(2.0, 8.0) default(5.0)
// @param crystalSize "Rozmiar kryształów" range(0.1, 0.4) default(0.2)
// @param facets "Ilość fasetek" range(4, 12) default(6)
// @param refraction "Refrakcja" range(0.0, 0.3) default(0.1)
// @param clarity "Klarowność" range(0.3, 1.0) default(0.7)
// @toggle glow "Wewnętrzny blask" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.03, 0.05);
for (int i = 0; i < 8; i++) {
    if (float(i) >= crystalCount) break;
    float fi = float(i);
    float2 center = float2(sin(fi * 1.7), cos(fi * 2.3)) * 0.4;
    float2 cp = p - center;
    cp += sin(cp.yx * 10.0) * refraction;
    float r = length(cp);
    float a = atan2(cp.y, cp.x) + iTime * 0.2;
    float crystal = cos(a * facets) * crystalSize;
    float d = smoothstep(crystal + 0.02, crystal, r);
    float3 crystalCol = 0.5 + 0.5 * cos(fi + float3(0.0, 2.0, 4.0));
    crystalCol *= clarity;
    if (glow > 0.5) {
        crystalCol += exp(-r / crystalSize * 3.0) * float3(0.5, 0.7, 1.0) * 0.3;
    }
    col += d * crystalCol;
}
return float4(col, 1.0);
"""

/// Caustics
let causticsCode = """
// @param scale "Skala" range(2.0, 10.0) default(5.0)
// @param speed "Prędkość" range(0.1, 2.0) default(0.5)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @param complexity "Złożoność" range(1, 5) default(3)
// @param waterColor "Kolor wody" range(0.0, 1.0) default(0.6)
// @toggle sunlight "Światło słoneczne" default(true)
float2 p = uv * scale;
float caustic = 0.0;
float amp = 1.0;
for (int i = 0; i < 5; i++) {
    if (float(i) >= float(complexity)) break;
    float fi = float(i);
    float2 offset = float2(sin(iTime * speed + fi), cos(iTime * speed * 0.7 + fi)) * 0.5;
    caustic += sin(p.x * (fi + 1.0) + offset.x + iTime * speed) * 
               sin(p.y * (fi + 1.0) + offset.y + iTime * speed * 0.8) * amp;
    amp *= 0.5;
}
caustic = caustic * 0.5 + 0.5;
caustic = pow(caustic, 1.5) * intensity;
float3 water = 0.5 + 0.5 * cos(waterColor * 6.28 + float3(2.0, 3.0, 4.0));
water *= 0.3;
float3 col = water + caustic * float3(0.8, 0.9, 1.0);
if (sunlight > 0.5) {
    float sun = pow(caustic, 3.0);
    col += sun * float3(1.0, 0.95, 0.8) * 0.5;
}
return float4(col, 1.0);
"""

/// Lava Lamp
let lavaLampCode = """
// @param blobCount "Liczba blobów" range(2, 6) default(3)
// @param blobSpeed "Prędkość blobów" range(0.1, 1.0) default(0.3)
// @param blobSize "Rozmiar blobów" range(0.1, 0.3) default(0.2)
// @param heat "Ciepło" range(0.0, 1.0) default(0.5)
// @param glassEffect "Efekt szkła" range(0.0, 0.3) default(0.1)
// @toggle retro "Retro kolory" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
float d = 0.0;
for (int i = 0; i < 6; i++) {
    if (float(i) >= float(blobCount)) break;
    float fi = float(i);
    float phase = fi * 1.5;
    float2 blobPos = float2(
        sin(iTime * blobSpeed + phase) * 0.3,
        sin(iTime * blobSpeed * 0.7 + phase + 1.0) * 0.7
    );
    d += blobSize / length(p - blobPos);
}
float blob = smoothstep(0.9, 1.1, d);
float3 blobColor;
if (retro > 0.5) {
    blobColor = mix(float3(1.0, 0.3, 0.0), float3(1.0, 0.8, 0.0), heat);
} else {
    blobColor = 0.5 + 0.5 * cos(d + iTime + float3(0.0, 2.0, 4.0));
}
float3 bgColor = float3(0.1, 0.02, 0.05);
col = mix(bgColor, blobColor, blob);
float glass = abs(uv.x - 0.5) * 2.0;
glass = pow(glass, 3.0) * glassEffect;
col += float3(1.0) * glass;
return float4(col, 1.0);
"""

