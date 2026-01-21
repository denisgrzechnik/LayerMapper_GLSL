//
//  ShaderCodes_Part7.swift
//  LM_GLSL
//
//  Shader codes - Part 7: Cosmic & Space Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Cosmic Parametric Shaders

/// Supernova Explosion
let supernovaCode = """
// @param explosionSize "Rozmiar eksplozji" range(0.1, 1.0) default(0.5)
// @param shockwaveSpeed "Prędkość fali uderzeniowej" range(0.5, 3.0) default(1.5)
// @param particleDensity "Gęstość cząstek" range(10, 50) default(30)
// @param coreIntensity "Intensywność jądra" range(0.5, 3.0) default(1.5)
// @param colorTemp "Temperatura kolorów" range(0.0, 1.0) default(0.5)
// @toggle showShockwave "Pokaż falę uderzeniową" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float time = fract(iTime * 0.3) * shockwaveSpeed;
float3 col = float3(0.0);
float core = exp(-r / (explosionSize * 0.3)) * coreIntensity;
float3 coreColor = mix(float3(1.0, 0.8, 0.3), float3(0.5, 0.8, 1.0), colorTemp);
col += core * coreColor;
if (showShockwave > 0.5) {
    float shockwave = smoothstep(0.05, 0.0, abs(r - time * explosionSize));
    shockwave *= smoothstep(explosionSize * 1.5, 0.0, r);
    col += shockwave * float3(0.8, 0.6, 1.0);
}
for (int i = 0; i < 50; i++) {
    if (float(i) >= float(particleDensity)) break;
    float fi = float(i);
    float pa = fi * 2.399;
    float pr = time * (0.5 + fract(sin(fi * 43.758) * 43758.5453) * 0.5);
    float2 particlePos = float2(cos(pa), sin(pa)) * pr * explosionSize;
    float pd = length(p - particlePos);
    col += smoothstep(0.02, 0.0, pd) * coreColor * (1.0 - time / shockwaveSpeed);
}
return float4(col, 1.0);
"""

/// Wormhole Portal
let wormholeCode = """
// @param tunnelDepth "Głębokość tunelu" range(1.0, 5.0) default(3.0)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 3.0) default(1.0)
// @param spiralTightness "Ciasność spirali" range(1.0, 10.0) default(5.0)
// @param eventHorizonSize "Rozmiar horyzontu zdarzeń" range(0.05, 0.3) default(0.15)
// @param distortionStrength "Siła zniekształcenia" range(0.0, 1.0) default(0.3)
// @toggle accretionDisk "Dysk akrecyjny" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float tunnel = 1.0 / (r + 0.001);
float spiral = a + tunnel * spiralTightness + iTime * rotationSpeed;
float warp = sin(spiral) * 0.5 + 0.5;
warp *= smoothstep(eventHorizonSize, eventHorizonSize + 0.5, r);
float3 col = warp * (0.5 + 0.5 * cos(tunnel / tunnelDepth + float3(0.0, 2.0, 4.0)));
col *= exp(-r * 0.5);
float hole = smoothstep(eventHorizonSize, eventHorizonSize - 0.02, r);
col *= (1.0 - hole);
if (accretionDisk > 0.5) {
    float diskAngle = a + iTime * rotationSpeed * 2.0;
    float disk = smoothstep(0.03, 0.0, abs(r - 0.3 - sin(diskAngle * 5.0) * 0.02));
    disk *= smoothstep(0.5, 0.2, r);
    col += disk * float3(1.0, 0.6, 0.2);
}
col += exp(-r / eventHorizonSize * 0.5) * float3(0.3, 0.2, 0.5) * distortionStrength;
return float4(col, 1.0);
"""

/// Pulsar Beam
let pulsarBeamCode = """
// @param beamWidth "Szerokość wiązki" range(0.05, 0.3) default(0.1)
// @param pulseRate "Częstotliwość pulsu" range(1.0, 10.0) default(3.0)
// @param beamLength "Długość wiązki" range(0.5, 2.0) default(1.0)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 2.0) default(0.5)
// @param starSize "Rozmiar gwiazdy" range(0.05, 0.2) default(0.1)
// @toggle dualBeam "Podwójna wiązka" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float rotation = iTime * rotationSpeed;
float3 col = float3(0.02, 0.02, 0.05);
float pulse = sin(iTime * pulseRate) * 0.5 + 0.5;
pulse = pow(pulse, 2.0);
float beam1Angle = rotation;
float beam1 = smoothstep(beamWidth, 0.0, abs(sin(a - beam1Angle)));
beam1 *= smoothstep(starSize, starSize + beamLength, r);
beam1 *= pulse;
col += beam1 * float3(0.5, 0.7, 1.0);
if (dualBeam > 0.5) {
    float beam2Angle = rotation + 3.14159;
    float beam2 = smoothstep(beamWidth, 0.0, abs(sin(a - beam2Angle)));
    beam2 *= smoothstep(starSize, starSize + beamLength, r);
    beam2 *= pulse;
    col += beam2 * float3(0.5, 0.7, 1.0);
}
float star = exp(-r / starSize);
col += star * float3(1.0, 0.9, 0.8) * (0.7 + 0.3 * pulse);
return float4(col, 1.0);
"""

