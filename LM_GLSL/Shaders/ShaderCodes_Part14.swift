//
//  ShaderCodes_Part14.swift
//  LM_GLSL
//
//  Shader codes - Part 14: Mechanical & Industrial Effects (20 shaders)
//

import Foundation

// MARK: - Mechanical & Industrial Effects

/// Clockwork Mechanism
let clockworkMechanismCode = """
// @param gearCount "Liczba kół zębatych" range(3, 8) default(5)
// @param rotationSpeed "Prędkość rotacji" range(0.2, 2.0) default(0.5)
// @param gearSize "Rozmiar kół" range(0.1, 0.3) default(0.2)
// @param teethCount "Liczba zębów" range(8, 24) default(12)
// @param brassiness "Mosiężność" range(0.0, 1.0) default(0.7)
// @toggle ticking "Tykanie" default(false)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05, 0.04, 0.03);
float3 brassColor = mix(float3(0.6, 0.5, 0.3), float3(0.8, 0.6, 0.2), brassiness);
float3 steelColor = float3(0.5, 0.5, 0.55);
float time = ticking > 0.5 ? floor(iTime * 2.0) * 0.5 : iTime;
for (int i = 0; i < 8; i++) {
    if (i >= int(gearCount)) break;
    float fi = float(i);
    float2 gearPos = float2(
        sin(fi * 2.4) * 0.5,
        cos(fi * 2.4) * 0.5
    );
    float gearR = gearSize * (0.8 + fract(sin(fi * 127.1) * 43758.5453) * 0.4);
    float spinDir = (i % 2 == 0) ? 1.0 : -1.0;
    float gearSpeed = rotationSpeed / gearR;
    float2 toP = p - gearPos;
    float r = length(toP);
    float a = atan2(toP.y, toP.x) + time * gearSpeed * spinDir;
    float teeth = sin(a * float(teethCount)) * 0.5 + 0.5;
    float gearShape = smoothstep(gearR + 0.02, gearR, r - teeth * 0.02);
    gearShape -= smoothstep(gearR * 0.3, gearR * 0.25, r);
    float3 gearColor = (i % 2 == 0) ? brassColor : steelColor;
    float shading = 0.7 + teeth * 0.3;
    col += gearShape * gearColor * shading;
    float axle = smoothstep(gearR * 0.15, gearR * 0.1, r);
    col += axle * steelColor * 0.8;
    for (int s = 0; s < 4; s++) {
        float spokeA = float(s) * 1.5708 + time * gearSpeed * spinDir;
        float spokeDist = abs(sin(a - spokeA)) * r;
        float spoke = step(spokeDist, 0.01) * step(gearR * 0.2, r) * step(r, gearR * 0.8);
        col += spoke * gearColor * 0.5;
    }
}
return float4(col, 1.0);
"""

/// Steam Pipes
let steamPipesCode = """
// @param pipeCount "Liczba rur" range(3, 10) default(6)
// @param steamAmount "Ilość pary" range(0.0, 1.0) default(0.5)
// @param pipeRadius "Promień rur" range(0.02, 0.08) default(0.04)
// @param rustAmount "Ilość rdzy" range(0.0, 1.0) default(0.3)
// @param pressureLevel "Ciśnienie" range(0.5, 2.0) default(1.0)
// @toggle leaking "Wycieki" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.08, 0.06);
float3 metalColor = float3(0.4, 0.35, 0.3);
float3 rustColor = float3(0.5, 0.25, 0.1);
float3 steamColor = float3(0.8, 0.8, 0.85);
for (int i = 0; i < 10; i++) {
    if (i >= int(pipeCount)) break;
    float fi = float(i);
    float pipeY = (fi + 0.5) / float(pipeCount);
    float pipeDist = abs(p.y - pipeY);
    float pipe = smoothstep(pipeRadius + 0.005, pipeRadius, pipeDist);
    float rust = sin(p.x * 50.0 + fi * 10.0) * sin(p.x * 30.0 + pipeY * 100.0);
    rust = rust * 0.5 + 0.5;
    rust *= rustAmount;
    float3 pipeColor = mix(metalColor, rustColor, rust * step(pipeDist, pipeRadius));
    float highlight = smoothstep(pipeRadius, pipeRadius * 0.5, pipeDist);
    highlight *= 1.0 - smoothstep(pipeRadius * 0.3, 0.0, pipeDist);
    pipeColor += highlight * 0.2;
    col = mix(col, pipeColor, pipe);
    float jointX = fract(fi * 0.3 + 0.2);
    float jointDist = abs(p.x - jointX);
    float joint = step(jointDist, 0.02) * step(pipeDist, pipeRadius + 0.01);
    col = mix(col, metalColor * 0.8, joint);
    if (leaking > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.5) {
        float leakX = fract(sin(fi * 127.1) * 43758.5453) * 0.8 + 0.1;
        float leakDist = length(float2(p.x - leakX, (p.y - pipeY) * 0.5));
        float steamTime = fract(iTime * 0.5 + fi * 0.3);
        float steam = exp(-leakDist * 10.0 / pressureLevel) * steamAmount;
        steam *= step(pipeY, p.y) * (1.0 - steamTime);
        float steamNoise = fract(sin(floor(p.y * 50.0) * 127.1 + iTime * 10.0) * 43758.5453);
        steam *= steamNoise * 0.5 + 0.5;
        col += steam * steamColor;
    }
}
return float4(col, 1.0);
"""

