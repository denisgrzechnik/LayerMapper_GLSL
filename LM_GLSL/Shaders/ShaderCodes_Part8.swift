//
//  ShaderCodes_Part8.swift
//  LM_GLSL
//
//  Shader codes - Part 8: Retro, Glitch & Digital Art Shaders (20 shaders)
//  Each shader has multiple controllable parameters
//

import Foundation

// MARK: - Retro & Digital Parametric Shaders

/// VHS Tape Distortion Advanced
let vhsAdvancedCode = """
// @param scanlineIntensity "Intensywność linii" range(0.0, 1.0) default(0.5)
// @param noiseAmount "Ilość szumu" range(0.0, 0.5) default(0.2)
// @param colorBleed "Rozmazanie kolorów" range(0.0, 0.05) default(0.02)
// @param trackingError "Błąd śledzenia" range(0.0, 0.1) default(0.03)
// @param flickerSpeed "Prędkość migotania" range(0.0, 20.0) default(10.0)
// @toggle staticNoise "Szum statyczny" default(true)
float2 p = uv;
float trackError = sin(iTime * 2.0 + p.y * 20.0) * trackingError * step(0.9, sin(iTime * 0.5));
p.x += trackError;
float r = sin(p.x * 500.0 + iTime * flickerSpeed) * 0.5 + 0.5;
float g = sin((p.x + colorBleed) * 500.0 + iTime * flickerSpeed) * 0.5 + 0.5;
float b = sin((p.x - colorBleed) * 500.0 + iTime * flickerSpeed) * 0.5 + 0.5;
float3 col = float3(r, g, b);
float scanline = sin(p.y * 400.0) * 0.5 + 0.5;
scanline = pow(scanline, 2.0);
col *= (1.0 - scanlineIntensity * 0.5 + scanlineIntensity * 0.5 * scanline);
if (staticNoise > 0.5) {
    float noise = fract(sin(dot(p + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * noiseAmount;
}
float vignette = 1.0 - length(uv - 0.5) * 0.5;
col *= vignette;
float flicker = 0.98 + 0.02 * sin(iTime * flickerSpeed * 3.0);
col *= flicker;
return float4(col, 1.0);
"""

/// CRT Monitor Effect
let crtMonitorCode = """
// @param curvature "Krzywizna" range(0.0, 0.5) default(0.2)
// @param scanlineWeight "Waga linii skanujących" range(0.0, 1.0) default(0.5)
// @param phosphorGlow "Poświata fosforowa" range(0.0, 1.0) default(0.3)
// @param rgbOffset "Przesunięcie RGB" range(0.0, 0.01) default(0.003)
// @param brightness "Jasność" range(0.5, 1.5) default(1.0)
// @toggle interlace "Przeplot" default(true)
float2 p = uv - 0.5;
float2 curved = p * (1.0 + length(p) * curvature);
curved += 0.5;
if (curved.x < 0.0 || curved.x > 1.0 || curved.y < 0.0 || curved.y > 1.0) {
    return float4(0.0, 0.0, 0.0, 1.0);
}
float r = sin(curved.x * 100.0 + iTime) * 0.5 + 0.5;
float g = sin((curved.x + rgbOffset) * 100.0 + iTime * 1.1) * 0.5 + 0.5;
float b = sin((curved.x - rgbOffset) * 100.0 + iTime * 0.9) * 0.5 + 0.5;
float3 col = float3(r, g, b);
float scanline = sin(curved.y * 600.0) * 0.5 + 0.5;
col *= (1.0 - scanlineWeight * (1.0 - scanline));
if (interlace > 0.5) {
    float interlaceLines = fmod(floor(curved.y * 300.0) + floor(iTime * 30.0), 2.0);
    col *= (0.9 + 0.1 * interlaceLines);
}
float phosphor = exp(-length(curved - 0.5) * 2.0) * phosphorGlow;
col += float3(0.0, phosphor * 0.5, phosphor);
col *= brightness;
float bezel = smoothstep(0.0, 0.05, curved.x) * smoothstep(1.0, 0.95, curved.x);
bezel *= smoothstep(0.0, 0.05, curved.y) * smoothstep(1.0, 0.95, curved.y);
col *= bezel;
return float4(col, 1.0);
"""

/// Glitch Art
let glitchArtCode = """
// @param glitchIntensity "Intensywność glitcha" range(0.0, 1.0) default(0.5)
// @param blockSize "Rozmiar bloków" range(0.02, 0.2) default(0.05)
// @param shiftAmount "Przesunięcie" range(0.0, 0.2) default(0.1)
// @param colorSplit "Rozdzielenie kolorów" range(0.0, 0.05) default(0.02)
// @param glitchSpeed "Prędkość glitcha" range(1.0, 20.0) default(5.0)
// @toggle digitalNoise "Cyfrowy szum" default(true)
float2 p = uv;
float time = floor(iTime * glitchSpeed);
float glitchTrigger = step(0.8, fract(sin(time * 43.758) * 43758.5453));
float blockY = floor(p.y / blockSize) * blockSize;
float blockRand = fract(sin(blockY * 43.758 + time) * 43758.5453);
if (blockRand > (1.0 - glitchIntensity) && glitchTrigger > 0.5) {
    p.x += (blockRand - 0.5) * shiftAmount;
}
float3 col;
float r = sin(p.x * 50.0 + sin(p.y * 30.0 + iTime)) * 0.5 + 0.5;
float g = sin((p.x + colorSplit) * 50.0 + sin(p.y * 30.0 + iTime)) * 0.5 + 0.5;
float b = sin((p.x - colorSplit) * 50.0 + sin(p.y * 30.0 + iTime)) * 0.5 + 0.5;
col = float3(r, g, b);
if (digitalNoise > 0.5) {
    float noise = fract(sin(dot(floor(p * 100.0) + time, float2(12.9898, 78.233))) * 43758.5453);
    if (noise > 0.98 && glitchTrigger > 0.5) {
        col = float3(1.0);
    }
}
float corruptLine = step(0.995, fract(sin(floor(p.y * 50.0 + time * 0.1) * 43.758) * 43758.5453));
corruptLine *= glitchTrigger * glitchIntensity;
col = mix(col, float3(1.0) - col, corruptLine);
return float4(col, 1.0);
"""