/// Asteroid Field
let asteroidFieldCode = """
// @param asteroidCount "Liczba asteroid" range(10, 50) default(25)
// @param asteroidSize "Rozmiar asteroid" range(0.01, 0.05) default(0.02)
// @param fieldDepth "Głębokość pola" range(1.0, 5.0) default(2.0)
// @param driftSpeed "Prędkość dryfowania" range(0.0, 1.0) default(0.3)
// @param rotationAmount "Rotacja" range(0.0, 1.0) default(0.2)
// @toggle parallax "Efekt paralaksy" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.01, 0.01, 0.02);
for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float depth = 1.0 + fl * fieldDepth * 0.5;
    float layerSize = asteroidSize / depth;
    int count = int(float(asteroidCount) / depth);
    for (int i = 0; i < 50; i++) {
        if (i >= count) break;
        float fi = float(i);
        float hash = fract(sin(fi * 43.758 + fl * 12.345) * 43758.5453);
        float2 pos = float2(
            fract(hash * 7.0 + iTime * driftSpeed / depth) * 2.0 - 1.0,
            fract(hash * 13.0 + sin(iTime * 0.1 + fi) * rotationAmount) * 2.0 - 1.0
        );
        if (parallax > 0.5) {
            pos.x += sin(iTime * 0.2) * 0.1 / depth;
        }
        float d = length(p - pos);
        float asteroid = smoothstep(layerSize, layerSize * 0.5, d);
        float shade = 0.5 + 0.5 * sin(fi);
        col += asteroid * float3(0.4, 0.35, 0.3) * shade / depth;
    }
}
float stars = step(0.998, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.3;
return float4(col, 1.0);
"""

/// Solar Eclipse
let solarEclipseCode = """
// @param moonSize "Rozmiar księżyca" range(0.2, 0.5) default(0.35)
// @param sunSize "Rozmiar słońca" range(0.25, 0.6) default(0.4)
// @param coronaSize "Rozmiar korony" range(0.1, 0.5) default(0.25)
// @param eclipseProgress "Postęp zaćmienia" range(0.0, 1.0) default(0.5)
// @param coronaIntensity "Intensywność korony" range(0.5, 2.0) default(1.0)
// @toggle diamondRing "Efekt diamentowego pierścienia" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float moonOffset = (eclipseProgress - 0.5) * 0.5;
float2 moonCenter = float2(moonOffset, 0.0);
float moonDist = length(p - moonCenter);
float3 col = float3(0.0);
float sun = smoothstep(sunSize + 0.02, sunSize, r);
float3 sunColor = float3(1.0, 0.9, 0.7);
col += sun * sunColor;
float corona = exp(-(r - sunSize) / coronaSize) * coronaIntensity;
corona *= (1.0 - sun);
float coronaRays = 0.5 + 0.5 * sin(a * 12.0 + iTime * 0.5);
col += corona * coronaRays * float3(1.0, 0.6, 0.3);
float moon = smoothstep(moonSize + 0.01, moonSize, moonDist);
col *= (1.0 - moon);
if (diamondRing > 0.5 && abs(eclipseProgress - 0.5) < 0.1) {
    float edgeDist = abs(moonDist - moonSize);
    float diamond = exp(-edgeDist * 50.0) * step(moonDist, moonSize + 0.02);
    diamond *= smoothstep(0.0, 0.02, abs(a - moonOffset * 10.0));
    col += diamond * float3(1.0, 1.0, 1.0) * 2.0;
}
return float4(col, 1.0);
"""

