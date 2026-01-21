//
//  ShaderCodes_Part12.swift
//  LM_GLSL
//
//  Shader codes - Part 12: Weather & Atmospheric Effects (20 shaders)
//

import Foundation

// MARK: - Weather & Atmospheric Effects

/// Rain Storm
let rainStormCode = """
// @param rainDensity "Gęstość deszczu" range(10.0, 100.0) default(50.0)
// @param rainSpeed "Prędkość deszczu" range(1.0, 5.0) default(2.5)
// @param rainAngle "Kąt deszczu" range(-0.5, 0.5) default(0.1)
// @param dropLength "Długość kropli" range(0.02, 0.1) default(0.05)
// @param splashIntensity "Intensywność plusków" range(0.0, 1.0) default(0.5)
// @toggle lightning "Błyskawice" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.12, 0.15);
float lightningFlash = 0.0;
if (lightning > 0.5) {
    float flash = step(0.98, fract(sin(floor(iTime * 2.0) * 43.758) * 43758.5453));
    lightningFlash = flash * (sin(iTime * 100.0) * 0.5 + 0.5);
    col += lightningFlash * float3(0.8, 0.85, 0.9);
}
for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float layerSpeed = rainSpeed * (1.0 + fl * 0.3);
    float layerDensity = rainDensity * (1.0 - fl * 0.2);
    for (int i = 0; i < 100; i++) {
        if (float(i) >= layerDensity) break;
        float fi = float(i);
        float dropX = fract(sin(fi * 127.1 + fl * 50.0) * 43758.5453);
        float dropY = fract(sin(fi * 311.7 + fl * 50.0) * 43758.5453 + iTime * layerSpeed);
        float2 dropPos = float2(dropX + (1.0 - dropY) * rainAngle, 1.0 - dropY);
        float2 toP = p - dropPos;
        float dropDist = abs(toP.x) + max(0.0, toP.y) * 0.5 / dropLength;
        dropDist = max(dropDist, -toP.y / dropLength);
        float drop = smoothstep(0.01, 0.0, dropDist) * step(-dropLength, toP.y);
        float brightness = 0.3 + fl * 0.2;
        col += drop * brightness;
    }
}
if (splashIntensity > 0.0) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float splashX = fract(sin(fi * 43.758) * 43758.5453);
        float splashPhase = fract(sin(fi * 78.233) * 43758.5453 + iTime * rainSpeed * 0.5);
        if (p.y < 0.1) {
            float2 splashPos = float2(splashX, 0.05);
            float splashR = splashPhase * 0.05;
            float splash = smoothstep(0.005, 0.0, abs(length(p - splashPos) - splashR));
            splash *= (1.0 - splashPhase) * splashIntensity;
            col += splash * 0.3;
        }
    }
}
return float4(col, 1.0);
"""

/// Snow Fall
let snowFallCode = """
// @param snowDensity "Gęstość śniegu" range(20.0, 200.0) default(80.0)
// @param fallSpeed "Prędkość opadania" range(0.1, 1.0) default(0.3)
// @param windStrength "Siła wiatru" range(0.0, 0.5) default(0.1)
// @param flakeSize "Rozmiar płatków" range(0.005, 0.02) default(0.01)
// @param sparkle "Błysk" range(0.0, 1.0) default(0.5)
// @toggle accumulation "Akumulacja" default(true)
float2 p = uv;
float3 col = float3(0.15, 0.18, 0.25);
for (int layer = 0; layer < 4; layer++) {
    float fl = float(layer);
    float layerSpeed = fallSpeed * (0.5 + fl * 0.3);
    float layerSize = flakeSize * (0.7 + fl * 0.2);
    for (int i = 0; i < 200; i++) {
        if (float(i) >= snowDensity / 4.0) break;
        float fi = float(i);
        float seed = fi + fl * 200.0;
        float flakeX = fract(sin(seed * 127.1) * 43758.5453);
        float flakeY = fract(sin(seed * 311.7) * 43758.5453 + iTime * layerSpeed);
        float wind = sin(iTime * 0.5 + fi) * windStrength;
        float wobble = sin(iTime * 2.0 + fi * 3.0) * 0.02;
        float2 flakePos = float2(flakeX + wind + wobble, 1.0 - flakeY);
        float d = length(p - flakePos);
        float flake = smoothstep(layerSize, layerSize * 0.3, d);
        float brightness = 0.5 + fl * 0.15;
        if (sparkle > 0.0) {
            float sp = step(0.99, sin(iTime * 10.0 + fi * 5.0)) * sparkle;
            brightness += sp * 0.5;
        }
        col += flake * brightness;
    }
}
if (accumulation > 0.5) {
    float groundHeight = 0.08 + sin(p.x * 20.0) * 0.02 + sin(p.x * 50.0) * 0.005;
    float ground = smoothstep(groundHeight + 0.02, groundHeight, p.y);
    col = mix(col, float3(0.95, 0.97, 1.0), ground);
}
return float4(col, 1.0);
"""