/// Pixel Art Style
let pixelArtCode = """
// @param pixelSize "Rozmiar pikseli" range(4.0, 64.0) default(16.0)
// @param colorDepth "Głębia kolorów" range(2.0, 16.0) default(8.0)
// @param dithering "Dithering" range(0.0, 1.0) default(0.3)
// @param palette "Paleta" range(0.0, 3.0) default(0.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle showGrid "Pokaż siatkę" default(false)
float2 pixelUV = floor(uv * pixelSize) / pixelSize;
float2 pixelCenter = pixelUV + 0.5 / pixelSize;
float pattern = sin(pixelCenter.x * 20.0 + iTime) * sin(pixelCenter.y * 20.0 + iTime * 0.7);
pattern = pattern * 0.5 + 0.5;
float3 col;
if (palette < 1.0) {
    col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0));
} else if (palette < 2.0) {
    col = float3(pattern, pattern * 0.8, pattern * 0.5);
} else if (palette < 3.0) {
    col = float3(pattern * 0.3, pattern, pattern * 0.5);
} else {
    col = float3(pattern, pattern * 0.5, pattern);
}
col = pow(col, float3(contrast));
if (dithering > 0.0) {
    float2 ditherPos = fract(uv * pixelSize);
    float ditherPattern = fmod(floor(ditherPos.x * 2.0) + floor(ditherPos.y * 2.0), 2.0);
    col += (ditherPattern - 0.5) * dithering * 0.1;
}
col = floor(col * colorDepth) / colorDepth;
if (showGrid > 0.5) {
    float2 gridPos = fract(uv * pixelSize);
    float grid = step(0.95, max(gridPos.x, gridPos.y));
    col = mix(col, float3(0.0), grid * 0.5);
}
return float4(col, 1.0);
"""

/// Arcade Machine
let arcadeMachineCode = """
// @param screenGlow "Poświata ekranu" range(0.0, 1.0) default(0.5)
// @param scanlineGap "Odstęp linii" range(100.0, 500.0) default(200.0)
// @param bloomAmount "Bloom" range(0.0, 1.0) default(0.3)
// @param colorBoost "Wzmocnienie kolorów" range(1.0, 2.0) default(1.3)
// @param noiseLevel "Poziom szumu" range(0.0, 0.2) default(0.05)
// @toggle cabinetFrame "Ramka automatu" default(true)
float2 p = uv;
float3 col = float3(0.0);
float game = sin(p.x * 30.0 + iTime * 2.0) * sin(p.y * 30.0 + iTime * 1.5);
game = step(0.0, game);
float3 gameColor = game * float3(0.2, 1.0, 0.3);
float player = smoothstep(0.05, 0.03, length(p - float2(0.5 + sin(iTime) * 0.2, 0.3)));
gameColor += player * float3(1.0, 1.0, 0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 enemyPos = float2(0.2 + fi * 0.15, 0.7 + sin(iTime + fi) * 0.1);
    float enemy = smoothstep(0.03, 0.02, length(p - enemyPos));
    gameColor += enemy * float3(1.0, 0.0, 0.3);
}
col = gameColor * colorBoost;
float scanline = sin(p.y * scanlineGap) * 0.5 + 0.5;
col *= (0.9 + 0.1 * scanline);
col += col * bloomAmount * 0.3;
float noise = fract(sin(dot(p + iTime, float2(12.9898, 78.233))) * 43758.5453);
col += (noise - 0.5) * noiseLevel;
float glow = exp(-length(p - 0.5) * 2.0) * screenGlow;
col += float3(0.0, glow * 0.2, glow * 0.1);
if (cabinetFrame > 0.5) {
    float frame = step(0.05, p.x) * step(p.x, 0.95) * step(0.05, p.y) * step(p.y, 0.95);
    col *= frame;
    float bezel = (1.0 - frame) * 0.1;
    col += bezel * float3(0.1, 0.1, 0.1);
}
return float4(col, 1.0);
"""

