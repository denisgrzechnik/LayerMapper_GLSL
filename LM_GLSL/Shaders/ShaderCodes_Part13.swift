//
//  ShaderCodes_Part13.swift
//  LM_GLSL
//
//  Shader codes - Part 13: Cyberpunk & Sci-Fi Effects (20 shaders)
//

import Foundation

// MARK: - Cyberpunk & Sci-Fi Effects

/// Neon Grid City
let neonGridCityCode = """
// @param gridDensity "Gęstość siatki" range(5.0, 20.0) default(10.0)
// @param neonIntensity "Intensywność neonu" range(0.5, 2.0) default(1.2)
// @param perspectiveAmount "Perspektywa" range(0.0, 1.0) default(0.7)
// @param scrollSpeed "Prędkość przewijania" range(0.0, 2.0) default(0.5)
// @param colorCycle "Cykl kolorów" range(0.0, 2.0) default(1.0)
// @toggle buildings "Budynki" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.08);
float horizon = 0.4;
if (p.y < horizon) {
    float perspective = pow((horizon - p.y) / horizon, perspectiveAmount + 0.5);
    float2 gridP = float2(p.x - 0.5, perspective);
    gridP.y += iTime * scrollSpeed;
    float gridX = smoothstep(0.02, 0.0, abs(fract(gridP.x * gridDensity) - 0.5) - 0.45);
    float gridY = smoothstep(0.02, 0.0, abs(fract(gridP.y * gridDensity * 0.5) - 0.5) - 0.45);
    float grid = max(gridX, gridY);
    float3 gridColor = 0.5 + 0.5 * cos(iTime * colorCycle + float3(0.0, 2.0, 4.0));
    col += grid * gridColor * neonIntensity * (1.0 - perspective * 0.5);
}
if (buildings > 0.5 && p.y > horizon - 0.1) {
    for (int i = 0; i < 15; i++) {
        float fi = float(i);
        float bx = fract(sin(fi * 127.1) * 43758.5453);
        float bw = fract(sin(fi * 311.7) * 43758.5453) * 0.05 + 0.02;
        float bh = fract(sin(fi * 178.3) * 43758.5453) * 0.3 + 0.1;
        float building = step(abs(p.x - bx), bw) * step(horizon, p.y) * step(p.y, horizon + bh);
        col = mix(col, float3(0.05, 0.05, 0.1), building);
        float windowY = floor((p.y - horizon) * 30.0);
        float windowX = floor((p.x - bx + bw) * 50.0);
        float window = step(0.5, fract(sin(windowX * 127.1 + windowY * 311.7 + fi) * 43758.5453));
        window *= building;
        float3 windowColor = 0.5 + 0.5 * cos(fi + float3(0.0, 2.0, 4.0));
        col += window * windowColor * 0.3 * neonIntensity;
    }
}
float glow = smoothstep(horizon + 0.1, horizon - 0.1, p.y);
col += glow * float3(1.0, 0.2, 0.5) * 0.2 * neonIntensity;
return float4(col, 1.0);
"""

/// Holographic Interface
let holographicInterfaceCode = """
// @param elementCount "Liczba elementów" range(3, 10) default(6)
// @param scanlineSpeed "Prędkość linii skanowania" range(0.5, 3.0) default(1.5)
// @param glitchAmount "Ilość glitchy" range(0.0, 0.3) default(0.1)
// @param transparency "Przezroczystość" range(0.3, 0.8) default(0.5)
// @param flickerRate "Częstotliwość migotania" range(0.0, 1.0) default(0.2)
// @toggle hexGrid "Siatka heksagonalna" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.05, 0.08);
float scanline = fract(p.y * 100.0 - iTime * scanlineSpeed);
scanline = step(0.9, scanline) * 0.1;
col += scanline * float3(0.0, 0.5, 1.0);
if (hexGrid > 0.5) {
    float2 hexP = p * 20.0;
    float2 hexCell = floor(hexP);
    float hex = smoothstep(0.1, 0.05, length(fract(hexP) - 0.5) - 0.3);
    col += hex * float3(0.0, 0.3, 0.5) * transparency * 0.3;
}
for (int i = 0; i < 10; i++) {
    if (i >= int(elementCount)) break;
    float fi = float(i);
    float2 elemPos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1,
        fract(sin(fi * 311.7) * 43758.5453) * 0.8 + 0.1
    );
    float elemSize = fract(sin(fi * 178.3) * 43758.5453) * 0.1 + 0.05;
    float elem = smoothstep(elemSize + 0.01, elemSize, length(p - elemPos));
    elem -= smoothstep(elemSize - 0.01, elemSize - 0.02, length(p - elemPos));
    float flicker = 1.0;
    if (flickerRate > 0.0) {
        flicker = step(flickerRate, fract(sin(iTime * 10.0 + fi * 5.0) * 0.5 + 0.5));
    }
    float3 elemColor = 0.5 + 0.5 * cos(fi * 0.5 + float3(4.0, 2.0, 0.0));
    col += elem * elemColor * transparency * flicker;
}
if (glitchAmount > 0.0) {
    float glitch = step(1.0 - glitchAmount, fract(sin(floor(iTime * 20.0) * 43.758) * 43758.5453));
    if (glitch > 0.5) {
        float offset = (fract(sin(floor(p.y * 20.0) * 78.233) * 43758.5453) - 0.5) * 0.1;
        col = mix(col, col.gbr, 0.5);
    }
}
col *= transparency + 0.5;
return float4(col, 1.0);
"""