/// Fog Mist
let fogMistCode = """
// @param fogDensity "Gęstość mgły" range(0.5, 3.0) default(1.5)
// @param fogSpeed "Prędkość mgły" range(0.0, 1.0) default(0.2)
// @param layerCount "Liczba warstw" range(2, 6) default(4)
// @param fogHeight "Wysokość mgły" range(0.0, 1.0) default(0.5)
// @param visibility "Widoczność" range(0.1, 1.0) default(0.5)
// @toggle volumetric "Volumetryczny" default(true)
float2 p = uv;
float3 col = float3(0.2, 0.25, 0.3);
float fog = 0.0;
for (int i = 0; i < 6; i++) {
    if (i >= int(layerCount)) break;
    float fi = float(i);
    float2 fogP = p;
    fogP.x += iTime * fogSpeed * (0.5 + fi * 0.2);
    fogP *= 2.0 + fi;
    float n1 = sin(fogP.x * 2.0 + fi) * sin(fogP.y * 1.5 + iTime * 0.3);
    float n2 = sin(fogP.x * 4.0 - fi * 0.5) * sin(fogP.y * 3.0 - iTime * 0.2);
    float layerFog = (n1 + n2 * 0.5) * 0.5 + 0.5;
    layerFog *= exp(-fi * 0.3);
    if (volumetric > 0.5) {
        layerFog *= smoothstep(fogHeight + 0.3, fogHeight - 0.1, p.y);
    }
    fog += layerFog / float(layerCount);
}
fog *= fogDensity;
fog = clamp(fog, 0.0, 1.0);
float3 fogColor = float3(0.7, 0.75, 0.8);
col = mix(col, fogColor, fog * (1.0 - visibility) + (1.0 - visibility) * 0.3);
return float4(col, 1.0);
"""

/// Cloud Formation
let cloudFormationCode = """
// @param cloudCover "Pokrycie chmur" range(0.0, 1.0) default(0.5)
// @param cloudSpeed "Prędkość chmur" range(0.0, 0.5) default(0.1)
// @param cloudHeight "Wysokość chmur" range(0.3, 0.8) default(0.6)
// @param fluffiness "Puszystość" range(1.0, 5.0) default(3.0)
// @param shadowDepth "Głębokość cieni" range(0.0, 0.5) default(0.2)
// @toggle sunset "Zachód słońca" default(false)
float2 p = uv;
float3 skyColor;
if (sunset > 0.5) {
    skyColor = mix(float3(0.9, 0.4, 0.2), float3(0.2, 0.1, 0.3), p.y);
} else {
    skyColor = mix(float3(0.6, 0.8, 1.0), float3(0.3, 0.5, 0.9), p.y);
}
float3 col = skyColor;
float cloud = 0.0;
for (int oct = 0; oct < 5; oct++) {
    float fo = float(oct);
    float freq = pow(2.0, fo);
    float amp = pow(0.5, fo);
    float2 cloudP = p * freq * fluffiness;
    cloudP.x += iTime * cloudSpeed * (1.0 + fo * 0.5);
    float n = sin(cloudP.x) * sin(cloudP.y * 0.7 + fo);
    n += sin(cloudP.x * 1.5 + cloudP.y) * 0.5;
    cloud += n * amp;
}
cloud = cloud * 0.5 + 0.5;
cloud = smoothstep(1.0 - cloudCover, 1.0 - cloudCover + 0.3, cloud);
cloud *= smoothstep(cloudHeight - 0.3, cloudHeight, p.y);
cloud *= smoothstep(1.0, cloudHeight + 0.1, p.y);
float3 cloudColor;
if (sunset > 0.5) {
    cloudColor = mix(float3(1.0, 0.8, 0.6), float3(0.9, 0.5, 0.4), 1.0 - p.y);
} else {
    cloudColor = float3(1.0, 1.0, 1.0);
}
float shadow = cloud * shadowDepth * (1.0 - p.y);
cloudColor *= (1.0 - shadow);
col = mix(col, cloudColor, cloud);
return float4(col, 1.0);
"""

/// Thunderstorm
let thunderstormCode = """
// @param stormIntensity "Intensywność burzy" range(0.3, 1.0) default(0.7)
// @param lightningFrequency "Częstotliwość błyskawic" range(0.1, 1.0) default(0.3)
// @param rainAmount "Ilość deszczu" range(0.0, 1.0) default(0.7)
// @param cloudDarkness "Ciemność chmur" range(0.3, 0.8) default(0.5)
// @param windForce "Siła wiatru" range(0.0, 0.5) default(0.2)
// @toggle dramaticLighting "Dramatyczne oświetlenie" default(true)
float2 p = uv;
float3 col = float3(0.1, 0.1, 0.12);
float clouds = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float2 cp = p * (2.0 + fi);
    cp.x += iTime * 0.1 * (1.0 + fi * 0.3);
    float n = sin(cp.x * 3.0) * sin(cp.y * 2.0 + fi);
    clouds += n * pow(0.6, fi);
}
clouds = clouds * 0.5 + 0.5;
clouds = pow(clouds, 1.0 / stormIntensity);
float3 cloudCol = mix(float3(0.2, 0.2, 0.25), float3(0.05, 0.05, 0.08), clouds * cloudDarkness);
col = mix(col, cloudCol, smoothstep(0.3, 0.7, p.y));
float lightning = 0.0;
float lightningTime = floor(iTime * lightningFrequency * 3.0);
float lightningRand = fract(sin(lightningTime * 43.758) * 43758.5453);
if (lightningRand > 0.7) {
    float flashPhase = fract(iTime * lightningFrequency * 3.0);
    if (flashPhase < 0.1) {
        float boltX = fract(sin(lightningTime * 127.1) * 43758.5453);
        float boltDist = abs(p.x - boltX);
        float bolt = exp(-boltDist * 20.0) * step(0.5, p.y);
        for (int j = 0; j < 5; j++) {
            float fj = float(j);
            float branchY = 0.9 - fj * 0.1;
            if (p.y < branchY && p.y > branchY - 0.1) {
                float branchX = boltX + (fract(sin(fj * 78.233 + lightningTime) * 43758.5453) - 0.5) * 0.2;
                bolt += exp(-abs(p.x - branchX) * 30.0) * 0.5;
            }
        }
        lightning = bolt * (1.0 - flashPhase * 10.0);
    }
}
if (dramaticLighting > 0.5) {
    col += lightning * float3(0.9, 0.9, 1.0);
    col += lightning * float3(0.3, 0.3, 0.4) * (1.0 - p.y);
}
if (rainAmount > 0.0) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float rx = fract(sin(fi * 127.1) * 43758.5453);
        float ry = fract(sin(fi * 311.7) * 43758.5453 + iTime * 2.0);
        float2 rp = float2(rx + (1.0 - ry) * windForce, 1.0 - ry);
        float rd = abs(p.x - rp.x);
        float rain = smoothstep(0.003, 0.0, rd) * step(rp.y - 0.03, p.y) * step(p.y, rp.y);
        col += rain * rainAmount * 0.3;
    }
}
return float4(col, 1.0);
"""