/// Commodore 64 Style
let c64StyleCode = """
// @param charScale "Skala znaków" range(8.0, 32.0) default(16.0)
// @param borderSize "Rozmiar ramki" range(0.0, 0.15) default(0.08)
// @param scrollSpeed "Prędkość przewijania" range(0.0, 3.0) default(1.0)
// @param colorCycle "Cykl kolorów" range(0.0, 2.0) default(0.5)
// @param scanlines "Linie skanujące" range(0.0, 1.0) default(0.3)
// @toggle flashCursor "Migający kursor" default(true)
float2 p = uv;
float3 c64Blue = float3(0.2, 0.3, 0.8);
float3 c64LightBlue = float3(0.4, 0.6, 1.0);
float3 col = c64Blue;
float2 borderMin = float2(borderSize);
float2 borderMax = float2(1.0 - borderSize);
if (p.x > borderMin.x && p.x < borderMax.x && p.y > borderMin.y && p.y < borderMax.y) {
    float2 screenP = (p - borderMin) / (borderMax - borderMin);
    screenP.x += iTime * scrollSpeed * 0.1;
    float2 charPos = floor(screenP * charScale);
    float charRand = fract(sin(dot(charPos, float2(12.9898, 78.233))) * 43758.5453);
    float char = step(0.3, charRand) * step(charRand, 0.7);
    float2 inChar = fract(screenP * charScale);
    float charPixel = step(0.2, inChar.x) * step(inChar.x, 0.8);
    charPixel *= step(0.2, inChar.y) * step(inChar.y, 0.8);
    charPixel *= char;
    float3 textColor = 0.5 + 0.5 * cos(charPos.x * 0.1 + iTime * colorCycle + float3(0.0, 2.0, 4.0));
    col = mix(float3(0.1, 0.1, 0.3), textColor, charPixel);
    if (flashCursor > 0.5) {
        float cursorX = fmod(floor(iTime * 2.0), charScale);
        float cursorY = charScale - 1.0;
        float cursor = step(cursorX - 0.5, charPos.x) * step(charPos.x, cursorX + 0.5);
        cursor *= step(cursorY - 0.5, charPos.y) * step(charPos.y, cursorY + 0.5);
        cursor *= step(0.5, sin(iTime * 5.0));
        col += cursor * c64LightBlue;
    }
}
if (scanlines > 0.0) {
    float scanline = sin(p.y * 500.0) * 0.5 + 0.5;
    col *= (1.0 - scanlines * 0.3 + scanlines * 0.3 * scanline);
}
return float4(col, 1.0);
"""

/// Synthwave Horizon
let synthwaveHorizonCode = """
// @param gridSpeed "Prędkość siatki" range(0.5, 5.0) default(2.0)
// @param sunSize "Rozmiar słońca" range(0.1, 0.4) default(0.25)
// @param horizonLine "Linia horyzontu" range(0.3, 0.7) default(0.5)
// @param gridDensity "Gęstość siatki" range(5.0, 20.0) default(10.0)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.5)
// @toggle mountains "Góry" default(true)
float2 p = uv;
float3 col = float3(0.0);
float sky = smoothstep(horizonLine + 0.3, horizonLine, p.y);
float3 skyColor = mix(float3(0.1, 0.0, 0.2), float3(0.5, 0.0, 0.3), sky);
col = skyColor;
float2 sunCenter = float2(0.5, horizonLine + 0.1);
float sunDist = length(p - sunCenter);
float sun = smoothstep(sunSize + 0.02, sunSize, sunDist);
float sunStripes = step(0.5, sin(p.y * 50.0));
sun *= sunStripes + (1.0 - step(horizonLine, p.y));
float3 sunColor = mix(float3(1.0, 0.8, 0.0), float3(1.0, 0.3, 0.5), (sunCenter.y - p.y) / sunSize + 0.5);
col = mix(col, sunColor, sun);
if (p.y < horizonLine) {
    float groundY = (horizonLine - p.y) / horizonLine;
    float z = 1.0 / (groundY + 0.01);
    float x = (p.x - 0.5) * z;
    x += iTime * gridSpeed;
    z += iTime * gridSpeed * 3.0;
    float gridX = smoothstep(0.1, 0.0, abs(fract(x / gridDensity) - 0.5));
    float gridZ = smoothstep(0.1, 0.0, abs(fract(z / gridDensity) - 0.5));
    float grid = max(gridX, gridZ);
    float3 gridColor = float3(1.0, 0.0, 0.5);
    col = mix(float3(0.05, 0.0, 0.1), gridColor, grid);
    col *= (1.0 - groundY * 0.5);
}
if (mountains > 0.5 && p.y < horizonLine + 0.1 && p.y > horizonLine - 0.15) {
    float mountain = sin(p.x * 20.0) * 0.05 + sin(p.x * 7.0) * 0.03;
    float mountainShape = step(p.y, horizonLine + mountain);
    col = mix(col, float3(0.1, 0.0, 0.15), mountainShape);
}
float glow = exp(-sunDist * 3.0) * glowIntensity;
col += glow * float3(1.0, 0.5, 0.3);
return float4(col, 1.0);
"""

