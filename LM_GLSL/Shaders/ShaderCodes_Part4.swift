//
//  ShaderCodes_Part4.swift
//  LM_GLSL
//
//  Shader codes - Part 4: Patterns, Fractals, AudioReactive, Gradient
//

import Foundation

// MARK: - Patterns Category

let chevronCode = """
float2 p = uv * 10.0;
float y = p.y + abs(fract(p.x) - 0.5) * 2.0;
float chevron = step(0.5, fract(y + iTime));
float3 col = mix(float3(0.2, 0.2, 0.3), float3(0.8, 0.6, 0.2), chevron);
return float4(col, 1.0);
"""

let houndstoothCode = """
float2 p = floor(uv * 10.0);
float2 f = fract(uv * 10.0);
float check = mod(p.x + p.y, 2.0);
float tooth = 0.0;
if (check > 0.5) {
    tooth = step(f.x, f.y);
} else {
    tooth = step(f.y, f.x);
}
tooth = mix(tooth, 1.0 - tooth, step(0.5, fract((p.x + p.y) * 0.5)));
float3 col = mix(float3(0.1), float3(0.9), tooth);
return float4(col, 1.0);
"""

let herringboneCode = """
float2 p = uv * 10.0;
float2 i = floor(p);
float2 f = fract(p);
float row = mod(i.y, 2.0);
float brick = step(0.5, fract((p.x + row * 0.5) * 0.5));
float line = smoothstep(0.02, 0.0, abs(f.y - 0.5));
line += smoothstep(0.02, 0.0, abs(fract((p.x + row * 0.5) * 0.5)));
float3 col = mix(float3(0.6, 0.4, 0.3), float3(0.4, 0.25, 0.15), brick);
col += line * 0.1;
return float4(col, 1.0);
"""

let islamicPatternCode = """
float2 p = uv * 6.0;
float2 i = floor(p);
float2 f = fract(p) - 0.5;
float pattern = 0.0;
for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
        float2 offset = float2(float(x), float(y));
        float d = length(f - offset);
        pattern += smoothstep(0.4, 0.38, d);
    }
}
float star = 1.0 - smoothstep(0.0, 0.02, abs(length(f) - 0.3));
star *= step(0.2, abs(sin(atan2(f.y, f.x) * 8.0)));
pattern += star;
float3 col = mix(float3(0.1, 0.3, 0.5), float3(0.9, 0.8, 0.5), clamp(pattern, 0.0, 1.0));
return float4(col, 1.0);
"""

let celticKnotCode = """
float2 p = uv * 4.0;
float2 i = floor(p);
float2 f = fract(p) - 0.5;
float knot = 0.0;
float r = length(f);
float a = atan2(f.y, f.x);
float weave = sin(a * 4.0 + i.x + i.y + iTime);
float ring = smoothstep(0.35, 0.33, r) * smoothstep(0.25, 0.27, r);
ring *= 0.5 + 0.5 * sign(weave);
float3 col = ring * float3(0.8, 0.6, 0.2);
col += (1.0 - ring) * float3(0.1, 0.2, 0.1);
return float4(col, 1.0);
"""

// MARK: - Fractals Category

let mandelbrotCode = """
float2 c = (uv - 0.5) * 3.0;
c.x -= 0.5;
c *= 1.0 + sin(iTime * 0.1) * 0.5;
float2 z = float2(0.0);
int iter = 0;
for (int i = 0; i < 100; i++) {
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > 4.0) break;
    iter = i;
}
float t = float(iter) / 100.0;
float3 col = 0.5 + 0.5 * cos(t * 6.28 + float3(0.0, 2.0, 4.0) + iTime);
col *= step(0.01, t);
return float4(col, 1.0);
"""

let juliaSetCode = """
float2 z = (uv - 0.5) * 3.0;
float2 c = float2(sin(iTime * 0.3) * 0.4, cos(iTime * 0.2) * 0.4);
int iter = 0;
for (int i = 0; i < 100; i++) {
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > 4.0) break;
    iter = i;
}
float t = float(iter) / 100.0;
float3 col = 0.5 + 0.5 * cos(t * 6.28 + float3(0.0, 2.0, 4.0));
col *= step(0.01, t);
return float4(col, 1.0);
"""

let sierpinskiCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 10; i++) {
    p *= 2.0;
    float2 m = mod(p, 2.0);
    if (m.x > 1.0 && m.y > 1.0) {
        col = 0.5 + 0.5 * cos(float(i) + iTime + float3(0.0, 2.0, 4.0));
        break;
    }
    p = fract(p) * 2.0;
}
return float4(col, 1.0);
"""

let burningShipCode = """
float2 c = (uv - float2(0.4, 0.5)) * 3.0;
float2 z = float2(0.0);
int iter = 0;
for (int i = 0; i < 100; i++) {
    z = abs(z);
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > 4.0) break;
    iter = i;
}
float t = float(iter) / 100.0;
float3 col = 0.5 + 0.5 * cos(t * 6.28 + float3(0.0, 1.0, 2.0) + iTime * 0.5);
col *= step(0.01, t);
return float4(col, 1.0);
"""

let fractalTreeCode = """
float2 p = uv * 2.0 - 1.0;
p.y += 0.5;
float tree = 0.0;
float2 dir = float2(0.0, 0.15);
float2 pos = float2(0.0, -0.5);
float scale = 1.0;
for (int i = 0; i < 8; i++) {
    float branch = smoothstep(0.02 * scale, 0.0, abs(p.x - pos.x)) * 
                   step(pos.y, p.y) * step(p.y, pos.y + dir.y);
    tree += branch;
    pos.y += dir.y;
    dir *= 0.7;
    float angle = 0.5 + sin(iTime + float(i)) * 0.2;
    float side = sign(sin(float(i) * 2.3));
    pos.x += side * dir.y * angle;
    scale *= 0.8;
}
float3 col = tree * float3(0.4, 0.25, 0.1);
col += (1.0 - tree) * float3(0.1, 0.15, 0.2);
return float4(col, 1.0);
"""

// MARK: - AudioReactive Category (simulated)

let audioWaveformCode = """
float2 p = uv;
float wave = sin(p.x * 20.0 + iTime * 3.0) * 0.3;
wave += sin(p.x * 35.0 - iTime * 2.0) * 0.15;
wave += sin(p.x * 50.0 + iTime * 5.0) * 0.1;
wave = wave * 0.5 + 0.5;
float line = smoothstep(0.02, 0.0, abs(p.y - wave));
float3 col = line * float3(0.0, 1.0, 0.5);
col += smoothstep(wave, wave - 0.3, p.y) * float3(0.0, 0.3, 0.2) * 0.5;
return float4(col, 1.0);
"""

let spectrumBarsCode = """
float2 p = uv;
float3 col = float3(0.05);
float barWidth = 0.03;
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float x = fi / 20.0 + 0.025;
    float height = 0.3 + 0.5 * (0.5 + 0.5 * sin(iTime * 2.0 + fi * 0.5));
    height *= 0.5 + 0.5 * sin(fi * 0.3 + iTime);
    float bar = step(x - barWidth * 0.5, p.x) * step(p.x, x + barWidth * 0.5);
    bar *= step(0.0, p.y) * step(p.y, height);
    float3 barCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi * 0.3);
    col += bar * barCol;
}
return float4(col, 1.0);
"""

let beatPulseCode = """
float2 p = uv * 2.0 - 1.0;
float beat = pow(sin(iTime * 6.28) * 0.5 + 0.5, 4.0);
float r = length(p);
float pulse = smoothstep(0.5 + beat * 0.2, 0.48, r);
float ring = smoothstep(0.02, 0.0, abs(r - 0.5 - beat * 0.2));
float3 col = pulse * float3(0.2, 0.0, 0.3);
col += ring * float3(1.0, 0.0, 0.5);
col += pow(max(0.0, 1.0 - r * 2.0), 2.0) * beat * float3(1.0, 0.5, 0.8);
return float4(col, 1.0);
"""

let soundCirclesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.02);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float r = 0.2 + fi * 0.15;
    float beat = 0.5 + 0.5 * sin(iTime * 3.0 + fi * 1.5);
    r *= 0.8 + beat * 0.4;
    float ring = smoothstep(0.02, 0.0, abs(length(p) - r));
    float3 ringCol = 0.5 + 0.5 * cos(float3(0.0, 2.0, 4.0) + fi);
    col += ring * ringCol * beat;
}
return float4(col, 1.0);
"""

let frequencyMeshCode = """
float2 p = uv * 10.0;
float3 col = float3(0.02);
float freq = sin(iTime * 2.0) * 0.5 + 0.5;
float gridX = smoothstep(0.05, 0.0, abs(fract(p.x) - 0.5));
float gridY = smoothstep(0.05, 0.0, abs(fract(p.y) - 0.5));
float distort = sin(p.x * 0.5 + iTime) * sin(p.y * 0.5 + iTime) * freq;
gridX *= 1.0 + distort;
gridY *= 1.0 + distort;
col += (gridX + gridY) * 0.5 * float3(0.0, 0.8, 1.0);
col += gridX * gridY * float3(1.0, 0.0, 0.5);
return float4(col, 1.0);
"""

// MARK: - Gradient Category

let linearGradientCode = """
float2 p = uv;
float angle = iTime * 0.2;
float grad = p.x * cos(angle) + p.y * sin(angle);
grad = grad * 0.5 + 0.5;
float3 col1 = float3(1.0, 0.3, 0.5);
float3 col2 = float3(0.3, 0.5, 1.0);
float3 col = mix(col1, col2, grad);
return float4(col, 1.0);
"""

let radialGradientCode = """
float2 p = uv * 2.0 - 1.0;
p.x += sin(iTime) * 0.3;
p.y += cos(iTime) * 0.3;
float r = length(p);
float3 col1 = float3(1.0, 0.8, 0.3);
float3 col2 = float3(0.8, 0.2, 0.5);
float3 col3 = float3(0.2, 0.1, 0.5);
float3 col = col1;
col = mix(col, col2, smoothstep(0.0, 0.5, r));
col = mix(col, col3, smoothstep(0.5, 1.0, r));
return float4(col, 1.0);
"""

let conicGradientCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x) / 6.28 + 0.5;
a = fract(a + iTime * 0.1);
float3 col = 0.5 + 0.5 * cos(a * 6.28 + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""

let diamondGradientCode = """
float2 p = abs(uv * 2.0 - 1.0);
float d = max(p.x, p.y);
d = fract(d - iTime * 0.2);
float3 col = 0.5 + 0.5 * cos(d * 6.28 * 2.0 + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""

let spiralGradientCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = fract(r * 3.0 - a / 6.28 + iTime * 0.3);
float3 col = 0.5 + 0.5 * cos(spiral * 6.28 + float3(0.0, 2.0, 4.0));
return float4(col, 1.0);
"""