/// Industrial Pistons
let industrialPistonsCode = """
// @param pistonCount "Liczba tłoków" range(2, 6) default(4)
// @param cycleSpeed "Prędkość cyklu" range(0.5, 3.0) default(1.5)
// @param strokeLength "Długość skoku" range(0.1, 0.3) default(0.2)
// @param shininess "Połysk" range(0.3, 1.0) default(0.6)
// @param oilAmount "Ilość oleju" range(0.0, 0.5) default(0.2)
// @toggle synchronized "Zsynchronizowane" default(false)
float2 p = uv;
float3 col = float3(0.08, 0.08, 0.1);
float3 metalColor = float3(0.5, 0.5, 0.55);
float3 chromeColor = float3(0.7, 0.7, 0.75);
float3 oilColor = float3(0.15, 0.12, 0.08);
for (int i = 0; i < 6; i++) {
    if (i >= int(pistonCount)) break;
    float fi = float(i);
    float pistonX = (fi + 0.5) / float(pistonCount);
    float phase = synchronized > 0.5 ? 0.0 : fi * 0.5;
    float pistonY = sin(iTime * cycleSpeed * 3.0 + phase) * strokeLength + 0.5;
    float pistonWidth = 0.06;
    float pistonHeight = 0.15;
    float piston = step(abs(p.x - pistonX), pistonWidth);
    piston *= step(pistonY - pistonHeight, p.y) * step(p.y, pistonY);
    float highlight = 1.0 - abs(p.x - pistonX) / pistonWidth;
    highlight = pow(highlight, 2.0) * shininess;
    col = mix(col, chromeColor * (0.7 + highlight * 0.3), piston);
    float cylinderTop = pistonY - pistonHeight - 0.02;
    float cylinder = step(abs(p.x - pistonX), pistonWidth + 0.01);
    cylinder *= step(0.15, p.y) * step(p.y, cylinderTop);
    col = mix(col, metalColor * 0.6, cylinder);
    float rodWidth = 0.015;
    float rod = step(abs(p.x - pistonX), rodWidth);
    rod *= step(p.y, 0.15) * step(0.0, p.y);
    col = mix(col, chromeColor, rod);
    if (oilAmount > 0.0) {
        float oil = step(abs(p.x - pistonX), pistonWidth + 0.005);
        oil *= step(pistonY - pistonHeight - 0.03, p.y);
        oil *= step(p.y, pistonY - pistonHeight);
        float oilDrip = sin(p.y * 100.0 + iTime * 5.0 + fi * 20.0) * 0.5 + 0.5;
        oil *= oilDrip * oilAmount;
        col = mix(col, oilColor, oil);
    }
}
return float4(col, 1.0);
"""

/// Factory Sparks
let factorySparksCode = """
// @param sparkDensity "Gęstość iskier" range(20, 100) default(50)
// @param sparkSpeed "Prędkość iskier" range(1.0, 4.0) default(2.0)
// @param sparkSize "Rozmiar iskier" range(0.005, 0.02) default(0.01)
// @param sourceX "Źródło X" range(0.0, 1.0) default(0.5)
// @param sourceY "Źródło Y" range(0.0, 1.0) default(0.7)
// @toggle welding "Spawanie" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.03);
float2 source = float2(sourceX, sourceY);
if (welding > 0.5) {
    float weldGlow = exp(-length(p - source) * 10.0);
    float weldFlicker = sin(iTime * 50.0) * 0.3 + 0.7;
    col += weldGlow * float3(0.5, 0.7, 1.0) * weldFlicker;
    float weldCore = exp(-length(p - source) * 30.0);
    col += weldCore * float3(1.0, 1.0, 1.0);
}
for (int i = 0; i < 100; i++) {
    if (i >= int(sparkDensity)) break;
    float fi = float(i);
    float birthTime = fract(sin(fi * 127.1) * 43758.5453);
    float sparkAge = fract(iTime * 0.5 + birthTime);
    float angle = fract(sin(fi * 311.7) * 43758.5453) * 3.14159 - 1.5708;
    float speed = fract(sin(fi * 178.3) * 43758.5453) * 0.5 + 0.5;
    float2 velocity = float2(cos(angle), sin(angle)) * speed * sparkSpeed;
    float gravity = sparkAge * sparkAge * 2.0;
    float2 sparkPos = source + velocity * sparkAge - float2(0.0, gravity * 0.5);
    float d = length(p - sparkPos);
    float spark = smoothstep(sparkSize, sparkSize * 0.3, d);
    spark *= 1.0 - sparkAge;
    float3 sparkColor = mix(float3(1.0, 0.9, 0.5), float3(1.0, 0.4, 0.1), sparkAge);
    col += spark * sparkColor;
    if (sparkAge > 0.8 && fract(sin(fi * 43.758) * 43758.5453) > 0.7) {
        float trail = 0.0;
        for (int t = 1; t < 5; t++) {
            float ft = float(t);
            float trailAge = sparkAge - ft * 0.02;
            if (trailAge < 0.0) continue;
            float2 trailPos = source + velocity * trailAge - float2(0.0, trailAge * trailAge * 2.0 * 0.5);
            trail += smoothstep(sparkSize * 0.5, 0.0, length(p - trailPos)) * (1.0 - ft / 5.0);
        }
        col += trail * float3(1.0, 0.5, 0.2) * 0.3;
    }
}
return float4(col, 1.0);
"""

/// Metal Plates
let metalPlatesCode = """
// @param plateCountX "Płyty X" range(2, 8) default(4)
// @param plateCountY "Płyty Y" range(2, 8) default(4)
// @param bevelSize "Rozmiar fazy" range(0.01, 0.05) default(0.02)
// @param scratchAmount "Ilość rys" range(0.0, 1.0) default(0.4)
// @param dirtAmount "Ilość brudu" range(0.0, 0.5) default(0.2)
// @toggle rivets "Nity" default(true)
float2 p = uv;
float3 col = float3(0.4, 0.4, 0.45);
float cellX = floor(p.x * plateCountX);
float cellY = floor(p.y * plateCountY);
float2 cellP = float2(fract(p.x * plateCountX), fract(p.y * plateCountY));
float plateSeed = fract(sin(cellX * 127.1 + cellY * 311.7) * 43758.5453);
col *= 0.9 + plateSeed * 0.2;
float bevelLeft = smoothstep(0.0, bevelSize, cellP.x);
float bevelRight = smoothstep(0.0, bevelSize, 1.0 - cellP.x);
float bevelBottom = smoothstep(0.0, bevelSize, cellP.y);
float bevelTop = smoothstep(0.0, bevelSize, 1.0 - cellP.y);
float bevel = min(min(bevelLeft, bevelRight), min(bevelBottom, bevelTop));
col *= 0.7 + bevel * 0.3;
col += (1.0 - bevelLeft) * 0.1;
col -= (1.0 - bevelRight) * 0.1;
if (scratchAmount > 0.0) {
    float scratch = sin(p.x * 200.0 + p.y * 50.0 + plateSeed * 100.0);
    scratch = step(1.0 - scratchAmount * 0.1, scratch);
    col += scratch * 0.1;
    float scratch2 = sin(p.x * 50.0 + p.y * 200.0 + plateSeed * 50.0);
    scratch2 = step(1.0 - scratchAmount * 0.1, scratch2);
    col -= scratch2 * 0.05;
}
if (dirtAmount > 0.0) {
    float dirt = sin(p.x * 30.0 + plateSeed * 20.0) * sin(p.y * 25.0 + plateSeed * 30.0);
    dirt = dirt * 0.5 + 0.5;
    dirt *= dirtAmount;
    col = mix(col, float3(0.2, 0.18, 0.15), dirt * (1.0 - bevel));
}
if (rivets > 0.5) {
    float rivetR = 0.03;
    float2 rivetPositions[4];
    rivetPositions[0] = float2(0.1, 0.1);
    rivetPositions[1] = float2(0.9, 0.1);
    rivetPositions[2] = float2(0.1, 0.9);
    rivetPositions[3] = float2(0.9, 0.9);
    for (int i = 0; i < 4; i++) {
        float d = length(cellP - rivetPositions[i]);
        float rivet = smoothstep(rivetR, rivetR * 0.8, d);
        float rivetHighlight = smoothstep(rivetR * 0.5, rivetR * 0.3, d);
        col = mix(col, float3(0.35, 0.35, 0.4), 1.0 - rivet);
        col += rivetHighlight * 0.1;
    }
}
return float4(col, 1.0);
"""