/// Neon City
let neonCityCode = """
// @param buildingDensity "Gęstość budynków" range(10.0, 40.0) default(20.0)
// @param neonBrightness "Jasność neonów" range(0.5, 2.0) default(1.0)
// @param rainAmount "Ilość deszczu" range(0.0, 1.0) default(0.3)
// @param reflectionStrength "Siła odbić" range(0.0, 1.0) default(0.5)
// @param fogDensity "Gęstość mgły" range(0.0, 1.0) default(0.3)
// @toggle animatedSigns "Animowane znaki" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.01, 0.05);
float horizon = 0.4;
if (p.y > horizon) {
    float skyGrad = (p.y - horizon) / (1.0 - horizon);
    col = mix(float3(0.1, 0.02, 0.15), float3(0.02, 0.01, 0.05), skyGrad);
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float bx = fract(sin(fi * 127.1) * 43758.5453);
        float bh = fract(sin(fi * 311.7) * 43758.5453) * 0.5 + 0.2;
        float bw = 0.02 + fract(sin(fi * 78.233) * 43758.5453) * 0.03;
        float building = step(abs(p.x - bx), bw);
        building *= step(horizon, p.y) * step(p.y, horizon + bh);
        float depth = fi / 30.0;
        float3 buildingColor = float3(0.05, 0.03, 0.08) * (1.0 - depth * 0.5);
        col = mix(col, buildingColor, building);
        if (animatedSigns > 0.5) {
            float signY = horizon + bh * 0.7;
            float sign = step(abs(p.x - bx), bw * 0.8) * step(abs(p.y - signY), 0.01);
            float signFlicker = step(0.3, sin(iTime * 5.0 + fi));
            float3 signColor = 0.5 + 0.5 * cos(fi + float3(0.0, 2.0, 4.0));
            col += sign * signColor * neonBrightness * signFlicker;
        }
        float windowChance = fract(sin(dot(float2(floor(p.x * 100.0), floor(p.y * 50.0)), float2(12.9898, 78.233)) + fi) * 43758.5453);
        float window = step(0.7, windowChance) * building;
        float3 windowColor = float3(1.0, 0.9, 0.6);
        col += window * windowColor * 0.3;
    }
}
if (rainAmount > 0.0) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float rx = fract(sin(fi * 43.758) * 43758.5453);
        float ry = fract(sin(fi * 78.233) * 43758.5453 - iTime * 0.5);
        float rain = smoothstep(0.01, 0.0, abs(p.x - rx)) * smoothstep(0.03, 0.0, abs(fract(p.y + ry) - 0.5));
        col += rain * rainAmount * 0.3;
    }
}
if (p.y < horizon && reflectionStrength > 0.0) {
    float2 reflP = float2(p.x, horizon - (horizon - p.y));
    float refl = sin(reflP.x * buildingDensity + iTime) * 0.5 + 0.5;
    col += refl * float3(0.1, 0.05, 0.15) * reflectionStrength * (horizon - p.y) / horizon;
}
col = mix(col, float3(0.05, 0.02, 0.1), fogDensity * (1.0 - p.y));
return float4(col, 1.0);
"""

/// Digital Rain Advanced
let digitalRainAdvancedCode = """
// @param columnCount "Liczba kolumn" range(10, 50) default(30)
// @param fallSpeed "Prędkość opadania" range(0.5, 3.0) default(1.0)
// @param trailLength "Długość śladu" range(5, 20) default(10)
// @param brightness "Jasność" range(0.5, 2.0) default(1.0)
// @param colorHue "Odcień koloru" range(0.0, 1.0) default(0.33)
// @toggle highlightHead "Podświetl głowicę" default(true)
float2 p = uv;
float3 col = float3(0.0);
float3 mainColor = 0.5 + 0.5 * cos(colorHue * 6.28 + float3(0.0, 2.0, 4.0));
for (int i = 0; i < 50; i++) {
    if (float(i) >= float(columnCount)) break;
    float fi = float(i);
    float x = (fi + 0.5) / float(columnCount);
    float speed = 0.5 + fract(sin(fi * 127.1) * 43758.5453) * 0.5;
    float offset = fract(sin(fi * 311.7) * 43758.5453);
    float headY = fract(iTime * fallSpeed * speed + offset);
    float colDist = abs(p.x - x) * float(columnCount);
    if (colDist < 0.5) {
        for (int j = 0; j < 20; j++) {
            if (j >= int(trailLength)) break;
            float fj = float(j);
            float charY = headY - fj * 0.03;
            if (charY < 0.0) charY += 1.0;
            float charDist = abs(p.y - charY);
            if (charDist < 0.015) {
                float fade = 1.0 - fj / float(trailLength);
                float charRand = fract(sin(fi * 43.758 + fj * 12.345 + floor(iTime * 10.0)) * 43758.5453);
                float charPattern = step(0.3, charRand);
                float3 charColor = mainColor * fade * brightness * charPattern;
                if (highlightHead > 0.5 && j == 0) {
                    charColor = float3(1.0) * brightness * charPattern;
                }
                col += charColor * (1.0 - colDist * 2.0);
            }
        }
    }
}
return float4(col, 1.0);
"""

/// Demoscene Plasma
let demoscenePlasmaCode = """
// @param scale "Skala" range(1.0, 10.0) default(4.0)
// @param speed "Prędkość" range(0.5, 5.0) default(2.0)
// @param colorRotation "Rotacja kolorów" range(0.0, 2.0) default(0.5)
// @param distortion "Zniekształcenie" range(0.0, 1.0) default(0.3)
// @param bands "Liczba pasm" range(1.0, 5.0) default(2.0)
// @toggle copper "Efekt Copper" default(true)
float2 p = uv * scale;
float time = iTime * speed;
float plasma = 0.0;
plasma += sin(p.x + time);
plasma += sin(p.y + time * 0.5);
plasma += sin((p.x + p.y + time) * 0.5);
float cx = p.x + sin(time / 3.0) * distortion * 3.0;
float cy = p.y + cos(time / 2.0) * distortion * 3.0;
plasma += sin(sqrt(cx * cx + cy * cy + 1.0) + time);
plasma = plasma * bands * 0.5;
float3 col = 0.5 + 0.5 * cos(plasma + iTime * colorRotation + float3(0.0, 2.0, 4.0));
if (copper > 0.5) {
    float copperBar = sin(uv.y * 50.0 + iTime * 10.0) * 0.5 + 0.5;
    float3 copperColor = 0.5 + 0.5 * cos(uv.y * 20.0 + iTime * 3.0 + float3(0.0, 1.0, 2.0));
    col = mix(col, copperColor, copperBar * 0.3);
}
return float4(col, 1.0);
"""

// MARK: - Glitch & Corruption Effects

