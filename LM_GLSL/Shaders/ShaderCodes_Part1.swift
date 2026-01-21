//
//  ShaderCodes.swift
//  LM_GLSL
//
//  All shader fragment codes - Part 1: Basic, Tunnels, Nature, Geometric
//

import Foundation

// MARK: - Basic Category

let rainbowGradientCode = """
// @param speed "Prędkość" range(0.0, 2.0) default(0.2)
// @param frequency "Częstotliwość" range(0.5, 10.0) default(6.28318)
// @param saturation "Nasycenie" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 1.0) default(0.5)
// @param phaseR "Faza czerwieni" range(0.0, 1.0) default(0.0)
// @param phaseG "Faza zieleni" range(0.0, 1.0) default(0.33)
// @param phaseB "Faza niebieskiego" range(0.0, 1.0) default(0.67)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param scale "Skala" range(0.1, 5.0) default(1.0)
// @param rotation "Rotacja" range(0.0, 6.28) default(0.0)
// @param waveAmplitude "Amplituda fali" range(0.0, 0.5) default(0.0)
// @toggle horizontal "Poziomy" default(true)
// @toggle vertical "Pionowy" default(false)
// @toggle diagonal "Ukośny" default(false)
// @toggle radial "Promieniowy" default(false)
// @toggle animated "Animowany" default(true)
// @toggle reverse "Odwróć kierunek" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle colorShift "Przesunięcie kolorów" default(false)
// @toggle rainbow "Pełne spektrum" default(true)
// @toggle pastel "Pastelowe kolory" default(false)
// @toggle neon "Neonowe kolory" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle stripes "Paski" default(false)
// @toggle smooth "Wygładzanie" default(true)
// @toggle noise "Szum" default(false)
// @toggle vignette "Winieta" default(false)

float2 p = (uv - 0.5 + float2(offsetX, offsetY)) * scale;
float c = cos(rotation); float s = sin(rotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
p += 0.5;

float t = 0.0;
if (horizontal > 0.5) t += p.x;
if (vertical > 0.5) t += p.y;
if (diagonal > 0.5) t += (p.x + p.y) * 0.5;
if (radial > 0.5) t += length(p - 0.5);
if (t == 0.0) t = p.x;

if (mirror > 0.5) t = abs(t - 0.5) * 2.0;
if (waveAmplitude > 0.0) t += sin(p.y * 10.0 + iTime) * waveAmplitude;

float timeVal = animated > 0.5 ? iTime * speed : 0.0;
if (reverse > 0.5) timeVal = -timeVal;
t = t + timeVal;

if (stripes > 0.5) t = floor(t * 10.0) / 10.0;

float3 phase = float3(phaseR, phaseG, phaseB);
if (colorShift > 0.5) phase += iTime * 0.1;

float3 col = saturation + brightness * cos(frequency * (t + phase));

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 3.0);
if (pastel > 0.5) col = mix(col, float3(1.0), 0.3);
if (neon > 0.5) col = pow(col, float3(0.5)) * 1.5;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

if (vignette > 0.5) {
    float vig = 1.0 - length(uv - 0.5) * 0.8;
    col *= vig;
}

if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col, 1.0);
"""

let plasmaCode = """
// @param scale "Skala" range(1.0, 20.0) default(8.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param complexity "Złożoność" range(1.0, 5.0) default(1.0)
// @param colorShift "Przesunięcie koloru" range(0.0, 6.28) default(0.0)
// @param redAmount "Czerwień" range(0.0, 2.0) default(1.0)
// @param greenAmount "Zieleń" range(0.0, 2.0) default(1.0)
// @param blueAmount "Niebieski" range(0.0, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param distortion "Zniekształcenie" range(0.0, 1.0) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle radial "Promieniowy" default(false)
// @toggle spiral "Spirala" default(false)
// @toggle waves "Fale" default(true)
// @toggle colorCycle "Cykl kolorów" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle kaleidoscope "Kalejdoskop" default(false)
// @toggle highContrast "Wysoki kontrast" default(false)
// @toggle pastel "Pastelowy" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle grid "Siatka" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle smooth "Wygładzenie" default(true)
// @toggle vignette "Winieta" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * scale;

if (mirror > 0.5) p = abs(p);
if (kaleidoscope > 0.5) {
    float a = atan2(p.y, p.x);
    a = mod(a, 0.785) - 0.393;
    float r = length(p);
    p = float2(cos(a), sin(a)) * r;
}

float timeVal = animated > 0.5 ? iTime * speed : 0.0;

float v = 0.0;
if (waves > 0.5) {
    v += sin(p.x + timeVal);
    v += sin(p.y + timeVal * 0.5);
    v += sin((p.x + p.y) + timeVal * 0.3);
}
if (radial > 0.5) v += sin(length(p) * complexity + timeVal);
if (spiral > 0.5) v += sin(atan2(p.y, p.x) * 3.0 + length(p) * 2.0 - timeVal);

v *= complexity;
if (distortion > 0.0) v += sin(v * distortion * 10.0) * distortion;

float3 phase = float3(0.0, 2.0, 4.0) + colorShift;
if (colorCycle > 0.5) phase += iTime * 0.5;

float3 col = 0.5 + 0.5 * cos(v + phase);
col *= float3(redAmount, greenAmount, blueAmount);

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(iTime * 4.0);
if (invert > 0.5) col = 1.0 - col;
if (highContrast > 0.5) col = smoothstep(0.3, 0.7, col);
if (pastel > 0.5) col = mix(col, float3(1.0), 0.4);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 50.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}

if (grid > 0.5) {
    float2 g = abs(fract(uv * 10.0) - 0.5);
    col *= 0.8 + 0.2 * step(0.45, min(g.x, g.y));
}

if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.6;
if (smooth > 0.5) col = clamp(col, 0.0, 1.0);

return float4(col, 1.0);
"""