/// Sunrise Gradient
let sunriseGradientCode = """
// @param sunPosition "Pozycja słońca" range(-0.2, 0.5) default(0.1)
// @param sunSize "Rozmiar słońca" range(0.05, 0.2) default(0.1)
// @param glowIntensity "Intensywność blasku" range(0.5, 2.0) default(1.0)
// @param atmosphereThickness "Grubość atmosfery" range(0.5, 2.0) default(1.0)
// @param cloudAmount "Ilość chmur" range(0.0, 1.0) default(0.3)
// @toggle goldenHour "Złota godzina" default(true)
float2 p = uv;
float2 sunPos = float2(0.5, sunPosition);
float3 col;
if (goldenHour > 0.5) {
    float3 horizon = float3(1.0, 0.5, 0.2);
    float3 sky = float3(0.4, 0.6, 0.9);
    float3 zenith = float3(0.2, 0.3, 0.6);
    col = mix(horizon, sky, smoothstep(sunPosition, sunPosition + 0.4, p.y));
    col = mix(col, zenith, smoothstep(0.5, 1.0, p.y));
} else {
    col = mix(float3(0.9, 0.6, 0.4), float3(0.5, 0.7, 1.0), p.y);
}
float sunDist = length(p - sunPos);
float sun = smoothstep(sunSize, sunSize * 0.8, sunDist);
float3 sunColor = float3(1.0, 0.95, 0.8);
col = mix(col, sunColor, sun);
float glow = exp(-sunDist * 3.0 / glowIntensity) * glowIntensity;
float3 glowColor = goldenHour > 0.5 ? float3(1.0, 0.6, 0.3) : float3(1.0, 0.8, 0.5);
col += glow * glowColor * 0.5;
float scatter = exp(-sunDist * 2.0 / atmosphereThickness);
scatter *= smoothstep(sunPosition + 0.3, sunPosition, p.y);
col += scatter * float3(1.0, 0.4, 0.1) * 0.3 * atmosphereThickness;
if (cloudAmount > 0.0) {
    float2 cp = p * 5.0;
    cp.x += iTime * 0.05;
    float cloud = sin(cp.x * 2.0) * sin(cp.y * 1.5) * 0.5 + 0.5;
    cloud = smoothstep(1.0 - cloudAmount * 0.5, 1.0, cloud);
    cloud *= smoothstep(sunPosition, sunPosition + 0.5, p.y);
    float3 cloudCol = mix(float3(1.0, 0.7, 0.5), float3(1.0, 0.9, 0.8), p.y);
    col = mix(col, cloudCol, cloud * cloudAmount);
}
return float4(col, 1.0);
"""

/// Northern Lights Advanced
let northernLightsAdvancedCode = """
// @param waveCount "Liczba fal" range(2, 8) default(4)
// @param waveSpeed "Prędkość fal" range(0.1, 1.0) default(0.3)
// @param waveHeight "Wysokość fal" range(0.1, 0.5) default(0.3)
// @param colorMix "Mieszanie kolorów" range(0.0, 1.0) default(0.5)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @toggle stars "Gwiazdy" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.03, 0.05);
if (stars > 0.5) {
    for (int i = 0; i < 100; i++) {
        float fi = float(i);
        float2 starPos = float2(
            fract(sin(fi * 127.1) * 43758.5453),
            fract(sin(fi * 311.7) * 43758.5453)
        );
        float starD = length(p - starPos);
        float twinkle = sin(iTime * 3.0 + fi * 2.0) * 0.3 + 0.7;
        float star = smoothstep(0.003, 0.0, starD) * twinkle;
        col += star * 0.5;
    }
}
for (int w = 0; w < 8; w++) {
    if (w >= int(waveCount)) break;
    float fw = float(w);
    float waveBase = 0.5 + fw * 0.08;
    float waveY = waveBase + sin(p.x * 5.0 + iTime * waveSpeed + fw * 1.5) * waveHeight * 0.3;
    waveY += sin(p.x * 8.0 - iTime * waveSpeed * 1.5 + fw) * waveHeight * 0.15;
    float wave = smoothstep(waveHeight * 0.5, 0.0, abs(p.y - waveY));
    wave *= smoothstep(0.0, 0.3, p.y);
    float3 waveColor;
    float colorPhase = fw / float(waveCount) + colorMix;
    waveColor = 0.5 + 0.5 * cos(colorPhase * 6.28 + float3(0.0, 2.0, 4.0));
    waveColor = mix(float3(0.2, 0.8, 0.4), waveColor, colorMix);
    col += wave * waveColor * intensity / float(waveCount) * 2.0;
}
float curtain = sin(p.x * 30.0 + iTime * 2.0) * 0.5 + 0.5;
curtain *= smoothstep(0.3, 0.6, p.y) * smoothstep(0.9, 0.6, p.y);
col += curtain * float3(0.1, 0.3, 0.2) * intensity * 0.3;
return float4(col, 1.0);
"""