/// Data Corruption
let dataCorruptionCode = """
// @param corruptionLevel "Poziom korupcji" range(0.0, 1.0) default(0.4)
// @param blockScale "Skala bloków" range(0.02, 0.2) default(0.05)
// @param shiftRange "Zakres przesunięcia" range(0.0, 0.3) default(0.1)
// @param colorCorruption "Korupcja kolorów" range(0.0, 1.0) default(0.3)
// @param updateSpeed "Prędkość aktualizacji" range(1.0, 30.0) default(10.0)
// @toggle rgbShift "Przesunięcie RGB" default(true)
float2 p = uv;
float time = floor(iTime * updateSpeed);
float2 blockId = floor(p / blockScale);
float blockRand = fract(sin(dot(blockId, float2(12.9898, 78.233)) + time) * 43758.5453);
if (blockRand < corruptionLevel) {
    float shiftX = (fract(sin(blockId.x * 43.758 + time) * 43758.5453) - 0.5) * shiftRange;
    float shiftY = (fract(sin(blockId.y * 78.233 + time) * 43758.5453) - 0.5) * shiftRange * 0.5;
    p += float2(shiftX, shiftY);
}
float3 col;
float pattern = sin(p.x * 50.0 + iTime) * sin(p.y * 50.0 + iTime * 0.7);
pattern = pattern * 0.5 + 0.5;
col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0));
if (rgbShift > 0.5 && blockRand < corruptionLevel) {
    float rShift = fract(sin(blockId.x * 127.1 + time) * 43758.5453) * 0.02;
    float bShift = fract(sin(blockId.y * 311.7 + time) * 43758.5453) * 0.02;
    col.r = sin((p.x + rShift) * 50.0 + iTime) * 0.5 + 0.5;
    col.b = sin((p.x - bShift) * 50.0 + iTime) * 0.5 + 0.5;
}
if (colorCorruption > 0.0 && fract(sin(dot(blockId * 2.0, float2(127.1, 311.7)) + time) * 43758.5453) < colorCorruption * 0.3) {
    col = float3(1.0) - col;
}
return float4(col, 1.0);
"""

/// Signal Interference
let signalInterferenceCode = """
// @param interferenceStrength "Siła zakłóceń" range(0.0, 1.0) default(0.5)
// @param waveCount "Liczba fal" range(1, 10) default(5)
// @param noiseFrequency "Częstotliwość szumu" range(10.0, 100.0) default(50.0)
// @param rollSpeed "Prędkość przewijania" range(0.0, 5.0) default(1.0)
// @param colorShift "Przesunięcie kolorów" range(0.0, 0.1) default(0.02)
// @toggle verticalHold "Synchronizacja pionowa" default(true)
float2 p = uv;
if (verticalHold > 0.5) {
    float rollOffset = sin(iTime * rollSpeed) * 0.1 * interferenceStrength;
    p.y = fract(p.y + rollOffset);
}
float interference = 0.0;
for (int i = 0; i < 10; i++) {
    if (float(i) >= float(waveCount)) break;
    float fi = float(i);
    float freq = 10.0 + fi * 5.0;
    float phase = iTime * (1.0 + fi * 0.3);
    interference += sin(p.y * freq + phase) / (fi + 1.0);
}
interference *= interferenceStrength;
p.x += interference * 0.05;
float noise = fract(sin(dot(p * noiseFrequency + iTime, float2(12.9898, 78.233))) * 43758.5453);
float3 col;
float signal = sin(p.x * 30.0 + p.y * 20.0 + iTime) * 0.5 + 0.5;
col.r = signal;
col.g = sin((p.x + colorShift) * 30.0 + p.y * 20.0 + iTime) * 0.5 + 0.5;
col.b = sin((p.x - colorShift) * 30.0 + p.y * 20.0 + iTime) * 0.5 + 0.5;
col += (noise - 0.5) * interferenceStrength * 0.3;
float staticBurst = step(0.95, fract(sin(floor(iTime * 10.0) * 43.758) * 43758.5453));
col += staticBurst * (noise - 0.5) * 0.5;
return float4(col, 1.0);
"""

/// Broken LCD
let brokenLCDCode = """
// @param deadPixelDensity "Gęstość martwych pikseli" range(0.0, 0.1) default(0.02)
// @param lineDefects "Defekty linii" range(0, 5) default(2)
// @param pressurePoint "Punkt nacisku" range(0.0, 1.0) default(0.0)
// @param colorBleed "Rozmazanie kolorów" range(0.0, 0.5) default(0.1)
// @param flickerAmount "Migotanie" range(0.0, 0.3) default(0.1)
// @toggle backlight "Podświetlenie" default(true)
float2 p = uv;
float3 col = float3(0.0);
float content = sin(p.x * 20.0 + iTime) * sin(p.y * 15.0 + iTime * 0.7);
content = content * 0.5 + 0.5;
col = 0.5 + 0.5 * cos(content * 3.14 + float3(0.0, 2.0, 4.0));
float2 pixelPos = floor(p * 200.0);
float deadPixel = fract(sin(dot(pixelPos, float2(12.9898, 78.233))) * 43758.5453);
if (deadPixel < deadPixelDensity) {
    col = float3(0.0);
}
for (int i = 0; i < 5; i++) {
    if (float(i) >= float(lineDefects)) break;
    float fi = float(i);
    float lineY = fract(sin(fi * 127.1) * 43758.5453);
    float lineType = fract(sin(fi * 311.7) * 43758.5453);
    if (abs(p.y - lineY) < 0.003) {
        if (lineType < 0.5) {
            col = float3(0.0);
        } else {
            col = float3(1.0);
        }
    }
}
if (pressurePoint > 0.0) {
    float2 pressCenter = float2(0.3, 0.6);
    float pressDist = length(p - pressCenter);
    float pressure = smoothstep(pressurePoint * 0.3, 0.0, pressDist);
    float3 pressColor = 0.5 + 0.5 * cos(pressDist * 30.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, pressColor, pressure * pressurePoint);
}
col.r = mix(col.r, sin((p.x + colorBleed) * 20.0 + iTime) * 0.5 + 0.5, colorBleed);
col.b = mix(col.b, sin((p.x - colorBleed) * 20.0 + iTime) * 0.5 + 0.5, colorBleed);
float flicker = 1.0 - flickerAmount * 0.5 + flickerAmount * 0.5 * sin(iTime * 120.0);
col *= flicker;
if (backlight > 0.5) {
    float bl = 0.9 + 0.1 * sin(p.y * 3.0);
    col *= bl;
    col += float3(0.02, 0.02, 0.03);
}
return float4(col, 1.0);
"""