let noiseCode = """
// @param scale "Skala" range(1.0, 50.0) default(10.0)
// @param speed "Prędkość" range(0.0, 5.0) default(1.0)
// @param grainSize "Rozmiar ziarna" range(0.1, 2.0) default(1.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.0, 3.0) default(1.0)
// @param redTint "Odcień czerwieni" range(0.0, 2.0) default(1.0)
// @param greenTint "Odcień zieleni" range(0.0, 2.0) default(1.0)
// @param blueTint "Odcień niebieskiego" range(0.0, 2.0) default(1.0)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.0)
// @param layers "Warstwy" range(1.0, 5.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colored "Kolorowy" default(false)
// @toggle smooth "Wygładzony" default(false)
// @toggle fractal "Fraktalny" default(false)
// @toggle cellular "Komórkowy" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle pixelated "Pikselowy" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle film "Efekt filmu" default(false)
// @toggle chromatic "Aberracja chromatyczna" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle waves "Fale" default(false)
// @toggle vortex "Wir" default(false)
// @toggle grid "Siatka" default(false)
// @toggle vignette "Winieta" default(false)

float2 p = (uv + float2(offsetX, offsetY)) * scale;
float timeVal = animated > 0.5 ? iTime * speed : 0.0;

if (pixelated > 0.5) p = floor(p * grainSize) / grainSize;
if (vortex > 0.5) {
    float a = atan2(p.y - scale * 0.5, p.x - scale * 0.5);
    p += float2(cos(a), sin(a)) * timeVal;
}

float n = 0.0;
float amplitude = 1.0;
float freq = 1.0;

int numLayers = int(layers);
for (int i = 0; i < 5; i++) {
    if (i >= numLayers) break;
    float2 noiseP = floor(p * freq * grainSize + timeVal);
    float layerNoise = fract(sin(dot(noiseP, float2(12.9898, 78.233))) * 43758.5453);
    
    if (smooth > 0.5) {
        float2 f = fract(p * freq * grainSize + timeVal);
        f = f * f * (3.0 - 2.0 * f);
        float2 noiseP2 = floor(p * freq * grainSize + timeVal);
        float a = fract(sin(dot(noiseP2, float2(12.9898, 78.233))) * 43758.5453);
        float b = fract(sin(dot(noiseP2 + float2(1.0, 0.0), float2(12.9898, 78.233))) * 43758.5453);
        float c = fract(sin(dot(noiseP2 + float2(0.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
        float d = fract(sin(dot(noiseP2 + float2(1.0, 1.0), float2(12.9898, 78.233))) * 43758.5453);
        layerNoise = mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
    }
    
    n += layerNoise * amplitude;
    if (fractal < 0.5) break;
    amplitude *= 0.5;
    freq *= 2.0;
}

if (fractal > 0.5) n /= (2.0 - pow(0.5, float(numLayers)));
if (turbulence > 0.0) n = abs(n * 2.0 - 1.0) * turbulence + n * (1.0 - turbulence);

n = (n - 0.5) * contrast + 0.5;
n *= brightness;

if (waves > 0.5) n += sin(uv.y * 20.0 + timeVal * 2.0) * 0.1;
if (pulse > 0.5) n *= 0.8 + 0.2 * sin(timeVal * 3.0);

float3 col = float3(n);

if (colored > 0.5) {
    col = 0.5 + 0.5 * cos(n * 6.28 + float3(0.0, 2.0, 4.0) + timeVal);
}
if (gradient > 0.5) {
    col *= mix(float3(0.2, 0.3, 0.8), float3(1.0, 0.5, 0.2), uv.y);
}

col *= float3(redTint, greenTint, blueTint);

if (chromatic > 0.5) {
    float offset = 0.005;
    float nR = fract(sin(dot(floor((uv + float2(offset, 0.0) + float2(offsetX, offsetY)) * scale * grainSize + timeVal), float2(12.9898, 78.233))) * 43758.5453);
    float nB = fract(sin(dot(floor((uv - float2(offset, 0.0) + float2(offsetX, offsetY)) * scale * grainSize + timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col.r = nR * redTint * brightness;
    col.b = nB * blueTint * brightness;
}

if (invert > 0.5) col = 1.0 - col;
if (scanlines > 0.5) col *= 0.8 + 0.2 * sin(uv.y * 500.0);
if (film > 0.5) {
    col = mix(col, float3(dot(col, float3(0.299, 0.587, 0.114))), 0.3);
    col *= float3(1.1, 1.0, 0.9);
}
if (grid > 0.5) {
    float2 g = abs(fract(uv * 20.0) - 0.5);
    col *= 0.9 + 0.1 * step(0.4, min(g.x, g.y));
}
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.7;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

// MARK: - Tunnels Category

let warpTunnelCode = """
// @param speed "Prędkość" range(0.0, 5.0) default(2.0)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 3.0) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param twistAmount "Skręt" range(0.0, 10.0) default(3.0)
// @param colorSpeed "Prędkość kolorów" range(0.0, 3.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param fadeStart "Początek zanikania" range(0.0, 0.5) default(0.0)
// @param fadeEnd "Koniec zanikania" range(0.1, 1.0) default(0.3)
// @param ringWidth "Szerokość pierścieni" range(0.1, 2.0) default(1.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle rings "Pierścienie" default(false)
// @toggle spiral "Spirala" default(true)
// @toggle reverse "Odwróć kierunek" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle stripes "Paski" default(false)
// @toggle kaleidoscope "Kalejdoskop" default(false)
// @toggle chromatic "Aberracja chromatyczna" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć kolory" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x);

float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

float rotation = timeVal * rotationSpeed;
a += rotation;

if (kaleidoscope > 0.5) {
    a = mod(a, 0.785) - 0.393;
}

float v = 1.0 / (r + 0.001) + timeVal * speed;
if (spiral > 0.5) v += a * twistAmount;

if (rings > 0.5) v = floor(v * ringWidth * 5.0) / 5.0;
if (stripes > 0.5) v = floor(v * 10.0) / 10.0;

float3 col;
if (colorful > 0.5) {
    float colorTime = timeVal * colorSpeed;
    col = 0.5 + 0.5 * cos(v + a * twistAmount + float3(0.0, 2.0, 4.0) + colorTime);
} else {
    col = float3(fract(v));
}

if (chromatic > 0.5) {
    float offset = 0.03;
    float vR = 1.0 / (r + offset + 0.001) + timeVal * speed;
    float vB = 1.0 / (r - offset + 0.001) + timeVal * speed;
    if (spiral > 0.5) {
        vR += a * twistAmount;
        vB += a * twistAmount;
    }
    col.r = 0.5 + 0.5 * cos(vR);
    col.b = 0.5 + 0.5 * cos(vB);
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 4.0);
if (glow > 0.5) col += exp(-r * 3.0) * float3(0.5, 0.5, 1.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.5;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;
col *= smoothstep(fadeStart, fadeEnd, r);

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - r * 0.3;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let starTunnelCode = """
// @param speed "Prędkość" range(0.0, 5.0) default(1.0)
// @param starPoints "Liczba ramion" range(3.0, 12.0) default(5.0)
// @param starSharpness "Ostrość gwiazdy" range(0.1, 2.0) default(1.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param colorR "Czerwień" range(0.0, 1.0) default(1.0)
// @param colorG "Zieleń" range(0.0, 1.0) default(0.8)
// @param colorB "Niebieski" range(0.0, 1.0) default(0.3)
// @param rotationSpeed "Prędkość rotacji" range(0.0, 2.0) default(0.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(false)
// @toggle reverse "Odwróć kierunek" default(false)
// @toggle spiral "Spirala" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle stripes "Paski" default(false)
// @toggle glow "Poświata" default(true)
// @toggle invert "Odwróć kolory" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle chromatic "Aberracja chromatyczna" default(false)
// @toggle kaleidoscope "Kalejdoskop" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle twinkle "Migotanie" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x);

float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

a += timeVal * rotationSpeed;

if (kaleidoscope > 0.5) {
    float segments = 8.0;
    a = mod(a, 6.28318 / segments);
    a = abs(a - 3.14159 / segments);
}

float star = abs(cos(a * starPoints)) * starSharpness;
float tunnel = 1.0 / (r + 0.001) + timeVal * speed;

if (spiral > 0.5) tunnel += a * 2.0;

float v = star * tunnel;
if (stripes > 0.5) v = floor(v * 8.0) / 8.0;

float3 baseColor = float3(colorR, colorG, colorB);
float3 col;

if (colorful > 0.5) {
    col = 0.5 + 0.5 * cos(v * 0.5 + timeVal + float3(0.0, 2.0, 4.0));
} else {
    col = baseColor * fract(v);
}

if (chromatic > 0.5) {
    float starR = abs(cos(a * starPoints + 0.1)) * starSharpness;
    float starB = abs(cos(a * starPoints - 0.1)) * starSharpness;
    col.r = fract(starR * tunnel) * baseColor.r;
    col.b = fract(starB * tunnel) * baseColor.b;
}

if (twinkle > 0.5) {
    float tw = sin(timeVal * 10.0 + a * 5.0) * 0.3 + 0.7;
    col *= tw;
}
if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);
if (glow > 0.5) col += exp(-r * 2.0) * baseColor * 0.5;
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - r * 0.4;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let hypnoticSpiralCode = """
// @param speed "Prędkość" range(0.0, 10.0) default(3.0)
// @param spiralDensity "Gęstość spirali" range(1.0, 30.0) default(10.0)
// @param armCount "Liczba ramion" range(1.0, 10.0) default(3.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @param colorIntensity "Intensywność kolorów" range(0.0, 1.0) default(0.5)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(0.5)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param waveAmount "Fala" range(0.0, 5.0) default(5.0)
// @param pulseSpeed "Prędkość pulsu" range(0.0, 5.0) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle reverse "Odwróć kierunek" default(false)
// @toggle inward "Do środka" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle stripes "Paski" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć kolory" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle chromatic "Aberracja chromatyczna" default(false)
// @toggle kaleidoscope "Kalejdoskop" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle blackWhite "Czarno-biały" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;

if (mirror > 0.5) p = abs(p);

float r = length(p);
float a = atan2(p.y, p.x);

float timeVal = animated > 0.5 ? iTime : 0.0;
if (reverse > 0.5) timeVal = -timeVal;

if (kaleidoscope > 0.5) {
    float segments = 6.0;
    a = mod(a, 6.28318 / segments);
}

float spiral = sin(r * spiralDensity - a * armCount - timeVal * speed);
if (inward > 0.5) spiral = sin(r * spiralDensity + a * armCount + timeVal * speed);

if (stripes > 0.5) spiral = step(0.0, spiral);

float pulseVal = 1.0;
if (pulse > 0.5) pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed);
if (pulseSpeed > 0.0) pulseVal = 0.7 + 0.3 * sin(timeVal * pulseSpeed);

