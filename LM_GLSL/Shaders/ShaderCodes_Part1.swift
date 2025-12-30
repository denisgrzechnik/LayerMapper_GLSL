//
//  ShaderCodes.swift
//  LM_GLSL
//
//  All shader fragment codes - Part 1: Basic, Tunnels, Nature, Geometric
//

import Foundation

// MARK: - Basic Category

let rainbowGradientCode = """
float t = uv.x + iTime * 0.2;
float3 col = 0.5 + 0.5 * cos(6.28318 * (t + float3(0.0, 0.33, 0.67)));
return float4(col, 1.0);
"""

let plasmaCode = """
float2 p = uv * 8.0;
float v = sin(p.x + iTime);
v += sin(p.y + iTime * 0.5);
v += sin((p.x + p.y) + iTime * 0.3);
v += sin(length(p) + iTime);
float3 col = 0.5 + 0.5 * cos(v + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""

let noiseCode = """
float2 p = uv * 10.0;
float n = fract(sin(dot(floor(p + iTime), float2(12.9898, 78.233))) * 43758.5453);
float3 col = float3(n);
return float4(col, 1.0);
"""

// MARK: - Tunnels Category

let warpTunnelCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float v = 1.0 / r + iTime * 2.0;
float3 col = 0.5 + 0.5 * cos(v + a * 3.0 + float3(0.0, 2.0, 4.0));
col *= smoothstep(0.0, 0.3, r);
return float4(col, 1.0);
"""

let starTunnelCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float star = abs(cos(a * 5.0));
float tunnel = 1.0 / r + iTime;
float v = star * tunnel;
float3 col = float3(1.0, 0.8, 0.3) * fract(v);
return float4(col, 1.0);
"""

let hypnoticSpiralCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = sin(r * 10.0 - a * 3.0 - iTime * 3.0);
float3 col = float3(0.5 + 0.5 * spiral);
col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + r * 5.0);
return float4(col, 1.0);
"""

// MARK: - Nature Category

let fireCode = """
float2 p = uv;
p.y += iTime * 0.5;
float n = 0.0;
float amp = 1.0;
float2 freq = float2(3.0, 3.0);
for (int i = 0; i < 5; i++) {
    n += amp * (0.5 + 0.5 * sin(p.x * freq.x + p.y * freq.y + iTime));
    freq *= 2.0;
    amp *= 0.5;
}
float fire = pow(1.0 - uv.y, 2.0) * n;
float3 col = mix(float3(1.0, 0.0, 0.0), float3(1.0, 1.0, 0.0), fire);
col = mix(float3(0.0), col, fire);
return float4(col, 1.0);
"""

let oceanWavesCode = """
float2 p = uv;
float wave = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    wave += sin(p.x * (3.0 + fi) + iTime * (1.0 + fi * 0.2) + fi) * 0.1 / (fi + 1.0);
}
float water = smoothstep(0.0, 0.02, wave + 0.5 - p.y);
float3 col = mix(float3(0.0, 0.2, 0.4), float3(0.0, 0.5, 0.8), water);
col += float3(0.3, 0.4, 0.5) * (1.0 - uv.y);
return float4(col, 1.0);
"""

let auroraCode = """
float2 p = uv;
float3 col = float3(0.0, 0.02, 0.05);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float wave = sin(p.x * 3.0 + iTime + fi) * 0.1 + 0.5 + fi * 0.08;
    float glow = smoothstep(0.1, 0.0, abs(p.y - wave));
    float3 auroraCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + iTime * 0.5);
    col += glow * auroraCol * 0.3;
}
return float4(col, 1.0);
"""

let electricStormCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.02, 0.05);
float flash = step(0.98, fract(sin(floor(iTime * 10.0) * 43.758) * 43758.5453));
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float x = sin(p.y * 10.0 + iTime * 5.0 + fi * 2.0) * 0.2;
    float bolt = smoothstep(0.02, 0.0, abs(p.x - x));
    col += bolt * float3(0.5, 0.5, 1.0) * (0.5 + flash);
}
col += flash * float3(0.2, 0.2, 0.3);
return float4(col, 1.0);
"""

// MARK: - Geometric Category

let kaleidoscopeCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float segments = 8.0;
a = mod(a, 6.28318 / segments);
a = abs(a - 3.14159 / segments);
float r = length(p);
float2 np = float2(cos(a), sin(a)) * r;
float3 col = 0.5 + 0.5 * cos(np.x * 10.0 + np.y * 10.0 + iTime + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""

let hexagonGridCode = """
float2 p = uv * 10.0;
float2 h = float2(1.0, 1.732);
float2 a = mod(p, h) - h * 0.5;
float2 b = mod(p + h * 0.5, h) - h * 0.5;
float2 g = length(a) < length(b) ? a : b;
float d = max(abs(g.x), abs(g.y) * 0.577 + abs(g.x) * 0.5);
float hex = smoothstep(0.4, 0.38, d);
float3 col = hex * (0.5 + 0.5 * cos(iTime + p.x * 0.5 + float3(0.0, 2.0, 4.0)));
return float4(col, 1.0);
"""

let voronoiCode = """
float2 p = uv * 5.0;
float minDist = 1.0;
for (int i = 0; i < 9; i++) {
    float2 cell = float2(float(i % 3), float(i / 3));
    float2 cellCenter = cell + 0.5 + 0.3 * sin(iTime + cell * 5.0);
    float d = length(fract(p) - cellCenter + cell - floor(p));
    minDist = min(minDist, d);
}
float3 col = 0.5 + 0.5 * cos(minDist * 10.0 + iTime + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""

let fractalCirclesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float r = 0.5 / (fi + 1.0);
    float2 offset = float2(sin(iTime + fi), cos(iTime * 0.7 + fi)) * 0.3;
    float circle = smoothstep(r, r - 0.02, length(p - offset));
    col += circle * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""

let infiniteCubesCode = """
float2 p = uv * 2.0 - 1.0;
float z = mod(iTime, 1.0);
float3 col = float3(0.0);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float depth = fi + z;
    float size = 1.0 / depth;
    float2 box = abs(p * size) - 0.5;
    float d = max(box.x, box.y);
    float edge = smoothstep(0.02, 0.0, abs(d));
    col += edge * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + depth));
}
return float4(col, 1.0);
"""

let rotatingTrianglesCode = """
float2 p = uv * 2.0 - 1.0;
float angle = iTime;
float c = cos(angle); float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float3 col = float3(0.0);
for (int i = 0; i < 3; i++) {
    float a = float(i) * 2.094395 + iTime;
    float2 dir = float2(cos(a), sin(a));
    float d = dot(p, dir);
    col += smoothstep(0.01, 0.0, abs(d - 0.3)) * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + float(i)));
}
return float4(col, 1.0);
"""

let penroseTilesCode = """
float2 p = uv * 5.0;
float angle = 0.628318;
float3 col = float3(0.1);
for (int i = 0; i < 5; i++) {
    float a = float(i) * angle + iTime * 0.2;
    float2 dir = float2(cos(a), sin(a));
    float d = dot(p, dir);
    float grid = abs(fract(d) - 0.5);
    col += smoothstep(0.05, 0.0, grid) * 0.2 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + float(i)));
}
return float4(col, 1.0);
"""

let truchetPatternCode = """
float2 p = uv * 10.0;
float2 id = floor(p);
float2 f = fract(p) - 0.5;
float h = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453);
if (h > 0.5) f.x = -f.x;
float d = abs(abs(f.x) + abs(f.y) - 0.5);
float3 col = smoothstep(0.05, 0.0, d) * (0.5 + 0.5 * cos(iTime + id.x + id.y + float3(0.0, 2.0, 4.0)));
return float4(col, 1.0);
"""

let sacredGeometryCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
for (int i = 0; i < 6; i++) {
    float a = float(i) * 1.047198 + iTime * 0.3;
    float2 center = float2(cos(a), sin(a)) * 0.5;
    float d = length(p - center);
    col += smoothstep(0.52, 0.48, d) * smoothstep(0.48, 0.52, d + 0.04);
}
float centerCircle = smoothstep(0.52, 0.48, length(p));
col += centerCircle * 0.3;
col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + iTime);
return float4(col, 1.0);
"""
