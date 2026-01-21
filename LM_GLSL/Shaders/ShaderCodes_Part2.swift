//
//  ShaderCodes_Part2.swift
//  LM_GLSL
//
//  Shader codes - Part 2: Retro, Psychedelic, Abstract
//

import Foundation

// MARK: - Retro Category

let matrixRainCode = """
float2 p = uv;
p.y = mod(p.y - iTime * 0.5, 1.0);
float col = step(0.9, fract(sin(floor(p.x * 20.0) * 43.758 + floor(p.y * 30.0)) * 43758.5453));
col *= step(fract(sin(floor(p.x * 20.0) * 12.345) * 43758.5453), 0.5);
float3 color = float3(0.0, col, 0.0);
color += float3(0.0, 0.1, 0.0) * (1.0 - uv.y);
return float4(color, 1.0);
"""

let crtTvCode = """
float2 p = uv;
float scanline = sin(p.y * 400.0) * 0.1;
float vignette = 1.0 - length((p - 0.5) * 1.5);
float3 col = 0.5 + 0.5 * cos(iTime + p.xyx * 5.0 + float3(0.0, 2.0, 4.0));
col *= 0.9 + scanline;
col *= vignette;
float2 curve = (p - 0.5) * 2.0;
float barrel = 1.0 + 0.1 * dot(curve, curve);
col *= smoothstep(1.0, 0.9, max(abs(curve.x), abs(curve.y)) * barrel);
return float4(col, 1.0);
"""

let glitchCode = """
float2 p = uv;
float glitch = step(0.95, fract(sin(floor(iTime * 20.0) * 43.758) * 43758.5453));
float offset = glitch * sin(p.y * 50.0 + iTime * 100.0) * 0.05;
p.x += offset;
float3 col = float3(0.0);
col.r = 0.5 + 0.5 * sin(p.x * 10.0 + iTime);
col.g = 0.5 + 0.5 * sin((p.x + 0.01) * 10.0 + iTime);
col.b = 0.5 + 0.5 * sin((p.x - 0.01) * 10.0 + iTime);
col += glitch * float3(fract(sin(p.y * 1000.0) * 43758.5453)) * 0.3;
return float4(col, 1.0);
"""

let synthwaveGridCode = """
float2 p = uv;
p.y = 1.0 - p.y;
float horizon = 0.4;
float3 col = float3(0.0);
if (p.y < horizon) {
    col = mix(float3(0.0, 0.0, 0.2), float3(0.5, 0.0, 0.5), p.y / horizon);
    float sun = smoothstep(0.15, 0.0, length(float2(p.x - 0.5, (p.y - horizon) * 2.0)));
    col += sun * float3(1.0, 0.3, 0.5);
} else {
    float gy = (p.y - horizon) / (1.0 - horizon);
    float perspective = 1.0 / (gy + 0.01);
    float gridX = abs(fract((p.x - 0.5) * perspective * 2.0 + iTime) - 0.5);
    float gridY = abs(fract(gy * 10.0 - iTime * 2.0) - 0.5);
    float grid = min(gridX, gridY);
    col = smoothstep(0.05, 0.0, grid) * float3(1.0, 0.0, 1.0);
    col *= gy;
}
return float4(col, 1.0);
"""

let vhsDistortionCode = """
float2 p = uv;
float noise = fract(sin(dot(floor(p * 100.0 + iTime * 10.0), float2(12.9898, 78.233))) * 43758.5453);
p.x += sin(p.y * 20.0 + iTime * 5.0) * 0.01;
p.y += noise * 0.005;
float3 col = float3(0.0);
col.r = 0.5 + 0.5 * sin(p.x * 5.0 + iTime);
col.g = 0.5 + 0.5 * sin((p.x + 0.005) * 5.0 + iTime);
col.b = 0.5 + 0.5 * sin((p.x - 0.005) * 5.0 + iTime);
float scanline = sin(p.y * 200.0 + iTime * 50.0) * 0.1 + 0.9;
col *= scanline;
col += noise * 0.1;
return float4(col, 1.0);
"""

let scanlinesCode = """
float2 p = uv;
float3 col = 0.5 + 0.5 * cos(iTime + p.xyx * 3.0 + float3(0.0, 2.0, 4.0));
float scanline = sin(p.y * 300.0) * 0.5 + 0.5;
col *= 0.8 + 0.2 * scanline;
col *= 0.9 + 0.1 * sin(p.y * 600.0 + iTime * 10.0);
return float4(col, 1.0);
"""