/// Data Matrix
let dataMatrixCode = """
// @param columnDensity "Gęstość kolumn" range(10.0, 50.0) default(25.0)
// @param fallSpeed "Prędkość spadania" range(0.5, 3.0) default(1.5)
// @param charBrightness "Jasność znaków" range(0.5, 2.0) default(1.0)
// @param trailLength "Długość smugi" range(0.1, 0.5) default(0.3)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @toggle colorful "Kolorowy" default(false)
float2 p = uv;
float3 col = float3(0.02, 0.05, 0.02);
float columnWidth = 1.0 / columnDensity;
for (int c = 0; c < 50; c++) {
    float fc = float(c);
    if (fc >= columnDensity) break;
    float columnX = fc * columnWidth + columnWidth * 0.5;
    float columnSpeed = fract(sin(fc * 127.1) * 43758.5453) * 0.5 + 0.75;
    float columnOffset = fract(sin(fc * 311.7) * 43758.5453);
    float streamY = fract(iTime * fallSpeed * columnSpeed + columnOffset);
    float dist = abs(p.x - columnX);
    if (dist < columnWidth * 0.5) {
        float charY = fract(p.y * 20.0);
        float charCell = floor(p.y * 20.0);
        float charChange = floor(iTime * 10.0 + charCell * 0.5 + fc);
        float charPattern = fract(sin(charChange * 43.758 + fc * 78.233) * 43758.5453);
        float char = step(0.3, charPattern) * step(charPattern, 0.7);
        char *= step(charY, 0.8);
        float relY = 1.0 - p.y;
        float streamDist = relY - streamY;
        float trail = smoothstep(0.0, trailLength, streamDist) * smoothstep(trailLength + 0.1, trailLength, streamDist);
        float head = smoothstep(0.02, 0.0, abs(streamDist));
        float3 charColor;
        if (colorful > 0.5) {
            charColor = 0.5 + 0.5 * cos(fc * 0.3 + iTime + float3(0.0, 2.0, 4.0));
        } else {
            charColor = float3(0.3, 1.0, 0.4);
        }
        col += char * trail * charColor * charBrightness * 0.5;
        col += head * float3(0.8, 1.0, 0.9) * charBrightness;
        if (glowAmount > 0.0) {
            float glow = exp(-dist / columnWidth * 3.0) * trail * glowAmount;
            col += glow * charColor * 0.3;
        }
    }
}
return float4(col, 1.0);
"""

/// Force Field
let forceFieldCode = """
// @param fieldRadius "Promień pola" range(0.2, 0.6) default(0.4)
// @param hexSize "Rozmiar sześciokątów" range(0.02, 0.1) default(0.05)
// @param pulseSpeed "Prędkość pulsu" range(0.5, 3.0) default(1.5)
// @param distortionAmount "Zniekształcenie" range(0.0, 0.3) default(0.1)
// @param energyFlow "Przepływ energii" range(0.0, 1.0) default(0.6)
// @toggle impactEffect "Efekt uderzenia" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float r = length(p);
float a = atan2(p.y, p.x);
float fieldMask = smoothstep(fieldRadius + 0.05, fieldRadius, r);
fieldMask -= smoothstep(fieldRadius - 0.02, fieldRadius - 0.05, r);
float2 hexP = p * (1.0 / hexSize);
float2 hexGrid = floor(hexP);
float hexPattern = 0.0;
for (int hx = -1; hx <= 1; hx++) {
    for (int hy = -1; hy <= 1; hy++) {
        float2 cell = hexGrid + float2(hx, hy);
        float2 cellCenter = cell + 0.5;
        float d = length(hexP - cellCenter);
        hexPattern = max(hexPattern, smoothstep(0.5, 0.4, d));
    }
}
float pulse = sin(r * 20.0 - iTime * pulseSpeed * 5.0) * 0.5 + 0.5;
pulse *= energyFlow;
float3 fieldColor = mix(float3(0.0, 0.5, 1.0), float3(0.0, 1.0, 1.0), pulse);
col += fieldMask * hexPattern * fieldColor * 0.8;
col += fieldMask * (1.0 - hexPattern) * fieldColor * 0.2;
if (impactEffect > 0.5) {
    float impactTime = fract(iTime * 0.5);
    float2 impactPos = float2(cos(floor(iTime * 0.5) * 2.0), sin(floor(iTime * 0.5) * 3.0)) * fieldRadius * 0.8;
    float impactDist = length(p - impactPos);
    float impact = smoothstep(impactTime * 0.3, 0.0, impactDist) * (1.0 - impactTime);
    impact *= fieldMask;
    col += impact * float3(1.0, 0.8, 0.3);
    float ripple = sin(impactDist * 30.0 - impactTime * 20.0) * (1.0 - impactTime);
    ripple *= smoothstep(0.3, 0.0, impactDist) * fieldMask;
    col += ripple * float3(0.5, 0.8, 1.0) * 0.3;
}
float edge = smoothstep(fieldRadius, fieldRadius - 0.01, r) - smoothstep(fieldRadius - 0.01, fieldRadius - 0.02, r);
col += edge * float3(0.3, 0.6, 1.0);
return float4(col, 1.0);
"""

/// Warp Drive
let warpDriveCode = """
// @param starDensity "Gęstość gwiazd" range(50.0, 200.0) default(100.0)
// @param warpSpeed "Prędkość warp" range(1.0, 5.0) default(2.5)
// @param streakLength "Długość smug" range(0.1, 0.5) default(0.3)
// @param tunnelWidth "Szerokość tunelu" range(0.1, 0.5) default(0.3)
// @param colorTemperature "Temperatura barwowa" range(0.0, 1.0) default(0.5)
// @toggle hyperspace "Nadprzestrzeń" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
for (int i = 0; i < 200; i++) {
    if (float(i) >= starDensity) break;
    float fi = float(i);
    float starAngle = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
    float starDist = fract(sin(fi * 311.7) * 43758.5453 + iTime * warpSpeed * 0.2);
    float2 starPos = float2(cos(starAngle), sin(starAngle)) * starDist * (1.0 - tunnelWidth) + tunnelWidth;
    starPos = float2(cos(starAngle), sin(starAngle)) * (tunnelWidth + starDist * (1.0 - tunnelWidth));
    float2 prevPos = float2(cos(starAngle), sin(starAngle)) * (tunnelWidth + (starDist - streakLength * warpSpeed * 0.05) * (1.0 - tunnelWidth));
    float2 toP = p - starPos;
    float2 streakDir = normalize(starPos - prevPos);
    float along = dot(toP, -streakDir);
    float perp = abs(dot(toP, float2(streakDir.y, -streakDir.x)));
    float streak = smoothstep(streakLength * starDist, 0.0, along) * step(0.0, along);
    streak *= smoothstep(0.02, 0.005, perp);
    streak *= smoothstep(0.0, 0.1, starDist);
    float3 starColor;
    if (hyperspace > 0.5) {
        starColor = 0.5 + 0.5 * cos(fi * 0.1 + iTime + float3(0.0, 2.0, 4.0));
    } else {
        starColor = mix(float3(0.8, 0.9, 1.0), float3(1.0, 0.9, 0.7), colorTemperature);
    }
    col += streak * starColor;
}
float tunnel = smoothstep(tunnelWidth, tunnelWidth - 0.05, r);
if (hyperspace > 0.5) {
    float3 tunnelColor = 0.5 + 0.5 * cos(r * 10.0 + iTime * 3.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, tunnelColor * 0.3, tunnel);
}
return float4(col, 1.0);
"""