/// Dust Storm
let dustStormCode = """
// @param dustDensity "Gęstość pyłu" range(0.3, 1.0) default(0.6)
// @param windSpeed "Prędkość wiatru" range(1.0, 5.0) default(2.5)
// @param visibility "Widoczność" range(0.1, 0.8) default(0.4)
// @param particleSize "Rozmiar cząstek" range(0.005, 0.02) default(0.01)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.5)
// @toggle sandColor "Kolor piasku" default(true)
float2 p = uv;
float3 baseColor = sandColor > 0.5 ? float3(0.8, 0.6, 0.4) : float3(0.5, 0.5, 0.5);
float3 col = baseColor * visibility;
for (int layer = 0; layer < 5; layer++) {
    float fl = float(layer);
    float layerSpeed = windSpeed * (0.5 + fl * 0.3);
    float layerTurb = turbulence * (1.0 + fl * 0.2);
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float seed = fi + fl * 100.0;
        float px = fract(sin(seed * 127.1) * 43758.5453 + iTime * layerSpeed * 0.1);
        float py = fract(sin(seed * 311.7) * 43758.5453);
        float turb = sin(iTime * 2.0 + fi + fl) * layerTurb * 0.1;
        float2 particlePos = float2(px, py + turb);
        float d = length(p - particlePos);
        float particle = smoothstep(particleSize * (1.0 + fl * 0.5), 0.0, d);
        particle *= dustDensity;
        float brightness = 0.5 + fl * 0.1;
        col += particle * baseColor * brightness * 0.3;
    }
}
float noise = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 np = p * (3.0 + fi * 2.0);
    np.x += iTime * windSpeed * (0.3 + fi * 0.2);
    noise += sin(np.x * 5.0 + np.y * 3.0 + fi) * pow(0.5, fi);
}
noise = noise * 0.5 + 0.5;
col += noise * baseColor * dustDensity * 0.2;
col = mix(col, baseColor * 0.7, (1.0 - visibility) * dustDensity);
return float4(col, 1.0);
"""

/// Rainbow Arc
let rainbowArcCode = """
// @param arcRadius "Promień łuku" range(0.3, 0.8) default(0.5)
// @param arcWidth "Szerokość łuku" range(0.05, 0.2) default(0.1)
// @param arcPosition "Pozycja łuku" range(0.0, 0.5) default(0.2)
// @param saturation "Nasycenie" range(0.5, 1.0) default(0.8)
// @param secondaryArc "Drugorzędny łuk" range(0.0, 1.0) default(0.3)
// @toggle doubleRainbow "Podwójna tęcza" default(false)
float2 p = uv;
float2 arcCenter = float2(0.5, arcPosition - 0.2);
float3 skyColor = mix(float3(0.4, 0.5, 0.7), float3(0.6, 0.75, 0.95), p.y);
float3 col = skyColor;
float dist = length(p - arcCenter);
float arc = smoothstep(arcWidth, 0.0, abs(dist - arcRadius));
arc *= step(arcCenter.y, p.y);
float colorAngle = (dist - arcRadius + arcWidth) / (arcWidth * 2.0);
colorAngle = clamp(colorAngle, 0.0, 1.0);
float3 rainbowColor = 0.5 + 0.5 * cos((1.0 - colorAngle) * 3.0 + float3(0.0, 2.0, 4.0));
rainbowColor = mix(float3(0.5), rainbowColor, saturation);
col = mix(col, rainbowColor, arc * 0.7);
if (doubleRainbow > 0.5) {
    float secondRadius = arcRadius * 1.4;
    float secondWidth = arcWidth * 0.7;
    float secondDist = length(p - arcCenter);
    float secondArcMask = smoothstep(secondWidth, 0.0, abs(secondDist - secondRadius));
    secondArcMask *= step(arcCenter.y, p.y);
    float secondColorAngle = (secondDist - secondRadius + secondWidth) / (secondWidth * 2.0);
    secondColorAngle = clamp(secondColorAngle, 0.0, 1.0);
    float3 secondColor = 0.5 + 0.5 * cos(secondColorAngle * 3.0 + float3(0.0, 2.0, 4.0));
    col = mix(col, secondColor, secondArcMask * secondaryArc * 0.4);
}
return float4(col, 1.0);
"""