/// Rotating Fan
let rotatingFanCode = """
// @param bladeCount "Liczba łopat" range(3, 8) default(5)
// @param rotationSpeed "Prędkość rotacji" range(0.5, 5.0) default(2.0)
// @param fanRadius "Promień" range(0.3, 0.5) default(0.4)
// @param bladeWidth "Szerokość łopat" range(0.1, 0.3) default(0.2)
// @param cageOpacity "Klatka ochronna" range(0.0, 1.0) default(0.5)
// @toggle motionBlur "Rozmycie ruchu" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.1, 0.1, 0.12);
float3 bladeColor = float3(0.3, 0.3, 0.35);
float3 hubColor = float3(0.4, 0.4, 0.45);
float blade = 0.0;
float rotAngle = iTime * rotationSpeed * 3.0;
if (motionBlur > 0.5 && rotationSpeed > 2.0) {
    for (int b = 0; b < 8; b++) {
        float fb = float(b);
        float blurOffset = fb * 0.02;
        float bladeA = a - rotAngle + blurOffset;
        float bladeAngle = mod(bladeA, 6.28318 / float(bladeCount));
        float bladeDist = abs(bladeAngle - 3.14159 / float(bladeCount));
        float bladeShape = step(bladeDist, bladeWidth) * step(0.08, r) * step(r, fanRadius);
        blade += bladeShape * (1.0 - fb / 8.0);
    }
    blade = min(blade, 1.0) * 0.7;
} else {
    for (int i = 0; i < 8; i++) {
        if (i >= int(bladeCount)) break;
        float fi = float(i);
        float bladeA = fi * 6.28318 / float(bladeCount) + rotAngle;
        float angleDiff = abs(mod(a - bladeA + 3.14159, 6.28318) - 3.14159);
        float bladeShape = smoothstep(bladeWidth * 0.5, bladeWidth * 0.3, angleDiff);
        bladeShape *= step(0.08, r) * step(r, fanRadius);
        blade = max(blade, bladeShape);
    }
}
col = mix(col, bladeColor, blade);
float hub = smoothstep(0.1, 0.08, r);
col = mix(col, hubColor, hub);
float hubDetail = smoothstep(0.05, 0.03, r);
col = mix(col, hubColor * 1.2, hubDetail);
if (cageOpacity > 0.0) {
    float cage = 0.0;
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float cageA = fi * 0.785;
        float cageLine = smoothstep(0.02, 0.01, abs(sin(a - cageA) * r));
        cageLine *= step(fanRadius - 0.05, r) * step(r, fanRadius + 0.05);
        cage = max(cage, cageLine);
    }
    float cageRing = smoothstep(0.02, 0.01, abs(r - fanRadius));
    cage = max(cage, cageRing);
    col = mix(col, float3(0.2, 0.2, 0.22), cage * cageOpacity);
}
return float4(col, 1.0);
"""

/// Pressure Gauge
let pressureGaugeCode = """
// @param pressure "Ciśnienie" range(0.0, 1.0) default(0.6)
// @param needleSmooth "Płynność wskazówki" range(0.1, 1.0) default(0.5)
// @param gaugeSize "Rozmiar" range(0.3, 0.5) default(0.4)
// @param dangerZone "Strefa niebezpieczeństwa" range(0.7, 0.95) default(0.8)
// @param glassReflection "Odbicie szkła" range(0.0, 0.5) default(0.2)
// @toggle warning "Ostrzeżenie" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.1, 0.1, 0.1);
float gauge = smoothstep(gaugeSize + 0.02, gaugeSize, r);
float3 faceColor = float3(0.9, 0.9, 0.85);
col = mix(col, faceColor, gauge);
float rim = smoothstep(gaugeSize, gaugeSize - 0.02, r);
rim -= smoothstep(gaugeSize - 0.02, gaugeSize - 0.04, r);
col = mix(col, float3(0.3, 0.3, 0.35), rim);
float startAngle = 2.35619;
float endAngle = 0.785398;
float dangerStart = startAngle - (startAngle - endAngle) * dangerZone;
for (int i = 0; i <= 10; i++) {
    float fi = float(i);
    float tickAngle = startAngle - (startAngle - endAngle) * fi / 10.0;
    float2 tickDir = float2(cos(tickAngle), sin(tickAngle));
    float tickStart = gaugeSize * 0.7;
    float tickEnd = gaugeSize * 0.85;
    float2 toP = p - tickDir * tickStart;
    float along = dot(p, tickDir);
    float perp = abs(dot(p, float2(-tickDir.y, tickDir.x)));
    float tick = step(tickStart, along) * step(along, tickEnd) * step(perp, 0.01);
    float3 tickColor = tickAngle < dangerStart ? float3(0.8, 0.2, 0.2) : float3(0.2, 0.2, 0.2);
    col = mix(col, tickColor, tick * gauge);
}
float smoothPressure = pressure;
float needleAngle = startAngle - (startAngle - endAngle) * smoothPressure;
float2 needleDir = float2(cos(needleAngle), sin(needleAngle));
float needleAlong = dot(p, needleDir);
float needlePerp = abs(dot(p, float2(-needleDir.y, needleDir.x)));
float needleWidth = 0.015 * (1.0 - needleAlong / gaugeSize);
float needle = step(0.0, needleAlong) * step(needleAlong, gaugeSize * 0.75);
needle *= step(needlePerp, needleWidth);
float3 needleColor = float3(0.8, 0.2, 0.1);
col = mix(col, needleColor, needle * gauge);
float hub = smoothstep(0.05, 0.03, r);
col = mix(col, float3(0.3, 0.3, 0.35), hub * gauge);
if (glassReflection > 0.0) {
    float reflection = smoothstep(0.0, gaugeSize, p.x + p.y);
    reflection *= gauge * glassReflection;
    col += reflection * 0.2;
}
if (warning > 0.5 && pressure > dangerZone) {
    float warn = sin(iTime * 10.0) * 0.5 + 0.5;
    col = mix(col, float3(1.0, 0.3, 0.2), warn * 0.3 * gauge);
}
return float4(col, 1.0);
"""