/// Cyber Brain
let cyberBrainCode = """
// @param neuronDensity "Gęstość neuronów" range(10, 30) default(20)
// @param synapseSpeed "Prędkość synaps" range(0.5, 3.0) default(1.5)
// @param pulseRate "Częstotliwość pulsów" range(0.5, 3.0) default(1.0)
// @param connectionStrength "Siła połączeń" range(0.3, 1.0) default(0.6)
// @param glowRadius "Promień poświaty" range(0.02, 0.1) default(0.05)
// @toggle activeThought "Aktywna myśl" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.03, 0.05);
float2 neurons[30];
for (int i = 0; i < 30; i++) {
    float fi = float(i);
    neurons[i] = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0,
        fract(sin(fi * 311.7) * 43758.5453) * 2.0 - 1.0
    ) * 0.8;
}
for (int i = 0; i < 30; i++) {
    if (i >= int(neuronDensity)) break;
    for (int j = i + 1; j < 30; j++) {
        if (j >= int(neuronDensity)) break;
        float fi = float(i);
        float fj = float(j);
        float dist = length(neurons[i] - neurons[j]);
        if (dist < 0.6 * connectionStrength) {
            float2 dir = normalize(neurons[j] - neurons[i]);
            float2 toP = p - neurons[i];
            float along = dot(toP, dir);
            float perp = abs(dot(toP, float2(-dir.y, dir.x)));
            float connection = step(0.0, along) * step(along, dist);
            connection *= smoothstep(0.01, 0.003, perp);
            float signal = fract((along / dist - iTime * synapseSpeed + fi * 0.1) * 3.0);
            signal = smoothstep(0.0, 0.1, signal) * smoothstep(0.2, 0.1, signal);
            col += connection * float3(0.0, 0.3, 0.5) * 0.3;
            col += connection * signal * float3(0.0, 0.8, 1.0);
        }
    }
}
for (int i = 0; i < 30; i++) {
    if (i >= int(neuronDensity)) break;
    float fi = float(i);
    float d = length(p - neurons[i]);
    float neuron = smoothstep(0.02, 0.01, d);
    float pulse = sin(iTime * pulseRate * 5.0 + fi * 2.0) * 0.3 + 0.7;
    float3 neuronColor = float3(0.2, 0.6, 0.8);
    col += neuron * neuronColor * pulse;
    float glow = exp(-d / glowRadius) * 0.5;
    col += glow * float3(0.0, 0.4, 0.6);
}
if (activeThought > 0.5) {
    float thoughtPhase = fract(iTime * 0.3);
    int thoughtNeuron = int(floor(iTime * 0.3 * float(neuronDensity))) % int(neuronDensity);
    float d = length(p - neurons[thoughtNeuron]);
    float thought = exp(-d * 10.0) * (1.0 - thoughtPhase);
    col += thought * float3(1.0, 0.8, 0.3);
}
return float4(col, 1.0);
"""

/// Laser Scan
let laserScanCode = """
// @param scanSpeed "Prędkość skanowania" range(0.5, 3.0) default(1.5)
// @param lineCount "Liczba linii" range(1, 5) default(2)
// @param lineWidth "Szerokość linii" range(0.01, 0.05) default(0.02)
// @param glowIntensity "Intensywność blasku" range(0.5, 2.0) default(1.0)
// @param scanPattern "Wzór skanowania" range(0.0, 2.0) default(0.0)
// @toggle gridOverlay "Nakładka siatki" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.05);
if (gridOverlay > 0.5) {
    float gridX = smoothstep(0.01, 0.0, abs(fract(p.x * 20.0) - 0.5) - 0.48);
    float gridY = smoothstep(0.01, 0.0, abs(fract(p.y * 20.0) - 0.5) - 0.48);
    col += (gridX + gridY) * float3(0.0, 0.1, 0.15);
}
for (int i = 0; i < 5; i++) {
    if (i >= int(lineCount)) break;
    float fi = float(i);
    float offset = fi / float(lineCount);
    float scanPos;
    if (scanPattern < 1.0) {
        scanPos = fract(iTime * scanSpeed * 0.5 + offset);
    } else if (scanPattern < 2.0) {
        scanPos = abs(fract(iTime * scanSpeed * 0.25 + offset) * 2.0 - 1.0);
    } else {
        scanPos = fract(iTime * scanSpeed * 0.5 + offset + sin(iTime + fi) * 0.1);
    }
    float scanDist = abs(p.y - scanPos);
    float scan = smoothstep(lineWidth, 0.0, scanDist);
    float3 scanColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 2.0, 4.0));
    col += scan * scanColor * glowIntensity;
    float glow = exp(-scanDist * 30.0) * glowIntensity;
    col += glow * scanColor * 0.3;
    float particle = smoothstep(0.01, 0.0, scanDist) * step(0.95, fract(p.x * 50.0 + iTime * 10.0));
    col += particle * float3(1.0);
}
return float4(col, 1.0);
"""