/// Hail Storm
let hailStormCode = """
// @param hailDensity "Gęstość gradu" range(10.0, 50.0) default(25.0)
// @param hailSize "Rozmiar gradu" range(0.01, 0.04) default(0.02)
// @param fallSpeed "Prędkość spadania" range(1.0, 4.0) default(2.0)
// @param bounceHeight "Wysokość odbicia" range(0.0, 0.2) default(0.1)
// @param iceSheen "Połysk lodu" range(0.0, 1.0) default(0.5)
// @toggle ground "Podłoże" default(true)
float2 p = uv;
float3 col = float3(0.15, 0.18, 0.22);
if (ground > 0.5) {
    float groundLine = 0.1;
    if (p.y < groundLine) {
        col = float3(0.3, 0.32, 0.35);
        float ice = sin(p.x * 50.0) * sin(p.x * 30.0 + 1.0) * 0.5 + 0.5;
        col += ice * 0.1 * iceSheen;
    }
}
for (int i = 0; i < 50; i++) {
    if (float(i) >= hailDensity) break;
    float fi = float(i);
    float hx = fract(sin(fi * 127.1) * 43758.5453);
    float hy = fract(sin(fi * 311.7) * 43758.5453 + iTime * fallSpeed);
    float groundY = 0.1;
    float fallY = 1.0 - hy;
    float bouncePhase = 0.0;
    if (fallY < groundY + bounceHeight) {
        float bounceT = (groundY + bounceHeight - fallY) / bounceHeight;
        bouncePhase = sin(bounceT * 3.14159);
    }
    float2 hailPos = float2(hx, max(groundY, fallY) + bouncePhase * bounceHeight * (1.0 - hy));
    float d = length(p - hailPos);
    float hail = smoothstep(hailSize, hailSize * 0.5, d);
    float3 hailColor = float3(0.9, 0.92, 0.95);
    float sheen = exp(-d / hailSize * 2.0) * iceSheen;
    hailColor += sheen * 0.3;
    col = mix(col, hailColor, hail);
}
return float4(col, 1.0);
"""

/// Heat Shimmer
let heatShimmerCode = """
// @param shimmerIntensity "Intensywność mżenia" range(0.0, 0.1) default(0.03)
// @param shimmerSpeed "Prędkość mżenia" range(1.0, 5.0) default(2.0)
// @param shimmerScale "Skala mżenia" range(5.0, 30.0) default(15.0)
// @param horizonHeight "Wysokość horyzontu" range(0.2, 0.5) default(0.3)
// @param heatIntensity "Intensywność ciepła" range(0.0, 1.0) default(0.5)
// @toggle desert "Pustynny" default(true)
float2 p = uv;
float shimmerMask = smoothstep(horizonHeight + 0.3, horizonHeight, p.y);
float2 shimmer = float2(
    sin(p.y * shimmerScale + iTime * shimmerSpeed) * sin(p.y * shimmerScale * 1.7 + iTime * shimmerSpeed * 0.7),
    sin(p.x * shimmerScale * 0.5 + iTime * shimmerSpeed * 0.5)
) * shimmerIntensity * shimmerMask;
float2 sp = p + shimmer;
float3 col;
if (desert > 0.5) {
    float3 skyColor = mix(float3(0.9, 0.85, 0.7), float3(0.6, 0.75, 0.95), sp.y);
    float3 groundColor = float3(0.85, 0.75, 0.55);
    col = mix(groundColor, skyColor, smoothstep(horizonHeight - 0.05, horizonHeight + 0.05, sp.y));
} else {
    col = mix(float3(0.3, 0.35, 0.3), float3(0.5, 0.7, 0.9), sp.y);
}
float heatHaze = shimmerMask * heatIntensity;
col = mix(col, col * 1.1, heatHaze * sin(p.y * 50.0 + iTime * 3.0) * 0.5 + 0.5);
if (desert > 0.5 && p.y < horizonHeight) {
    float mirage = smoothstep(horizonHeight, horizonHeight - 0.1, p.y);
    mirage *= shimmerMask;
    float3 mirageColor = mix(float3(0.7, 0.85, 1.0), col, 0.5);
    col = mix(col, mirageColor, mirage * 0.3);
}
return float4(col, 1.0);
"""

/// Tornado Funnel
let tornadoFunnelCode = """
// @param funnelWidth "Szerokość leja" range(0.05, 0.2) default(0.1)
// @param rotationSpeed "Prędkość rotacji" range(1.0, 5.0) default(3.0)
// @param debrisAmount "Ilość gruzu" range(0.0, 1.0) default(0.5)
// @param funnelHeight "Wysokość leja" range(0.5, 1.0) default(0.8)
// @param intensity "Intensywność" range(0.5, 2.0) default(1.0)
// @toggle touchingGround "Dotyka ziemi" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.3, 0.35, 0.4);
float cloudBase = 0.6;
if (p.y > cloudBase) {
    float cloud = sin(p.x * 5.0 + iTime * 0.5) * 0.1 + 0.5;
    col = mix(col, float3(0.2, 0.22, 0.25), cloud);
}
float groundY = touchingGround > 0.5 ? -0.8 : -0.5;
float funnelY = (p.y - groundY) / (cloudBase - groundY);
funnelY = clamp(funnelY, 0.0, 1.0);
float currentWidth = funnelWidth * (0.3 + funnelY * 0.7);
float twist = atan2(p.x, funnelY + 0.1) + iTime * rotationSpeed;
float spiral = sin(twist * 5.0 + funnelY * 10.0) * 0.5 + 0.5;
float funnelDist = abs(p.x) - currentWidth;
float funnel = smoothstep(0.05, 0.0, funnelDist);
funnel *= step(groundY, p.y) * step(p.y, cloudBase);
float3 funnelColor = mix(float3(0.2, 0.18, 0.15), float3(0.35, 0.32, 0.28), spiral);
funnelColor *= intensity;
col = mix(col, funnelColor, funnel);
if (debrisAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float debrisAngle = fi * 0.5 + iTime * rotationSpeed * (0.8 + fract(sin(fi) * 0.4));
        float debrisY = fract(fi * 0.123 + iTime * 0.3) * (cloudBase - groundY) + groundY;
        float debrisR = currentWidth * (1.0 + sin(fi) * 0.5) * ((debrisY - groundY) / (cloudBase - groundY));
        float2 debrisPos = float2(sin(debrisAngle) * debrisR, debrisY);
        float d = length(p - debrisPos);
        float debris = smoothstep(0.02, 0.01, d) * debrisAmount;
        col = mix(col, float3(0.15, 0.12, 0.1), debris);
    }
}
return float4(col, 1.0);
"""

