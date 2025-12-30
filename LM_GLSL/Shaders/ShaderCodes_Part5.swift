//
//  ShaderCodes_Part5.swift
//  LM_GLSL
//
//  Shader codes - Part 5: ThreeD (3DStyle), Particles, Neon, Tech, Motion, Minimal
//

import Foundation

// MARK: - 3DStyle Category

let raymarchingCubeCode = """
float2 p = uv * 2.0 - 1.0;
float3 ro = float3(0.0, 0.0, -3.0);
float3 rd = normalize(float3(p, 1.0));
float t = 0.0;
for (int i = 0; i < 50; i++) {
    float3 pos = ro + rd * t;
    float a = iTime;
    float c = cos(a); float s = sin(a);
    pos.xz = float2(pos.x * c - pos.z * s, pos.x * s + pos.z * c);
    float d = max(abs(pos.x), max(abs(pos.y), abs(pos.z))) - 0.5;
    if (d < 0.001) break;
    t += d;
    if (t > 10.0) break;
}
float3 col = float3(0.0);
if (t < 10.0) {
    col = 0.5 + 0.5 * cos(t * 2.0 + float3(0.0, 2.0, 4.0));
}
return float4(col, 1.0);
"""

let sphereGridCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1);
for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
        float fi = float(i) - 2.0;
        float fj = float(j) - 2.0;
        float2 center = float2(fi, fj) * 0.3;
        float z = sin(iTime + fi + fj) * 0.3;
        float size = 0.1 + z * 0.05;
        float d = length(p - center) / size;
        float sphere = smoothstep(1.0, 0.9, d);
        float3 scol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi + fj);
        col += sphere * scol * (0.5 + z);
    }
}
return float4(col, 1.0);
"""

let tunnelCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float tunnel = 1.0 / r;
float z = tunnel + iTime * 2.0;
float3 col = 0.5 + 0.5 * cos(z + a * 2.0 + float3(0.0, 2.0, 4.0));
col *= smoothstep(0.0, 0.1, r);
col *= exp(-r * 0.5);
return float4(col, 1.0);
"""

let torusCode = """
float2 p = uv * 2.0 - 1.0;
float3 ro = float3(0.0, 0.0, -4.0);
float3 rd = normalize(float3(p, 1.5));
float t = 0.0;
for (int i = 0; i < 64; i++) {
    float3 pos = ro + rd * t;
    float a = iTime * 0.5;
    pos.yz = float2(pos.y * cos(a) - pos.z * sin(a), pos.y * sin(a) + pos.z * cos(a));
    float2 q = float2(length(pos.xz) - 1.0, pos.y);
    float d = length(q) - 0.4;
    if (d < 0.001) break;
    t += d * 0.5;
    if (t > 10.0) break;
}
float3 col = (t < 10.0) ? 0.5 + 0.5 * cos(t + float3(0.0, 2.0, 4.0)) : float3(0.0);
return float4(col, 1.0);
"""

let infiniteGridCode = """
float2 p = uv * 2.0 - 1.0;
float z = 1.0 / (1.0 - p.y * 0.5);
float x = p.x * z;
x += iTime;
z += iTime * 3.0;
float gridX = smoothstep(0.05, 0.0, abs(fract(x) - 0.5));
float gridZ = smoothstep(0.05, 0.0, abs(fract(z * 0.5) - 0.5));
float grid = max(gridX, gridZ);
float3 col = grid * float3(0.0, 0.8, 1.0);
col *= (1.0 - p.y) * 0.5;
col += float3(0.0, 0.0, 0.1);
return float4(col, 1.0);
"""

// MARK: - Particles Category

let particleFieldCode = """
float2 p = uv;
float3 col = float3(0.02);
for (int i = 0; i < 30; i++) {
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453 + iTime * 0.1),
        fract(sin(fi * 78.233) * 43758.5453 + iTime * 0.15)
    );
    float d = length(p - pos);
    float particle = smoothstep(0.02, 0.0, d);
    float3 pcol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += particle * pcol;
}
return float4(col, 1.0);
"""

let sparklesCode = """
float2 p = uv;
float3 col = float3(0.02);
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453),
        fract(sin(fi * 78.233) * 43758.5453)
    );
    float phase = fract(iTime * 0.5 + fi * 0.1);
    float brightness = sin(phase * 3.14159);
    brightness = pow(brightness, 3.0);
    float d = length(p - pos);
    float sparkle = smoothstep(0.03, 0.0, d) * brightness;
    col += sparkle * float3(1.0, 0.9, 0.7);
}
return float4(col, 1.0);
"""