/// Tractor Beam
let tractorBeamCode = """
// @param beamWidth "Szerokość wiązki" range(0.1, 0.4) default(0.2)
// @param ringSpeed "Prędkość pierścieni" range(0.5, 3.0) default(1.5)
// @param ringCount "Liczba pierścieni" range(5, 20) default(10)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @param particleDensity "Gęstość cząstek" range(0.0, 1.0) default(0.5)
// @toggle active "Aktywny" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float2 beamTop = float2(0.0, 1.0);
float2 beamBottom = float2(0.0, -0.8);
float beamT = (p.y - beamBottom.y) / (beamTop.y - beamBottom.y);
beamT = clamp(beamT, 0.0, 1.0);
float currentWidth = beamWidth * (1.0 - beamT * 0.5);
float beamDist = abs(p.x) - currentWidth * (1.0 - beamT);
float beam = smoothstep(0.05, 0.0, beamDist);
beam *= step(beamBottom.y, p.y);
if (active > 0.5) {
    for (int i = 0; i < 20; i++) {
        if (i >= int(ringCount)) break;
        float fi = float(i);
        float ringY = fract(fi / float(ringCount) - iTime * ringSpeed * 0.5);
        ringY = beamBottom.y + ringY * (beamTop.y - beamBottom.y);
        float ringWidth = beamWidth * (1.0 - (ringY - beamBottom.y) / (beamTop.y - beamBottom.y) * 0.5);
        float ringDist = abs(p.y - ringY);
        float ring = smoothstep(0.03, 0.01, ringDist);
        ring *= step(abs(p.x), ringWidth);
        col += ring * float3(0.3, 0.8, 1.0) * intensity * 0.5;
    }
}
col += beam * float3(0.0, 0.4, 0.6) * intensity * 0.5;
float edge = smoothstep(0.02, 0.0, abs(beamDist)) * step(beamBottom.y, p.y);
col += edge * float3(0.0, 0.8, 1.0) * intensity;
if (particleDensity > 0.0 && active > 0.5) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float px = (fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0) * beamWidth;
        float py = fract(sin(fi * 311.7) * 43758.5453 - iTime * ringSpeed * 0.3);
        py = beamBottom.y + py * (beamTop.y - beamBottom.y);
        float d = length(p - float2(px * (1.0 - (py - beamBottom.y) / (beamTop.y - beamBottom.y) * 0.5), py));
        float particle = smoothstep(0.02, 0.01, d) * particleDensity;
        col += particle * float3(0.5, 0.9, 1.0);
    }
}
return float4(col, 1.0);
"""

/// Quantum Tunnel
let quantumTunnelCode = """
// @param tunnelSpeed "Prędkość tunelu" range(0.5, 3.0) default(1.5)
// @param waveFrequency "Częstotliwość fal" range(5.0, 20.0) default(10.0)
// @param colorShift "Przesunięcie kolorów" range(0.0, 2.0) default(1.0)
// @param probability "Prawdopodobieństwo" range(0.3, 1.0) default(0.7)
// @param entanglement "Splątanie" range(0.0, 1.0) default(0.5)
// @toggle superposition "Superpozycja" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float tunnel = fract(log(r + 0.001) * 2.0 - iTime * tunnelSpeed);
float wave = sin(tunnel * waveFrequency * 6.28 + a * 3.0) * 0.5 + 0.5;
float probWave = pow(wave, 1.0 / probability);
float3 tunnelColor = 0.5 + 0.5 * cos(tunnel * 3.0 + colorShift * iTime + float3(0.0, 2.0, 4.0));
col += probWave * tunnelColor * (1.0 - tunnel * 0.5);
if (superposition > 0.5) {
    float tunnel2 = fract(log(r + 0.001) * 2.0 - iTime * tunnelSpeed + 0.5);
    float wave2 = sin(tunnel2 * waveFrequency * 6.28 - a * 3.0) * 0.5 + 0.5;
    float3 color2 = 0.5 + 0.5 * cos(tunnel2 * 3.0 + colorShift * iTime + 3.14 + float3(0.0, 2.0, 4.0));
    col += wave2 * color2 * (1.0 - tunnel2 * 0.5) * 0.5;
}
if (entanglement > 0.0) {
    float entangle = sin(a * 8.0 + iTime * 3.0) * sin(r * 20.0 - iTime * tunnelSpeed * 5.0);
    entangle = entangle * 0.5 + 0.5;
    col += entangle * float3(1.0, 0.5, 0.8) * entanglement * 0.3;
}
col *= smoothstep(0.0, 0.1, r);
return float4(col, 1.0);
"""

/// Cyberpunk Rain
let cyberpunkRainCode = """
// @param rainDensity "Gęstość deszczu" range(20.0, 80.0) default(40.0)
// @param rainSpeed "Prędkość deszczu" range(1.0, 4.0) default(2.0)
// @param neonReflection "Odbicia neonów" range(0.0, 1.0) default(0.6)
// @param fogAmount "Ilość mgły" range(0.0, 0.5) default(0.2)
// @param colorVariety "Różnorodność kolorów" range(0.0, 1.0) default(0.5)
// @toggle wetSurface "Mokra powierzchnia" default(true)
float2 p = uv;
float3 col = float3(0.05, 0.05, 0.1);
float3 neonColors[4];
neonColors[0] = float3(1.0, 0.1, 0.5);
neonColors[1] = float3(0.1, 0.8, 1.0);
neonColors[2] = float3(0.0, 1.0, 0.5);
neonColors[3] = float3(1.0, 0.5, 0.0);
float neonGlow = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float neonY = 0.7 + fract(sin(fi * 127.1) * 43758.5453) * 0.2;
    float neonX = fract(sin(fi * 311.7) * 43758.5453);
    float d = length(p - float2(neonX, neonY));
    float glow = exp(-d * 5.0) * neonReflection;
    col += glow * neonColors[i] * 0.3;
}
for (int i = 0; i < 80; i++) {
    if (float(i) >= rainDensity) break;
    float fi = float(i);
    float rx = fract(sin(fi * 127.1) * 43758.5453);
    float ry = fract(sin(fi * 311.7) * 43758.5453 + iTime * rainSpeed);
    float2 rainPos = float2(rx, 1.0 - ry);
    float rd = abs(p.x - rainPos.x);
    float rain = smoothstep(0.003, 0.0, rd);
    rain *= step(rainPos.y - 0.05, p.y) * step(p.y, rainPos.y);
    int colorIdx = int(fmod(fi, 4.0));
    float3 rainColor = mix(float3(0.6, 0.7, 0.8), neonColors[colorIdx], colorVariety);
    col += rain * rainColor * 0.4;
}
if (wetSurface > 0.5 && p.y < 0.15) {
    float2 reflP = float2(p.x, 0.15 - p.y);
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float neonY = 0.7 + fract(sin(fi * 127.1) * 43758.5453) * 0.2;
        float neonX = fract(sin(fi * 311.7) * 43758.5453);
        float wave = sin(p.x * 50.0 + iTime * 3.0) * 0.01;
        float d = length(reflP + float2(wave, 0.0) - float2(neonX, neonY));
        float refl = exp(-d * 8.0) * neonReflection;
        col += refl * neonColors[i] * 0.2 * (1.0 - p.y / 0.15);
    }
}
if (fogAmount > 0.0) {
    float fog = fogAmount * (1.0 - p.y);
    col = mix(col, float3(0.1, 0.1, 0.15), fog);
}
return float4(col, 1.0);
"""