/// Blizzard
let blizzardCode = """
// @param snowIntensity "Intensywność śniegu" range(50.0, 200.0) default(100.0)
// @param windStrength "Siła wiatru" range(0.2, 1.0) default(0.5)
// @param visibility "Widoczność" range(0.1, 0.5) default(0.3)
// @param whiteoutAmount "Zamieć" range(0.0, 0.5) default(0.2)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.5)
// @toggle ground "Podłoże" default(true)
float2 p = uv;
float3 col = float3(0.7, 0.75, 0.8) * visibility;
if (ground > 0.5 && p.y < 0.2) {
    col = float3(0.9, 0.92, 0.95);
    float snowDrift = sin(p.x * 10.0 + iTime * windStrength) * 0.02;
    col *= 0.95 + snowDrift;
}
for (int layer = 0; layer < 5; layer++) {
    float fl = float(layer);
    float layerWind = windStrength * (0.8 + fl * 0.2);
    float layerTurb = turbulence * (1.0 + fl * 0.3);
    for (int i = 0; i < 200; i++) {
        if (float(i) >= snowIntensity / 5.0) break;
        float fi = float(i);
        float seed = fi + fl * 200.0;
        float sx = fract(sin(seed * 127.1) * 43758.5453 + iTime * layerWind * 0.2);
        float sy = fract(sin(seed * 311.7) * 43758.5453 + iTime * 0.5);
        float turb = sin(iTime * 3.0 + fi + fl) * layerTurb * 0.05;
        sx += turb;
        float2 snowPos = float2(sx, 1.0 - sy);
        float d = length(p - snowPos);
        float flakeSize = 0.008 * (0.7 + fl * 0.2);
        float snow = smoothstep(flakeSize, flakeSize * 0.3, d);
        float brightness = 0.4 + fl * 0.15;
        col += snow * brightness;
    }
}
float whiteout = whiteoutAmount * (1.0 - visibility);
col = mix(col, float3(0.85, 0.88, 0.9), whiteout);
col += whiteout * sin(p.x * 20.0 + iTime * windStrength * 5.0) * 0.05;
return float4(col, 1.0);
"""

/// Acid Rain
let acidRainCode = """
// @param rainDensity "Gęstość deszczu" range(20.0, 80.0) default(40.0)
// @param rainSpeed "Prędkość deszczu" range(1.0, 4.0) default(2.0)
// @param toxicity "Toksyczność" range(0.0, 1.0) default(0.6)
// @param puddleSize "Rozmiar kałuż" range(0.0, 0.3) default(0.15)
// @param steamAmount "Ilość pary" range(0.0, 1.0) default(0.3)
// @toggle glowing "Świecący" default(true)
float2 p = uv;
float3 skyColor = mix(float3(0.2, 0.25, 0.15), float3(0.1, 0.15, 0.1), p.y);
float3 col = skyColor;
for (int i = 0; i < 80; i++) {
    if (float(i) >= rainDensity) break;
    float fi = float(i);
    float rx = fract(sin(fi * 127.1) * 43758.5453);
    float ry = fract(sin(fi * 311.7) * 43758.5453 + iTime * rainSpeed);
    float2 rainPos = float2(rx, 1.0 - ry);
    float rd = abs(p.x - rainPos.x);
    float rain = smoothstep(0.003, 0.0, rd);
    rain *= step(rainPos.y - 0.04, p.y) * step(p.y, rainPos.y);
    float3 rainColor;
    if (glowing > 0.5) {
        rainColor = mix(float3(0.5, 1.0, 0.3), float3(0.3, 0.8, 0.2), toxicity);
        rain *= 1.0 + toxicity * 0.5;
    } else {
        rainColor = float3(0.6, 0.7, 0.4);
    }
    col += rain * rainColor * 0.5;
}
if (puddleSize > 0.0 && p.y < 0.15) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float px = fract(sin(fi * 43.758) * 43758.5453);
        float2 puddlePos = float2(px, 0.08);
        float pd = length((p - puddlePos) * float2(1.0, 3.0));
        float puddle = smoothstep(puddleSize, puddleSize - 0.05, pd);
        float3 puddleColor = mix(float3(0.3, 0.5, 0.2), float3(0.4, 0.7, 0.3), toxicity);
        if (glowing > 0.5) {
            puddleColor += float3(0.1, 0.2, 0.05) * sin(iTime * 2.0 + fi) * 0.5;
        }
        col = mix(col, puddleColor, puddle * 0.7);
    }
}
if (steamAmount > 0.0) {
    float steam = sin(p.x * 10.0 + iTime) * sin(p.y * 8.0 + iTime * 0.7) * 0.5 + 0.5;
    steam *= smoothstep(0.3, 0.0, p.y) * steamAmount;
    float3 steamColor = float3(0.4, 0.5, 0.3);
    col = mix(col, steamColor, steam * 0.3);
}
return float4(col, 1.0);
"""