/// Chain Links
let chainLinksCode = """
// @param linkCount "Liczba ogniw" range(3, 10) default(6)
// @param linkSize "Rozmiar ogniw" range(0.05, 0.15) default(0.1)
// @param chainAngle "Kąt łańcucha" range(-0.5, 0.5) default(0.0)
// @param swingAmount "Kołysanie" range(0.0, 0.3) default(0.1)
// @param shininess "Połysk" range(0.3, 1.0) default(0.6)
// @toggle rusty "Zardzewiały" default(false)
float2 p = uv;
float3 col = float3(0.1, 0.1, 0.12);
float3 metalColor = rusty > 0.5 ? float3(0.5, 0.3, 0.2) : float3(0.5, 0.5, 0.55);
float swing = sin(iTime * 2.0) * swingAmount;
for (int i = 0; i < 10; i++) {
    if (i >= int(linkCount)) break;
    float fi = float(i);
    float linkSwing = swing * (1.0 + fi * 0.2);
    float2 linkCenter = float2(
        0.5 + sin(chainAngle + linkSwing) * fi * linkSize * 0.8,
        0.9 - fi * linkSize * 1.5
    );
    float linkAngle = chainAngle + linkSwing + (i % 2 == 0 ? 0.0 : 1.5708);
    float2 toP = p - linkCenter;
    float2 rotP = float2(
        toP.x * cos(linkAngle) + toP.y * sin(linkAngle),
        -toP.x * sin(linkAngle) + toP.y * cos(linkAngle)
    );
    float outerW = linkSize * 0.6;
    float outerH = linkSize;
    float innerW = linkSize * 0.3;
    float innerH = linkSize * 0.7;
    float outer = step(abs(rotP.x), outerW) * step(abs(rotP.y), outerH);
    float inner = step(abs(rotP.x), innerW) * step(abs(rotP.y), innerH);
    float link = outer - inner;
    float cornerDist = length(float2(abs(rotP.x) - innerW, abs(rotP.y) - innerH));
    link = max(link, step(cornerDist, (outerW - innerW) * 0.5) * step(innerW, abs(rotP.x)));
    float highlight = (rotP.x + outerW) / (outerW * 2.0) * shininess;
    float3 linkColor = metalColor * (0.7 + highlight * 0.5);
    if (rusty > 0.5) {
        float rust = sin(rotP.x * 100.0 + rotP.y * 80.0 + fi * 20.0) * 0.5 + 0.5;
        linkColor = mix(linkColor, float3(0.4, 0.2, 0.1), rust * 0.3);
    }
    col = mix(col, linkColor, link);
}
return float4(col, 1.0);
"""

/// Control Panel
let controlPanelCode = """
// @param buttonCount "Liczba przycisków" range(4, 12) default(8)
// @param ledBrightness "Jasność LED" range(0.5, 1.5) default(1.0)
// @param screenGlow "Blask ekranu" range(0.0, 1.0) default(0.5)
// @param activeButtons "Aktywne przyciski" range(0.0, 1.0) default(0.6)
// @param flickerRate "Migotanie" range(0.0, 0.5) default(0.1)
// @toggle powered "Zasilony" default(true)
float2 p = uv;
float3 col = float3(0.15, 0.15, 0.18);
float panelBorder = step(0.02, p.x) * step(p.x, 0.98);
panelBorder *= step(0.02, p.y) * step(p.y, 0.98);
col = mix(float3(0.1, 0.1, 0.12), col, panelBorder);
if (powered > 0.5) {
    float screenArea = step(0.1, p.x) * step(p.x, 0.5);
    screenArea *= step(0.6, p.y) * step(p.y, 0.9);
    float3 screenColor = float3(0.1, 0.3, 0.15);
    float scanline = sin(p.y * 200.0 + iTime * 5.0) * 0.1 + 0.9;
    col = mix(col, screenColor * scanline, screenArea);
    float screenGlowEffect = exp(-length(p - float2(0.3, 0.75)) * 3.0) * screenGlow;
    col += screenGlowEffect * float3(0.0, 0.2, 0.1);
}
int buttonsPerRow = int(ceil(float(buttonCount) / 2.0));
for (int i = 0; i < 12; i++) {
    if (i >= int(buttonCount)) break;
    float fi = float(i);
    int row = i / buttonsPerRow;
    int colIdx = i % buttonsPerRow;
    float bx = 0.6 + float(colIdx) * 0.1;
    float by = 0.75 - float(row) * 0.15;
    float buttonDist = length(p - float2(bx, by));
    float button = smoothstep(0.03, 0.025, buttonDist);
    float isActive = step(fi / float(buttonCount), activeButtons);
    float flicker = 1.0;
    if (flickerRate > 0.0 && powered > 0.5) {
        flicker = step(flickerRate, fract(sin(iTime * 10.0 + fi * 5.0) * 0.5 + 0.5));
    }
    float3 buttonColor = isActive > 0.5 && powered > 0.5 ? 
        float3(0.2, 0.8, 0.3) * flicker : float3(0.2, 0.2, 0.2);
    col = mix(col, buttonColor, button);
    if (powered > 0.5) {
        float ledX = bx;
        float ledY = by + 0.05;
        float ledDist = length(p - float2(ledX, ledY));
        float led = smoothstep(0.008, 0.005, ledDist);
        float3 ledColor = isActive > 0.5 ? float3(0.0, 1.0, 0.3) : float3(0.5, 0.0, 0.0);
        ledColor *= ledBrightness * flicker;
        col += led * ledColor;
    }
}
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float sliderX = 0.2 + fi * 0.1;
    float sliderY = 0.3;
    float sliderHeight = 0.2;
    float sliderTrack = step(abs(p.x - sliderX), 0.01);
    sliderTrack *= step(sliderY - sliderHeight * 0.5, p.y);
    sliderTrack *= step(p.y, sliderY + sliderHeight * 0.5);
    col = mix(col, float3(0.1, 0.1, 0.1), sliderTrack);
    float sliderPos = sin(iTime * (1.0 + fi * 0.3)) * 0.5 + 0.5;
    float sliderKnob = length(p - float2(sliderX, sliderY - sliderHeight * 0.5 + sliderPos * sliderHeight));
    float knob = smoothstep(0.02, 0.015, sliderKnob);
    col = mix(col, float3(0.4, 0.4, 0.45), knob);
}
return float4(col, 1.0);
"""