/// Android Vision
let androidVisionCode = """
// @param scanlineIntensity "Intensywność linii" range(0.0, 0.5) default(0.2)
// @param overlayOpacity "Przezroczystość nakładki" range(0.3, 0.8) default(0.5)
// @param dataSpeed "Prędkość danych" range(0.5, 3.0) default(1.5)
// @param focusX "Fokus X" range(0.0, 1.0) default(0.5)
// @param focusY "Fokus Y" range(0.0, 1.0) default(0.5)
// @toggle targeting "Celownik" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.15, 0.1);
float scanline = sin(p.y * 200.0 + iTime * 5.0) * 0.5 + 0.5;
scanline = 1.0 - scanline * scanlineIntensity;
col *= scanline;
float2 focus = float2(focusX, focusY);
if (targeting > 0.5) {
    float focusDist = length(p - focus);
    float targetRing = smoothstep(0.12, 0.11, focusDist) - smoothstep(0.11, 0.10, focusDist);
    targetRing += smoothstep(0.08, 0.07, focusDist) - smoothstep(0.07, 0.06, focusDist);
    col += targetRing * float3(1.0, 0.3, 0.3);
    float crossV = step(abs(p.x - focus.x), 0.002) * step(abs(p.y - focus.y), 0.05);
    float crossH = step(abs(p.y - focus.y), 0.002) * step(abs(p.x - focus.x), 0.05);
    crossV *= step(0.02, abs(p.y - focus.y));
    crossH *= step(0.02, abs(p.x - focus.x));
    col += (crossV + crossH) * float3(1.0, 0.3, 0.3);
}
float dataBar = step(0.02, p.x) * step(p.x, 0.15);
dataBar *= step(0.1, p.y) * step(p.y, 0.9);
if (dataBar > 0.5) {
    float dataY = floor(p.y * 30.0);
    float dataScroll = floor(iTime * dataSpeed * 10.0);
    float data = fract(sin((dataY + dataScroll) * 43.758) * 43758.5453);
    float bar = step(0.05, p.x) * step(p.x, 0.05 + data * 0.08);
    col += bar * float3(0.0, 0.8, 0.3) * overlayOpacity;
}
float borderH = step(abs(p.y - 0.5), 0.48) - step(abs(p.y - 0.5), 0.47);
float borderV = step(abs(p.x - 0.5), 0.48) - step(abs(p.x - 0.5), 0.47);
float border = max(borderH * step(abs(p.x - 0.5), 0.48), borderV * step(abs(p.y - 0.5), 0.48));
col += border * float3(0.0, 0.5, 0.2) * overlayOpacity;
float corner = 0.0;
float2 corners[4];
corners[0] = float2(0.05, 0.05);
corners[1] = float2(0.95, 0.05);
corners[2] = float2(0.05, 0.95);
corners[3] = float2(0.95, 0.95);
for (int i = 0; i < 4; i++) {
    float cDist = length(p - corners[i]);
    corner += smoothstep(0.03, 0.02, cDist);
}
col += corner * float3(0.0, 0.6, 0.3) * overlayOpacity;
return float4(col, 1.0);
"""

/// Teleporter
let teleporterCode = """
// @param ringCount "Liczba pierścieni" range(3, 10) default(6)
// @param spinSpeed "Prędkość obrotu" range(0.5, 3.0) default(1.5)
// @param particleAmount "Ilość cząstek" range(0.0, 1.0) default(0.6)
// @param energyPulse "Puls energii" range(0.0, 1.0) default(0.5)
// @param convergence "Zbieżność" range(0.0, 1.0) default(0.5)
// @toggle active "Aktywny" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float baseR = 0.3;
for (int i = 0; i < 10; i++) {
    if (i >= int(ringCount)) break;
    float fi = float(i);
    float ringR = baseR + fi * 0.08;
    float spinDir = (int(fi) % 2 == 0) ? 1.0 : -1.0;
    float ringA = a + iTime * spinSpeed * spinDir * (1.0 + fi * 0.2);
    float segments = 8.0 + fi * 2.0;
    float segmentMask = step(0.5, sin(ringA * segments) * 0.5 + 0.5);
    float ring = smoothstep(0.02, 0.01, abs(r - ringR)) * segmentMask;
    float pulse = active > 0.5 ? sin(iTime * 5.0 + fi) * 0.3 + 0.7 : 0.5;
    float3 ringColor = 0.5 + 0.5 * cos(fi * 0.5 + float3(4.0, 2.0, 0.0));
    col += ring * ringColor * pulse;
}
if (active > 0.5 && particleAmount > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float particleA = fract(sin(fi * 127.1) * 43758.5453) * 6.28;
        float particleR = fract(sin(fi * 311.7) * 43758.5453);
        float converge = iTime * 2.0 * convergence + fi * 0.1;
        particleR = fract(particleR - converge * 0.1) * (0.7 - baseR) + baseR;
        float2 particlePos = float2(cos(particleA), sin(particleA)) * particleR;
        float d = length(p - particlePos);
        float particle = smoothstep(0.015, 0.005, d) * particleAmount;
        col += particle * float3(0.5, 0.8, 1.0);
    }
}
if (active > 0.5 && energyPulse > 0.0) {
    float core = smoothstep(baseR, 0.0, r);
    float pulse = sin(iTime * 8.0) * 0.5 + 0.5;
    col += core * float3(0.8, 0.9, 1.0) * pulse * energyPulse;
}
return float4(col, 1.0);
"""