/// Meteor Rain
let meteorRainCode = """
// @param meteorCount "Liczba meteorów" range(5, 30) default(15)
// @param meteorSpeed "Prędkość meteorów" range(1.0, 5.0) default(2.5)
// @param trailLength "Długość smugi" range(0.1, 0.4) default(0.2)
// @param glowIntensity "Intensywność blasku" range(0.0, 1.0) default(0.6)
// @param fireIntensity "Intensywność ognia" range(0.0, 1.0) default(0.7)
// @toggle explosions "Eksplozje" default(true)
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.05);
for (int i = 0; i < 50; i++) {
    float fi = float(i);
    float2 starPos = float2(
        fract(sin(fi * 127.1) * 43758.5453),
        fract(sin(fi * 311.7) * 43758.5453)
    );
    float starD = length(p - starPos);
    float star = smoothstep(0.002, 0.0, starD);
    col += star * 0.3;
}
for (int i = 0; i < 30; i++) {
    if (i >= int(meteorCount)) break;
    float fi = float(i);
    float startX = fract(sin(fi * 127.1) * 43758.5453);
    float startY = fract(sin(fi * 311.7) * 43758.5453) * 0.5 + 0.5;
    float meteorPhase = fract(iTime * meteorSpeed * 0.2 + fi * 0.1);
    float2 meteorPos = float2(
        startX + meteorPhase * 0.3,
        startY - meteorPhase
    );
    if (meteorPos.y < 0.0) continue;
    float2 dir = normalize(float2(0.3, -1.0));
    float2 toP = p - meteorPos;
    float along = dot(toP, -dir);
    float perp = abs(dot(toP, float2(dir.y, -dir.x)));
    float trail = smoothstep(trailLength, 0.0, along) * step(0.0, along);
    trail *= smoothstep(0.02, 0.005, perp);
    float3 trailColor = mix(float3(1.0, 0.8, 0.3), float3(1.0, 0.3, 0.1), along / trailLength);
    trailColor *= fireIntensity;
    col += trail * trailColor;
    float head = smoothstep(0.02, 0.01, length(toP));
    col += head * float3(1.0, 0.9, 0.7);
    float glow = exp(-length(toP) * 10.0) * glowIntensity;
    col += glow * float3(1.0, 0.5, 0.2);
}
if (explosions > 0.5) {
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float explodeTime = fract(iTime * 0.5 + fi * 0.2);
        if (explodeTime < 0.2) {
            float2 explodePos = float2(
                fract(sin(fi * 43.758 + floor(iTime * 0.5)) * 43758.5453),
                0.05 + fract(sin(fi * 78.233 + floor(iTime * 0.5)) * 43758.5453) * 0.1
            );
            float explodeR = explodeTime * 0.3;
            float explode = smoothstep(explodeR + 0.02, explodeR, length(p - explodePos));
            explode *= (1.0 - explodeTime * 5.0);
            col += explode * float3(1.0, 0.6, 0.2);
        }
    }
}
return float4(col, 1.0);
"""

/// Eclipse
let eclipseCode = """
// @param eclipsePhase "Faza zaćmienia" range(0.0, 1.0) default(0.5)
// @param coronaSize "Rozmiar korony" range(0.1, 0.4) default(0.2)
// @param coronaIntensity "Intensywność korony" range(0.5, 2.0) default(1.0)
// @param sunSize "Rozmiar słońca" range(0.15, 0.3) default(0.2)
// @param diamondRing "Pierścień diamentowy" range(0.0, 1.0) default(0.0)
// @toggle totalEclipse "Całkowite zaćmienie" default(true)
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
for (int i = 0; i < 100; i++) {
    float fi = float(i);
    float2 starPos = float2(
        fract(sin(fi * 127.1) * 43758.5453) * 2.0 - 1.0,
        fract(sin(fi * 311.7) * 43758.5453) * 2.0 - 1.0
    );
    float starD = length(p - starPos);
    float star = smoothstep(0.003, 0.0, starD) * 0.5;
    col += star;
}
float2 sunPos = float2(0.0, 0.0);
float sunDist = length(p - sunPos);
float moonOffset = totalEclipse > 0.5 ? 0.0 : (eclipsePhase - 0.5) * 0.3;
float2 moonPos = float2(moonOffset, 0.0);
float moonDist = length(p - moonPos);
float corona = exp(-sunDist / coronaSize) * coronaIntensity;
float3 coronaColor = mix(float3(1.0, 0.8, 0.5), float3(1.0, 0.4, 0.2), sunDist / coronaSize);
col += corona * coronaColor;
float streamers = 0.0;
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float angle = fi * 0.785 + iTime * 0.1;
    float2 dir = float2(cos(angle), sin(angle));
    float streamer = exp(-abs(dot(p, float2(-dir.y, dir.x))) * 10.0);
    streamer *= exp(-sunDist * 3.0);
    streamers += streamer;
}
col += streamers * coronaColor * coronaIntensity * 0.3;
float sun = smoothstep(sunSize + 0.01, sunSize, sunDist);
col = mix(col, float3(1.0, 0.95, 0.8), sun);
float moonSize = sunSize * (0.9 + eclipsePhase * 0.2);
float moon = smoothstep(moonSize + 0.005, moonSize, moonDist);
col *= (1.0 - moon);
if (diamondRing > 0.0 && abs(eclipsePhase - 0.5) < 0.1) {
    float ringAngle = 0.785;
    float2 ringDir = float2(cos(ringAngle), sin(ringAngle));
    float ring = exp(-length(p - ringDir * sunSize) * 20.0);
    col += ring * float3(1.0, 1.0, 1.0) * diamondRing * 2.0;
}
return float4(col, 1.0);
"""