/// Mechanical Heart
let mechanicalHeartCode = """
// @param beatRate "Częstotliwość bicia" range(0.5, 2.0) default(1.0)
// @param heartSize "Rozmiar serca" range(0.2, 0.4) default(0.3)
// @param gearDetail "Detale przekładni" range(0.3, 1.0) default(0.7)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.5)
// @param steamAmount "Ilość pary" range(0.0, 0.5) default(0.2)
// @toggle beating "Bijące" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05, 0.04, 0.03);
float beat = beating > 0.5 ? sin(iTime * beatRate * 6.0) * 0.1 + 1.0 : 1.0;
float2 hp = p / (heartSize * beat);
float heart = pow(abs(hp.x), 2.0/3.0) + pow(abs(hp.y), 2.0/3.0);
heart = 1.0 - smoothstep(0.8, 1.0, heart);
float3 brassColor = float3(0.7, 0.5, 0.2);
float3 copperColor = float3(0.7, 0.4, 0.3);
col = mix(col, brassColor, heart);
if (gearDetail > 0.0) {
    float gearR = heartSize * 0.4;
    float gearA = atan2(p.y, p.x) + iTime * 2.0 * (beating > 0.5 ? beat : 1.0);
    float r = length(p);
    float teeth = sin(gearA * 12.0) * 0.5 + 0.5;
    float gear = smoothstep(gearR + 0.01, gearR - 0.01, r - teeth * 0.02);
    gear -= smoothstep(gearR * 0.4, gearR * 0.3, r);
    gear *= heart * gearDetail;
    col = mix(col, copperColor, gear);
    float smallGearR = heartSize * 0.15;
    float2 smallGearPos = float2(heartSize * 0.3, heartSize * 0.2);
    float smallGearDist = length(p - smallGearPos);
    float smallGearA = atan2(p.y - smallGearPos.y, p.x - smallGearPos.x) - iTime * 4.0;
    float smallTeeth = sin(smallGearA * 8.0) * 0.5 + 0.5;
    float smallGear = smoothstep(smallGearR, smallGearR - 0.01, smallGearDist - smallTeeth * 0.01);
    smallGear -= smoothstep(smallGearR * 0.3, smallGearR * 0.2, smallGearDist);
    smallGear *= heart;
    col = mix(col, brassColor * 0.8, smallGear * gearDetail);
}
if (glowIntensity > 0.0 && beating > 0.5) {
    float glow = heart * (beat - 0.9) * 5.0;
    glow = max(0.0, glow);
    col += glow * float3(1.0, 0.3, 0.1) * glowIntensity;
}
if (steamAmount > 0.0 && beating > 0.5) {
    float2 steamPos = float2(0.0, heartSize * 0.8);
    float steamDist = length(p - steamPos);
    float steam = exp(-steamDist * 5.0) * steamAmount;
    float steamNoise = fract(sin(floor(p.y * 30.0 + iTime * 10.0) * 127.1) * 43758.5453);
    steam *= steamNoise;
    steam *= step(heartSize * 0.5, p.y);
    col += steam * float3(0.8, 0.8, 0.85);
}
return float4(col, 1.0);
"""

/// Conveyor Belt
let conveyorBeltCode = """
// @param beltSpeed "Prędkość taśmy" range(0.5, 3.0) default(1.5)
// @param segmentCount "Liczba segmentów" range(10, 30) default(20)
// @param beltWidth "Szerokość taśmy" range(0.2, 0.4) default(0.3)
// @param itemCount "Liczba przedmiotów" range(0, 5) default(3)
// @param wearAmount "Zużycie" range(0.0, 0.5) default(0.2)
// @toggle running "Działający" default(true)
float2 p = uv;
float3 col = float3(0.15, 0.15, 0.18);
float beltY = 0.5;
float beltTop = beltY + beltWidth * 0.5;
float beltBottom = beltY - beltWidth * 0.5;
float belt = step(beltBottom, p.y) * step(p.y, beltTop);
float beltX = p.x;
if (running > 0.5) {
    beltX = fract(p.x + iTime * beltSpeed * 0.1);
}
float segment = floor(beltX * float(segmentCount));
float segmentLocal = fract(beltX * float(segmentCount));
float segmentLine = step(0.95, segmentLocal) + step(segmentLocal, 0.05);
segmentLine *= 0.3;
float3 beltColor = float3(0.2, 0.2, 0.22);
if (wearAmount > 0.0) {
    float wear = sin(segment * 17.3 + p.y * 50.0) * 0.5 + 0.5;
    wear *= wearAmount;
    beltColor = mix(beltColor, float3(0.15, 0.14, 0.13), wear);
}
col = mix(col, beltColor, belt);
col = mix(col, float3(0.1, 0.1, 0.1), belt * segmentLine);
float rollerRadius = 0.05;
float2 rollerLeft = float2(0.08, beltY);
float2 rollerRight = float2(0.92, beltY);
float leftRoller = smoothstep(rollerRadius + 0.01, rollerRadius, length(p - rollerLeft));
float rightRoller = smoothstep(rollerRadius + 0.01, rollerRadius, length(p - rollerRight));
col = mix(col, float3(0.4, 0.4, 0.45), leftRoller + rightRoller);
for (int i = 0; i < 5; i++) {
    if (i >= int(itemCount)) break;
    float fi = float(i);
    float itemX = fract(fi / float(itemCount) + (running > 0.5 ? iTime * beltSpeed * 0.1 : 0.0));
    itemX = 0.15 + itemX * 0.7;
    float itemSize = 0.05 + fract(sin(fi * 127.1) * 43758.5453) * 0.03;
    float itemDist = length(p - float2(itemX, beltY + beltWidth * 0.5 + itemSize));
    float item = smoothstep(itemSize + 0.01, itemSize, itemDist);
    float3 itemColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, itemColor * 0.6, item);
}
return float4(col, 1.0);
"""

/// Warning Lights
let warningLightsCode = """
// @param lightCount "Liczba świateł" range(1, 5) default(3)
// @param flashSpeed "Prędkość błysku" range(0.5, 4.0) default(2.0)
// @param lightSize "Rozmiar świateł" range(0.05, 0.15) default(0.1)
// @param glowRadius "Promień poświaty" range(0.1, 0.4) default(0.2)
// @param warningLevel "Poziom ostrzeżenia" range(0.0, 1.0) default(0.5)
// @toggle alternating "Naprzemienne" default(true)
float2 p = uv;
float3 col = float3(0.05, 0.05, 0.06);
float3 warningColor = mix(float3(1.0, 0.8, 0.0), float3(1.0, 0.2, 0.1), warningLevel);
for (int i = 0; i < 5; i++) {
    if (i >= int(lightCount)) break;
    float fi = float(i);
    float lightX = (fi + 0.5) / float(lightCount);
    float2 lightPos = float2(lightX, 0.5);
    float phase = alternating > 0.5 ? fi * 3.14159 : 0.0;
    float flash = sin(iTime * flashSpeed * 3.14159 + phase);
    flash = step(0.0, flash);
    flash *= 0.7 + warningLevel * 0.3;
    float lightDist = length(p - lightPos);
    float light = smoothstep(lightSize, lightSize * 0.7, lightDist);
    col += light * warningColor * flash;
    float glow = exp(-lightDist / glowRadius) * flash;
    col += glow * warningColor * 0.5;
    float housing = smoothstep(lightSize + 0.02, lightSize + 0.01, lightDist);
    housing -= smoothstep(lightSize + 0.01, lightSize, lightDist);
    col = mix(col, float3(0.2, 0.2, 0.22), housing);
    float lens = smoothstep(lightSize * 0.9, lightSize * 0.8, lightDist);
    lens *= step(lightDist, lightSize);
    col += lens * 0.3 * (1.0 - flash * 0.5);
}
if (warningLevel > 0.5) {
    float ambient = sin(iTime * flashSpeed * 6.28) * 0.5 + 0.5;
    ambient *= warningLevel - 0.5;
    col += ambient * warningColor * 0.1;
}
return float4(col, 1.0);
"""