/// Cyber Lock
let cyberLockCode = """
// @param ringCount "Liczba pierścieni" range(2, 6) default(4)
// @param rotationSpeed "Prędkość rotacji" range(0.2, 2.0) default(0.5)
// @param segmentCount "Liczba segmentów" range(4, 16) default(8)
// @param glowIntensity "Intensywność blasku" range(0.5, 2.0) default(1.0)
// @param unlockProgress "Postęp odblokowania" range(0.0, 1.0) default(0.0)
// @toggle locked "Zablokowany" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float3 lockColor = locked > 0.5 ? float3(1.0, 0.2, 0.2) : float3(0.2, 1.0, 0.4);
for (int i = 0; i < 6; i++) {
    if (i >= int(ringCount)) break;
    float fi = float(i);
    float ringR = 0.2 + fi * 0.12;
    float spinDir = (int(fi) % 2 == 0) ? 1.0 : -1.0;
    float ringOffset = fi * 0.5;
    float isUnlocked = step(fi / float(ringCount), unlockProgress);
    float targetAngle = isUnlocked > 0.5 ? 0.0 : ringOffset;
    float ringA = a + iTime * rotationSpeed * spinDir * (1.0 - isUnlocked) + targetAngle;
    float segment = floor((ringA + 3.14159) / (6.28318 / float(segmentCount)));
    float segmentLocal = fract((ringA + 3.14159) / (6.28318 / float(segmentCount)));
    float gap = step(0.1, segmentLocal) * step(segmentLocal, 0.9);
    float ring = smoothstep(0.03, 0.02, abs(r - ringR)) * gap;
    float3 ringColor = mix(lockColor, float3(0.2, 0.6, 1.0), fi / float(ringCount));
    if (isUnlocked > 0.5) ringColor = float3(0.2, 1.0, 0.4);
    col += ring * ringColor * glowIntensity * 0.7;
    float glow = exp(-abs(r - ringR) * 20.0) * gap * 0.3;
    col += glow * ringColor * glowIntensity;
}
float core = smoothstep(0.12, 0.1, r);
float coreGlow = exp(-r * 5.0) * 0.5;
float3 coreColor = unlockProgress >= 1.0 ? float3(0.2, 1.0, 0.4) : lockColor;
col += core * coreColor * glowIntensity;
col += coreGlow * coreColor * glowIntensity;
float icon = 0.0;
if (locked > 0.5 && unlockProgress < 1.0) {
    icon = step(abs(p.x), 0.03) * step(abs(p.y), 0.05);
    icon += step(abs(p.y + 0.02), 0.02) * step(abs(p.x), 0.05);
} else {
    float checkV = step(abs(p.x + 0.02), 0.015) * step(-0.03, p.y) * step(p.y, 0.02);
    float checkD = step(abs(p.x - p.y * 0.5 - 0.01), 0.015) * step(-0.02, p.y) * step(p.y, 0.04);
    icon = max(checkV, checkD);
}
col += icon * float3(1.0) * step(r, 0.08);
return float4(col, 1.0);
"""

/// Energy Core
let energyCoreCode = """
// @param coreSize "Rozmiar rdzenia" range(0.1, 0.3) default(0.2)
// @param pulseSpeed "Prędkość pulsu" range(0.5, 3.0) default(1.5)
// @param rayCount "Liczba promieni" range(4, 16) default(8)
// @param instability "Niestabilność" range(0.0, 0.5) default(0.1)
// @param powerLevel "Poziom mocy" range(0.3, 1.5) default(1.0)
// @toggle overload "Przeciążenie" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float pulse = sin(iTime * pulseSpeed * 5.0) * 0.2 + 0.8;
pulse *= powerLevel;
float jitter = 0.0;
if (instability > 0.0) {
    jitter = sin(iTime * 20.0 + a * 5.0) * instability * 0.05;
}
float currentSize = coreSize * pulse + jitter;
float core = smoothstep(currentSize, currentSize * 0.5, r);
float3 coreColor = overload > 0.5 ? float3(1.0, 0.3, 0.1) : float3(0.3, 0.7, 1.0);
col += core * coreColor * powerLevel;
for (int i = 0; i < 16; i++) {
    if (i >= int(rayCount)) break;
    float fi = float(i);
    float rayAngle = fi / float(rayCount) * 6.28318 + iTime * (overload > 0.5 ? 2.0 : 0.5);
    float rayJitter = sin(iTime * 10.0 + fi * 3.0) * instability;
    float angleDiff = abs(mod(a - rayAngle + 3.14159, 6.28318) - 3.14159);
    float ray = exp(-angleDiff * 10.0);
    ray *= smoothstep(currentSize, currentSize + 0.3 + rayJitter, r);
    ray *= smoothstep(0.8, currentSize + 0.1, r);
    col += ray * coreColor * powerLevel * 0.5;
}
float glow = exp(-r / (coreSize * 2.0)) * powerLevel;
col += glow * coreColor * 0.5;
if (overload > 0.5) {
    float arc = sin(a * 10.0 + iTime * 20.0) * sin(r * 30.0 - iTime * 15.0);
    arc = step(0.9, arc);
    arc *= step(currentSize, r) * step(r, 0.6);
    col += arc * float3(1.0, 0.8, 0.3) * powerLevel;
}
float ring = smoothstep(0.02, 0.01, abs(r - 0.5));
col += ring * coreColor * 0.3 * powerLevel;
return float4(col, 1.0);
"""