/// Cosmic Web
let cosmicWebCode = """
// @param webDensity "Gęstość sieci" range(2.0, 10.0) default(5.0)
// @param filamentWidth "Grubość filamentów" range(0.01, 0.1) default(0.03)
// @param nodeSize "Rozmiar węzłów" range(0.02, 0.1) default(0.05)
// @param pulseSpeed "Prędkość pulsowania" range(0.0, 3.0) default(1.0)
// @param colorVariation "Wariacja kolorów" range(0.0, 2.0) default(1.0)
// @toggle showNodes "Pokaż węzły" default(true)
float2 p = uv * webDensity;
float2 id = floor(p);
float2 f = fract(p);
float3 col = float3(0.01, 0.02, 0.03);
float minDist = 10.0;
float2 closestNode = float2(0.0);
for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 nodeId = id + neighbor;
        float2 nodeOffset = float2(
            fract(sin(dot(nodeId, float2(127.1, 311.7))) * 43758.5453),
            fract(sin(dot(nodeId, float2(269.5, 183.3))) * 43758.5453)
        );
        nodeOffset = 0.5 + 0.4 * sin(iTime * pulseSpeed * 0.3 + 6.28 * nodeOffset);
        float2 nodePos = neighbor + nodeOffset - f;
        float d = length(nodePos);
        if (d < minDist) {
            minDist = d;
            closestNode = nodeId;
        }
    }
}
for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 nodeId = id + neighbor;
        if (nodeId.x == closestNode.x && nodeId.y == closestNode.y) continue;
        float2 nodeOffset = 0.5 + 0.4 * sin(iTime * pulseSpeed * 0.3 + 6.28 * 
            float2(fract(sin(dot(nodeId, float2(127.1, 311.7))) * 43758.5453),
                   fract(sin(dot(nodeId, float2(269.5, 183.3))) * 43758.5453)));
        float2 nodePos = neighbor + nodeOffset - f;
        float2 closestOffset = 0.5 + 0.4 * sin(iTime * pulseSpeed * 0.3 + 6.28 *
            float2(fract(sin(dot(closestNode, float2(127.1, 311.7))) * 43758.5453),
                   fract(sin(dot(closestNode, float2(269.5, 183.3))) * 43758.5453)));
        float2 closestPos = closestNode - id + closestOffset - f;
        float2 toNode = nodePos - closestPos;
        float2 toPoint = -closestPos;
        float t = clamp(dot(toPoint, toNode) / dot(toNode, toNode), 0.0, 1.0);
        float2 closest = closestPos + t * toNode;
        float lineDist = length(closest);
        float line = smoothstep(filamentWidth, 0.0, lineDist);
        float3 lineColor = 0.5 + 0.5 * cos(dot(nodeId, float2(1.0, 0.5)) * colorVariation + float3(0.0, 2.0, 4.0));
        col += line * lineColor * 0.3;
    }
}
if (showNodes > 0.5) {
    float node = smoothstep(nodeSize, nodeSize * 0.5, minDist);
    float pulse = 0.8 + 0.2 * sin(iTime * pulseSpeed + dot(closestNode, float2(1.0, 1.0)));
    col += node * float3(0.8, 0.6, 1.0) * pulse;
}
return float4(col, 1.0);
"""

/// Quasar Jet
let quasarJetCode = """
// @param jetWidth "Szerokość dżetu" range(0.05, 0.3) default(0.15)
// @param jetLength "Długość dżetu" range(0.3, 1.0) default(0.7)
// @param coreSize "Rozmiar jądra" range(0.05, 0.2) default(0.1)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.3)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @toggle counterJet "Przeciwny dżet" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.01, 0.01, 0.02);
float core = exp(-r / coreSize);
col += core * float3(1.0, 0.9, 0.7) * intensity;
float jetAngle = 1.5708;
float turbNoise = sin(p.y * 10.0 + iTime * 3.0) * turbulence * 0.1;
float jet1 = smoothstep(jetWidth + turbNoise, 0.0, abs(a - jetAngle));
jet1 *= smoothstep(0.0, jetLength, p.y);
jet1 *= smoothstep(coreSize * 2.0, coreSize, r);
float3 jetColor = float3(0.3, 0.5, 1.0);
col += jet1 * jetColor * intensity;
if (counterJet > 0.5) {
    float jet2 = smoothstep(jetWidth + turbNoise, 0.0, abs(a + jetAngle));
    jet2 *= smoothstep(0.0, jetLength, -p.y);
    jet2 *= smoothstep(coreSize * 2.0, coreSize, r);
    col += jet2 * jetColor * intensity * 0.7;
}
float disk = smoothstep(0.02, 0.0, abs(p.y)) * smoothstep(0.5, coreSize, r);
col += disk * float3(1.0, 0.5, 0.2) * 0.5;
return float4(col, 1.0);
"""

/// Planetary Rings
let planetaryRingsCode = """
// @param planetSize "Rozmiar planety" range(0.15, 0.35) default(0.25)
// @param ringInner "Wewnętrzna krawędź pierścienia" range(0.3, 0.5) default(0.35)
// @param ringOuter "Zewnętrzna krawędź pierścienia" range(0.5, 0.9) default(0.7)
// @param ringBands "Liczba pasm" range(2, 10) default(5)
// @param tilt "Nachylenie" range(0.0, 0.5) default(0.2)
// @toggle atmosphere "Atmosfera" default(true)
float2 p = uv * 2.0 - 1.0;
p.y /= (1.0 - tilt);
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.01, 0.01, 0.02);
float planet = smoothstep(planetSize + 0.01, planetSize, r);
float3 planetColor = float3(0.6, 0.5, 0.4);
float shade = 0.5 + 0.5 * p.x / planetSize;
col += planet * planetColor * shade;
if (atmosphere > 0.5) {
    float atmo = smoothstep(planetSize + 0.1, planetSize, r) - planet;
    col += atmo * float3(0.3, 0.5, 0.8) * 0.5;
}
float ring = smoothstep(ringInner, ringInner + 0.02, r) * smoothstep(ringOuter + 0.02, ringOuter, r);
ring *= (1.0 - planet);
float bands = 0.0;
for (int i = 0; i < 10; i++) {
    if (float(i) >= ringBands) break;
    float fi = float(i);
    float bandPos = ringInner + (ringOuter - ringInner) * fi / ringBands;
    bands += smoothstep(0.02, 0.0, abs(r - bandPos)) * 0.5;
}
float3 ringColor = float3(0.8, 0.7, 0.6) * (0.5 + bands);
float shadow = step(0.0, p.y) * step(abs(p.x), planetSize) * step(r, ringOuter);
ringColor *= (1.0 - shadow * 0.5);
col += ring * ringColor;
return float4(col, 1.0);
"""