/// Hydraulic Press
let hydraulicPressCode = """
// @param pressSpeed "Prędkość prasy" range(0.3, 2.0) default(0.8)
// @param pressForce "Siła nacisku" range(0.3, 0.7) default(0.5)
// @param pistonWidth "Szerokość tłoka" range(0.15, 0.3) default(0.2)
// @param oilLevel "Poziom oleju" range(0.0, 0.3) default(0.15)
// @param metalShine "Połysk metalu" range(0.3, 1.0) default(0.6)
// @toggle crushing "Miażdżenie" default(false)
float2 p = uv;
float3 col = float3(0.12, 0.12, 0.14);
float pressPhase = sin(iTime * pressSpeed) * 0.5 + 0.5;
float pressY = 0.9 - pressPhase * pressForce;
float pistonX = abs(p.x - 0.5);
float piston = step(pistonX, pistonWidth);
piston *= step(pressY, p.y);
float3 pistonColor = float3(0.5, 0.5, 0.55);
float highlight = (1.0 - pistonX / pistonWidth) * metalShine;
pistonColor += highlight * 0.2;
col = mix(col, pistonColor, piston);
float baseY = 0.15;
float base = step(p.y, baseY);
col = mix(col, float3(0.35, 0.35, 0.4), base);
float plateY = baseY;
if (crushing > 0.5) {
    float squish = (1.0 - pressPhase) * 0.05;
    plateY = baseY + squish;
}
float plate = step(abs(p.x - 0.5), pistonWidth + 0.05);
plate *= step(baseY, p.y) * step(p.y, plateY + 0.03);
col = mix(col, float3(0.4, 0.35, 0.3), plate);
if (crushing > 0.5 && pressPhase > 0.8) {
    float2 crushCenter = float2(0.5, plateY);
    float crushDist = length(p - crushCenter);
    float sparks = step(0.95, fract(sin(crushDist * 100.0 + iTime * 20.0) * 43758.5453));
    sparks *= step(crushDist, 0.3);
    col += sparks * float3(1.0, 0.7, 0.3);
}
if (oilLevel > 0.0) {
    float oil = step(p.y, baseY + oilLevel);
    oil *= step(abs(p.x - 0.5), 0.4);
    oil *= step(baseY, p.y);
    float3 oilColor = float3(0.15, 0.12, 0.08);
    float oilShine = sin(p.x * 50.0 + iTime) * 0.1 + 0.1;
    oilColor += oilShine;
    col = mix(col, oilColor, oil * 0.8);
}
float frameL = step(p.x, 0.1);
float frameR = step(0.9, p.x);
float frame = (frameL + frameR) * step(0.1, p.y);
col = mix(col, float3(0.3, 0.3, 0.35), frame);
return float4(col, 1.0);
"""

/// Engine Cylinder
let engineCylinderCode = """
// @param cylinderCount "Liczba cylindrów" range(1, 6) default(4)
// @param rpmSpeed "Obroty" range(0.5, 4.0) default(2.0)
// @param exhaustGlow "Blask wydechu" range(0.0, 1.0) default(0.5)
// @param oilTemp "Temperatura oleju" range(0.0, 1.0) default(0.3)
// @param wear "Zużycie" range(0.0, 0.5) default(0.1)
// @toggle firing "Zapłon" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.1, 0.12);
float3 metalColor = float3(0.45, 0.45, 0.5);
float3 hotColor = float3(0.8, 0.4, 0.2);
for (int i = 0; i < 6; i++) {
    if (i >= int(cylinderCount)) break;
    float fi = float(i);
    float cylX = (fi + 0.5) / float(cylinderCount);
    float cylWidth = 0.4 / float(cylinderCount);
    float cylinder = step(abs(p.x - cylX), cylWidth * 0.8);
    cylinder *= step(0.2, p.y) * step(p.y, 0.9);
    float phase = fi * 6.28318 / float(cylinderCount);
    float pistonPos = sin(iTime * rpmSpeed * 5.0 + phase) * 0.15 + 0.55;
    float pistonHeight = 0.1;
    float piston = step(abs(p.x - cylX), cylWidth * 0.7);
    piston *= step(pistonPos - pistonHeight, p.y) * step(p.y, pistonPos);
    float3 cylColor = metalColor;
    if (wear > 0.0) {
        float wearPattern = sin(p.y * 50.0 + fi * 10.0) * 0.5 + 0.5;
        cylColor = mix(cylColor, cylColor * 0.7, wearPattern * wear);
    }
    if (oilTemp > 0.5) {
        float heat = (oilTemp - 0.5) * 2.0;
        cylColor = mix(cylColor, hotColor, heat * 0.3);
    }
    col = mix(col, cylColor * 0.6, cylinder);
    col = mix(col, metalColor * 0.9, piston);
    if (firing > 0.5) {
        float firePhase = fract(iTime * rpmSpeed * 2.5 + phase / 6.28318);
        if (firePhase < 0.1 && pistonPos > 0.6) {
            float fireDist = length(p - float2(cylX, pistonPos + 0.05));
            float fire = exp(-fireDist * 30.0);
            col += fire * float3(1.0, 0.6, 0.2) * exhaustGlow;
        }
    }
}
float crankY = 0.15;
float crank = step(0.05, p.x) * step(p.x, 0.95);
crank *= step(crankY - 0.03, p.y) * step(p.y, crankY + 0.03);
col = mix(col, float3(0.35, 0.35, 0.4), crank);
for (int i = 0; i < 6; i++) {
    if (i >= int(cylinderCount)) break;
    float fi = float(i);
    float cylX = (fi + 0.5) / float(cylinderCount);
    float phase = fi * 6.28318 / float(cylinderCount);
    float crankAngle = iTime * rpmSpeed * 5.0 + phase;
    float2 crankPin = float2(cylX + cos(crankAngle) * 0.03, crankY + sin(crankAngle) * 0.02);
    float pin = smoothstep(0.015, 0.01, length(p - crankPin));
    col = mix(col, float3(0.5, 0.5, 0.55), pin);
}
return float4(col, 1.0);
"""