/// Hologram Display
let hologramDisplayCode = """
// @param scanlineSpacing "Odstęp linii skanujących" range(50.0, 200.0) default(100.0)
// @param flickerIntensity "Intensywność migotania" range(0.0, 0.5) default(0.2)
// @param noiseLevel "Poziom szumu" range(0.0, 0.3) default(0.1)
// @param rgbSeparation "Separacja RGB" range(0.0, 0.02) default(0.005)
// @param distortionWave "Fala zniekształcenia" range(0.0, 0.1) default(0.03)
// @toggle tripleImage "Potrójny obraz" default(false)
float2 p = uv;
p.x += sin(p.y * 10.0 + iTime * 5.0) * distortionWave;
float3 col = float3(0.0);
float shape = smoothstep(0.3, 0.28, length(p - 0.5));
shape += smoothstep(0.32, 0.3, length(p - 0.5)) * 0.3;
float3 holoColor = float3(0.0, 0.8, 1.0);
if (tripleImage > 0.5) {
    float shape1 = smoothstep(0.3, 0.28, length(p - float2(0.48, 0.5)));
    float shape2 = smoothstep(0.3, 0.28, length(p - float2(0.52, 0.5)));
    col += shape1 * float3(1.0, 0.0, 0.0) * 0.3;
    col += shape2 * float3(0.0, 0.0, 1.0) * 0.3;
}
col += shape * holoColor;
float scanline = sin(p.y * scanlineSpacing) * 0.5 + 0.5;
col *= (0.8 + 0.2 * scanline);
float flicker = 1.0 - flickerIntensity * (fract(sin(iTime * 50.0) * 43758.5453));
col *= flicker;
float noise = fract(sin(dot(p + iTime, float2(12.9898, 78.233))) * 43758.5453);
col += (noise - 0.5) * noiseLevel;
col.r = mix(col.r, col.g, p.x * rgbSeparation * 10.0);
col.b = mix(col.b, col.g, (1.0 - p.x) * rgbSeparation * 10.0);
float edge = smoothstep(0.0, 0.1, p.x) * smoothstep(1.0, 0.9, p.x);
edge *= smoothstep(0.0, 0.1, p.y) * smoothstep(1.0, 0.9, p.y);
col *= edge;
return float4(col, 1.0);
"""

/// Databending
let databendingCode = """
// @param bendIntensity "Intensywność zginania" range(0.0, 1.0) default(0.5)
// @param chunkSize "Rozmiar fragmentów" range(0.01, 0.1) default(0.03)
// @param sortAmount "Sortowanie" range(0.0, 1.0) default(0.3)
// @param repeatGlitch "Powtarzanie glitcha" range(0.0, 0.5) default(0.1)
// @param colorShift "Przesunięcie kolorów" range(0.0, 1.0) default(0.2)
// @toggle invertRandom "Losowa inwersja" default(true)
float2 p = uv;
float time = floor(iTime * 5.0);
float chunkY = floor(p.y / chunkSize) * chunkSize;
float chunkRand = fract(sin(chunkY * 43.758 + time) * 43758.5453);
if (chunkRand < bendIntensity) {
    float bendAmount = (chunkRand - 0.5) * 0.5;
    p.x = fract(p.x + bendAmount);
    if (sortAmount > 0.0) {
        p.x = mix(p.x, chunkRand, sortAmount);
    }
}
if (repeatGlitch > 0.0 && fract(sin(chunkY * 78.233 + time) * 43758.5453) < repeatGlitch) {
    p.x = fract(p.x * 3.0);
}
float3 col;
float pattern = sin(p.x * 30.0 + iTime) * sin(p.y * 20.0);
pattern = pattern * 0.5 + 0.5;
col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(0.0, 2.0, 4.0));
if (colorShift > 0.0 && chunkRand < bendIntensity) {
    float shift = colorShift * chunkRand;
    col = 0.5 + 0.5 * cos(pattern * 6.28 + float3(shift, 2.0 + shift, 4.0 - shift));
}
if (invertRandom > 0.5 && fract(sin(chunkY * 127.1 + time) * 43758.5453) < bendIntensity * 0.3) {
    col = float3(1.0) - col;
}
return float4(col, 1.0);
"""