float3 col;
if (blackWhite > 0.5) {
    col = float3(0.5 + 0.5 * spiral);
} else {
    col = float3(0.5 + 0.5 * spiral);
    if (colorful > 0.5) {
        float3 colorPhase = float3(0.0, 2.0, 4.0) + r * waveAmount + timeVal * colorSpeed;
        col *= colorIntensity + (1.0 - colorIntensity) * (0.5 + 0.5 * cos(colorPhase));
    }
}

if (chromatic > 0.5) {
    float spiralR = sin(r * spiralDensity - a * armCount - timeVal * speed + 0.1);
    float spiralB = sin(r * spiralDensity - a * armCount - timeVal * speed - 0.1);
    col.r = 0.5 + 0.5 * spiralR;
    col.b = 0.5 + 0.5 * spiralB;
}

col *= pulseVal;
if (glow > 0.5) col += exp(-r * 2.0) * 0.3;
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - r * 0.3;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

// MARK: - Nature Category

let fireCode = """
// @param speed "Prędkość" range(0.0, 2.0) default(0.5)
// @param intensity "Intensywność" range(0.5, 3.0) default(1.0)
// @param turbulence "Turbulencja" range(1.0, 10.0) default(3.0)
// @param height "Wysokość płomieni" range(0.5, 3.0) default(2.0)
// @param colorTemp "Temperatura koloru" range(0.0, 1.0) default(0.5)
// @param flameWidth "Szerokość płomieni" range(0.5, 2.0) default(1.0)
// @param noiseScale "Skala szumu" range(0.5, 5.0) default(1.0)
// @param flickerSpeed "Prędkość migotania" range(0.0, 5.0) default(1.0)
// @param baseY "Podstawa Y" range(0.0, 0.5) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param smokeAmount "Dym" range(0.0, 1.0) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle blueFlame "Niebieski płomień" default(false)
// @toggle greenFlame "Zielony płomień" default(false)
// @toggle purpleFlame "Fioletowy płomień" default(false)
// @toggle embers "Iskry" default(false)
// @toggle smoke "Dym" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle intense "Intensywny" default(false)
// @toggle soft "Miękki" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Dodatkowy szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle glow "Poświata" default(true)

float2 p = uv;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;
p.y += timeVal * speed;

float n = 0.0;
float amp = intensity;
float2 freq = float2(turbulence, turbulence) * noiseScale;

for (int i = 0; i < 5; i++) {
    float noiseVal = sin(p.x * freq.x * flameWidth + p.y * freq.y + timeVal * flickerSpeed);
    n += amp * (0.5 + 0.5 * noiseVal);
    freq *= 2.0;
    amp *= 0.5;
}

float fire = pow(max(0.0, 1.0 - (uv.y - baseY)), height) * n;
if (intense > 0.5) fire = pow(fire, 0.7) * 1.3;
if (soft > 0.5) fire = pow(fire, 1.5) * 0.8;

float3 coldColor, hotColor;
if (blueFlame > 0.5) {
    coldColor = float3(0.0, 0.0, 1.0);
    hotColor = float3(0.5, 0.8, 1.0);
} else if (greenFlame > 0.5) {
    coldColor = float3(0.0, 0.5, 0.0);
    hotColor = float3(0.5, 1.0, 0.3);
} else if (purpleFlame > 0.5) {
    coldColor = float3(0.5, 0.0, 0.5);
    hotColor = float3(1.0, 0.5, 1.0);
} else {
    coldColor = mix(float3(1.0, 0.0, 0.0), float3(1.0, 0.3, 0.0), colorTemp);
    hotColor = mix(float3(1.0, 0.5, 0.0), float3(1.0, 1.0, 0.0), colorTemp);
}

float3 col = mix(coldColor, hotColor, fire);
col = mix(float3(0.0), col, fire);

if (embers > 0.5) {
    float ember = fract(sin(dot(floor(uv * 50.0 + timeVal * 2.0), float2(12.9898, 78.233))) * 43758.5453);
    ember = step(0.97, ember) * fire * 2.0;
    col += float3(1.0, 0.6, 0.2) * ember;
}

if (smoke > 0.5 || smokeAmount > 0.0) {
    float smokeVal = pow(max(0.0, uv.y - 0.5), 0.5) * smokeAmount;
    float smokeNoise = fract(sin(dot(floor(uv * 20.0 - timeVal), float2(12.9898, 78.233))) * 43758.5453);
    col += float3(0.3, 0.3, 0.35) * smokeVal * smokeNoise;
}

if (pulse > 0.5) col *= 0.8 + 0.2 * sin(timeVal * 5.0);
if (glow > 0.5) col += fire * float3(0.2, 0.1, 0.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float noiseVal = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (noiseVal - 0.5) * 0.05;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let oceanWavesCode = """
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param waveHeight "Wysokość fal" range(0.0, 0.3) default(0.1)
// @param waveFrequency "Częstotliwość fal" range(1.0, 10.0) default(3.0)
// @param waveLayers "Warstwy fal" range(1.0, 8.0) default(5.0)
// @param deepColorR "Głębia R" range(0.0, 0.5) default(0.0)
// @param deepColorG "Głębia G" range(0.0, 0.5) default(0.2)
// @param deepColorB "Głębia B" range(0.0, 1.0) default(0.4)
// @param surfaceColorR "Powierzchnia R" range(0.0, 0.5) default(0.0)
// @param surfaceColorG "Powierzchnia G" range(0.0, 1.0) default(0.5)
// @param surfaceColorB "Powierzchnia B" range(0.0, 1.0) default(0.8)
// @param foamAmount "Piana" range(0.0, 1.0) default(0.3)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle foam "Piana" default(true)
// @toggle sunReflection "Odbicie słońca" default(false)
// @toggle storm "Sztorm" default(false)
// @toggle calm "Spokój" default(false)
// @toggle tropical "Tropikalny" default(false)
// @toggle arctic "Arktyczny" default(false)
// @toggle sunset "Zachód słońca" default(false)
// @toggle caustics "Kaustyki" default(false)
// @toggle bubbles "Bąbelki" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle depth "Głębia" default(true)

float2 p = uv;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;