/// Radar Dish
let radarDishCode = """
// @param rotationSpeed "Prędkość rotacji" range(0.2, 2.0) default(0.5)
// @param dishSize "Rozmiar anteny" range(0.3, 0.5) default(0.4)
// @param signalStrength "Siła sygnału" range(0.0, 1.0) default(0.6)
// @param sweepWidth "Szerokość skanowania" range(0.1, 0.5) default(0.3)
// @param targetCount "Liczba celów" range(0, 5) default(2)
// @toggle transmitting "Nadawanie" default(true)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02, 0.05, 0.02);
float sweepAngle = iTime * rotationSpeed * 2.0;
float angleDiff = mod(a - sweepAngle + 3.14159, 6.28318) - 3.14159;
float sweep = smoothstep(sweepWidth, 0.0, angleDiff) * step(0.0, angleDiff);
sweep *= step(r, dishSize);
col += sweep * float3(0.0, 0.4, 0.1) * signalStrength;
float dish = smoothstep(dishSize + 0.02, dishSize, r);
dish -= smoothstep(dishSize - 0.02, dishSize - 0.04, r);
col += dish * float3(0.0, 0.3, 0.1);
for (int i = 1; i <= 4; i++) {
    float ringR = dishSize * float(i) / 4.0;
    float ring = smoothstep(0.01, 0.005, abs(r - ringR));
    col += ring * float3(0.0, 0.2, 0.05);
}
float crossH = step(abs(p.y), 0.005) * step(r, dishSize);
float crossV = step(abs(p.x), 0.005) * step(r, dishSize);
col += (crossH + crossV) * float3(0.0, 0.15, 0.05);
float center = smoothstep(0.03, 0.02, r);
col += center * float3(0.0, 0.5, 0.2);
float centerPulse = sin(iTime * 5.0) * 0.5 + 0.5;
col += center * centerPulse * float3(0.0, 0.3, 0.1) * signalStrength;
for (int i = 0; i < 5; i++) {
    if (i >= int(targetCount)) break;
    float fi = float(i);
    float targetA = fract(sin(fi * 127.1) * 43758.5453) * 6.28318;
    float targetR = fract(sin(fi * 311.7) * 43758.5453) * (dishSize - 0.05) + 0.05;
    float2 targetPos = float2(cos(targetA), sin(targetA)) * targetR;
    float targetDist = length(p - targetPos);
    float sweepHit = step(abs(mod(targetA - sweepAngle + 3.14159, 6.28318) - 3.14159), sweepWidth * 0.5);
    float target = smoothstep(0.02, 0.01, targetDist) * sweepHit;
    float fade = 1.0 - fract(iTime * rotationSpeed * 0.5);
    target *= fade;
    col += target * float3(0.0, 1.0, 0.3);
}
if (transmitting > 0.5) {
    float wave = fract(iTime * 2.0 - r * 3.0);
    wave = smoothstep(0.0, 0.1, wave) * smoothstep(0.2, 0.1, wave);
    wave *= step(dishSize, r) * step(r, 0.8);
    wave *= signalStrength * 0.5;
    col += wave * float3(0.0, 0.3, 0.1);
}
return float4(col, 1.0);
"""

/// Steel Mesh
let steelMeshCode = """
// @param meshDensity "Gęstość siatki" range(5.0, 20.0) default(10.0)
// @param wireThickness "Grubość drutu" range(0.02, 0.1) default(0.05)
// @param rustAmount "Rdza" range(0.0, 0.5) default(0.2)
// @param depth "Głębokość" range(0.0, 0.3) default(0.1)
// @param lightAngle "Kąt światła" range(0.0, 6.28) default(0.785)
// @toggle woven "Pleciony" default(true)
float2 p = uv;
float3 col = float3(0.05, 0.05, 0.06);
float3 wireColor = float3(0.4, 0.4, 0.45);
float3 rustColor = float3(0.4, 0.25, 0.15);
float2 gridP = p * meshDensity;
float2 gridCell = floor(gridP);
float2 gridLocal = fract(gridP);
float wireH = smoothstep(wireThickness, wireThickness * 0.5, abs(gridLocal.y - 0.5));
float wireV = smoothstep(wireThickness, wireThickness * 0.5, abs(gridLocal.x - 0.5));
float depthH = 0.0;
float depthV = 0.0;
if (woven > 0.5) {
    float weavePattern = mod(gridCell.x + gridCell.y, 2.0);
    depthH = weavePattern * depth;
    depthV = (1.0 - weavePattern) * depth;
}
float3 wireHColor = wireColor * (1.0 - depthH);
float3 wireVColor = wireColor * (1.0 - depthV);
float2 lightDir = float2(cos(lightAngle), sin(lightAngle));
float highlightH = dot(float2(0.0, 1.0), lightDir) * 0.5 + 0.5;
float highlightV = dot(float2(1.0, 0.0), lightDir) * 0.5 + 0.5;
wireHColor *= 0.7 + highlightH * 0.3;
wireVColor *= 0.7 + highlightV * 0.3;
if (rustAmount > 0.0) {
    float rustH = sin(p.x * 100.0 + gridCell.y * 20.0) * sin(p.y * 80.0) * 0.5 + 0.5;
    float rustV = sin(p.y * 100.0 + gridCell.x * 20.0) * sin(p.x * 80.0) * 0.5 + 0.5;
    wireHColor = mix(wireHColor, rustColor, rustH * rustAmount);
    wireVColor = mix(wireVColor, rustColor, rustV * rustAmount);
}
if (woven > 0.5) {
    if (depthH < depthV) {
        col = mix(col, wireVColor, wireV);
        col = mix(col, wireHColor, wireH);
    } else {
        col = mix(col, wireHColor, wireH);
        col = mix(col, wireVColor, wireV);
    }
} else {
    col = mix(col, wireHColor, wireH);
    col = mix(col, wireVColor, wireV);
}
float joint = wireH * wireV;
col = mix(col, wireColor * 0.9, joint * 0.5);
return float4(col, 1.0);
"""