/// Space Dust Cloud
let spaceDustCloudCode = """
// @param cloudDensity "Gęstość chmury" range(0.5, 3.0) default(1.5)
// @param cloudScale "Skala chmury" range(2.0, 10.0) default(5.0)
// @param driftSpeed "Prędkość dryfowania" range(0.0, 1.0) default(0.2)
// @param starDensity "Gęstość gwiazd" range(0.0, 1.0) default(0.5)
// @param colorHue "Odcień koloru" range(0.0, 1.0) default(0.7)
// @toggle nebulaBrightSpots "Jasne punkty" default(true)
float2 p = uv + float2(iTime * driftSpeed, sin(iTime * driftSpeed * 0.5) * 0.1);
float cloud = 0.0;
float amp = 1.0;
float2 freq = float2(cloudScale, cloudScale);
for (int i = 0; i < 5; i++) {
    float n = sin(p.x * freq.x) * sin(p.y * freq.y) * 0.5 + 0.5;
    cloud += n * amp;
    freq *= 2.0;
    amp *= 0.5;
    p += float2(0.5, 0.3);
}
cloud = pow(cloud * 0.5, cloudDensity);
float3 cloudColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
float3 col = cloud * cloudColor * 0.5;
float stars = step(1.0 - starDensity * 0.01, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
float starTwinkle = 0.7 + 0.3 * sin(iTime * 5.0 + dot(floor(uv * 100.0), float2(1.0, 1.0)));
col += stars * starTwinkle * (1.0 - cloud * 0.5);
if (nebulaBrightSpots > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float2 spotPos = float2(fract(sin(fi * 127.1) * 43758.5453), fract(sin(fi * 311.7) * 43758.5453));
        float spot = exp(-length(uv - spotPos) * 5.0) * 0.3;
        col += spot * cloudColor * 2.0;
    }
}
return float4(col, 1.0);
"""

/// Binary Star System
let binaryStarCode = """
// @param star1Size "Rozmiar gwiazdy 1" range(0.05, 0.2) default(0.12)
// @param star2Size "Rozmiar gwiazdy 2" range(0.03, 0.15) default(0.08)
// @param orbitRadius "Promień orbity" range(0.2, 0.5) default(0.3)
// @param orbitSpeed "Prędkość orbitalna" range(0.1, 2.0) default(0.5)
// @param glowIntensity "Intensywność poświaty" range(0.5, 2.0) default(1.0)
// @toggle massTransfer "Transfer masy" default(true)
float2 p = uv * 2.0 - 1.0;
float orbitAngle = iTime * orbitSpeed;
float2 star1Pos = float2(cos(orbitAngle), sin(orbitAngle)) * orbitRadius * 0.6;
float2 star2Pos = float2(cos(orbitAngle + 3.14159), sin(orbitAngle + 3.14159)) * orbitRadius;
float3 col = float3(0.01, 0.01, 0.02);
float d1 = length(p - star1Pos);
float star1 = exp(-d1 / star1Size) * glowIntensity;
float3 star1Color = float3(1.0, 0.7, 0.4);
col += star1 * star1Color;
float d2 = length(p - star2Pos);
float star2 = exp(-d2 / star2Size) * glowIntensity;
float3 star2Color = float3(0.6, 0.8, 1.0);
col += star2 * star2Color;
if (massTransfer > 0.5) {
    float2 mid = (star1Pos + star2Pos) * 0.5;
    float2 dir = normalize(star2Pos - star1Pos);
    float2 perp = float2(-dir.y, dir.x);
    float stream = 0.0;
    for (int i = 0; i < 10; i++) {
        float fi = float(i) / 10.0;
        float2 streamPos = mix(star1Pos, star2Pos, fi);
        streamPos += perp * sin(fi * 6.28 + iTime * 5.0) * 0.05;
        float sd = length(p - streamPos);
        stream += smoothstep(0.02, 0.0, sd) * (1.0 - fi);
    }
    col += stream * float3(1.0, 0.5, 0.3) * 0.5;
}
return float4(col, 1.0);
"""

// MARK: - Space Environment Shaders