/// Mech HUD
let mechHUDCode = """
// @param hudOpacity "Przezroczystość HUD" range(0.3, 1.0) default(0.7)
// @param warningLevel "Poziom ostrzeżenia" range(0.0, 1.0) default(0.0)
// @param radarRange "Zasięg radaru" range(0.1, 0.3) default(0.2)
// @param targetCount "Liczba celów" range(0, 5) default(2)
// @param systemStatus "Status systemu" range(0.0, 1.0) default(1.0)
// @toggle combatMode "Tryb bojowy" default(false)
float2 p = uv;
float3 col = float3(0.05, 0.08, 0.05);
float3 hudColor = combatMode > 0.5 ? float3(1.0, 0.3, 0.2) : float3(0.2, 1.0, 0.4);
float3 warningColor = float3(1.0, 0.8, 0.0);
float topBar = step(0.92, p.y) * step(0.05, p.x) * step(p.x, 0.95);
col += topBar * hudColor * hudOpacity * 0.3;
float bottomBar = step(p.y, 0.08) * step(0.05, p.x) * step(p.x, 0.95);
col += bottomBar * hudColor * hudOpacity * 0.3;
float leftBorder = step(p.x, 0.02) * step(0.1, p.y) * step(p.y, 0.9);
float rightBorder = step(0.98, p.x) * step(0.1, p.y) * step(p.y, 0.9);
col += (leftBorder + rightBorder) * hudColor * hudOpacity;
float2 radarCenter = float2(0.15, 0.15);
float radarDist = length(p - radarCenter);
float radar = smoothstep(radarRange + 0.01, radarRange, radarDist);
radar -= smoothstep(radarRange - 0.01, radarRange - 0.02, radarDist);
col += radar * hudColor * hudOpacity;
float sweep = smoothstep(0.02, 0.0, abs(atan2(p.y - radarCenter.y, p.x - radarCenter.x) - fract(iTime * 0.5) * 6.28 + 3.14));
sweep *= step(radarDist, radarRange);
col += sweep * hudColor * hudOpacity * 0.5;
for (int i = 0; i < 5; i++) {
    if (i >= int(targetCount)) break;
    float fi = float(i);
    float2 targetPos = radarCenter + float2(
        sin(iTime + fi * 2.0) * radarRange * 0.6,
        cos(iTime * 0.7 + fi * 2.0) * radarRange * 0.6
    );
    float targetD = length(p - targetPos);
    float target = smoothstep(0.01, 0.005, targetD);
    col += target * float3(1.0, 0.3, 0.3) * hudOpacity;
}
float statusX = 0.85;
float statusY = 0.7;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float barY = statusY - fi * 0.08;
    float barFill = step(fi / 5.0, systemStatus);
    float bar = step(statusX, p.x) * step(p.x, statusX + 0.1);
    bar *= step(barY, p.y) * step(p.y, barY + 0.05);
    float3 barColor = barFill > 0.5 ? hudColor : float3(0.3, 0.3, 0.3);
    col += bar * barColor * hudOpacity * 0.5;
}
if (warningLevel > 0.0) {
    float warning = sin(iTime * 10.0) * 0.5 + 0.5;
    warning *= warningLevel;
    col += warning * warningColor * 0.2;
}
float crosshairV = step(abs(p.x - 0.5), 0.001) * step(abs(p.y - 0.5), 0.05);
float crosshairH = step(abs(p.y - 0.5), 0.001) * step(abs(p.x - 0.5), 0.05);
crosshairV *= step(0.01, abs(p.y - 0.5));
crosshairH *= step(0.01, abs(p.x - 0.5));
col += (crosshairV + crosshairH) * hudColor * hudOpacity;
return float4(col, 1.0);
"""

/// Particle Accelerator
let particleAcceleratorCode = """
// @param ringRadius "Promień pierścienia" range(0.3, 0.5) default(0.4)
// @param particleSpeed "Prędkość cząstek" range(1.0, 5.0) default(3.0)
// @param particleCount "Liczba cząstek" range(2, 10) default(4)
// @param collisionEnergy "Energia kolizji" range(0.0, 1.0) default(0.0)
// @param magnetStrength "Siła magnesu" range(0.5, 2.0) default(1.0)
// @toggle beamOn "Wiązka włączona" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float ring = smoothstep(0.02, 0.01, abs(r - ringRadius));
col += ring * float3(0.2, 0.2, 0.3);
for (int i = -1; i <= 1; i++) {
    float innerR = ringRadius - 0.03 + float(i) * 0.015;
    float detail = smoothstep(0.005, 0.002, abs(r - innerR));
    col += detail * float3(0.1, 0.1, 0.2);
}
if (beamOn > 0.5) {
    for (int i = 0; i < 10; i++) {
        if (i >= int(particleCount)) break;
        float fi = float(i);
        float particleAngle = iTime * particleSpeed + fi * 6.28318 / float(particleCount);
        if (i % 2 == 1) particleAngle = -particleAngle;
        float2 particlePos = float2(cos(particleAngle), sin(particleAngle)) * ringRadius;
        float d = length(p - particlePos);
        float particle = smoothstep(0.03, 0.01, d);
        float3 particleColor = (i % 2 == 0) ? float3(0.3, 0.7, 1.0) : float3(1.0, 0.5, 0.3);
        col += particle * particleColor * magnetStrength;
        float trail = 0.0;
        for (int t = 1; t < 10; t++) {
            float ft = float(t);
            float trailAngle = particleAngle - ft * 0.1 * (i % 2 == 0 ? 1.0 : -1.0);
            float2 trailPos = float2(cos(trailAngle), sin(trailAngle)) * ringRadius;
            trail += smoothstep(0.02, 0.01, length(p - trailPos)) * (1.0 - ft / 10.0);
        }
        col += trail * particleColor * 0.2;
    }
}
if (collisionEnergy > 0.0) {
    float collision = exp(-r * 5.0) * collisionEnergy;
    float burst = sin(iTime * 30.0) * 0.5 + 0.5;
    col += collision * float3(1.0, 0.9, 0.5) * burst;
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float rayAngle = fi * 0.785 + iTime * 2.0;
        float rayDist = abs(sin(a - rayAngle));
        float ray = exp(-rayDist * 10.0) * collisionEnergy * 0.5;
        ray *= smoothstep(0.0, 0.3, r);
        col += ray * float3(1.0, 0.7, 0.3);
    }
}
float glow = exp(-abs(r - ringRadius) * 10.0) * magnetStrength * 0.3;
col += glow * float3(0.3, 0.3, 0.5);
return float4(col, 1.0);
"""