float heightMult = storm > 0.5 ? 2.0 : (calm > 0.5 ? 0.3 : 1.0);
float speedMult = storm > 0.5 ? 2.0 : (calm > 0.5 ? 0.5 : 1.0);

float wave = 0.0;
int numLayers = int(waveLayers);
for (int i = 0; i < 8; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    float freq = waveFrequency + fi;
    float spd = (1.0 + fi * 0.2) * speed * speedMult;
    wave += sin(p.x * freq + timeVal * spd + fi) * waveHeight * heightMult / (fi + 1.0);
}

float water = smoothstep(0.0, 0.02, wave + 0.5 - p.y);

float3 deepColor = float3(deepColorR, deepColorG, deepColorB);
float3 surfaceColor = float3(surfaceColorR, surfaceColorG, surfaceColorB);

if (tropical > 0.5) {
    deepColor = float3(0.0, 0.3, 0.4);
    surfaceColor = float3(0.0, 0.8, 0.7);
} else if (arctic > 0.5) {
    deepColor = float3(0.1, 0.2, 0.3);
    surfaceColor = float3(0.6, 0.8, 0.9);
} else if (sunset > 0.5) {
    deepColor = float3(0.2, 0.1, 0.3);
    surfaceColor = float3(1.0, 0.5, 0.3);
}

float3 col = mix(deepColor, surfaceColor, water);

if (depth > 0.5) {
    col += float3(0.3, 0.4, 0.5) * (1.0 - uv.y) * 0.5;
}

if (foam > 0.5) {
    float foamLine = smoothstep(0.02, 0.0, abs(wave + 0.5 - p.y)) * foamAmount;
    col = mix(col, float3(1.0), foamLine);
}

if (sunReflection > 0.5) {
    float sun = exp(-pow((p.x - 0.5) * 3.0, 2.0)) * (1.0 - p.y) * 0.5;
    sun *= 0.7 + 0.3 * sin(timeVal * 2.0 + p.x * 10.0);
    col += float3(1.0, 0.9, 0.7) * sun;
}

if (caustics > 0.5) {
    float caustic = sin(p.x * 20.0 + timeVal) * sin(p.y * 20.0 + timeVal * 0.7);
    col += float3(0.1, 0.2, 0.3) * caustic * 0.2 * (1.0 - p.y);
}