/// Volcanic Ash
let volcanicAshCode = """
// @param ashDensity "Gęstość popiołu" range(0.3, 1.0) default(0.6)
// @param fallSpeed "Prędkość opadania" range(0.1, 0.5) default(0.2)
// @param emberAmount "Ilość żaru" range(0.0, 1.0) default(0.4)
// @param smokeOpacity "Przezroczystość dymu" range(0.3, 0.8) default(0.5)
// @param lavaGlow "Blask lawy" range(0.0, 1.0) default(0.3)
// @toggle volcano "Wulkan" default(true)
float2 p = uv;
float3 col = float3(0.15, 0.1, 0.08);
if (volcano > 0.5) {
    float volcanoShape = smoothstep(0.3, 0.0, abs(p.x - 0.5) - (0.3 - p.y * 0.3));
    volcanoShape *= step(p.y, 0.4);
    col = mix(col, float3(0.1, 0.08, 0.06), volcanoShape);
    float crater = smoothstep(0.05, 0.0, abs(p.x - 0.5)) * step(0.35, p.y) * step(p.y, 0.42);
    float3 craterGlow = float3(1.0, 0.4, 0.1) * lavaGlow;
    craterGlow *= 0.8 + sin(iTime * 3.0) * 0.2;
    col += crater * craterGlow;
}
for (int i = 0; i < 100; i++) {
    float fi = float(i);
    float ax = fract(sin(fi * 127.1) * 43758.5453);
    float ay = fract(sin(fi * 311.7) * 43758.5453 + iTime * fallSpeed);
    float2 ashPos = float2(ax, 1.0 - ay);
    float wind = sin(iTime + fi) * 0.05;
    ashPos.x += wind;
    float d = length(p - ashPos);
    float ash = smoothstep(0.008, 0.003, d) * ashDensity;
    col += ash * float3(0.3, 0.28, 0.25);
}
if (emberAmount > 0.0) {
    for (int i = 0; i < 30; i++) {
        float fi = float(i);
        float ex = fract(sin(fi * 43.758) * 43758.5453) * 0.4 + 0.3;
        float ey = fract(sin(fi * 78.233) * 43758.5453 - iTime * 0.3);
        if (volcano > 0.5) {
            ey = 0.4 + ey * 0.5;
        }
        float2 emberPos = float2(ex, ey);
        float d = length(p - emberPos);
        float ember = smoothstep(0.01, 0.005, d) * emberAmount;
        float flicker = sin(iTime * 10.0 + fi * 5.0) * 0.3 + 0.7;
        col += ember * float3(1.0, 0.5, 0.1) * flicker;
    }
}
float smoke = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 sp = p * (2.0 + fi);
    sp.y -= iTime * 0.1 * (1.0 + fi * 0.3);
    smoke += sin(sp.x * 3.0 + fi) * sin(sp.y * 2.0) * pow(0.5, fi);
}
smoke = smoke * 0.5 + 0.5;
smoke *= step(0.3, p.y) * smokeOpacity;
col = mix(col, float3(0.2, 0.18, 0.15), smoke * 0.5);
return float4(col, 1.0);
"""

/// Wind Patterns
let windPatternsCode = """
// @param windSpeed "Prędkość wiatru" range(0.5, 3.0) default(1.5)
// @param streamCount "Liczba strumieni" range(5, 20) default(10)
// @param streamLength "Długość strumieni" range(0.1, 0.5) default(0.3)
// @param turbulence "Turbulencja" range(0.0, 1.0) default(0.3)
// @param visibility "Widoczność" range(0.2, 0.8) default(0.5)
// @toggle showParticles "Pokaż cząstki" default(true)
float2 p = uv;
float3 col = float3(0.7, 0.8, 0.9);
for (int i = 0; i < 20; i++) {
    if (i >= int(streamCount)) break;
    float fi = float(i);
    float streamY = fract(sin(fi * 127.1) * 43758.5453);
    float streamPhase = fract(iTime * windSpeed * 0.2 + fi * 0.1);
    float waveY = sin(p.x * 10.0 + iTime * windSpeed + fi) * turbulence * 0.1;
    float streamDist = abs(p.y - streamY - waveY);
    float stream = smoothstep(0.02, 0.005, streamDist);
    float fade = smoothstep(0.0, streamLength, streamPhase) * smoothstep(1.0, 1.0 - streamLength, streamPhase);
    float xMask = smoothstep(streamPhase - streamLength, streamPhase, p.x);
    xMask *= smoothstep(streamPhase + 0.02, streamPhase, p.x);
    col += stream * visibility * fade * xMask * 0.3;
}
if (showParticles > 0.5) {
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        float px = fract(sin(fi * 127.1) * 43758.5453 + iTime * windSpeed * 0.3);
        float py = fract(sin(fi * 311.7) * 43758.5453);
        float wobble = sin(iTime * 2.0 + fi) * turbulence * 0.05;
        float2 particlePos = float2(px, py + wobble);
        float d = length(p - particlePos);
        float particle = smoothstep(0.005, 0.002, d);
        col += particle * visibility * 0.2;
    }
}
return float4(col, 1.0);
"""