/// TV Static
let tvStaticCode = """
// @param staticIntensity "Intensywność statyczna" range(0.0, 1.0) default(0.7)
// @param scanlineBlend "Mieszanie linii skanujących" range(0.0, 1.0) default(0.3)
// @param colorStatic "Kolorowy szum" range(0.0, 1.0) default(0.0)
// @param signalStrength "Siła sygnału" range(0.0, 1.0) default(0.2)
// @param rollSpeed "Prędkość przewijania" range(0.0, 2.0) default(0.5)
// @toggle ghostImage "Obraz-duch" default(true)
float2 p = uv;
float roll = fract(p.y + iTime * rollSpeed);
p.y = roll;
float3 col = float3(0.0);
float noise = fract(sin(dot(floor(p * 500.0) + iTime * 100.0, float2(12.9898, 78.233))) * 43758.5453);
if (colorStatic > 0.0) {
    col.r = fract(sin(dot(floor(p * 500.0) + iTime * 100.0, float2(127.1, 311.7))) * 43758.5453);
    col.g = fract(sin(dot(floor(p * 500.0) + iTime * 100.0, float2(269.5, 183.3))) * 43758.5453);
    col.b = noise;
    col = mix(float3(noise), col, colorStatic);
} else {
    col = float3(noise);
}
col *= staticIntensity;
if (signalStrength > 0.0) {
    float signal = sin(p.x * 50.0 + iTime * 2.0) * sin(p.y * 40.0);
    signal = signal * 0.5 + 0.5;
    float3 signalColor = 0.5 + 0.5 * cos(signal * 3.14 + float3(0.0, 2.0, 4.0));
    float signalMask = step(0.5, sin(iTime * 3.0 + p.y * 10.0));
    col = mix(col, signalColor, signalStrength * signalMask);
}
if (ghostImage > 0.5) {
    float2 ghostP = p + float2(0.05, 0.0);
    float ghost = sin(ghostP.x * 50.0 + iTime * 2.0) * sin(ghostP.y * 40.0) * 0.5 + 0.5;
    col += float3(ghost) * 0.2 * signalStrength;
}
float scanline = sin(p.y * 300.0) * 0.5 + 0.5;
col *= (1.0 - scanlineBlend * (1.0 - scanline));
return float4(col, 1.0);
"""

/// ASCII Art Shader
let asciiArtShaderCode = """
// @param charSize "Rozmiar znaków" range(8.0, 32.0) default(16.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.2)
// @param brightness "Jasność" range(0.0, 1.0) default(0.5)
// @param charSet "Zestaw znaków" range(0.0, 2.0) default(0.0)
// @param colorMode "Tryb kolorów" range(0.0, 2.0) default(0.0)
// @toggle inverted "Odwrócony" default(false)
float2 p = uv;
float2 charCell = floor(p * charSize);
float2 cellCenter = (charCell + 0.5) / charSize;
float value = sin(cellCenter.x * 20.0 + iTime) * sin(cellCenter.y * 15.0 + iTime * 0.7);
value = value * 0.5 + 0.5;
value = pow(value, 1.0 / contrast) * brightness * 2.0;
if (inverted > 0.5) {
    value = 1.0 - value;
}
float2 inCell = fract(p * charSize);
float charPattern = 0.0;
int charIndex = int(value * 10.0);
if (charSet < 1.0) {
    if (charIndex > 8) charPattern = step(0.2, inCell.x) * step(inCell.x, 0.8) * step(0.2, inCell.y) * step(inCell.y, 0.8);
    else if (charIndex > 6) charPattern = step(0.3, inCell.x) * step(inCell.x, 0.7);
    else if (charIndex > 4) charPattern = step(0.4, inCell.y) * step(inCell.y, 0.6);
    else if (charIndex > 2) charPattern = step(0.5, abs(inCell.x - 0.5) + abs(inCell.y - 0.5));
    else charPattern = 0.0;
} else {
    float hash = fract(sin(dot(charCell, float2(12.9898, 78.233)) + float(charIndex)) * 43758.5453);
    charPattern = step(1.0 - value, hash);
}
float3 col;
if (colorMode < 1.0) {
    col = float3(charPattern);
} else if (colorMode < 2.0) {
    col = charPattern * float3(0.0, 1.0, 0.0);
} else {
    col = charPattern * (0.5 + 0.5 * cos(cellCenter.x * 10.0 + iTime + float3(0.0, 2.0, 4.0)));
}
return float4(col, 1.0);
"""