if (bubbles > 0.5) {
    float bubble = fract(sin(dot(floor(uv * 30.0 + timeVal), float2(12.9898, 78.233))) * 43758.5453);
    bubble = step(0.95, bubble) * (1.0 - p.y);
    col += float3(0.5, 0.7, 1.0) * bubble;
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;
col *= brightness;

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.4;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let auroraCode = """
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param waveFrequency "Częstotliwość fal" range(1.0, 10.0) default(3.0)
// @param waveHeight "Wysokość fal" range(0.0, 0.3) default(0.1)
// @param layerCount "Liczba warstw" range(1.0, 10.0) default(5.0)
// @param glowIntensity "Intensywność poświaty" range(0.0, 0.5) default(0.3)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(0.5)
// @param baseY "Podstawa Y" range(0.3, 0.7) default(0.5)
// @param layerSpacing "Odstęp warstw" range(0.02, 0.15) default(0.08)
// @param skyDarkness "Ciemność nieba" range(0.0, 0.1) default(0.02)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param starDensity "Gęstość gwiazd" range(0.0, 1.0) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle greenDominant "Dominująca zieleń" default(false)
// @toggle pinkDominant "Dominujący róż" default(false)
// @toggle blueDominant "Dominujący niebieski" default(false)
// @toggle stars "Gwiazdy" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle curtain "Kurtyna" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle shimmer "Migotanie" default(true)
// @toggle vertical "Pionowy" default(false)
// @toggle intense "Intensywny" default(false)

float2 p = uv;
if (mirror > 0.5) p.x = abs(p.x - 0.5) + 0.5;
if (vertical > 0.5) p = p.yx;

float timeVal = animated > 0.5 ? iTime : 0.0;

float3 col = float3(0.0, skyDarkness, skyDarkness * 2.5);

if (stars > 0.5 || starDensity > 0.0) {
    float star = fract(sin(dot(floor(uv * 200.0), float2(12.9898, 78.233))) * 43758.5453);
    float threshold = 0.99 - starDensity * 0.05;
    if (star > threshold) {
        float twinkle = 0.5 + 0.5 * sin(timeVal * 5.0 + star * 100.0);
        col += float3(1.0) * twinkle * (star - threshold) * 50.0;
    }
}

int numLayers = int(layerCount);
for (int i = 0; i < 10; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    
    float wave = sin(p.x * waveFrequency + timeVal * speed + fi) * waveHeight + baseY + fi * layerSpacing;
    
    if (curtain > 0.5) {
        wave += sin(p.x * 20.0 + timeVal * 3.0 + fi * 2.0) * 0.02;
    }
    
    float glowWidth = 0.1;
    if (intense > 0.5) glowWidth = 0.15;
    float glow = smoothstep(glowWidth, 0.0, abs(p.y - wave));
    
    float3 auroraCol;
    if (greenDominant > 0.5) {
        auroraCol = float3(0.2, 1.0, 0.4);
    } else if (pinkDominant > 0.5) {
        auroraCol = float3(1.0, 0.3, 0.6);
    } else if (blueDominant > 0.5) {
        auroraCol = float3(0.2, 0.5, 1.0);
    } else if (colorful > 0.5) {
        auroraCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        auroraCol = float3(0.3, 0.8, 0.4);
    }
    
    if (shimmer > 0.5) {
        float shimmerVal = 0.7 + 0.3 * sin(p.x * 30.0 + timeVal * 5.0 + fi * 3.0);
        auroraCol *= shimmerVal;
    }
    
    col += glow * auroraCol * glowIntensity;
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 2.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.4;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let electricStormCode = """
// @param speed "Prędkość" range(0.0, 10.0) default(5.0)
// @param boltCount "Liczba błyskawic" range(1.0, 10.0) default(5.0)
// @param boltWidth "Szerokość błyskawic" range(0.01, 0.1) default(0.02)
// @param zigzagAmount "Zygzak" range(0.0, 0.5) default(0.2)
// @param flashIntensity "Intensywność błysku" range(0.0, 1.0) default(0.5)
// @param flashFrequency "Częstotliwość błysków" range(1.0, 20.0) default(10.0)
// @param colorR "Kolor R" range(0.0, 1.0) default(0.5)
// @param colorG "Kolor G" range(0.0, 1.0) default(0.5)
// @param colorB "Kolor B" range(0.0, 1.0) default(1.0)
// @param skyDarkness "Ciemność nieba" range(0.0, 0.1) default(0.02)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle flash "Błysk tła" default(true)
// @toggle branching "Rozgałęzienia" default(false)
// @toggle horizontal "Poziome" default(false)
// @toggle purple "Fioletowy" default(false)
// @toggle orange "Pomarańczowy" default(false)
// @toggle green "Zielony" default(false)
// @toggle rain "Deszcz" default(false)
// @toggle clouds "Chmury" default(false)
// @toggle glow "Poświata" default(true)
// @toggle mirror "Lustro" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle pulse "Pulsowanie" default(false)

float2 p = uv * 2.0 - 1.0;
if (mirror > 0.5) p.x = abs(p.x);
if (horizontal > 0.5) p = p.yx;

float timeVal = animated > 0.5 ? iTime : 0.0;

float3 col = float3(skyDarkness, skyDarkness, skyDarkness * 2.5);

if (clouds > 0.5) {
    float cloud = fract(sin(dot(floor(uv * 10.0 + timeVal * 0.1), float2(12.9898, 78.233))) * 43758.5453);
    cloud = smoothstep(0.4, 0.6, cloud) * 0.1;
    col += float3(cloud);
}

float flash = step(1.0 - (1.0 / flashFrequency), fract(sin(floor(timeVal * flashFrequency) * 43.758) * 43758.5453));

float3 boltColor = float3(colorR, colorG, colorB);
if (purple > 0.5) boltColor = float3(0.7, 0.3, 1.0);
if (orange > 0.5) boltColor = float3(1.0, 0.6, 0.2);
if (green > 0.5) boltColor = float3(0.3, 1.0, 0.5);

int numBolts = int(boltCount);
for (int i = 0; i < 10; i++) {
    if (i >= numBolts) break;
    float fi = float(i);
    float x = sin(p.y * 10.0 + timeVal * speed + fi * 2.0) * zigzagAmount;
    
    if (branching > 0.5 && i > 0) {
        x += sin(p.y * 20.0 + fi * 5.0) * zigzagAmount * 0.3;
    }
    
    float bolt = smoothstep(boltWidth, 0.0, abs(p.x - x - (fi - float(numBolts) / 2.0) * 0.3));
    
    if (glow > 0.5) {
        float glowBolt = exp(-abs(p.x - x - (fi - float(numBolts) / 2.0) * 0.3) * 10.0) * 0.3;
        col += glowBolt * boltColor;
    }
    
    col += bolt * boltColor * (flashIntensity + flash * (1.0 - flashIntensity));
}

if (flash > 0.5) {
    col += float3(0.2, 0.2, 0.3) * flashIntensity;
}

if (rain > 0.5) {
    float rainDrop = fract(sin(dot(floor(uv * float2(100.0, 20.0) + float2(0.0, timeVal * 10.0)), float2(12.9898, 78.233))) * 43758.5453);
    rainDrop = step(0.97, rainDrop);
    col += float3(0.3, 0.4, 0.5) * rainDrop * 0.5;
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

// MARK: - Geometric Category

let kaleidoscopeCode = """
// @param segments "Segmenty" range(2.0, 16.0) default(8.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param zoom "Zoom" range(0.5, 5.0) default(1.0)
// @param patternScale "Skala wzoru" range(1.0, 20.0) default(10.0)
// @param rotation "Rotacja" range(0.0, 6.28) default(0.0)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param colorMix "Mieszanie kolorów" range(0.0, 1.0) default(0.5)
// @param patternComplexity "Złożoność" range(1.0, 5.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle spinning "Wirujący" default(false)
// @toggle mirror "Lustrzane odbicie" default(true)
// @toggle waves "Fale" default(false)
// @toggle circles "Okręgi" default(false)
// @toggle diamonds "Diamenty" default(false)
// @toggle psychedelic "Psychodeliczny" default(false)
// @toggle stripes "Paski" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle pulse "Pulsowanie" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;

float timeVal = animated > 0.5 ? iTime : 0.0;

float spinAngle = spinning > 0.5 ? timeVal * 0.5 : 0.0;
float c = cos(spinAngle + rotation);
float s = sin(spinAngle + rotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float a = atan2(p.y, p.x);
float segmentAngle = 6.28318 / segments;
a = mod(a, segmentAngle);
if (mirror > 0.5) a = abs(a - segmentAngle * 0.5);

float r = length(p);
float2 np = float2(cos(a), sin(a)) * r;

float pattern = 0.0;
if (circles > 0.5) {
    pattern = sin(r * patternScale + timeVal * speed);
} else if (diamonds > 0.5) {
    pattern = sin((abs(np.x) + abs(np.y)) * patternScale + timeVal * speed);
} else if (stripes > 0.5) {
    pattern = sin(np.x * patternScale + timeVal * speed);
} else {
    pattern = sin(np.x * patternScale + np.y * patternScale + timeVal * speed);
}

if (waves > 0.5) {
    pattern += sin(r * 5.0 - timeVal * 2.0) * 0.3;
}

pattern *= patternComplexity;

float3 col;
if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (psychedelic > 0.5) {
        colorPhase += pattern * 2.0;
    }
    col = 0.5 + 0.5 * cos(pattern + colorPhase);
} else {
    col = float3(0.5 + 0.5 * pattern);
}

col = mix(float3(0.5), col, colorMix + 0.5);

if (glow > 0.5) {
    col += exp(-r * 2.0) * 0.3;
}
if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.1;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - r * 0.3;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let hexagonGridCode = """
// @param scale "Skala" range(2.0, 30.0) default(10.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param lineWidth "Szerokość linii" range(0.01, 0.1) default(0.02)
// @param hexSize "Rozmiar heksów" range(0.2, 0.5) default(0.4)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(0.5)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param fillAmount "Wypełnienie" range(0.0, 1.0) default(1.0)
// @param glowAmount "Poświata" range(0.0, 1.0) default(0.0)
// @param rotation "Rotacja" range(0.0, 6.28) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle outline "Tylko kontury" default(false)
// @toggle filled "Wypełnione" default(true)
// @toggle wave "Fala" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle rainbow "Tęczowy" default(false)
// @toggle grid "Siatka" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle gradient "Gradient" default(false)

float2 p = (uv + float2(offsetX, offsetY)) * scale;

float c = cos(rotation);
float s = sin(rotation);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;

float2 h = float2(1.0, 1.732);
float2 a = mod(p, h) - h * 0.5;
float2 b = mod(p + h * 0.5, h) - h * 0.5;
float2 g = length(a) < length(b) ? a : b;

float d = max(abs(g.x), abs(g.y) * 0.577 + abs(g.x) * 0.5);

float hexSizeAnim = hexSize;
if (wave > 0.5) {
    float2 hexId = floor(p / h);
    hexSizeAnim += sin(hexId.x * 0.5 + hexId.y * 0.5 + timeVal * speed) * 0.1;
}
if (pulse > 0.5) {
    hexSizeAnim += sin(timeVal * 3.0) * 0.05;
}

float hex;
if (outline > 0.5) {
    hex = smoothstep(hexSizeAnim + lineWidth, hexSizeAnim, d) - smoothstep(hexSizeAnim, hexSizeAnim - lineWidth, d);
} else if (filled > 0.5) {
    hex = smoothstep(hexSizeAnim, hexSizeAnim - lineWidth, d) * fillAmount;
} else {
    hex = smoothstep(hexSizeAnim, hexSizeAnim - lineWidth, d);
}

float2 hexId = floor(p / h);
float3 col;

if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (rainbow > 0.5) {
        colorPhase += hexId.x * 0.2 + hexId.y * 0.3;
    } else {
        colorPhase += p.x * 0.5 / scale;
    }
    col = hex * (0.5 + 0.5 * cos(colorPhase));
} else {
    col = float3(hex);
}

if (gradient > 0.5) {
    col *= mix(float3(0.5, 0.7, 1.0), float3(1.0, 0.5, 0.7), uv.y);
}

if (glow > 0.5 || glowAmount > 0.0) {
    float glowVal = exp(-d * 5.0) * (glow > 0.5 ? 0.5 : glowAmount);
    col += glowVal * float3(0.3, 0.5, 1.0);
}

if (grid > 0.5) {
    float2 gridLines = abs(fract(p) - 0.5);
    float gridLine = step(0.48, min(gridLines.x, gridLines.y));
    col = mix(col, float3(0.3), gridLine * 0.5);
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let voronoiCode = """
// @param scale "Skala" range(1.0, 15.0) default(5.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param cellMovement "Ruch komórek" range(0.0, 1.0) default(0.3)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param edgeWidth "Szerokość krawędzi" range(0.0, 0.5) default(0.0)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param cellCount "Liczba komórek" range(1.0, 5.0) default(3.0)
// @param distortAmount "Zniekształcenie" range(0.0, 1.0) default(0.0)
// @param smoothness "Wygładzenie" range(0.0, 1.0) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle edges "Krawędzie" default(false)
// @toggle cellColor "Kolor komórki" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle cracked "Popękany" default(false)
// @toggle organic "Organiczny" default(false)
// @toggle crystal "Kryształowy" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle pulse "Pulsowanie" default(false)

float2 p = (uv + float2(offsetX, offsetY)) * scale;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;

if (distortAmount > 0.0) {
    p += float2(sin(p.y * 5.0 + timeVal), cos(p.x * 5.0 + timeVal)) * distortAmount;
}

float minDist = 1.0;
float secondMinDist = 1.0;
float2 closestCell = float2(0.0);

int cells = int(cellCount);
int gridSize = cells * cells;
for (int i = 0; i < 25; i++) {
    if (i >= gridSize) break;
    float2 cell = float2(float(i % cells), float(i / cells));
    float2 cellOffset = 0.5 + cellMovement * sin(timeVal * speed + cell * 5.0);
    if (organic > 0.5) {
        cellOffset += float2(sin(timeVal + cell.x * 3.0), cos(timeVal * 0.7 + cell.y * 2.0)) * 0.2;
    }
    float2 cellCenter = cell + cellOffset;
    float d = length(fract(p) - cellCenter + cell - floor(p));
    
    if (d < minDist) {
        secondMinDist = minDist;
        minDist = d;
        closestCell = cell;
    } else if (d < secondMinDist) {
        secondMinDist = d;
    }
}

float val = minDist;
if (smoothness > 0.0) {
    val = smoothstep(0.0, smoothness, minDist);
}

float3 col;
if (colorful > 0.5) {
    float3 colorPhase = float3(0.0, 2.0, 4.0) + timeVal * colorSpeed;
    if (cellColor > 0.5) {
        colorPhase += closestCell.x + closestCell.y;
    } else {
        colorPhase += val * 10.0;
    }
    col = 0.5 + 0.5 * cos(colorPhase);
} else {
    col = float3(val);
}

if (edges > 0.5 || edgeWidth > 0.0) {
    float edge = smoothstep(edgeWidth, edgeWidth + 0.02, secondMinDist - minDist);
    if (cracked > 0.5) {
        col = mix(float3(0.0), col, edge);
    } else {
        col *= edge;
    }
}

if (crystal > 0.5) {
    col *= 0.7 + 0.3 * sin(minDist * 20.0);
}

if (gradient > 0.5) {
    col *= mix(float3(0.5, 0.7, 1.0), float3(1.0, 0.5, 0.7), uv.y);
}

if (glow > 0.5) {
    col += exp(-minDist * 5.0) * 0.3;
}

if (pulse > 0.5) col *= 0.7 + 0.3 * sin(timeVal * 3.0);
if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let fractalCirclesCode = """
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param circleCount "Liczba okręgów" range(2.0, 15.0) default(8.0)
// @param baseRadius "Bazowy promień" range(0.1, 1.0) default(0.5)
// @param movementRange "Zakres ruchu" range(0.0, 0.8) default(0.3)
// @param thickness "Grubość" range(0.005, 0.1) default(0.02)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param overlap "Nakładanie" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle filled "Wypełnione" default(false)
// @toggle rings "Pierścienie" default(true)
// @toggle spiral "Spirala" default(false)
// @toggle orbit "Orbita" default(false)
// @toggle random "Losowy" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle blend "Mieszanie" default(true)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float timeVal = animated > 0.5 ? iTime : 0.0;

float3 col = float3(0.0);
int numCircles = int(circleCount);

for (int i = 0; i < 15; i++) {
    if (i >= numCircles) break;
    float fi = float(i);
    float r = baseRadius / (fi + 1.0);
    
    float2 offset;
    if (spiral > 0.5) {
        float angle = fi * 0.7 + timeVal * speed;
        float dist = fi * 0.05 * movementRange;
        offset = float2(cos(angle), sin(angle)) * dist;
    } else if (orbit > 0.5) {
        float angle = timeVal * speed + fi * 1.0;
        offset = float2(cos(angle), sin(angle)) * movementRange * 0.5;
    } else if (random > 0.5) {
        float seed = fi * 123.456;
        offset = float2(
            sin(timeVal * speed + seed) * sin(seed * 2.0),
            cos(timeVal * speed * 0.7 + seed) * cos(seed * 3.0)
        ) * movementRange;
    } else {
        offset = float2(sin(timeVal * speed + fi), cos(timeVal * speed * 0.7 + fi)) * movementRange;
    }
    
    float rAnim = r;
    if (pulse > 0.5) {
        rAnim *= 0.8 + 0.2 * sin(timeVal * 3.0 + fi);
    }
    
    float d = length(p - offset);
    float circle;
    
    if (filled > 0.5) {
        circle = smoothstep(rAnim, rAnim - thickness, d);
    } else if (rings > 0.5) {
        circle = smoothstep(rAnim, rAnim - thickness, d) - smoothstep(rAnim - thickness, rAnim - thickness * 2.0, d);
    } else {
        circle = smoothstep(thickness, 0.0, abs(d - rAnim));
    }
    
    float3 circleColor;
    if (colorful > 0.5) {
        circleColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.5 + timeVal * colorSpeed);
    } else {
        circleColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-d * 3.0) * 0.3;
        circleColor += glowVal;
    }
    
    if (blend > 0.5) {
        col += circle * circleColor * overlap;
    } else {
        col = mix(col, circleColor, circle);
    }
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let infiniteCubesCode = """
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param cubeCount "Liczba sześcianów" range(3.0, 20.0) default(10.0)
// @param lineWidth "Szerokość linii" range(0.005, 0.05) default(0.02)
// @param cubeSize "Rozmiar sześcianu" range(0.2, 0.8) default(0.5)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param depth "Głębokość" range(0.5, 3.0) default(1.0)
// @param rotation "Rotacja" range(0.0, 6.28) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle filled "Wypełnione" default(false)
// @toggle rotating "Obracający się" default(false)
// @toggle alternating "Naprzemienne" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle circles "Okręgi" default(false)
// @toggle diamonds "Diamenty" default(false)
// @toggle stars "Gwiazdy" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float timeVal = animated > 0.5 ? iTime : 0.0;
float z = mod(timeVal * speed, 1.0);

float rotAngle = rotation;
if (rotating > 0.5) rotAngle += timeVal * 0.5;
float c = cos(rotAngle);
float s = sin(rotAngle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float3 col = float3(0.0);
int numCubes = int(cubeCount);

for (int i = 0; i < 20; i++) {
    if (i >= numCubes) break;
    float fi = float(i);
    float depthVal = (fi + z) * depth;
    float size = 1.0 / depthVal;
    
    float sizeAnim = size;
    if (pulse > 0.5) {
        sizeAnim *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    float d;
    float edge;
    
    if (circles > 0.5) {
        d = length(p * sizeAnim) - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else if (diamonds > 0.5) {
        d = abs(p.x * sizeAnim) + abs(p.y * sizeAnim) - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else if (stars > 0.5) {
        float a = atan2(p.y, p.x);
        float starShape = cos(a * 5.0) * 0.3 + 0.7;
        d = length(p * sizeAnim) / starShape - cubeSize;
        edge = smoothstep(lineWidth, 0.0, abs(d));
    } else {
        float2 box = abs(p * sizeAnim) - cubeSize;
        d = max(box.x, box.y);
        if (filled > 0.5) {
            edge = smoothstep(0.0, -lineWidth, d);
        } else {
            edge = smoothstep(lineWidth, 0.0, abs(d));
        }
    }
    
    float3 cubeColor;
    if (colorful > 0.5) {
        float3 colorPhase = float3(0.0, 2.0, 4.0) + depthVal + timeVal * colorSpeed;
        if (alternating > 0.5 && int(fi) % 2 == 0) {
            colorPhase += 3.14159;
        }
        cubeColor = 0.5 + 0.5 * cos(colorPhase);
    } else {
        cubeColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-abs(d) * sizeAnim * 10.0) * 0.2;
        cubeColor += glowVal;
    }
    
    col += edge * cubeColor;
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let rotatingTrianglesCode = """
// @param speed "Prędkość rotacji" range(0.0, 5.0) default(1.0)
// @param triangleCount "Liczba trójkątów" range(2.0, 8.0) default(3.0)
// @param size "Rozmiar" range(0.1, 0.8) default(0.3)
// @param lineWidth "Szerokość linii" range(0.005, 0.05) default(0.01)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param spacing "Odstęp" range(0.0, 1.0) default(0.0)
// @param phaseOffset "Przesunięcie fazy" range(0.0, 6.28) default(0.0)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle filled "Wypełnione" default(false)
// @toggle counterRotate "Przeciwna rotacja" default(false)
// @toggle nested "Zagnieżdżone" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle squares "Kwadraty" default(false)
// @toggle pentagons "Pięciokąty" default(false)
// @toggle hexagons "Sześciokąty" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float timeVal = animated > 0.5 ? iTime : 0.0;
float angle = timeVal * speed + phaseOffset;

float c = cos(angle);
float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);

