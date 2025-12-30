//
//  ShaderCodes_Part3.swift
//  LM_GLSL
//
//  Shader codes - Part 3: Cosmic, Organic, WaterLiquid, FireEnergy
//

import Foundation

// MARK: - Cosmic Category

let galaxyCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = sin(a * 3.0 + r * 10.0 - iTime * 2.0);
float stars = step(0.98, fract(sin(dot(floor(uv * 200.0), float2(12.9898, 78.233))) * 43758.5453));
float3 col = spiral * float3(0.5, 0.2, 0.8) * (1.0 - r);
col += stars * float3(1.0);
col += float3(0.1, 0.0, 0.2) * (1.0 - r * 0.5);
return float4(col, 1.0);
"""

let starfieldCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 sp = p * (50.0 + fi * 50.0);
    sp += float2(iTime * (1.0 + fi * 0.5), iTime * 0.3);
    float star = step(0.98, fract(sin(dot(floor(sp), float2(12.9898, 78.233))) * 43758.5453));
    float twinkle = 0.5 + 0.5 * sin(iTime * 5.0 + fi);
    col += star * twinkle * (1.0 - fi * 0.2);
}
return float4(col, 1.0);
"""

let nebulaCode = """
float2 p = uv * 3.0;
float3 col = float3(0.0);
float n = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 q = p + float2(sin(iTime * 0.1 + fi), cos(iTime * 0.15 + fi));
    n += sin(q.x * 2.0 + q.y * 2.0 + iTime * 0.5 + fi) * (1.0 / (fi + 1.0));
}
col = 0.5 + 0.5 * cos(n + float3(0.0, 2.0, 4.0));
col *= 0.8;
float stars = step(0.99, fract(sin(dot(floor(uv * 300.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars;
return float4(col, 1.0);
"""

let blackHoleCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float distort = 1.0 / (r + 0.1);
a += distort * 0.5 + iTime;
float3 col = float3(0.0);
float disk = smoothstep(0.2, 0.3, r) * smoothstep(0.8, 0.5, r);
disk *= 0.5 + 0.5 * sin(a * 10.0 - iTime * 5.0);
col += disk * float3(1.0, 0.5, 0.2);
col *= 1.0 - smoothstep(0.0, 0.2, r);
col += (1.0 - smoothstep(0.15, 0.2, r)) * 0.1;
return float4(col, 1.0);
"""

let cosmicDustCode = """
float2 p = uv * 4.0;
float3 col = float3(0.0);
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float2 q = p + float2(sin(iTime * 0.2 + fi * 2.0), cos(iTime * 0.3 + fi * 1.5));
    float dust = fract(sin(dot(floor(q), float2(12.9898, 78.233))) * 43758.5453);
    dust = smoothstep(0.5, 1.0, dust);
    col += dust * 0.2 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