/// Aurora Borealis Advanced
let auroraAdvancedCode = """
// @param waveCount "Liczba fal" range(2, 8) default(5)
// @param waveHeight "Wysokość fal" range(0.1, 0.5) default(0.2)
// @param flowSpeed "Prędkość przepływu" range(0.1, 2.0) default(0.5)
// @param colorShift "Przesunięcie kolorów" range(0.0, 6.28) default(0.0)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @toggle multiLayer "Wielowarstwowy" default(true)
float2 p = uv;
float3 col = float3(0.01, 0.02, 0.05);
int layers = multiLayer > 0.5 ? 3 : 1;
for (int layer = 0; layer < 3; layer++) {
    if (layer >= layers) break;
    float fl = float(layer);
    float layerOffset = fl * 0.1;
    for (int i = 0; i < 8; i++) {
        if (float(i) >= waveCount) break;
        float fi = float(i);
        float waveY = 0.3 + fi * 0.1 + layerOffset;
        float wave = sin(p.x * 3.0 + iTime * flowSpeed + fi * 1.5) * waveHeight;
        wave += sin(p.x * 5.0 - iTime * flowSpeed * 0.7 + fi) * waveHeight * 0.5;
        float d = abs(p.y - waveY - wave);
        float glow = smoothstep(0.15, 0.0, d);
        float3 auroraCol = 0.5 + 0.5 * cos(fi * 0.5 + colorShift + fl + float3(0.0, 2.0, 4.0));
        col += glow * auroraCol * intensity * (1.0 / float(layers));
    }
}
float stars = step(0.997, fract(sin(dot(floor(uv * 150.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.3 * (1.0 - col);
return float4(col, 1.0);
"""

/// Meteor Shower
let meteorShowerCode = """
// @param meteorCount "Liczba meteorów" range(5, 30) default(15)
// @param meteorSpeed "Prędkość meteorów" range(0.5, 3.0) default(1.5)
// @param tailLength "Długość ogona" range(0.05, 0.3) default(0.15)
// @param meteorSize "Rozmiar meteorów" range(0.005, 0.02) default(0.01)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @toggle randomDirection "Losowy kierunek" default(false)
float2 p = uv;
float3 col = float3(0.01, 0.01, 0.02);
float stars = step(0.998, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.4;
for (int i = 0; i < 30; i++) {
    if (float(i) >= float(meteorCount)) break;
    float fi = float(i);
    float hash = fract(sin(fi * 43.758) * 43758.5453);
    float phase = fract(iTime * meteorSpeed * (0.5 + hash * 0.5) + hash * 10.0);
    float2 startPos = float2(hash, 1.0 - hash * 0.5);
    float2 dir = float2(1.0, -1.0);
    if (randomDirection > 0.5) {
        float angle = hash * 1.57 - 0.785;
        dir = float2(cos(angle), sin(angle));
    }
    dir = normalize(dir);
    float2 meteorPos = startPos + dir * phase * 1.5;
    float d = length(p - meteorPos);
    float meteor = smoothstep(meteorSize, 0.0, d);
    for (int t = 1; t < 10; t++) {
        float ft = float(t) / 10.0;
        float2 tailPos = meteorPos - dir * ft * tailLength;
        float td = length(p - tailPos);
        float tail = smoothstep(meteorSize * (1.0 - ft * 0.8), 0.0, td) * (1.0 - ft);
        meteor += tail * 0.3;
    }
    meteor *= (1.0 - phase * 0.5);
    float3 meteorColor = float3(1.0, 0.8, 0.5);
    col += meteor * meteorColor;
    if (glowAmount > 0.0) {
        float glow = smoothstep(0.1, 0.0, d) * glowAmount * (1.0 - phase);
        col += glow * float3(0.5, 0.4, 0.3);
    }
}
return float4(col, 1.0);
"""

/// Stargate Activation
let stargateCode = """
// @param ringCount "Liczba pierścieni" range(1, 5) default(3)
// @param symbolCount "Liczba symboli" range(6, 12) default(9)
// @param rotationSpeed "Prędkość rotacji" range(0.1, 2.0) default(0.5)
// @param eventHorizon "Horyzont zdarzeń" range(0.0, 1.0) default(0.7)
// @param glowIntensity "Intensywność blasku" range(0.5, 2.0) default(1.0)
// @toggle active "Aktywny" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.03);
for (int i = 0; i < 5; i++) {
    if (float(i) >= float(ringCount)) break;
    float fi = float(i);
    float ringR = 0.6 + fi * 0.1;
    float ringWidth = 0.03;
    float ring = smoothstep(ringWidth, 0.0, abs(r - ringR));
    float rotation = iTime * rotationSpeed * (fi + 1.0) * (fmod(fi, 2.0) * 2.0 - 1.0);
    float symbols = step(0.7, sin((a + rotation) * symbolCount));
    symbols *= ring;
    float3 ringColor = float3(0.6, 0.5, 0.3) * glowIntensity;
    col += ring * ringColor * 0.3;
    col += symbols * float3(1.0, 0.8, 0.4) * glowIntensity;
}
if (active > 0.5 && eventHorizon > 0.0) {
    float horizon = smoothstep(0.5, 0.0, r) * eventHorizon;
    float ripple = sin(r * 20.0 - iTime * 5.0) * 0.5 + 0.5;
    float3 horizonColor = float3(0.2, 0.5, 1.0) * (0.5 + ripple * 0.5);
    col += horizon * horizonColor * glowIntensity;
}
float outerGlow = exp(-(r - 0.9) * 5.0) * step(0.9, r) * glowIntensity;
col += outerGlow * float3(0.4, 0.3, 0.2);
return float4(col, 1.0);
"""