/// Turbine Blades
let turbineBladesCode = """
// @param bladeCount "Liczba łopat" range(6, 20) default(12)
// @param rotationSpeed "Prędkość rotacji" range(0.5, 5.0) default(2.0)
// @param bladeAngle "Kąt łopat" range(0.1, 0.5) default(0.3)
// @param hubSize "Rozmiar piasty" range(0.1, 0.25) default(0.15)
// @param tipGlow "Blask końcówek" range(0.0, 1.0) default(0.3)
// @toggle afterburner "Dopalacz" default(false)
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.05, 0.05, 0.08);
float rotAngle = iTime * rotationSpeed * 3.0;
float bladeAngleRad = a - rotAngle;
float bladeId = floor((bladeAngleRad + 3.14159) / (6.28318 / float(bladeCount)));
float bladeLocal = fract((bladeAngleRad + 3.14159) / (6.28318 / float(bladeCount)));
float bladeCurve = bladeLocal - 0.5 + (r - hubSize) * bladeAngle * 2.0;
float blade = smoothstep(0.15, 0.05, abs(bladeCurve));
blade *= step(hubSize, r) * step(r, 0.45);
float3 bladeColor = float3(0.5, 0.5, 0.55);
float highlight = 1.0 - abs(bladeCurve) * 3.0;
highlight *= (r - hubSize) / 0.3;
bladeColor += highlight * 0.2;
col = mix(col, bladeColor, blade);
if (tipGlow > 0.0) {
    float tip = blade * smoothstep(0.35, 0.45, r);
    float3 tipColor = afterburner > 0.5 ? float3(1.0, 0.5, 0.2) : float3(0.3, 0.5, 1.0);
    col += tip * tipColor * tipGlow;
}
float hub = smoothstep(hubSize + 0.01, hubSize, r);
float hubHighlight = smoothstep(hubSize, hubSize * 0.5, r);
col = mix(col, float3(0.4, 0.4, 0.45), hub);
col += hubHighlight * 0.1;
float center = smoothstep(hubSize * 0.4, hubSize * 0.3, r);
col = mix(col, float3(0.3, 0.3, 0.35), center);
if (afterburner > 0.5) {
    float exhaust = smoothstep(0.5, 0.45, r) * step(0.45, r);
    float flame = sin(r * 30.0 - iTime * 20.0) * 0.5 + 0.5;
    float flameNoise = fract(sin(a * 10.0 + iTime * 5.0) * 43758.5453);
    exhaust *= flame * flameNoise;
    float3 exhaustColor = mix(float3(1.0, 0.3, 0.1), float3(1.0, 0.8, 0.3), flame);
    col += exhaust * exhaustColor;
}
float housing = smoothstep(0.48, 0.46, r) - smoothstep(0.46, 0.44, r);
col = mix(col, float3(0.25, 0.25, 0.3), housing);
return float4(col, 1.0);
"""

/// Electrical Panel
let electricalPanelCode = """
// @param circuitDensity "Gęstość obwodów" range(0.3, 1.0) default(0.6)
// @param sparkChance "Szansa na iskry" range(0.0, 0.3) default(0.1)
// @param powerLevel "Poziom mocy" range(0.0, 1.0) default(0.7)
// @param wiringComplexity "Złożoność okablowania" range(1.0, 3.0) default(2.0)
// @param indicatorBrightness "Jasność wskaźników" range(0.5, 1.5) default(1.0)
// @toggle damaged "Uszkodzony" default(false)
float2 p = uv;
float3 col = float3(0.12, 0.12, 0.14);
float panel = step(0.05, p.x) * step(p.x, 0.95);
panel *= step(0.05, p.y) * step(p.y, 0.95);
col = mix(float3(0.08, 0.08, 0.1), col, panel);
int circuitCount = int(circuitDensity * 8.0);
for (int i = 0; i < 8; i++) {
    if (i >= circuitCount) break;
    float fi = float(i);
    float startX = fract(sin(fi * 127.1) * 43758.5453) * 0.6 + 0.2;
    float startY = fract(sin(fi * 311.7) * 43758.5453) * 0.6 + 0.2;
    float2 circuitPos = float2(startX, startY);
    float wire = 0.0;
    float segmentCount = floor(wiringComplexity * 3.0);
    float2 currentPos = circuitPos;
    for (int s = 0; s < 9; s++) {
        if (s >= int(segmentCount)) break;
        float fs = float(s);
        float2 nextPos;
        if (int(fs) % 2 == 0) {
            nextPos = currentPos + float2(fract(sin((fi + fs) * 178.3) * 43758.5453) * 0.2 - 0.1, 0.0);
        } else {
            nextPos = currentPos + float2(0.0, fract(sin((fi + fs) * 43.758) * 43758.5453) * 0.2 - 0.1);
        }
        if (int(fs) % 2 == 0) {
            float segmentWire = step(min(currentPos.x, nextPos.x), p.x);
            segmentWire *= step(p.x, max(currentPos.x, nextPos.x));
            segmentWire *= step(abs(p.y - currentPos.y), 0.003);
            wire = max(wire, segmentWire);
        } else {
            float segmentWire = step(min(currentPos.y, nextPos.y), p.y);
            segmentWire *= step(p.y, max(currentPos.y, nextPos.y));
            segmentWire *= step(abs(p.x - currentPos.x), 0.003);
            wire = max(wire, segmentWire);
        }
        currentPos = nextPos;
    }
    float3 wireColor = 0.5 + 0.5 * cos(fi * 2.0 + float3(0.0, 2.0, 4.0));
    wireColor *= 0.4;
    if (powerLevel > 0.0) {
        float pulse = sin(iTime * 5.0 + fi * 2.0) * 0.3 + 0.7;
        wireColor *= pulse * powerLevel + (1.0 - powerLevel);
    }
    col += wire * wireColor * panel;
}
for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float2 ledPos = float2(0.15 + fi * 0.12, 0.85);
    float ledDist = length(p - ledPos);
    float led = smoothstep(0.012, 0.008, ledDist);
    float isOn = step(fi / 6.0, powerLevel);
    float3 ledColor = isOn > 0.5 ? float3(0.0, 1.0, 0.3) : float3(0.3, 0.0, 0.0);
    if (damaged > 0.5 && fract(sin(fi * 43.758) * 43758.5453) > 0.7) {
        float flicker = step(0.5, fract(sin(iTime * 20.0 + fi * 10.0) * 0.5 + 0.5));
        ledColor *= flicker;
    }
    col += led * ledColor * indicatorBrightness * panel;
}
if (damaged > 0.5 && sparkChance > 0.0) {
    float sparkTime = floor(iTime * 10.0);
    float sparkRand = fract(sin(sparkTime * 127.1) * 43758.5453);
    if (sparkRand < sparkChance) {
        float2 sparkPos = float2(
            fract(sin(sparkTime * 311.7) * 43758.5453) * 0.8 + 0.1,
            fract(sin(sparkTime * 178.3) * 43758.5453) * 0.8 + 0.1
        );
        float sparkDist = length(p - sparkPos);
        float spark = exp(-sparkDist * 30.0);
        col += spark * float3(0.5, 0.7, 1.0) * panel;
    }
}
return float4(col, 1.0);
"""

