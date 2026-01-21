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
// @param arcCount "Liczba łuków" range(1, 8) default(3)
// @param arcThickness "Grubość łuku" range(0.01, 0.05) default(0.02)
// @param jitterAmount "Drżenie" range(0.0, 0.2) default(0.1)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.7)
// @param branchChance "Szansa rozgałęzienia" range(0.0, 0.5) default(0.2)
// @toggle animated "Animowany" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
for (int arc = 0; arc < 8; arc++) {
    if (arc >= int(arcCount)) break;
    float fa = float(arc);
    float2 start = float2(-0.8, (fa / float(arcCount) - 0.5) * 1.5);
    float2 end = float2(0.8, (fa / float(arcCount) - 0.5) * 1.5 + sin(iTime + fa) * 0.2);
    float segments = 20.0;
    float t = (p.x - start.x) / (end.x - start.x);
    if (t >= 0.0 && t <= 1.0) {
        float baseY = mix(start.y, end.y, t);
        float jitter = 0.0;
        for (int j = 1; j < 8; j++) {
            float fj = float(j);
            float freq = pow(2.0, fj);
            float timeOffset = animated > 0.5 ? iTime * (5.0 + fj) : fa;
            jitter += sin(t * freq * 10.0 + timeOffset) * jitterAmount / freq;
        }
        float arcY = baseY + jitter;
        float d = abs(p.y - arcY);
        float arcLine = smoothstep(arcThickness, 0.0, d);
        float glow = exp(-d * 20.0) * glowIntensity;
        float3 arcColor = float3(0.5, 0.7, 1.0);
        col += arcLine * arcColor;
        col += glow * arcColor * 0.5;
        if (branchChance > 0.0) {
            float branchSeed = fract(sin(t * 100.0 + fa) * 43758.5453);
            if (branchSeed < branchChance) {
                float branchY = arcY + (branchSeed - branchChance * 0.5) * 0.3;
                float branchD = abs(p.y - branchY) + abs(p.x - (start.x + t * (end.x - start.x))) * 2.0;
                float branch = smoothstep(arcThickness * 0.5, 0.0, branchD);
                col += branch * arcColor * 0.5;
            }
        }
    }
}
return float4(col, 1.0);
"""

/// Plasma Ball
let plasmaBallCode = """
// @param streamCount "Liczba strumieni" range(3, 12) default(6)
// @param streamWidth "Szerokość strumienia" range(0.02, 0.1) default(0.04)
// @param coreSize "Rozmiar rdzenia" range(0.1, 0.3) default(0.15)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.5)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 3.0) default(1.0)
// @toggle touchPoint "Punkt dotyku" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.0, 0.03);
float sphere = smoothstep(0.95, 0.9, r);
col = mix(col, float3(0.05, 0.02, 0.08), sphere);
float sphereEdge = smoothstep(0.02, 0.0, abs(r - 0.9));
col += sphereEdge * float3(0.3, 0.2, 0.4);
for (int i = 0; i < 12; i++) {
    if (i >= int(streamCount)) break;
    float fi = float(i);
    float streamAngle = fi * 6.28318 / float(streamCount) + iTime * rotationSpeed;
    float2 streamDir = float2(cos(streamAngle), sin(streamAngle));
    float2 touchPos = touchPoint > 0.5 ? float2(0.5, 0.3) : streamDir * 0.8;
    float2 toP = p;
    float streamT = dot(toP, streamDir);
    if (streamT > 0.0) {
        float perpDist = length(toP - streamDir * streamT);
        float noise = sin(streamT * 20.0 + iTime * 5.0 + fi * 10.0) * turbulence * 0.05;
        perpDist += noise;
        float streamD = smoothstep(streamWidth, 0.0, perpDist);
        streamD *= smoothstep(0.9, coreSize, streamT);
        float3 streamColor = mix(float3(0.8, 0.4, 1.0), float3(0.4, 0.6, 1.0), streamT);
        col += streamD * streamColor * 0.4;
        float glow = exp(-perpDist * 10.0) * 0.2;
        col += glow * streamColor * sphere;
    }
}
float core = smoothstep(coreSize + 0.02, coreSize, r);
float corePulse = 0.8 + 0.2 * sin(iTime * 3.0);
col += core * float3(0.8, 0.6, 1.0) * corePulse;
float coreGlow = exp(-r / coreSize * 2.0);
col += coreGlow * float3(0.5, 0.3, 0.8) * 0.3;
return float4(col, 1.0);
"""

/// Shockwave
let shockwaveCode = """
// @param waveCount "Liczba fal" range(1, 5) default(3)
// @param waveSpeed "Prędkość fali" range(0.5, 3.0) default(1.5)
// @param waveThickness "Grubość fali" range(0.02, 0.15) default(0.05)
// @param distortionAmount "Zniekształcenie" range(0.0, 0.3) default(0.1)
// @param fadeDistance "Zanikanie" range(0.5, 1.5) default(1.0)
// @toggle colorful "Kolorowy" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05, 0.05, 0.08);
float3 background = 0.5 + 0.5 * cos(uv.xyx * 3.0 + float3(0.0, 2.0, 4.0));
col = mix(col, background * 0.2, 0.3);
for (int w = 0; w < 5; w++) {
    if (w >= int(waveCount)) break;
    float fw = float(w);
    float waveTime = fract(iTime * waveSpeed * 0.3 + fw * 0.3);
    float waveRadius = waveTime * fadeDistance * 1.5;
    float2 center = float2(sin(fw * 2.0) * 0.2, cos(fw * 3.0) * 0.2);
    float r = length(p - center);
    float wave = abs(r - waveRadius);
    float waveMask = smoothstep(waveThickness, 0.0, wave);
    waveMask *= 1.0 - waveTime;
    if (distortionAmount > 0.0) {
        float2 distortedUV = uv;
        float distort = smoothstep(waveThickness * 2.0, 0.0, wave) * distortionAmount;
        distortedUV += normalize(p - center) * distort * (1.0 - waveTime);
        float3 distortedBg = 0.5 + 0.5 * cos(distortedUV.xyx * 3.0 + float3(0.0, 2.0, 4.0));
        col = mix(col, distortedBg * 0.5, distort * 2.0);
    }
    float3 waveColor;
    if (colorful > 0.5) {
        waveColor = 0.5 + 0.5 * cos(fw * 1.5 + waveTime * 3.0 + float3(0.0, 2.0, 4.0));
    } else {
        waveColor = float3(1.0, 0.9, 0.8);
    }
    col += waveMask * waveColor;
    float glow = exp(-wave * 10.0) * (1.0 - waveTime) * 0.3;
    col += glow * waveColor;
}
return float4(col, 1.0);
"""

/// Tornado Vortex
let tornadoVortexCode = """
// @param vortexIntensity "Intensywność wiru" range(1.0, 5.0) default(3.0)
// @param debrisAmount "Ilość gruzu" range(0.0, 1.0) default(0.5)
// @param funnelWidth "Szerokość leja" range(0.1, 0.4) default(0.2)
// @param rotationSpeed "Prędkość rotacji" range(1.0, 5.0) default(2.0)
// @param dustOpacity "Przezroczystość pyłu" range(0.0, 1.0) default(0.4)
// @toggle lightning "Błyskawice" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.4, 0.35, 0.3);
float cloudNoise = sin(uv.x * 5.0 + iTime * 0.2) * sin(uv.y * 3.0) * 0.1;
col += cloudNoise;
float funnelY = (p.y + 1.0) * 0.5;
float funnelRadius = funnelWidth * (1.0 - funnelY * 0.7);
float funnelDist = abs(p.x) - funnelRadius;
float funnel = smoothstep(0.05, 0.0, funnelDist);
funnel *= step(p.y, 0.8);
float twist = atan2(p.x, funnelY + 0.1) + iTime * rotationSpeed;
float spiral = sin(twist * vortexIntensity + funnelY * 10.0) * 0.5 + 0.5;
float3 funnelColor = mix(float3(0.3, 0.25, 0.2), float3(0.15, 0.12, 0.1), spiral);
col = mix(col, funnelColor, funnel * 0.8);
if (debrisAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float debrisAngle = fi * 0.5 + iTime * rotationSpeed * (0.8 + fract(sin(fi) * 0.4));
        float debrisY = fract(fi * 0.123 + iTime * 0.3) * 1.5 - 0.5;
        float debrisRadius = funnelWidth * (1.0 - (debrisY + 0.5) * 0.4) * (1.0 + sin(fi) * 0.3);
        float2 debrisPos = float2(sin(debrisAngle) * debrisRadius, debrisY);
        float d = length(p - debrisPos);
        float debris = smoothstep(0.02, 0.01, d) * debrisAmount;
        col = mix(col, float3(0.2, 0.15, 0.1), debris);
    }
}
float dust = smoothstep(funnelRadius + 0.2, funnelRadius, abs(p.x)) * dustOpacity;
dust *= step(p.y, 0.5) * (1.0 - funnelY);
col = mix(col, float3(0.5, 0.45, 0.4), dust * 0.5);
if (lightning > 0.5) {
    float flash = step(0.98, sin(iTime * 10.0 + sin(iTime * 50.0) * 5.0));
    col += flash * float3(1.0, 0.95, 0.9) * 0.3;
}
return float4(col, 1.0);
"""

/// Magnetic Field
let magneticFieldCode = """
// @param fieldStrength "Siła pola" range(1.0, 5.0) default(2.5)
// @param lineCount "Liczba linii" range(10, 50) default(25)
// @param particleSpeed "Prędkość cząstek" range(0.5, 3.0) default(1.5)
// @param poleDistance "Odległość biegunów" range(0.3, 0.8) default(0.5)
// @param lineThickness "Grubość linii" range(0.005, 0.02) default(0.008)
// @toggle particles "Cząstki" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float2 pole1 = float2(-poleDistance, 0.0);
float2 pole2 = float2(poleDistance, 0.0);
for (int i = 0; i < 50; i++) {
    if (i >= int(lineCount)) break;
    float fi = float(i);
    float startAngle = (fi / float(lineCount)) * 3.14159;
    float2 fieldPos = pole1 + float2(cos(startAngle), sin(startAngle)) * 0.1;
    for (int step = 0; step < 50; step++) {
        float2 dir1 = normalize(fieldPos - pole1);
        float2 dir2 = normalize(pole2 - fieldPos);
        float dist1 = length(fieldPos - pole1);
        float dist2 = length(fieldPos - pole2);
        float2 fieldDir = dir1 / (dist1 * dist1) * fieldStrength + dir2 / (dist2 * dist2) * fieldStrength;
        fieldDir = normalize(fieldDir);
        float2 nextPos = fieldPos + fieldDir * 0.03;
        float d = length(p - fieldPos);
        float line = smoothstep(lineThickness, 0.0, d);
        col += line * float3(0.3, 0.5, 0.8) * 0.1;
        fieldPos = nextPos;
        if (length(fieldPos - pole2) < 0.1) break;
        if (length(fieldPos) > 1.5) break;
    }
}
float poleGlow1 = exp(-length(p - pole1) * 5.0);
float poleGlow2 = exp(-length(p - pole2) * 5.0);
col += poleGlow1 * float3(1.0, 0.3, 0.3);
col += poleGlow2 * float3(0.3, 0.3, 1.0);
if (particles > 0.5) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float particleT = fract(iTime * particleSpeed * 0.1 + fi * 0.05);
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
return float4(col, 1.0);
"""

/// Energy Beam
let energyBeamCode = """
// @param beamWidth "Szerokość wiązki" range(0.05, 0.3) default(0.15)
// @param beamIntensity "Intensywność" range(0.5, 2.0) default(1.0)
// @param noiseAmount "Szum" range(0.0, 0.2) default(0.05)
// @param pulseFrequency "Częstotliwość pulsacji" range(1.0, 10.0) default(5.0)
// @param coreRatio "Stosunek rdzenia" range(0.1, 0.5) default(0.3)
// @toggle horizontal "Poziomy" default(true)
float2 p = uv * 2.0 - 1.0;
if (horizontal < 0.5) {
    p = p.yx;
}
float3 col = float3(0.02, 0.02, 0.05);
float beamY = 0.0;
float noise = sin(p.x * 30.0 + iTime * 5.0) * sin(p.x * 50.0 + iTime * 8.0) * noiseAmount;
float distToBeam = abs(p.y - beamY - noise);
float beam = smoothstep(beamWidth, 0.0, distToBeam);
float core = smoothstep(beamWidth * coreRatio, 0.0, distToBeam);
float pulse = 0.7 + 0.3 * sin(p.x * 10.0 - iTime * pulseFrequency);
float3 outerColor = float3(0.3, 0.5, 1.0);
float3 innerColor = float3(0.8, 0.9, 1.0);
col += beam * outerColor * pulse * beamIntensity;
col += core * innerColor * beamIntensity;
float glow = exp(-distToBeam * 5.0) * 0.5;
col += glow * outerColor * beamIntensity;
float sparkle = step(0.99, fract(sin(dot(floor(p * 50.0 + iTime * 10.0), float2(12.9898, 78.233))) * 43758.5453));
sparkle *= beam;
col += sparkle * float3(1.0);
return float4(col, 1.0);
"""

/// Quantum Fluctuation
let quantumFluctuationCode = """
// @param fluctuationScale "Skala fluktuacji" range(5.0, 30.0) default(15.0)
// @param probabilityDensity "Gęstość prawdopodobieństwa" range(0.3, 1.0) default(0.6)
// @param waveFunctionSpeed "Prędkość funkcji falowej" range(0.5, 3.0) default(1.5)
// @param entanglementStrength "Siła splątania" range(0.0, 1.0) default(0.5)
// @param colorPhase "Faza koloru" range(0.0, 6.28) default(0.0)
// @toggle interference "Interferencja" default(true)
float2 p = uv * fluctuationScale;
float time = iTime * waveFunctionSpeed;
float3 col = float3(0.02, 0.02, 0.05);
float psi1 = sin(p.x + time) * sin(p.y * 1.3 + time * 0.7);
float psi2 = sin(p.x * 1.5 - time * 0.8) * sin(p.y * 0.8 - time);
float probability = psi1 * psi1 + psi2 * psi2;
probability = probability * 0.25 * probabilityDensity;
if (interference > 0.5) {
    float interf = psi1 * psi2;
    probability += interf * 0.3;
}
if (entanglementStrength > 0.0) {
    float entangle = sin(p.x * 2.0 + p.y * 2.0 + time * 2.0);
    entangle *= sin(fluctuationScale - p.x * 2.0 + fluctuationScale - p.y * 2.0 + time * 2.0);
    probability += entangle * entanglementStrength * 0.2;
}
float3 color1 = 0.5 + 0.5 * cos(probability * 5.0 + colorPhase + float3(0.0, 2.0, 4.0));
float3 color2 = 0.5 + 0.5 * cos(probability * 7.0 + colorPhase + float3(4.0, 2.0, 0.0));
col = mix(color1, color2, sin(time + p.x * 0.1) * 0.5 + 0.5);
col *= probability * 2.0 + 0.1;
float uncertainty = fract(sin(dot(p + time, float2(12.9898, 78.233))) * 43758.5453);
col += step(0.997, uncertainty) * float3(1.0, 0.9, 0.8);
return float4(col, 1.0);
"""

/// Fire Whirl
let fireWhirlCode = """
// @param whirlSpeed "Prędkość wiru" range(0.5, 4.0) default(2.0)
// @param flameHeight "Wysokość płomieni" range(0.5, 1.5) default(1.0)
// @param spiralTightness "Ciasność spirali" range(1.0, 5.0) default(2.5)
// @param emberCount "Ilość iskier" range(0.0, 1.0) default(0.5)
// @param heatDistortion "Zniekształcenie cieplne" range(0.0, 0.1) default(0.03)
// @toggle smokeTrail "Ślad dymu" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.05, 0.02, 0.01);
float distort = sin(a * 5.0 + iTime * 3.0) * heatDistortion;
float2 dp = p + float2(distort, distort * 0.5);
float spiral = a + r * spiralTightness - iTime * whirlSpeed;
float flame = sin(spiral * 3.0) * 0.5 + 0.5;
flame *= smoothstep(0.6, 0.0, r);
flame *= (1.0 - dp.y * 0.5 / flameHeight);
flame = max(0.0, flame);
float height = 1.0 - r * 0.5 - (1.0 - dp.y) * 0.3;
height = clamp(height, 0.0, 1.0);
float3 fireColor = mix(float3(1.0, 0.9, 0.3), float3(1.0, 0.3, 0.0), 1.0 - height);
fireColor = mix(fireColor, float3(0.8, 0.1, 0.0), pow(1.0 - height, 2.0));
col = mix(col, fireColor, flame);
if (smokeTrail > 0.5) {
    float smoke = smoothstep(0.3, 0.8, dp.y + r * 0.5);
    smoke *= smoothstep(0.8, 0.3, r);
    float smokeNoise = sin(dp.x * 10.0 + iTime * 2.0) * sin(dp.y * 8.0 + iTime) * 0.5 + 0.5;
    col = mix(col, float3(0.2, 0.18, 0.15) * smokeNoise, smoke * 0.5);
}
if (emberCount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float emberA = fi * 0.5 + iTime * whirlSpeed;
        float emberR = fract(sin(fi * 43.758) * 43758.5453) * 0.5;
        float emberY = fract(fi * 0.123 + iTime * 0.5) * flameHeight * 1.5;
        float2 emberPos = float2(sin(emberA) * emberR, emberY - 0.5);
        float d = length(p - emberPos);
        float ember = smoothstep(0.015, 0.005, d) * emberCount;
        col += ember * float3(1.0, 0.6, 0.2);
    }
}
return float4(col, 1.0);
"""

/// Cyberpunk Grid
let cyberpunkGridCode = """
// @param gridSize "Rozmiar siatki" range(5.0, 20.0) default(10.0)
// @param perspectiveStrength "Siła perspektywy" range(0.0, 1.0) default(0.5)
// @param scanlineSpeed "Prędkość linii skanowania" range(0.0, 3.0) default(1.0)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @param chromaShift "Przesunięcie chromatyczne" range(0.0, 0.02) default(0.005)
// @toggle neonPulse "Neonowy puls" default(true)
float2 p = uv;
p.y = pow(p.y, 1.0 + perspectiveStrength);
float3 col = float3(0.02, 0.01, 0.05);
float2 gridP = p * gridSize;
float2 gridF = fract(gridP);
float gridLineX = smoothstep(0.05, 0.0, abs(gridF.x - 0.5) - 0.45);
float gridLineY = smoothstep(0.05, 0.0, abs(gridF.y - 0.5) - 0.45);
float grid = max(gridLineX, gridLineY);
float depth = 1.0 - uv.y;
grid *= depth;
float3 gridColor = float3(1.0, 0.0, 0.5);
if (neonPulse > 0.5) {
    float pulse = 0.7 + 0.3 * sin(iTime * 3.0 + gridP.y * 0.5);
    gridColor *= pulse;
}
col += grid * gridColor;
col += grid * glowAmount * gridColor * 0.5;
if (chromaShift > 0.0) {
    float2 pR = uv - float2(chromaShift, 0.0);
    float2 pB = uv + float2(chromaShift, 0.0);
    pR.y = pow(pR.y, 1.0 + perspectiveStrength);
    pB.y = pow(pB.y, 1.0 + perspectiveStrength);
    float gridR = max(
        smoothstep(0.05, 0.0, abs(fract(pR.x * gridSize) - 0.5) - 0.45),
        smoothstep(0.05, 0.0, abs(fract(pR.y * gridSize) - 0.5) - 0.45)
    );
    float gridB = max(
        smoothstep(0.05, 0.0, abs(fract(pB.x * gridSize) - 0.5) - 0.45),
        smoothstep(0.05, 0.0, abs(fract(pB.y * gridSize) - 0.5) - 0.45)
    );
    col.r += gridR * (1.0 - uv.y) * 0.3;
    col.b += gridB * (1.0 - uv.y) * 0.3;
}
if (scanlineSpeed > 0.0) {
    float scanline = fract(uv.y * 50.0 - iTime * scanlineSpeed);
    scanline = smoothstep(0.0, 0.1, scanline) * smoothstep(0.2, 0.1, scanline);
    col += scanline * float3(0.0, 1.0, 1.0) * 0.1;
}
float horizon = smoothstep(0.02, 0.0, abs(uv.y - 0.3));
col += horizon * float3(1.0, 0.0, 0.5) * 0.5;
return float4(col, 1.0);
"""

/// Holographic Display
let holographicDisplayCode = """
// @param scanSpeed "Prędkość skanowania" range(0.5, 3.0) default(1.5)
// @param flickerAmount "Migotanie" range(0.0, 0.5) default(0.1)
// @param staticNoise "Szum statyczny" range(0.0, 0.3) default(0.1)
// @param transparency "Przezroczystość" range(0.3, 1.0) default(0.7)
// @param colorShift "Przesunięcie kolorów" range(0.0, 1.0) default(0.3)
// @toggle dataStreams "Strumienie danych" default(true)
float2 p = uv;
float3 col = float3(0.0);
float scanLine = fract(p.y * 100.0 - iTime * scanSpeed * 10.0);
scanLine = step(0.5, scanLine) * 0.1;
float shape = smoothstep(0.3, 0.25, abs(p.x - 0.5)) * smoothstep(0.4, 0.35, abs(p.y - 0.5));
float3 holoColor = float3(0.0, 0.8, 1.0);
holoColor = mix(holoColor, float3(0.0, 1.0, 0.5), p.y * colorShift);
float flicker = 1.0 - flickerAmount * step(0.95, fract(sin(iTime * 50.0) * 43758.5453));
float noise = fract(sin(dot(p + iTime, float2(12.9898, 78.233))) * 43758.5453);
noise = step(1.0 - staticNoise, noise) * staticNoise;
col = holoColor * shape * transparency * flicker;
col += scanLine * holoColor * shape;
col += noise * float3(0.0, 0.5, 0.5);
if (dataStreams > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float streamX = fract(fi * 0.2 + 0.1);
        float streamY = fract(iTime * 0.5 + fi * 0.3);
        float2 streamPos = float2(streamX, streamY);
        float d = length((p - streamPos) * float2(1.0, 10.0));
        float stream = smoothstep(0.05, 0.02, d);
        col += stream * float3(0.0, 1.0, 0.8) * 0.3;
    }
}
float edge = smoothstep(0.28, 0.25, abs(p.x - 0.5)) - smoothstep(0.25, 0.22, abs(p.x - 0.5));
edge += smoothstep(0.38, 0.35, abs(p.y - 0.5)) - smoothstep(0.35, 0.32, abs(p.y - 0.5));
col += edge * holoColor * 0.5;
return float4(col, 1.0);
"""

// MARK: - Experimental Shaders

/// Dimensional Rift
let dimensionalRiftCode = """
// @param riftWidth "Szerokość szczeliny" range(0.05, 0.3) default(0.1)
// @param edgeDistortion "Zniekształcenie krawędzi" range(0.0, 0.2) default(0.08)
// @param innerGlow "Wewnętrzna poświata" range(0.0, 1.0) default(0.7)
// @param dimensionBleed "Przenikanie wymiarów" range(0.0, 0.5) default(0.2)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.5)
// @toggle alternateReality "Alternatywna rzeczywistość" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float riftY = sin(p.y * 5.0 + iTime) * edgeDistortion;
float riftDist = abs(p.x - riftY) - riftWidth;
riftDist += sin(p.y * 20.0 + iTime * 3.0) * turbulence * 0.03;
float rift = smoothstep(0.0, -0.05, riftDist);
float edge = smoothstep(0.05, 0.0, abs(riftDist));
float3 riftColor = float3(0.5, 0.0, 0.8);
float3 edgeColor = float3(1.0, 0.5, 1.0);
float innerPulse = 0.5 + 0.5 * sin(iTime * 2.0 + p.y * 3.0);
col += rift * riftColor * innerGlow * innerPulse;
col += edge * edgeColor;
float glow = exp(-abs(riftDist) * 5.0) * 0.5;
col += glow * riftColor;
if (alternateReality > 0.5 && rift > 0.0) {
    float2 altP = p;
    altP.x = -altP.x;
    altP.y += iTime * 0.2;
    float3 altWorld = 0.5 + 0.5 * cos(altP.xyx * 3.0 + iTime + float3(0.0, 2.0, 4.0));
    altWorld = 1.0 - altWorld;
    col = mix(col, altWorld, rift * 0.7);
}
if (dimensionBleed > 0.0) {
    float bleed = smoothstep(riftWidth + dimensionBleed, riftWidth, abs(p.x - riftY));
    float3 bleedColor = 0.5 + 0.5 * cos(p.y * 5.0 + iTime + float3(2.0, 0.0, 4.0));
    col = mix(col, bleedColor * 0.3, bleed * dimensionBleed);
}
return float4(col, 1.0);
"""

/// Neural Synapse
let neuralSynapseCode = """
// @param synapseCount "Liczba synaps" range(5, 20) default(10)
// @param signalSpeed "Prędkość sygnału" range(0.5, 3.0) default(1.5)
// @param dendriteBranching "Rozgałęzienia dendrytów" range(2, 6) default(4)
// @param neurotransmitterDensity "Gęstość neuroprzekaźników" range(0.0, 1.0) default(0.5)
// @param potentialThreshold "Próg potencjału" range(0.3, 0.8) default(0.5)
// @toggle actionPotential "Potencjał czynnościowy" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.03, 0.05);
for (int s = 0; s < 20; s++) {
    if (s >= int(synapseCount)) break;
    float fs = float(s);
    float2 neuron1 = float2(
        sin(fs * 1.7) * 0.4 - 0.3,
        cos(fs * 2.3) * 0.4
    );
    float2 neuron2 = float2(
        sin(fs * 1.7 + 1.0) * 0.4 + 0.3,
        cos(fs * 2.3 + 1.0) * 0.4
    );
    float2 synapseCenter = (neuron1 + neuron2) * 0.5;
    float2 dir = normalize(neuron2 - neuron1);
    float len = length(neuron2 - neuron1);
    float2 toP = p - neuron1;
    float t = clamp(dot(toP, dir) / len, 0.0, 1.0);
    float2 closest = neuron1 + dir * t * len;
    float d = length(p - closest);
    float axon = smoothstep(0.015, 0.008, d);
    col += axon * float3(0.2, 0.3, 0.4);
    if (actionPotential > 0.5) {
        float signal = fract(t - iTime * signalSpeed + fs * 0.2);
        float potential = step(potentialThreshold, sin(iTime * 5.0 + fs * 2.0) * 0.5 + 0.5);
        signal = smoothstep(0.0, 0.1, signal) * smoothstep(0.2, 0.1, signal);
        col += axon * signal * potential * float3(0.5, 1.0, 0.8);
    }
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
        col += branch * float3(0.15, 0.2, 0.3);
    }
}
if (neurotransmitterDensity > 0.0) {
    for (int n = 0; n < 50; n++) {
        float fn = float(n);
        float2 ntPos = float2(
            fract(sin(fn * 127.1 + iTime * 0.5) * 43758.5453) * 2.0 - 1.0,
            fract(sin(fn * 311.7 + iTime * 0.3) * 43758.5453) * 2.0 - 1.0
        );
        float d = length(p - ntPos);
        float nt = smoothstep(0.01, 0.005, d) * neurotransmitterDensity;
        col += nt * float3(0.3, 0.8, 0.5);
    }
}
return float4(col, 1.0);
"""

/// Data Visualization
let dataVisualizationCode = """
// @param barCount "Liczba słupków" range(5, 30) default(15)
// @param dataSpeed "Prędkość danych" range(0.5, 3.0) default(1.0)
// @param smoothness "Gładkość" range(0.0, 1.0) default(0.5)
// @param colorScheme "Schemat kolorów" range(0.0, 6.28) default(0.0)
// @param barWidth "Szerokość słupków" range(0.5, 0.95) default(0.8)
// @toggle reflection "Odbicie" default(true)
float2 p = uv;
float3 col = float3(0.05, 0.05, 0.08);
float barW = 1.0 / float(barCount);
int barIndex = int(p.x / barW);
float barX = (float(barIndex) + 0.5) * barW;
float barLocalX = (p.x - float(barIndex) * barW) / barW;
float hash = fract(sin(float(barIndex) * 127.1 + floor(iTime * dataSpeed) * 43.758) * 43758.5453);
float nextHash = fract(sin(float(barIndex) * 127.1 + floor(iTime * dataSpeed + 1.0) * 43.758) * 43758.5453);
float barHeight = mix(hash, nextHash, smoothstep(0.0, 1.0, fract(iTime * dataSpeed) * smoothness + (1.0 - smoothness) * step(0.5, fract(iTime * dataSpeed))));
barHeight = barHeight * 0.7 + 0.1;
float barMask = step(abs(barLocalX - 0.5), barWidth * 0.5);
barMask *= step(p.y, barHeight);
barMask *= step(0.0, p.y);
float3 barColor = 0.5 + 0.5 * cos(float(barIndex) * 0.5 + colorScheme + float3(0.0, 2.0, 4.0));
col = mix(col, barColor, barMask);
float topGlow = smoothstep(0.02, 0.0, abs(p.y - barHeight)) * barMask;
col += topGlow * float3(1.0) * 0.3;
if (reflection > 0.5) {
    float refY = -p.y;
    float refMask = step(abs(barLocalX - 0.5), barWidth * 0.5);
    refMask *= step(refY, barHeight);
    refMask *= step(0.0, refY);
    refMask *= step(p.y, 0.0);
    float refFade = 1.0 + p.y * 3.0;
    col += barColor * refMask * refFade * 0.3;
}
float grid = step(0.98, fract(p.y * 10.0));
col += grid * float3(0.1, 0.1, 0.15);
return float4(col, 1.0);
"""

/// Time Warp
let timeWarpCode = """
// @param warpIntensity "Intensywność zakrzywienia" range(0.0, 1.0) default(0.5)
// @param spiralSpeed "Prędkość spirali" range(0.5, 3.0) default(1.0)
// @param colorCycles "Cykle kolorów" range(1.0, 5.0) default(2.0)
// @param centerPull "Przyciąganie środka" range(0.0, 1.0) default(0.3)
// @param echoCount "Liczba ech" range(1, 5) default(3)
// @toggle reverse "Odwróć" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.02, 0.05);
float direction = reverse > 0.5 ? -1.0 : 1.0;
float timeOffset = iTime * spiralSpeed * direction;
for (int echo = 0; echo < 5; echo++) {
    if (echo >= int(echoCount)) break;
    float fe = float(echo);
    float echoDelay = fe * 0.3;
    float warpedR = r + sin(a * 3.0 + timeOffset - echoDelay) * warpIntensity * 0.2;
    warpedR += sin(r * 10.0 - timeOffset + echoDelay) * warpIntensity * 0.1;
    float warpedA = a + sin(r * 5.0 + timeOffset - echoDelay) * warpIntensity * 0.5;
    warpedA += centerPull * (1.0 - r) * sin(timeOffset);
    float pattern = sin(warpedA * colorCycles + warpedR * 10.0 - timeOffset);
    pattern = pattern * 0.5 + 0.5;
    float3 echoColor = 0.5 + 0.5 * cos(pattern * 6.28 + fe * 1.5 + float3(0.0, 2.0, 4.0));
    float echoFade = 1.0 / (1.0 + fe * 0.5);
    col += echoColor * pattern * echoFade * 0.3;
}
float center = exp(-r * 3.0) * centerPull;
float centerPulse = 0.5 + 0.5 * sin(timeOffset * 2.0);
col += center * float3(1.0, 0.8, 0.5) * centerPulse;
float trail = sin(a * 10.0 - r * 20.0 + timeOffset * 3.0);
trail = smoothstep(0.8, 1.0, trail) * (1.0 - r);
col += trail * float3(0.3, 0.5, 0.8) * 0.3;
return float4(col, 1.0);
"""

/// Pixel Sorting
let pixelSortingCode = """
// @param sortThreshold "Próg sortowania" range(0.0, 1.0) default(0.5)
// @param sortDirection "Kierunek sortowania" range(0.0, 1.0) default(0.0)
// @param glitchAmount "Ilość glitchy" range(0.0, 1.0) default(0.3)
// @param colorBands "Pasma kolorów" range(2.0, 10.0) default(5.0)
// @param animationSpeed "Prędkość animacji" range(0.0, 2.0) default(0.5)
// @toggle vertical "Pionowy" default(false)
float2 p = uv;
if (vertical > 0.5) {
    p = p.yx;
}
float3 col = float3(0.0);
float3 baseColor = 0.5 + 0.5 * cos(uv.xyx * 3.0 + iTime * 0.5 + float3(0.0, 2.0, 4.0));
float luminance = dot(baseColor, float3(0.299, 0.587, 0.114));
float threshold = sortThreshold + sin(iTime * animationSpeed + p.y * 5.0) * 0.1;
float sorted = step(threshold, luminance);
float sortOffset = sorted * (p.x - threshold) * sortDirection;
float2 sortedP = p;
sortedP.x = fract(sortedP.x + sortOffset + iTime * animationSpeed * 0.1);
float3 sortedColor = 0.5 + 0.5 * cos(sortedP.xyx * colorBands + float3(0.0, 2.0, 4.0));
col = mix(baseColor, sortedColor, sorted * 0.7);
float band = floor(p.y * colorBands) / colorBands;
float bandColor = fract(band + iTime * animationSpeed * 0.2);
col = mix(col, 0.5 + 0.5 * cos(bandColor * 6.28 + float3(0.0, 2.0, 4.0)), sorted * 0.3);
if (glitchAmount > 0.0) {
    float glitchLine = step(0.98, fract(sin(floor(p.y * 50.0) * 43.758 + floor(iTime * 10.0)) * 43758.5453));
    float glitchOffset = (fract(sin(floor(p.y * 50.0) * 127.1) * 43758.5453) - 0.5) * glitchAmount;
    float2 glitchP = p;
    glitchP.x = fract(glitchP.x + glitchOffset * glitchLine);
    float3 glitchColor = 0.5 + 0.5 * cos(glitchP.xyx * 5.0 + float3(2.0, 0.0, 4.0));
    col = mix(col, glitchColor, glitchLine * glitchAmount);
}
return float4(col, 1.0);
"""

/// Morphing Geometry
let morphingGeometryCode = """
// @param shapeCount "Liczba kształtów" range(3, 8) default(5)
// @param morphSpeed "Prędkość morfowania" range(0.2, 2.0) default(0.5)
// @param blendSoftness "Miękkość mieszania" range(0.1, 0.5) default(0.2)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 2.0) default(0.3)
// @param scaleOscillation "Oscylacja skali" range(0.0, 0.5) default(0.2)
// @toggle fillShapes "Wypełnij kształty" default(true)
float2 p = uv * 2.0 - 1.0;
float angle = iTime * rotationSpeed;
float c = cos(angle);
float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float scale = 1.0 + sin(iTime * 1.5) * scaleOscillation;
p *= scale;
float3 col = float3(0.05, 0.05, 0.08);
float morphPhase = fract(iTime * morphSpeed);
int currentShape = int(floor(iTime * morphSpeed)) % int(shapeCount);
int nextShape = (currentShape + 1) % int(shapeCount);
float currentDist = 10.0;
float nextDist = 10.0;
float r = length(p);
float a = atan2(p.y, p.x);
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
float dist = mix(currentDist, nextDist, smoothstep(0.0, 1.0, morphPhase));
float shape;
if (fillShapes > 0.5) {
    shape = smoothstep(blendSoftness, -blendSoftness, dist);
} else {
    shape = smoothstep(blendSoftness, 0.0, abs(dist));
}
float3 shapeColor = 0.5 + 0.5 * cos(iTime + float(currentShape) + float3(0.0, 2.0, 4.0));
col = mix(col, shapeColor, shape);
float glow = exp(-abs(dist) * 5.0) * 0.5;
col += glow * shapeColor;
return float4(col, 1.0);
"""

/// Audio Spectrum
let audioSpectrumCode = """
// @param barCount "Liczba słupków" range(8, 64) default(32)
// @param barSpacing "Odstępy słupków" range(0.0, 0.5) default(0.2)
// @param reactivity "Reaktywność" range(0.5, 2.0) default(1.0)
// @param peakHold "Trzymanie szczytów" range(0.0, 1.0) default(0.5)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.3)
// @toggle mirrored "Lustrzany" default(true)
float2 p = uv;
if (mirrored > 0.5) {
    p.y = abs(p.y - 0.5) * 2.0;
}
float3 col = float3(0.02, 0.02, 0.05);
float barW = 1.0 / float(barCount);
int barIndex = int(p.x / barW);
float barLocalX = fract(p.x / barW);
float freq = float(barIndex) / float(barCount);
float amplitude = sin(freq * 10.0 + iTime * 3.0) * 0.3 + 0.3;
amplitude += sin(freq * 5.0 - iTime * 2.0) * 0.2;
amplitude *= reactivity;
amplitude = clamp(amplitude, 0.0, 0.9);
float barMask = step(barSpacing * 0.5, barLocalX) * step(barLocalX, 1.0 - barSpacing * 0.5);
barMask *= step(p.y, amplitude);
float3 barColor = mix(float3(0.0, 1.0, 0.5), float3(1.0, 0.5, 0.0), freq);
barColor = mix(barColor, float3(1.0, 0.0, 0.3), step(0.7, p.y / amplitude));
col = mix(col, barColor, barMask);
if (peakHold > 0.0) {
    float peakY = amplitude + 0.02;
    float peak = smoothstep(0.01, 0.0, abs(p.y - peakY)) * barMask;
    col += peak * float3(1.0) * peakHold;
}
if (glowAmount > 0.0) {
    float glow = barMask * glowAmount * 0.5;
    col += glow * barColor;
}
float grid = step(0.99, fract(p.y * 20.0)) * 0.1;
col += grid * float3(0.2, 0.2, 0.3);
return float4(col, 1.0);
"""

/// Fractal Tree Advanced
let fractalTreeAdvancedCode = """
// @param branchDepth "Głębokość gałęzi" range(3, 10) default(7)
// @param branchAngle "Kąt gałęzi" range(0.2, 0.8) default(0.4)
// @param branchRatio "Stosunek gałęzi" range(0.5, 0.8) default(0.67)
// @param windSpeed "Prędkość wiatru" range(0.0, 1.0) default(0.2)
// @param leafDensity "Gęstość liści" range(0.0, 1.0) default(0.5)
// @toggle autumn "Jesień" default(false)
float2 p = uv;
p.x = p.x * 2.0 - 1.0;
p.y = 1.0 - p.y;
float3 col = float3(0.6, 0.8, 0.95);
float3 trunkColor = float3(0.3, 0.2, 0.1);
float3 leafColor = autumn > 0.5 ? float3(0.9, 0.4, 0.1) : float3(0.2, 0.5, 0.2);
float tree = 0.0;
float leaves = 0.0;
float wind = sin(iTime * windSpeed * 2.0) * windSpeed;
float2 pos = float2(0.0, 0.0);
float angle = 1.5708;
float len = 0.25;
float thickness = 0.02;
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
col = mix(col, trunkColor, tree);
col = mix(col, leafColor, leaves);
return float4(col, 1.0);
"""

/// Kaleidoscope Advanced
let kaleidoscopeAdvancedCode = """
// @param segments "Segmenty" range(3, 16) default(8)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 2.0) default(0.5)
// @param zoomSpeed "Prędkość zoomu" range(0.0, 1.0) default(0.3)
// @param colorCycles "Cykle kolorów" range(1.0, 5.0) default(2.0)
// @param patternComplexity "Złożoność wzoru" range(1.0, 5.0) default(3.0)
// @toggle animate "Animuj" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
if (animate > 0.5) {
    a += iTime * rotationSpeed;
}
float segmentAngle = 6.28318 / float(segments);
a = fmod(a + segmentAngle * 0.5, segmentAngle) - segmentAngle * 0.5;
a = abs(a);
float2 kp = float2(cos(a), sin(a)) * r;
if (animate > 0.5) {
    float zoom = 1.0 + sin(iTime * zoomSpeed) * 0.3;
    kp *= zoom;
}
float3 col = float3(0.0);
float pattern1 = sin(kp.x * patternComplexity * 10.0 + iTime) * sin(kp.y * patternComplexity * 8.0 + iTime * 0.7);
float pattern2 = sin(length(kp) * patternComplexity * 15.0 - iTime * 1.5);
float pattern3 = sin(atan2(kp.y, kp.x) * patternComplexity * 3.0 + iTime * 0.5);
float combined = (pattern1 + pattern2 + pattern3) / 3.0;
combined = combined * 0.5 + 0.5;
col = 0.5 + 0.5 * cos(combined * colorCycles * 6.28 + float3(0.0, 2.0, 4.0));
float mandala = smoothstep(0.5, 0.48, fract(r * 5.0 - iTime * 0.2));
col = mix(col, col * 1.3, mandala * 0.3);
float center = exp(-r * 3.0);
col = mix(col, float3(1.0), center * 0.3);
return float4(col, 1.0);
"""