/// Bitcrusher Visual
let bitcrusherCode = """
// @param bitDepth "Głębia bitowa" range(1.0, 8.0) default(3.0)
// @param sampleRate "Częstotliwość próbkowania" range(10.0, 100.0) default(30.0)
// @param noiseFloor "Szum tła" range(0.0, 0.3) default(0.05)
// @param waveformMix "Mieszanka fali" range(0.0, 1.0) default(0.5)
// @param colorDepth "Głębia kolorów" range(2.0, 16.0) default(4.0)
// @toggle dithering "Dithering" default(true)
float2 p = uv;
float2 crushedP = floor(p * sampleRate) / sampleRate;
float wave1 = sin(crushedP.x * 30.0 + iTime * 2.0);
float wave2 = sin(crushedP.y * 20.0 + iTime * 1.5);
float wave = mix(wave1, wave2, waveformMix);
float levels = pow(2.0, bitDepth);
wave = floor(wave * levels) / levels;
float3 col = 0.5 + 0.5 * cos(wave * 6.28 + float3(0.0, 2.0, 4.0));
col = floor(col * colorDepth) / colorDepth;
if (dithering > 0.5) {
    float2 ditherPos = fract(p * sampleRate);
    float dither = fmod(floor(ditherPos.x * 2.0) + floor(ditherPos.y * 2.0), 2.0);
    col += (dither - 0.5) / colorDepth;
}
float noise = fract(sin(dot(crushedP + iTime, float2(12.9898, 78.233))) * 43758.5453);
col += (noise - 0.5) * noiseFloor;
col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

/// Oscilloscope Display
let oscilloscopeCode = """
// @param waveAmplitude "Amplituda fali" range(0.1, 0.5) default(0.3)
// @param waveFrequency "Częstotliwość fali" range(1.0, 10.0) default(3.0)
// @param lineThickness "Grubość linii" range(0.005, 0.03) default(0.01)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.5)
// @param waveType "Typ fali" range(0.0, 3.0) default(0.0)
// @toggle lissajous "Tryb Lissajous" default(false)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.05, 0.02);
float gridX = smoothstep(0.02, 0.0, abs(fract(p.x * 5.0) - 0.5));
float gridY = smoothstep(0.02, 0.0, abs(fract(p.y * 5.0) - 0.5));
col += (gridX + gridY) * 0.05;
float wave;
if (lissajous > 0.5) {
    float lx = sin(iTime * waveFrequency) * waveAmplitude * 2.0;
    float ly = sin(iTime * waveFrequency * 1.5 + 1.57) * waveAmplitude * 2.0;
    float d = length(p - float2(lx, ly));
    wave = smoothstep(lineThickness * 2.0, 0.0, d);
    for (int i = 1; i < 20; i++) {
        float fi = float(i);
        float t = iTime - fi * 0.02;
        float tx = sin(t * waveFrequency) * waveAmplitude * 2.0;
        float ty = sin(t * waveFrequency * 1.5 + 1.57) * waveAmplitude * 2.0;
        float td = length(p - float2(tx, ty));
        wave += smoothstep(lineThickness, 0.0, td) * (1.0 - fi / 20.0) * 0.3;
    }
} else {
    float waveY;
    if (waveType < 1.0) {
        waveY = sin(p.x * waveFrequency * 6.28 + iTime * 5.0) * waveAmplitude;
    } else if (waveType < 2.0) {
        waveY = (fract(p.x * waveFrequency + iTime) * 2.0 - 1.0) * waveAmplitude;
    } else if (waveType < 3.0) {
        waveY = sign(sin(p.x * waveFrequency * 6.28 + iTime * 5.0)) * waveAmplitude;
    } else {
        waveY = abs(fract(p.x * waveFrequency + iTime) * 2.0 - 1.0) * 2.0 * waveAmplitude - waveAmplitude;
    }
    wave = smoothstep(lineThickness, 0.0, abs(p.y - waveY));
    float glow = smoothstep(lineThickness * 10.0, 0.0, abs(p.y - waveY)) * glowAmount;
    wave += glow * 0.5;
}
float3 waveColor = float3(0.2, 1.0, 0.3);
col += wave * waveColor;
return float4(col, 1.0);
"""

/// Gameboy Style
let gameboyStyleCode = """
// @param pixelSize "Rozmiar pikseli" range(4.0, 20.0) default(8.0)
// @param scanlineIntensity "Intensywność linii skanowania" range(0.0, 0.5) default(0.2)
// @param patternSpeed "Prędkość wzoru" range(0.0, 2.0) default(0.5)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param ditherAmount "Ilość ditheringu" range(0.0, 1.0) default(0.3)
// @toggle originalGreen "Oryginalna zieleń" default(true)
float2 p = uv;
// Pixelate
float2 pixelUV = floor(p * pixelSize * 10.0) / (pixelSize * 10.0);
// Create pattern
float pattern = sin(pixelUV.x * 20.0 + iTime * patternSpeed) * 
                sin(pixelUV.y * 15.0 + iTime * patternSpeed * 0.7);
pattern += sin(length(pixelUV - 0.5) * 30.0 - iTime * 2.0) * 0.5;
pattern = pattern * 0.5 + 0.5;
pattern = pow(pattern, 1.0 / contrast);
// Dithering
float2 ditherCoord = floor(p * pixelSize * 10.0);
float dither = fract(sin(dot(ditherCoord, float2(12.9898, 78.233))) * 43758.5453);
pattern += (dither - 0.5) * ditherAmount * 0.2;
// Quantize to 4 shades
float shade = floor(pattern * 4.0) / 3.0;
shade = clamp(shade, 0.0, 1.0);
// Gameboy color palette
float3 col;
if (originalGreen > 0.5) {
    // Original DMG green palette
    float3 darkest = float3(0.06, 0.22, 0.06);
    float3 dark = float3(0.19, 0.38, 0.19);
    float3 light = float3(0.55, 0.67, 0.06);
    float3 lightest = float3(0.61, 0.73, 0.06);
    if (shade < 0.33) {
        col = mix(darkest, dark, shade * 3.0);
    } else if (shade < 0.66) {
        col = mix(dark, light, (shade - 0.33) * 3.0);
    } else {
        col = mix(light, lightest, (shade - 0.66) * 3.0);
    }
} else {
    // Grayscale
    col = float3(shade);
}
// Scanlines
float scanline = sin(p.y * pixelSize * 10.0 * 3.14159) * 0.5 + 0.5;
col *= 1.0 - scanline * scanlineIntensity;
// Screen border vignette
float vignette = smoothstep(0.5, 0.3, max(abs(p.x - 0.5), abs(p.y - 0.5)));
col *= 0.8 + vignette * 0.2;
return float4(col, 1.0);
"""