float stars = step(0.995, fract(sin(dot(floor(uv * 400.0), float2(12.9898, 78.233))) * 43758.5453));
col += stars;
return float4(col, 1.0);
"""

// MARK: - Organic Category

let cellsCode = """
float2 p = uv * 8.0;
float3 col = float3(0.0);
float minDist = 10.0;
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float2 center = float2(
        fract(sin(fi * 12.9898) * 43758.5453) * 8.0,
        fract(sin(fi * 78.233) * 43758.5453) * 8.0
    );
    center += float2(sin(iTime + fi), cos(iTime * 0.7 + fi)) * 0.3;
    float d = length(p - center);
    minDist = min(minDist, d);
}
col = 0.5 + 0.5 * cos(minDist * 2.0 + float3(0.0, 2.0, 4.0) + iTime);
col *= smoothstep(0.0, 0.2, minDist);
return float4(col, 1.0);
"""

let veinsCode = """
float2 p = uv * 5.0;
float n = 0.0;
float amp = 1.0;
for (int i = 0; i < 5; i++) {
    float2 q = p * (float(i) + 1.0);
    n += amp * abs(sin(q.x + sin(q.y + iTime)));
    amp *= 0.5;
}
float vein = smoothstep(0.3, 0.0, abs(n - 0.5));
float3 col = mix(float3(0.2, 0.0, 0.0), float3(0.8, 0.1, 0.1), vein);
col += 0.1 * float3(0.5, 0.0, 0.0);
return float4(col, 1.0);
"""

let bacteriaCode = """
float2 p = uv * 10.0;
float3 col = float3(0.1, 0.15, 0.1);
for (int i = 0; i < 15; i++) {
    float fi = float(i);
    float2 center = float2(
        fract(sin(fi * 12.9898) * 43758.5453) * 10.0,
        fract(sin(fi * 78.233) * 43758.5453) * 10.0
    );
    center += float2(sin(iTime * 0.5 + fi * 2.0), cos(iTime * 0.3 + fi * 3.0)) * 0.5;
    float d = length(p - center);
    float bacteria = smoothstep(0.4, 0.3, d);
    float3 bcol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += bacteria * bcol * 0.3;
}
return float4(col, 1.0);
"""

let leafVeinsCode = """
float2 p = uv * 2.0 - 1.0;
float mainVein = smoothstep(0.02, 0.0, abs(p.x));
float3 col = float3(0.2, 0.5, 0.2);
col += mainVein * float3(0.0, 0.3, 0.0);
for (int i = 1; i <= 5; i++) {
    float fi = float(i);
    float y = fi * 0.15 - 0.3;
    float2 start = float2(0.0, y);
    float branch = smoothstep(0.015, 0.0, abs(p.y - y - (p.x) * 0.5));
    branch *= step(0.0, p.x) * step(p.x, 0.5);
    col += branch * float3(0.0, 0.2, 0.0);
}
col *= 0.8 + 0.2 * sin(iTime);
return float4(col, 1.0);
"""

let coralCode = """
float2 p = uv * 4.0 - 2.0;
float3 col = float3(0.1, 0.2, 0.4);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    p = abs(p) - 0.7;
    float a = iTime * 0.1 + fi * 0.5;
    float c = cos(a); float s = sin(a);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    float branch = smoothstep(0.1, 0.0, min(abs(p.x), abs(p.y)));
    col += branch * 0.1 * (0.5 + 0.5 * cos(float3(0.0, 1.0, 2.0) + fi));
}
return float4(col, 1.0);
"""

// MARK: - WaterLiquid Category

let raindropsCode = """
float2 p = uv;
float3 col = float3(0.1, 0.2, 0.3);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float2 dropPos = float2(
        fract(sin(fi * 12.9898) * 43758.5453),
        fract(fract(sin(fi * 78.233) * 43758.5453) + iTime * (0.3 + fi * 0.1))
    );
    float d = length(p - dropPos);
    float ripple = sin(d * 50.0 - iTime * 5.0) * exp(-d * 10.0);
    col += ripple * 0.2 * float3(0.3, 0.5, 0.8);
}
return float4(col, 1.0);
"""

let underwaterCode = """
float2 p = uv;
p.x += sin(p.y * 10.0 + iTime) * 0.02;
p.y += cos(p.x * 10.0 + iTime) * 0.02;
float3 col = float3(0.0, 0.3, 0.5);
float caustic = sin(p.x * 20.0 + iTime) * sin(p.y * 20.0 + iTime * 1.3);
caustic = pow(abs(caustic), 0.5);
col += caustic * float3(0.2, 0.4, 0.3);
col *= 0.5 + 0.5 * (1.0 - p.y);
return float4(col, 1.0);
"""

let bubbleCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1, 0.2, 0.4);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float2 center = float2(
        sin(fi * 2.3 + iTime * 0.5) * 0.5,
        fract(fi * 0.3 - iTime * 0.2) * 2.0 - 1.0
    );
    float r = 0.1 + 0.05 * sin(fi);
    float d = length(p - center);
    float bubble = smoothstep(r, r - 0.02, d);
    float highlight = smoothstep(r * 0.7, r * 0.5, length(p - center - float2(0.02, 0.02)));
    col += bubble * float3(0.2, 0.3, 0.4);
    col += highlight * bubble * 0.5;
}
return float4(col, 1.0);
"""

let pondRippleCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1, 0.3, 0.4);
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 center = float2(sin(fi * 2.0) * 0.3, cos(fi * 3.0) * 0.3);
    float d = length(p - center);
    float ripple = sin(d * 30.0 - iTime * 3.0 - fi * 2.0);
    ripple *= exp(-d * 3.0);
    col += ripple * 0.15 * float3(0.3, 0.5, 0.6);
}
return float4(col, 1.0);
"""

let waterfallCode = """
float2 p = uv;
float3 col = float3(0.2, 0.4, 0.6);
float flow = fract(p.y * 5.0 - iTime * 2.0);
flow = pow(flow, 0.5);
float noise = fract(sin(dot(floor(p * float2(50.0, 100.0) + iTime * 10.0), float2(12.9898, 78.233))) * 43758.5453);
col += flow * noise * float3(0.3, 0.4, 0.5);
col *= 0.7 + 0.3 * sin(p.x * 20.0 + iTime);
float mist = smoothstep(1.0, 0.7, p.y) * 0.3;
col += mist;
return float4(col, 1.0);
"""

// MARK: - FireEnergy Category

let plasmaFireCode = """
float2 p = uv * 3.0;
float n = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    n += sin(p.x * (fi + 1.0) + iTime * 2.0) * sin(p.y * (fi + 1.0) - iTime);
}
n = n * 0.2 + 0.5;
float fire = pow(max(0.0, 1.0 - uv.y), 2.0) * n;
float3 col = mix(float3(1.0, 0.3, 0.0), float3(1.0, 1.0, 0.0), fire);
col *= fire * 2.0;
return float4(col, 1.0);
"""

let lightningBoltCode = """
float2 p = uv;
p.x = abs(p.x - 0.5);
float bolt = 0.0;
float x = 0.0;
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float y = fi / 20.0;
    x += (fract(sin(fi * 43.758 + floor(iTime * 10.0)) * 43758.5453) - 0.5) * 0.1;
    float d = abs(p.y - y) + abs(p.x - abs(x));
    bolt += smoothstep(0.02, 0.0, d);
}
float3 col = bolt * float3(0.5, 0.7, 1.0);
col += bolt * bolt * float3(0.8, 0.9, 1.0);
return float4(col, 1.0);
"""

let solarFlareCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float sun = smoothstep(0.3, 0.28, r);
float corona = 0.0;
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float flare = sin(a * (fi + 3.0) + iTime * (fi * 0.5 + 1.0));
    flare = pow(max(0.0, flare), 3.0);
    corona += flare * smoothstep(0.6, 0.3, r) * 0.15;
}
float3 col = sun * float3(1.0, 0.8, 0.3);
col += corona * float3(1.0, 0.4, 0.1);
col += smoothstep(0.5, 0.3, r) * float3(0.3, 0.1, 0.0);
return float4(col, 1.0);
"""

let energyOrbCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.0);
float core = smoothstep(0.2, 0.0, r);
col += core * float3(1.0, 1.0, 1.0);
for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float wave = sin(a * 3.0 + r * 20.0 - iTime * 3.0 + fi);
    wave = pow(max(0.0, wave), 2.0);
    float ring = smoothstep(0.5, 0.2, r) * wave;
    col += ring * 0.3 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""

let electricArcCode = """
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.05);
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float y = 0.5 + sin(iTime * 2.0 + fi) * 0.2;
    float x = p.x;
    float offset = 0.0;
    for (int j = 0; j < 10; j++) {
        offset += (fract(sin(float(j) * 43.758 + floor(iTime * 20.0) + fi) * 43758.5453) - 0.5) * 0.05;
        float segY = y + offset;
        float d = abs(p.y - segY);
        float arc = smoothstep(0.02, 0.0, d) * smoothstep(float(j + 1) / 10.0, float(j) / 10.0, abs(x - 0.5));
        col += arc * float3(0.3, 0.5, 1.0);
    }
}
return float4(col, 1.0);
"""