/// Galactic Core
let galacticCoreCode = """
// @param coreSize "Rozmiar jądra" range(0.1, 0.4) default(0.2)
// @param armCount "Liczba ramion" range(2, 6) default(4)
// @param armTightness "Ciasność ramion" range(1.0, 5.0) default(2.5)
// @param starDensity "Gęstość gwiazd" range(0.5, 2.0) default(1.0)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 1.0) default(0.2)
// @toggle darkMatter "Ciemna materia" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x) + iTime * rotationSpeed;
float3 col = float3(0.02, 0.01, 0.03);
float spiral = sin(a * float(armCount) + r * armTightness * 6.28);
spiral = pow(spiral * 0.5 + 0.5, 2.0);
float falloff = exp(-r * 3.0);
float3 armColor = float3(0.4, 0.5, 0.8);
col += spiral * falloff * armColor * starDensity;
float core = exp(-r / coreSize);
float3 coreColor = float3(1.0, 0.9, 0.7);
col += core * coreColor;
if (darkMatter > 0.5) {
    float dm = sin(a * 7.0 + r * 10.0 - iTime) * 0.5 + 0.5;
    dm *= exp(-r * 2.0);
    col *= (1.0 - dm * 0.3);
}
float2 starP = uv * 100.0;
float star = fract(sin(dot(floor(starP), float2(12.9898, 78.233))) * 43758.5453);
star = step(1.0 - 0.01 * starDensity * (1.0 - r), star);
float twinkle = 0.7 + 0.3 * sin(iTime * 5.0 + dot(floor(starP), float2(1.0, 1.0)));
col += star * twinkle * (0.3 + 0.7 * (1.0 - falloff));
return float4(col, 1.0);
"""

/// Comet Trail
let cometTrailCode = """
// @param cometSize "Rozmiar komety" range(0.02, 0.1) default(0.05)
// @param tailLength "Długość ogona" range(0.2, 0.8) default(0.5)
// @param tailWidth "Szerokość ogona" range(0.02, 0.15) default(0.08)
// @param speed "Prędkość" range(0.1, 1.0) default(0.3)
// @param dustAmount "Ilość pyłu" range(0.0, 1.0) default(0.5)
// @toggle ionTail "Ogon jonowy" default(true)
float2 p = uv * 2.0 - 1.0;
float time = iTime * speed;
float2 cometPos = float2(sin(time) * 0.5, cos(time * 0.7) * 0.3);
float3 col = float3(0.01, 0.01, 0.02);
float stars = step(0.997, fract(sin(dot(floor(uv * 100.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.4;
float2 velocity = float2(cos(time), -sin(time * 0.7) * 0.7);
velocity = normalize(velocity);
float2 toComet = p - cometPos;
float along = dot(toComet, -velocity);
float perp = length(toComet - along * (-velocity));
float dustTail = smoothstep(tailWidth, 0.0, perp);
dustTail *= smoothstep(0.0, tailLength, along);
dustTail *= smoothstep(tailLength * 1.5, tailLength * 0.5, along);
dustTail *= dustAmount;
float3 dustColor = float3(0.8, 0.7, 0.5);
col += dustTail * dustColor;
if (ionTail > 0.5) {
    float2 ionDir = velocity + float2(0.2, 0.5);
    ionDir = normalize(ionDir);
    float ionAlong = dot(toComet, -ionDir);
    float ionPerp = length(toComet - ionAlong * (-ionDir));
    float ionTailShape = smoothstep(tailWidth * 0.3, 0.0, ionPerp);
    ionTailShape *= smoothstep(0.0, tailLength * 0.8, ionAlong);
    ionTailShape *= smoothstep(tailLength, tailLength * 0.3, ionAlong);
    col += ionTailShape * float3(0.3, 0.5, 1.0) * 0.7;
}
float comet = smoothstep(cometSize, cometSize * 0.5, length(toComet));
float coma = exp(-length(toComet) / cometSize * 2.0);
col += comet * float3(1.0, 1.0, 1.0);
col += coma * float3(0.8, 0.9, 1.0) * 0.5;
return float4(col, 1.0);
"""