let snowCode = """
float2 p = uv;
float3 col = float3(0.1, 0.15, 0.2);
for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float speed = 0.3 + fl * 0.2;
    float size = 0.01 + fl * 0.005;
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float2 pos = float2(
            fract(sin(fi * 12.9898 + fl) * 43758.5453),
            fract(sin(fi * 78.233 + fl) * 43758.5453 - iTime * speed)
        );
        pos.x += sin(pos.y * 10.0 + iTime) * 0.02;
        float d = length(p - pos);
        float snow = smoothstep(size, 0.0, d);
        col += snow * 0.3 * (1.0 - fl * 0.2);
    }
}
return float4(col, 1.0);
"""

let firefliesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02, 0.03, 0.05);
for (int i = 0; i < 15; i++) {
    float fi = float(i);
    float2 pos = float2(
        sin(iTime * 0.5 + fi * 2.0) * 0.8,
        cos(iTime * 0.3 + fi * 1.7) * 0.8
    );
    float phase = sin(iTime * 3.0 + fi * 5.0) * 0.5 + 0.5;
    phase = pow(phase, 2.0);
    float d = length(p - pos);
    float glow = smoothstep(0.2, 0.0, d) * phase;
    col += glow * float3(0.8, 1.0, 0.3);
}
return float4(col, 1.0);
"""

let dustMotesCode = """
float2 p = uv;
float3 col = float3(0.05, 0.04, 0.03);
for (int i = 0; i < 30; i++) {
    float fi = float(i);
    float2 pos = float2(
        fract(sin(fi * 12.9898) * 43758.5453 + sin(iTime * 0.1 + fi) * 0.1),
        fract(sin(fi * 78.233) * 43758.5453 + cos(iTime * 0.08 + fi) * 0.1)
    );
    float d = length(p - pos);
    float mote = smoothstep(0.01, 0.0, d);
    float brightness = 0.3 + 0.2 * sin(iTime + fi);
    col += mote * brightness * float3(1.0, 0.95, 0.8);
}
return float4(col, 1.0);
"""

// MARK: - Neon Category

let neonLinesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float y = sin(p.x * 5.0 + iTime + fi * 2.0) * 0.3 + fi * 0.15 - 0.3;
    float line = smoothstep(0.02, 0.0, abs(p.y - y));
    float glow = smoothstep(0.15, 0.0, abs(p.y - y));
    float3 lineCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += line * lineCol;
    col += glow * lineCol * 0.3;
}
return float4(col, 1.0);
"""

let neonSignCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
float d = abs(length(p) - 0.5);
float ring = smoothstep(0.03, 0.0, d);
float glow = smoothstep(0.2, 0.0, d);
float flicker = 0.9 + 0.1 * sin(iTime * 30.0) * sin(iTime * 17.0);
float3 neonCol = float3(1.0, 0.1, 0.5) * flicker;
col += ring * neonCol;
col += glow * neonCol * 0.4;
float crossH = smoothstep(0.02, 0.0, abs(p.y)) * step(abs(p.x), 0.3);
float crossV = smoothstep(0.02, 0.0, abs(p.x)) * step(abs(p.y), 0.3);
col += (crossH + crossV) * float3(0.1, 0.5, 1.0) * flicker;
return float4(col, 1.0);
"""

let laserGridCode = """
float2 p = uv * 10.0;
float3 col = float3(0.02);
float gridX = smoothstep(0.05, 0.0, abs(fract(p.x) - 0.5));
float gridY = smoothstep(0.05, 0.0, abs(fract(p.y) - 0.5));
float pulse = 0.5 + 0.5 * sin(iTime * 3.0);
col += gridX * float3(1.0, 0.0, 0.5) * pulse;
col += gridY * float3(0.0, 0.5, 1.0) * pulse;
col += gridX * gridY * float3(1.0, 0.5, 1.0);
return float4(col, 1.0);
"""

let glowingEdgesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
float box = max(abs(p.x), abs(p.y));
float edge = smoothstep(0.02, 0.0, abs(box - 0.5));
float glow = smoothstep(0.2, 0.0, abs(box - 0.5));
float hue = atan2(p.y, p.x) / 6.28 + 0.5 + iTime * 0.1;
float3 edgeCol = 0.5 + 0.5 * cos(hue * 6.28 + float3(0.0, 2.0, 4.0));
col += edge * edgeCol;
col += glow * edgeCol * 0.4;
return float4(col, 1.0);
"""