let pixelSortCode = """
float2 p = uv;
float threshold = sin(iTime) * 0.3 + 0.5;
float y = floor(p.y * 50.0) / 50.0;
float sort = step(threshold, fract(sin(y * 43.758) * 43758.5453));
if (sort > 0.5) p.x = fract(p.x + iTime * 0.5);
float3 col = 0.5 + 0.5 * cos(p.x * 10.0 + float3(0.0, 2.0, 4.0));
col *= 0.5 + 0.5 * sin(p.y * 50.0);
return float4(col, 1.0);
"""

let asciiArtCode = """
float2 p = uv;
float2 grid = floor(p * 30.0);
float2 f = fract(p * 30.0);
float h = fract(sin(dot(grid, float2(12.9898, 78.233)) + iTime * 0.5) * 43758.5453);
float charVal = step(0.3, f.x) * step(f.x, 0.7) * step(0.2, f.y) * step(f.y, 0.8);
charVal *= step(0.5, h);
float3 col = float3(0.0, char, 0.0);
return float4(col, 1.0);
"""

let commodore64Code = """
float2 p = floor(uv * 40.0) / 40.0;
float3 c64colors[5] = {
    float3(0.0, 0.0, 0.0),
    float3(0.0, 0.0, 0.67),
    float3(0.67, 0.0, 0.0),
    float3(0.0, 0.67, 0.0),
    float3(0.67, 0.67, 0.67)
};
float h = fract(sin(dot(p + iTime * 0.1, float2(12.9898, 78.233))) * 43758.5453);
int idx = int(h * 5.0);
float3 col = c64colors[idx % 5];
return float4(col, 1.0);
"""

// MARK: - Psychedelic Category

let liquidMetalCode = """
float2 p = uv * 4.0 - 2.0;
float3 col = float3(0.0);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    p = abs(p) / dot(p, p) - 0.8;
    p += float2(sin(iTime * 0.3 + fi), cos(iTime * 0.2 + fi)) * 0.1;
    col += 0.5 + 0.5 * cos(length(p) * 3.0 + iTime + float3(0.0, 2.0, 4.0) + fi);
}
col /= 8.0;
return float4(col, 1.0);
"""

let neonPulseCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float pulse = sin(r * 10.0 - iTime * 3.0) * 0.5 + 0.5;
pulse = pow(pulse, 5.0);
float3 col = float3(1.0, 0.0, 0.5) * pulse;
col += float3(0.0, 0.5, 1.0) * (1.0 - pulse) * smoothstep(1.0, 0.0, r);
col *= 1.5;
return float4(col, 1.0);
"""

let fractalWarpCode = """
float2 p = uv * 4.0 - 2.0;
float3 col = float3(0.0);
for (int i = 0; i < 10; i++) {
    p = abs(p) - 1.0;
    p *= 1.5;
    float a = iTime * 0.1 + float(i) * 0.5;
    float c = cos(a); float s = sin(a);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    col += 0.1 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + length(p)));
}
return float4(col, 1.0);
"""

let colorExplosionCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float explosion = pow(max(0.0, 1.0 - r), 2.0);
explosion *= 0.5 + 0.5 * sin(a * 10.0 + r * 20.0 - iTime * 5.0);
float3 col = explosion * (0.5 + 0.5 * cos(a + iTime + float3(0.0, 2.0, 4.0)));
col += pow(max(0.0, 1.0 - r * 2.0), 4.0) * float3(1.0, 0.8, 0.5);
return float4(col, 1.0);
"""

let acidTripCode = """
float2 p = uv * 2.0 - 1.0;
float t = iTime * 0.5;
for (int i = 0; i < 5; i++) {
    p = abs(p) - 0.5;
    p *= 1.2;
    p = float2(p.x * cos(t) - p.y * sin(t), p.x * sin(t) + p.y * cos(t));
}
float3 col = 0.5 + 0.5 * cos(length(p) + iTime + float3(0.0, 2.0, 4.0));
col = pow(col, float3(0.5));
return float4(col, 1.0);
"""

let mushroomVisionCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float ripple = sin(r * 15.0 - iTime * 3.0 + sin(a * 5.0 + iTime) * 2.0);
float3 col = 0.5 + 0.5 * cos(ripple * 2.0 + float3(0.0, 2.0, 4.0) + a + iTime);
col *= 1.0 - r * 0.5;
col = pow(col, float3(0.8));
return float4(col, 1.0);
"""

let morphingShapesCode = """
float2 p = uv * 2.0 - 1.0;
float t = iTime * 0.5;
float morph = sin(t) * 0.5 + 0.5;
float circle = length(p);
float square = max(abs(p.x), abs(p.y));
float shape = mix(circle, square, morph);
float d = smoothstep(0.5, 0.48, shape);
float3 col = d * (0.5 + 0.5 * cos(iTime + float3(0.0, 2.0, 4.0)));
col += (1.0 - d) * 0.1;
return float4(col, 1.0);
"""

let colorFlowCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float wave = sin(p.x * 5.0 + p.y * 3.0 + iTime + fi) * 0.5 + 0.5;
    col += wave * 0.2 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
col = pow(col, float3(0.7));
return float4(col, 1.0);
"""

let dreamWeaverCode = """
float2 p = uv * 3.0;
float3 col = float3(0.0);
for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float2 offset = float2(sin(iTime * 0.3 + fi), cos(iTime * 0.4 + fi));
    float wave = sin(length(p + offset) * 5.0 - iTime * 2.0);
    col += (0.5 + 0.5 * wave) * 0.2 * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""

// MARK: - Abstract Category

let metaballsCode = """
float2 p = uv * 2.0 - 1.0;
float v = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 center = float2(sin(iTime + fi * 2.0), cos(iTime * 0.7 + fi * 1.5)) * 0.5;
    v += 0.1 / length(p - center);
}
float3 col = smoothstep(0.8, 2.0, v) * (0.5 + 0.5 * cos(v + iTime + float3(0.0, 2.0, 4.0)));
return float4(col, 1.0);
"""

let sineWavesCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float wave = sin(p.x * 10.0 + iTime + fi) * 0.1 + 0.5 + fi * 0.1;
    float line = smoothstep(0.02, 0.0, abs(p.y - wave));
    col += line * (0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""

let moirePatternCode = """
float2 p = uv * 2.0 - 1.0;
float2 p2 = p + float2(sin(iTime) * 0.1, cos(iTime) * 0.1);
float r1 = length(p);
float r2 = length(p2);
float v = sin(r1 * 50.0) * sin(r2 * 50.0);
float3 col = 0.5 + 0.5 * float3(v);
col *= 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + iTime);
return float4(col, 1.0);
"""

let inkBlotCode = """
float2 p = uv * 2.0 - 1.0;
p.x = abs(p.x);
float n = 0.0;
float2 q = p * 3.0;
for (int i = 0; i < 5; i++) {
    n += sin(q.x * float(i + 1) + iTime) * sin(q.y * float(i + 1));
}
n = n * 0.2 + 0.5;
float blob = smoothstep(0.3, 0.5, n * (1.0 - length(p)));
float3 col = blob * float3(0.1, 0.1, 0.2);
return float4(col, 1.0);
"""

let rorschachCode = """
float2 p = uv * 2.0 - 1.0;
p.x = abs(p.x);
float n = fract(sin(dot(floor(p * 10.0 + iTime * 0.5), float2(12.9898, 78.233))) * 43758.5453);
float blob = step(0.4, n) * step(length(p), 0.8);
float3 col = float3(blob * 0.3);
return float4(col, 1.0);
"""

let fabricCode = """
float2 p = uv * 20.0;
float weave = sin(p.x) * sin(p.y);
weave += sin(p.x + iTime) * sin(p.y + iTime) * 0.5;
float3 col = 0.5 + 0.5 * cos(weave + float3(0.0, 2.0, 4.0));
col *= 0.8 + 0.2 * sin(p.x * 2.0) * sin(p.y * 2.0);
return float4(col, 1.0);
"""

let marbleCode = """
float2 p = uv * 5.0;
float n = 0.0;
float amp = 1.0;
for (int i = 0; i < 5; i++) {
    n += amp * sin(p.x * float(i + 1) + p.y * 0.5 + iTime);
    amp *= 0.5;
}
float vein = abs(sin(p.x * 2.0 + n));
float3 col = mix(float3(0.9, 0.9, 0.85), float3(0.3, 0.3, 0.35), vein);
return float4(col, 1.0);
"""

let woodGrainCode = """
float2 p = uv * 10.0;
float r = length(p - float2(5.0, 5.0));
float n = sin(r * 5.0 + sin(p.y * 2.0 + iTime) * 2.0);
float3 col = mix(float3(0.4, 0.25, 0.1), float3(0.6, 0.4, 0.2), 0.5 + 0.5 * n);
col *= 0.9 + 0.1 * fract(sin(p.x * 100.0) * 43758.5453);
return float4(col, 1.0);
"""