/// Dark Energy Field
let darkEnergyCode = """
// @param fieldDensity "Gęstość pola" range(2.0, 10.0) default(5.0)
// @param flowSpeed "Prędkość przepływu" range(0.1, 2.0) default(0.5)
// @param waveAmplitude "Amplituda fali" range(0.1, 1.0) default(0.4)
// @param darkIntensity "Intensywność ciemności" range(0.0, 1.0) default(0.5)
// @param energyBursts "Wybuchy energii" range(0.0, 1.0) default(0.3)
// @toggle voidRift "Szczelina próżni" default(false)
float2 p = uv * fieldDensity;
float time = iTime * flowSpeed;
float field = 0.0;
field += sin(p.x + time) * sin(p.y * 1.3 + time * 0.7);
field += sin(p.x * 1.5 - time * 0.5) * sin(p.y + time * 1.2) * 0.5;
field += sin((p.x + p.y) * 0.7 + time * 0.3) * 0.3;
field = field * waveAmplitude;
float3 darkColor = float3(0.05, 0.02, 0.1);
float3 energyColor = float3(0.3, 0.1, 0.5);
float3 col = mix(darkColor, energyColor, field * 0.5 + 0.5);
col *= (1.0 - darkIntensity * 0.5);
if (energyBursts > 0.0) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float2 burstPos = float2(fract(sin(fi * 127.1 + floor(time)) * 43758.5453),
                                  fract(sin(fi * 311.7 + floor(time)) * 43758.5453));
        float burstPhase = fract(time + fi * 0.2);
        float burst = exp(-length(uv - burstPos) / (burstPhase * 0.3 + 0.01));
        burst *= (1.0 - burstPhase);
        col += burst * float3(0.5, 0.3, 1.0) * energyBursts;
    }
}
if (voidRift > 0.5) {
    float2 riftP = uv - 0.5;
    float rift = smoothstep(0.02, 0.0, abs(riftP.x + sin(riftP.y * 10.0 + time * 2.0) * 0.05));
    rift *= smoothstep(0.5, 0.0, abs(riftP.y));
    col *= (1.0 - rift * 0.8);
    col += rift * float3(0.1, 0.0, 0.2);
}
return float4(col, 1.0);
"""

/// Cosmic String
let cosmicStringCode = """
// @param stringCurvature "Krzywizna struny" range(0.5, 3.0) default(1.5)
// @param stringThickness "Grubość struny" range(0.01, 0.1) default(0.03)
// @param oscillationSpeed "Prędkość oscylacji" range(0.1, 3.0) default(1.0)
// @param glowRadius "Promień poświaty" range(0.1, 0.5) default(0.2)
// @param warpStrength "Siła zniekształcenia" range(0.0, 0.3) default(0.1)
// @toggle quantumFoam "Piana kwantowa" default(true)
float2 p = uv * 2.0 - 1.0;
float stringY = sin(p.x * stringCurvature * 3.14159 + iTime * oscillationSpeed) * 0.5;
stringY += sin(p.x * stringCurvature * 6.28 - iTime * oscillationSpeed * 1.5) * 0.2;
float distToString = abs(p.y - stringY);
if (warpStrength > 0.0) {
    float warp = exp(-distToString / glowRadius) * warpStrength;
    p.y += (p.y - stringY) * warp;
}
float3 col = float3(0.02, 0.02, 0.03);
if (quantumFoam > 0.5) {
    float foam = fract(sin(dot(floor(uv * 50.0 + iTime), float2(12.9898, 78.233))) * 43758.5453);
    foam = step(0.95, foam) * 0.1;
    col += foam;
}
float stringCore = smoothstep(stringThickness, 0.0, distToString);
float3 stringColor = float3(1.0, 0.9, 0.7);
col += stringCore * stringColor;
float glow = exp(-distToString / glowRadius);
float3 glowColor = float3(0.5, 0.3, 0.8);
col += glow * glowColor * 0.5;
float energy = sin(p.x * 20.0 - iTime * 5.0) * 0.5 + 0.5;
energy *= stringCore;
col += energy * float3(0.3, 0.5, 1.0) * 0.5;
return float4(col, 1.0);
"""

/// Gravitational Lensing
let gravitationalLensingCode = """
// @param lensStrength "Siła soczewki" range(0.1, 1.0) default(0.5)
// @param lensRadius "Promień soczewki" range(0.1, 0.5) default(0.3)
// @param einsteinRing "Pierścień Einsteina" range(0.0, 1.0) default(0.5)
// @param backgroundComplexity "Złożoność tła" range(1.0, 5.0) default(3.0)
// @param distortionSmooth "Gładkość zniekształcenia" range(0.1, 1.0) default(0.5)
// @toggle showLens "Pokaż soczewkę" default(false)
float2 p = uv * 2.0 - 1.0;
float2 lensCenter = float2(0.0, 0.0);
float r = length(p - lensCenter);
float2 distortedP = p;
if (r < lensRadius + 0.3) {
    float strength = lensStrength * exp(-r / distortionSmooth);
    float2 toCenter = normalize(p - lensCenter);
    distortedP = p + toCenter * strength * (lensRadius - r);
}
float2 bgP = distortedP * backgroundComplexity + 10.0;
float bg = sin(bgP.x) * sin(bgP.y);
bg += sin(bgP.x * 1.7 + iTime) * sin(bgP.y * 1.3) * 0.5;
bg = bg * 0.5 + 0.5;
float3 col = 0.5 + 0.5 * cos(bg * 3.14 + float3(0.0, 2.0, 4.0));
col *= 0.3;
float stars = step(0.99, fract(sin(dot(floor(distortedP * 30.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars * 0.8;
if (einsteinRing > 0.0) {
    float ring = smoothstep(0.03, 0.0, abs(r - lensRadius * 1.2));
    ring *= smoothstep(lensRadius, lensRadius * 1.5, r);
    col += ring * float3(1.0, 0.9, 0.7) * einsteinRing;
}
if (showLens > 0.5) {
    float lens = smoothstep(lensRadius + 0.02, lensRadius, r);
    col = mix(col, float3(0.0, 0.0, 0.0), lens * 0.8);
}
return float4(col, 1.0);
"""