let cyberpunkCityCode = """
float2 p = uv;
float3 col = float3(0.02, 0.01, 0.03);
float horizon = 0.4;
if (p.y < horizon) {
    float grad = p.y / horizon;
    col = mix(float3(0.5, 0.0, 0.3), float3(0.0, 0.0, 0.1), grad);
} else {
    float gy = (p.y - horizon) / (1.0 - horizon);
    float buildings = step(0.5, fract(sin(floor(p.x * 20.0) * 43.758) * 43758.5453));
    float height = fract(sin(floor(p.x * 20.0) * 78.233) * 43758.5453) * 0.6;
    buildings *= step(gy, height);
    col += buildings * float3(0.05);
    float window = step(0.8, fract(sin(dot(floor(p * float2(80.0, 40.0)), float2(12.9898, 78.233))) * 43758.5453));
    window *= buildings;
    float3 windowCol = 0.5 + 0.5 * cos(floor(p.x * 20.0) + float3(0.0, 2.0, 4.0));
    col += window * windowCol * 0.5;
}
return float4(col, 1.0);
"""

// MARK: - Tech Category

let circuitBoardCode = """
float2 p = uv * 20.0;
float2 i = floor(p);
float2 f = fract(p);
float3 col = float3(0.0, 0.2, 0.1);
float trace = 0.0;
float h = fract(sin(dot(i, float2(12.9898, 78.233))) * 43758.5453);
if (h > 0.7) {
    trace = smoothstep(0.52, 0.48, abs(f.x - 0.5));
} else if (h > 0.4) {
    trace = smoothstep(0.52, 0.48, abs(f.y - 0.5));
}
col += trace * float3(0.6, 0.5, 0.2);
float pad = step(length(f - 0.5), 0.15) * step(0.9, h);
col += pad * float3(0.8, 0.7, 0.3);
return float4(col, 1.0);
"""

let dataStreamCode = """
float2 p = uv;
float3 col = float3(0.02);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float x = fi / 10.0 + 0.05;
    float speed = 1.0 + fract(sin(fi * 43.758) * 43758.5453);
    float y = fract(iTime * speed + fi * 0.3);
    float bit = step(0.5, fract(sin(floor(y * 20.0) * 43.758 + fi) * 43758.5453));
    float d = length(p - float2(x, y));
    float glow = smoothstep(0.05, 0.0, d) * bit;
    col += glow * float3(0.0, 1.0, 0.5);
}
return float4(col, 1.0);
"""

let hologramCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.0);
float ring = smoothstep(0.02, 0.0, abs(r - 0.5));
ring *= 0.5 + 0.5 * sin(a * 20.0 - iTime * 5.0);
col += ring * float3(0.0, 0.8, 1.0);
float scanline = sin(p.y * 50.0 + iTime * 10.0) * 0.5 + 0.5;
col *= 0.7 + 0.3 * scanline;
float flicker = 0.95 + 0.05 * sin(iTime * 50.0);
col *= flicker;
col += smoothstep(0.6, 0.0, r) * float3(0.0, 0.2, 0.3) * 0.3;
return float4(col, 1.0);
"""

let binaryRainCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float x = fi / 20.0 + 0.025;
    float speed = 0.5 + fract(sin(fi * 12.9898) * 43758.5453) * 0.5;
    float y = fract(iTime * speed + fi * 0.5);
    for (int j = 0; j < 10; j++) {
        float fj = float(j);
        float by = fract(y + fj * 0.05);
        float bit = step(0.5, fract(sin(fj * 78.233 + floor(iTime * 5.0) + fi) * 43758.5453));
        float d = length(p - float2(x, by));
        float glow = smoothstep(0.02, 0.0, d);
        float fade = 1.0 - fj * 0.1;
        col += glow * float3(0.0, 1.0 * fade, 0.3 * fade);
    }
}
return float4(col, 1.0);
"""

let loadingSpinnerCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.02);
float segments = 12.0;
float seg = floor(a / 6.28 * segments + 0.5);
float segAngle = seg / segments * 6.28;
float arcLength = mod(iTime * 2.0, segments);
float brightness = 1.0 - mod(seg - arcLength + segments, segments) / segments;
brightness = pow(brightness, 2.0);
float ring = smoothstep(0.45, 0.4, r) * smoothstep(0.3, 0.35, r);
ring *= step(abs(fract(a / 6.28 * segments) - 0.5), 0.35);
col += ring * brightness * float3(0.2, 0.5, 1.0);
return float4(col, 1.0);
"""

// MARK: - Motion Category

let flowFieldCode = """
float2 p = uv * 5.0;
float2 flow = float2(0.0);
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    flow.x += sin(p.y * (fi + 1.0) + iTime);
    flow.y += cos(p.x * (fi + 1.0) + iTime);
}
flow *= 0.1;
float3 col = 0.5 + 0.5 * cos(length(flow) * 5.0 + float3(0.0, 2.0, 4.0) + iTime);
return float4(col, 1.0);
"""

let vortexCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
a += iTime * 2.0;
a += r * 5.0;
float3 col = 0.5 + 0.5 * cos(a + float3(0.0, 2.0, 4.0));
col *= smoothstep(1.0, 0.0, r);
col += pow(max(0.0, 1.0 - r * 5.0), 2.0);
return float4(col, 1.0);
"""

let wavesCode = """
float2 p = uv;
float wave = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    wave += sin(p.x * 10.0 * (fi + 1.0) + iTime * (fi + 1.0)) * (1.0 / (fi + 1.0));
}
wave = wave * 0.2 + 0.5;
float3 col = smoothstep(0.02, 0.0, abs(p.y - wave)) * float3(0.2, 0.5, 1.0);
col += smoothstep(0.3, 0.0, abs(p.y - wave)) * float3(0.1, 0.2, 0.4);
return float4(col, 1.0);
"""

let oscillationCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float phase = iTime + fi * 0.5;
    float2 center = float2(sin(phase), cos(phase * 1.3)) * 0.5;
    float d = length(p - center);
    float ring = smoothstep(0.02, 0.0, abs(d - 0.2));
    float3 ringCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += ring * ringCol;
}
return float4(col, 1.0);
"""

let pendulumCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
float2 pivot = float2(0.0, 0.8);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float len = 0.3 + fi * 0.1;
    float angle = sin(iTime * 2.0 + fi * 0.5) * 0.8;
    float2 bob = pivot + float2(sin(angle), -cos(angle)) * len;
    float line = smoothstep(0.01, 0.0, abs(cross(float3(p - pivot, 0.0), float3(normalize(bob - pivot), 0.0)).z));
    line *= step(0.0, dot(p - pivot, bob - pivot));
    line *= step(length(p - pivot), len);
    col += line * 0.3;
    float d = length(p - bob);
    float ball = smoothstep(0.05, 0.03, d);
    float3 ballCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += ball * ballCol;
}
return float4(col, 1.0);
"""

// MARK: - Minimal Category

let singleCircleCode = """
float2 p = uv * 2.0 - 1.0;
float d = length(p);
float circle = smoothstep(0.52, 0.48, d);
float3 col = circle * float3(1.0);
return float4(col, 1.0);
"""

let crosshairCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
float h = smoothstep(0.02, 0.0, abs(p.y)) * step(0.1, abs(p.x)) * step(abs(p.x), 0.4);
float v = smoothstep(0.02, 0.0, abs(p.x)) * step(0.1, abs(p.y)) * step(abs(p.y), 0.4);
col += (h + v) * float3(1.0);
return float4(col, 1.0);
"""

let dotGridCode = """
float2 p = fract(uv * 10.0) - 0.5;
float d = length(p);
float dot = smoothstep(0.15, 0.1, d);
float3 col = dot * float3(1.0);
return float4(col, 1.0);
"""

let stripesCode = """
float stripe = step(0.5, fract(uv.x * 10.0 + iTime * 0.5));
float3 col = mix(float3(0.1), float3(0.9), stripe);
return float4(col, 1.0);
"""

let pulsingDotCode = """
float2 p = uv * 2.0 - 1.0;
float pulse = 0.3 + 0.1 * sin(iTime * 3.0);
float d = length(p);
float dot = smoothstep(pulse + 0.02, pulse, d);
float3 col = dot * float3(1.0);
return float4(col, 1.0);
"""