/// Stasis Field
let stasisFieldCode = """
// @param fieldStrength "Siła pola" range(0.3, 1.0) default(0.7)
// @param crystalCount "Liczba kryształów" range(3, 12) default(6)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 1.0) default(0.3)
// @param pulseRate "Częstotliwość pulsu" range(0.5, 3.0) default(1.0)
// @param iceAmount "Ilość lodu" range(0.0, 1.0) default(0.5)
// @toggle frozen "Zamrożony" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.05, 0.08);
float pulse = frozen > 0.5 ? 1.0 : sin(iTime * pulseRate * 3.0) * 0.3 + 0.7;
for (int i = 0; i < 12; i++) {
    if (i >= int(crystalCount)) break;
    float fi = float(i);
    float crystalAngle = fi / float(crystalCount) * 6.28318;
    if (frozen < 0.5) crystalAngle += iTime * rotationSpeed;
    float2 crystalDir = float2(cos(crystalAngle), sin(crystalAngle));
    float2 crystalPos = crystalDir * 0.3;
    float2 toP = p - crystalPos;
    float along = dot(toP, crystalDir);
    float perp = abs(dot(toP, float2(-crystalDir.y, crystalDir.x)));
    float crystal = step(-0.05, along) * step(along, 0.2);
    crystal *= step(perp, 0.02 + (0.2 - along) * 0.1);
    float3 crystalColor = float3(0.5, 0.8, 1.0);
    col += crystal * crystalColor * fieldStrength * pulse;
}
float field = exp(-r * 3.0) * fieldStrength;
col += field * float3(0.3, 0.6, 0.8) * pulse;
float fieldEdge = smoothstep(0.52, 0.48, r) - smoothstep(0.48, 0.44, r);
float edgePattern = sin(a * 20.0 + (frozen > 0.5 ? 0.0 : iTime * 2.0)) * 0.5 + 0.5;
col += fieldEdge * edgePattern * float3(0.4, 0.7, 1.0) * fieldStrength;
if (iceAmount > 0.0) {
    float ice = sin(p.x * 50.0 + p.y * 30.0) * sin(p.x * 30.0 - p.y * 50.0);
    ice = ice * 0.5 + 0.5;
    ice *= smoothstep(0.5, 0.3, r) * iceAmount;
    col += ice * float3(0.6, 0.8, 1.0) * 0.3;
}
if (frozen > 0.5) {
    float frost = sin(r * 100.0) * sin(a * 30.0) * 0.5 + 0.5;
    frost *= fieldStrength * 0.2;
    col += frost * float3(0.8, 0.9, 1.0);
}
return float4(col, 1.0);
"""

/// Alien Script
let alienScriptCode = """
// @param symbolSize "Rozmiar symboli" range(0.05, 0.15) default(0.08)
// @param scrollSpeed "Prędkość przewijania" range(0.1, 1.0) default(0.3)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @param complexity "Złożoność" range(1.0, 3.0) default(2.0)
// @param colorHue "Odcień koloru" range(0.0, 1.0) default(0.5)
// @toggle ancient "Starożytny" default(false)
float2 p = uv;
float3 col = ancient > 0.5 ? float3(0.05, 0.04, 0.02) : float3(0.02, 0.02, 0.05);
float3 glyphColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
if (ancient > 0.5) glyphColor = float3(0.8, 0.6, 0.3);
float gridX = floor(p.x / symbolSize);
float gridY = floor((p.y + iTime * scrollSpeed) / symbolSize);
float2 cellP = float2(
    fract(p.x / symbolSize) - 0.5,
    fract((p.y + iTime * scrollSpeed) / symbolSize) - 0.5
) * 2.0;
float seed = fract(sin(gridX * 127.1 + gridY * 311.7) * 43758.5453);
float symbolType = floor(seed * 5.0);
float symbol = 0.0;
if (symbolType < 1.0) {
    symbol = smoothstep(0.6, 0.5, length(cellP));
    symbol -= smoothstep(0.4, 0.3, length(cellP));
} else if (symbolType < 2.0) {
    float arm1 = step(abs(cellP.x), 0.1) * step(abs(cellP.y), 0.6);
    float arm2 = step(abs(cellP.y), 0.1) * step(abs(cellP.x), 0.6);
    symbol = max(arm1, arm2);
} else if (symbolType < 3.0) {
    float tri = step(abs(cellP.x), 0.6 - abs(cellP.y) * 0.8);
    tri *= step(-0.5, cellP.y) * step(cellP.y, 0.5);
    symbol = tri;
} else if (symbolType < 4.0) {
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float lineY = -0.4 + fi * 0.4;
        symbol += step(abs(cellP.y - lineY), 0.08) * step(abs(cellP.x), 0.5);
    }
    symbol = min(symbol, 1.0);
} else {
    float angle = atan2(cellP.y, cellP.x);
    float spiral = fract(angle / 6.28 + length(cellP) * complexity);
    symbol = step(0.4, spiral) * step(spiral, 0.6);
    symbol *= step(length(cellP), 0.6);
}
col += symbol * glyphColor * 0.8;
if (glowAmount > 0.0) {
    float glow = symbol * glowAmount;
    col += glow * glyphColor * 0.3;
}
if (ancient > 0.5) {
    float crack = sin(p.x * 100.0 + p.y * 80.0) * sin(p.x * 60.0 - p.y * 120.0);
    crack = step(0.95, crack) * 0.1;
    col -= crack;
}
return float4(col, 1.0);
"""