/// Neutron Star Surface
let neutronStarCode = """
// @param magneticPoles "Bieguny magnetyczne" range(0.1, 0.5) default(0.2)
// @param surfaceTemp "Temperatura powierzchni" range(0.0, 1.0) default(0.7)
// @param rotationSpeed "Prędkość rotacji" range(0.5, 5.0) default(2.0)
// @param pulseIntensity "Intensywność pulsu" range(0.0, 1.0) default(0.5)
// @param crustPattern "Wzór skorupy" range(2.0, 10.0) default(5.0)
// @toggle xrayBurst "Rozbłysk rentgenowski" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x) + iTime * rotationSpeed;
float3 col = float3(0.02, 0.02, 0.03);
float surface = smoothstep(0.52, 0.48, r);
float3 surfaceColor = mix(float3(0.8, 0.4, 0.2), float3(1.0, 0.9, 0.8), surfaceTemp);
float crust = sin(a * crustPattern + r * 10.0) * sin(r * 15.0 - iTime);
crust = crust * 0.5 + 0.5;
surfaceColor *= (0.8 + crust * 0.2);
col += surface * surfaceColor;
float pole1 = exp(-length(p - float2(0.0, 0.4)) / magneticPoles);
float pole2 = exp(-length(p - float2(0.0, -0.4)) / magneticPoles);
float pulse = sin(iTime * 10.0) * 0.5 + 0.5;
pulse = pow(pulse, 4.0) * pulseIntensity;
col += (pole1 + pole2) * float3(0.5, 0.7, 1.0) * (0.5 + pulse);
if (xrayBurst > 0.5) {
    float burst = sin(iTime * 20.0) * 0.5 + 0.5;
    burst = step(0.95, burst);
    col += burst * float3(1.0, 1.0, 1.0) * surface;
}
float atmosphere = smoothstep(0.6, 0.5, r) - surface;
col += atmosphere * float3(0.3, 0.4, 0.6) * 0.5;
return float4(col, 1.0);
"""

/// Event Horizon
let eventHorizonCode = """
// @param holeSize "Rozmiar horyzontu" range(0.1, 0.4) default(0.25)
// @param diskIntensity "Intensywność dysku" range(0.3, 1.0) default(0.7)
// @param rotationSpeed "Prędkość rotacji" range(0.5, 3.0) default(1.0)
// @param lensingStrength "Siła soczewkowania" range(0.0, 0.5) default(0.2)
// @param hawkingRadiation "Promieniowanie Hawkinga" range(0.0, 1.0) default(0.3)
// @toggle photonSphere "Sfera fotonowa" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.01, 0.01, 0.02);
// Gravitational lensing effect
float2 lensedP = p;
if (r > holeSize && r < 1.0) {
    float lensing = lensingStrength / (r - holeSize + 0.1);
    lensedP = p * (1.0 + lensing * 0.1);
}
// Accretion disk
float diskAngle = atan2(lensedP.y, lensedP.x) + iTime * rotationSpeed;
float diskR = length(lensedP);
float diskMask = smoothstep(holeSize + 0.05, holeSize + 0.15, diskR);
diskMask *= smoothstep(0.6, 0.4, diskR);
diskMask *= smoothstep(0.1, 0.0, abs(lensedP.y / (diskR + 0.01)) - 0.3);
float diskSpiral = sin(diskAngle * 8.0 + diskR * 20.0 - iTime * 3.0) * 0.5 + 0.5;
float3 diskColor = mix(float3(1.0, 0.6, 0.2), float3(1.0, 0.9, 0.7), diskSpiral);
col += diskMask * diskColor * diskIntensity;
// Photon sphere
if (photonSphere > 0.5) {
    float photonR = holeSize * 1.5;
    float photon = smoothstep(0.03, 0.0, abs(r - photonR));
    col += photon * float3(0.8, 0.9, 1.0) * 0.5;
}
// Event horizon (pure black)
float horizon = smoothstep(holeSize + 0.01, holeSize, r);
col *= (1.0 - horizon);
// Hawking radiation
if (hawkingRadiation > 0.0) {
    float radiation = smoothstep(holeSize + 0.02, holeSize, r);
    radiation *= sin(a * 20.0 + iTime * 10.0) * 0.5 + 0.5;
    col += radiation * float3(0.5, 0.5, 1.0) * hawkingRadiation * 0.3;
}
return float4(col, 1.0);
"""