float3 col = float3(0.0);

int sides = 3;
if (squares > 0.5) sides = 4;
if (pentagons > 0.5) sides = 5;
if (hexagons > 0.5) sides = 6;

float sideAngle = 6.28318 / float(sides);

int numTriangles = int(triangleCount);
for (int i = 0; i < 8; i++) {
    if (i >= numTriangles) break;
    float fi = float(i);
    
    float layerAngle = fi * sideAngle + timeVal * speed;
    if (counterRotate > 0.5 && i % 2 == 1) {
        layerAngle = -fi * sideAngle - timeVal * speed;
    }
    
    float layerSize = size;
    if (nested > 0.5) {
        layerSize = size * (1.0 - fi * 0.1);
    }
    layerSize += fi * spacing * 0.1;
    
    if (pulse > 0.5) {
        layerSize *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    float2 dir = float2(cos(layerAngle), sin(layerAngle));
    float d = dot(p, dir);
    
    float edge;
    if (filled > 0.5) {
        edge = smoothstep(layerSize + lineWidth, layerSize, abs(d));
    } else {
        edge = smoothstep(lineWidth, 0.0, abs(d - layerSize));
    }
    
    float3 triColor;
    if (colorful > 0.5) {
        triColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        triColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-abs(d - layerSize) * 20.0) * 0.3;
        triColor += glowVal;
    }
    
    col += edge * triColor;
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let penroseTilesCode = """
// @param scale "Skala" range(1.0, 15.0) default(5.0)
// @param speed "Prędkość" range(0.0, 1.0) default(0.2)
// @param lineWidth "Szerokość linii" range(0.01, 0.1) default(0.05)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param layers "Warstwy" range(3.0, 10.0) default(5.0)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param baseAngle "Bazowy kąt" range(0.0, 1.0) default(0.628318)
// @param intensity "Intensywność" range(0.1, 0.5) default(0.2)
// @param bgBrightness "Jasność tła" range(0.0, 0.5) default(0.1)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle quasicrystal "Kwazikryształ" default(false)
// @toggle islamic "Islamski wzór" default(false)
// @toggle celtic "Celtycki" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle rotation "Rotacja" default(false)
// @toggle wave "Fala" default(false)

float2 p = (uv + float2(offsetX, offsetY)) * scale;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;

if (rotation > 0.5) {
    float angle = timeVal * 0.2;
    float c = cos(angle);
    float s = sin(angle);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
}

float angleStep = baseAngle;
if (quasicrystal > 0.5) angleStep = 0.523599;
if (islamic > 0.5) angleStep = 0.785398;
if (celtic > 0.5) angleStep = 0.698132;

float3 col = float3(bgBrightness);

int numLayers = int(layers);
for (int i = 0; i < 10; i++) {
    if (i >= numLayers) break;
    float fi = float(i);
    float a = fi * angleStep + timeVal * speed;
    float2 dir = float2(cos(a), sin(a));
    float d = dot(p, dir);
    
    if (wave > 0.5) {
        d += sin(timeVal * 2.0 + fi) * 0.2;
    }
    
    float grid = abs(fract(d) - 0.5);
    float line = smoothstep(lineWidth, 0.0, grid);
    
    if (pulse > 0.5) {
        line *= 0.7 + 0.3 * sin(timeVal * 3.0 + fi);
    }
    
    float3 lineColor;
    if (colorful > 0.5) {
        lineColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + timeVal * colorSpeed);
    } else {
        lineColor = float3(1.0);
    }
    
    if (glow > 0.5) {
        float glowVal = exp(-grid * 10.0) * 0.2;
        lineColor += glowVal;
    }
    
    col += line * intensity * lineColor;
}

if (gradient > 0.5) {
    col *= mix(float3(0.6, 0.8, 1.0), float3(1.0, 0.8, 0.6), uv.y);
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let truchetPatternCode = """
// @param scale "Skala" range(2.0, 30.0) default(10.0)
// @param speed "Prędkość" range(0.0, 3.0) default(1.0)
// @param lineWidth "Szerokość linii" range(0.01, 0.15) default(0.05)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param offsetX "Przesunięcie X" range(-1.0, 1.0) default(0.0)
// @param offsetY "Przesunięcie Y" range(-1.0, 1.0) default(0.0)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param randomSeed "Ziarno losowe" range(0.0, 100.0) default(0.0)
// @param patternVariant "Wariant wzoru" range(0.0, 1.0) default(0.5)
// @param curveSmooth "Wygładzenie krzywych" range(0.0, 0.5) default(0.0)
// @param bgBrightness "Jasność tła" range(0.0, 0.5) default(0.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle arcs "Łuki" default(false)
// @toggle diagonal "Ukośne" default(true)
// @toggle maze "Labirynt" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle gradient "Gradient" default(false)
// @toggle rotating "Rotujący" default(false)
// @toggle weave "Splot" default(false)

float2 p = (uv + float2(offsetX, offsetY)) * scale;
if (mirror > 0.5) p.x = abs(p.x - scale * 0.5) + scale * 0.5;

float timeVal = animated > 0.5 ? iTime : 0.0;

if (rotating > 0.5) {
    float angle = timeVal * 0.3;
    float2 center = float2(scale * 0.5);
    p -= center;
    float c = cos(angle);
    float s = sin(angle);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    p += center;
}

float2 id = floor(p);
float2 f = fract(p) - 0.5;

float h = fract(sin(dot(id + randomSeed, float2(12.9898, 78.233))) * 43758.5453);

float flipThreshold = patternVariant;
if (h > flipThreshold) f.x = -f.x;

float d;
if (arcs > 0.5) {
    float2 corner1 = float2(-0.5, -0.5);
    float2 corner2 = float2(0.5, 0.5);
    if (h > flipThreshold) {
        corner1 = float2(0.5, -0.5);
        corner2 = float2(-0.5, 0.5);
    }
    float d1 = abs(length(f - corner1) - 0.5);
    float d2 = abs(length(f - corner2) - 0.5);
    d = min(d1, d2);
} else if (maze > 0.5) {
    float h2 = fract(sin(dot(id + randomSeed + 1.0, float2(78.233, 12.9898))) * 43758.5453);
    if (h2 > 0.5) {
        d = min(abs(f.x), abs(f.y));
    } else {
        d = abs(abs(f.x) + abs(f.y) - 0.5);
    }
} else if (weave > 0.5) {
    float wave = sin((f.x + f.y) * 6.28 + timeVal * speed) * 0.1;
    d = abs(abs(f.x) + abs(f.y) - 0.5 + wave);
} else {
    d = abs(abs(f.x) + abs(f.y) - 0.5);
}

if (curveSmooth > 0.0) {
    d = smoothstep(curveSmooth, 0.0, d);
} else {
    d = smoothstep(lineWidth, 0.0, d);
}

if (pulse > 0.5) {
    d *= 0.7 + 0.3 * sin(timeVal * 3.0 + id.x + id.y);
}

float3 col = float3(bgBrightness);

float3 lineColor;
if (colorful > 0.5) {
    lineColor = 0.5 + 0.5 * cos(timeVal * colorSpeed + id.x + id.y + float3(0.0, 2.0, 4.0));
} else {
    lineColor = float3(1.0);
}

if (glow > 0.5) {
    float glowVal = exp(-d * 3.0) * 0.3;
    lineColor += glowVal;
}

col = mix(col, lineColor, d);

if (gradient > 0.5) {
    col *= mix(float3(0.6, 0.8, 1.0), float3(1.0, 0.8, 0.6), uv.y);
}

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""

let sacredGeometryCode = """
// @param speed "Prędkość" range(0.0, 2.0) default(0.3)
// @param circleCount "Liczba okręgów" range(4.0, 12.0) default(6.0)
// @param circleRadius "Promień okręgów" range(0.3, 0.7) default(0.5)
// @param orbitRadius "Promień orbity" range(0.2, 0.8) default(0.5)
// @param lineWidth "Szerokość linii" range(0.01, 0.08) default(0.04)
// @param colorSpeed "Prędkość kolorów" range(0.0, 2.0) default(1.0)
// @param centerCircleSize "Rozmiar środkowego" range(0.3, 0.7) default(0.52)
// @param brightness "Jasność" range(0.0, 2.0) default(1.0)
// @param contrast "Kontrast" range(0.5, 2.0) default(1.0)
// @param centerX "Środek X" range(0.0, 1.0) default(0.5)
// @param centerY "Środek Y" range(0.0, 1.0) default(0.5)
// @param zoom "Zoom" range(0.5, 3.0) default(1.0)
// @toggle animated "Animowany" default(true)
// @toggle colorful "Kolorowy" default(true)
// @toggle flowerOfLife "Kwiat życia" default(true)
// @toggle metatron "Kostka Metatrona" default(false)
// @toggle sriYantra "Sri Yantra" default(false)
// @toggle rotating "Rotujący" default(false)
// @toggle pulse "Pulsowanie" default(false)
// @toggle glow "Poświata" default(false)
// @toggle invert "Odwróć" default(false)
// @toggle neon "Neonowy" default(false)
// @toggle noise "Szum" default(false)
// @toggle scanlines "Linie skanowania" default(false)
// @toggle vignette "Winieta" default(false)
// @toggle mirror "Lustro" default(false)
// @toggle filled "Wypełnione" default(false)
// @toggle gradient "Gradient" default(false)

float2 center = float2(centerX, centerY);
float2 p = (uv - center) * 2.0 * zoom;
if (mirror > 0.5) p = abs(p);

float timeVal = animated > 0.5 ? iTime : 0.0;

if (rotating > 0.5) {
    float angle = timeVal * 0.5;
    float c = cos(angle);
    float s = sin(angle);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
}

float3 col = float3(0.0);

int numCircles = int(circleCount);
for (int i = 0; i < 12; i++) {
    if (i >= numCircles) break;
    float fi = float(i);
    float a = fi * (6.28318 / float(numCircles)) + timeVal * speed;
    float2 circleCenter = float2(cos(a), sin(a)) * orbitRadius;
    
    float d = length(p - circleCenter);
    float radiusAnim = circleRadius;
    
    if (pulse > 0.5) {
        radiusAnim *= 0.9 + 0.1 * sin(timeVal * 3.0 + fi);
    }
    
    float circle;
    if (filled > 0.5) {
        circle = smoothstep(radiusAnim, radiusAnim - lineWidth, d);
    } else {
        circle = smoothstep(radiusAnim + lineWidth * 0.5, radiusAnim, d) * 
                 smoothstep(radiusAnim - lineWidth * 0.5, radiusAnim, d + lineWidth);
    }
    
    float3 circleColor;
    if (colorful > 0.5) {
        circleColor = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.5 + timeVal * colorSpeed);
    } else {
        circleColor = float3(1.0);
    }
    
    col += circle * circleColor;
}

float centerD = length(p);
float centerCircle;
if (filled > 0.5) {
    centerCircle = smoothstep(centerCircleSize, centerCircleSize - lineWidth, centerD);
} else {
    centerCircle = smoothstep(centerCircleSize + lineWidth * 0.5, centerCircleSize, centerD) *
                   smoothstep(centerCircleSize - lineWidth * 0.5, centerCircleSize, centerD + lineWidth);
}
col += centerCircle * 0.3;

if (metatron > 0.5) {
    for (int i = 0; i < 12; i++) {
        if (i >= numCircles) break;
        float fi = float(i);
        float a1 = fi * (6.28318 / float(numCircles));
        float a2 = (fi + 1.0) * (6.28318 / float(numCircles));
        float2 p1 = float2(cos(a1), sin(a1)) * orbitRadius;
        float2 p2 = float2(cos(a2), sin(a2)) * orbitRadius;
        
        float2 lineDir = normalize(p2 - p1);
        float2 toP = p - p1;
        float proj = dot(toP, lineDir);
        proj = clamp(proj, 0.0, length(p2 - p1));
        float2 closest = p1 + lineDir * proj;
        float lineDist = length(p - closest);
        float line = smoothstep(lineWidth * 0.3, 0.0, lineDist);
        col += line * 0.5;
    }
}

if (sriYantra > 0.5) {
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float triSize = 0.3 + fi * 0.15;
        float triAngle = fi * 1.047 + (fi == 1.0 ? 3.14159 : 0.0);
        for (int j = 0; j < 3; j++) {
            float a = float(j) * 2.094 + triAngle;
            float2 dir = float2(cos(a), sin(a));
            float d = abs(dot(p, dir) - triSize * 0.5);
            col += smoothstep(lineWidth * 0.3, 0.0, d) * 0.3;
        }
    }
}

if (glow > 0.5) {
    col += exp(-centerD * 2.0) * 0.3;
}

if (gradient > 0.5) {
    col *= mix(float3(0.7, 0.8, 1.0), float3(1.0, 0.9, 0.7), uv.y);
}

col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + timeVal);

if (neon > 0.5) col = pow(col, float3(0.6)) * 1.4;
if (invert > 0.5) col = 1.0 - col;

col = (col - 0.5) * contrast + 0.5;
col *= brightness;

if (noise > 0.5) {
    float n = fract(sin(dot(uv * 100.0 + timeVal, float2(12.9898, 78.233))) * 43758.5453);
    col += (n - 0.5) * 0.08;
}
if (scanlines > 0.5) col *= 0.9 + 0.1 * sin(uv.y * 400.0);
if (vignette > 0.5) col *= 1.0 - length(uv - 0.5) * 0.5;

col = clamp(col, 0.0, 1.0);
return float4(col, 1.0);
"""
