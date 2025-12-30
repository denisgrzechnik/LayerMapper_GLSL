//
//  HexagonGrid.metal
//  LM_GLSL
//
//  Category: Geometric
//

let hexagonGridCode = """
float2 p = uv * 10.0;

float2 r = float2(1.0, 1.73205);
float2 h = r * 0.5;

float2 a = fmod(p, r) - h;
float2 b = fmod(p - h, r) - h;

float2 gv = length(a) < length(b) ? a : b;
float d = length(gv);

float hex = smoothstep(0.5, 0.45, d);
float edge = smoothstep(0.48, 0.5, d) - smoothstep(0.5, 0.52, d);

float3 col = float3(0.1, 0.2, 0.3) * hex;
col += float3(0.0, 0.8, 0.6) * edge;

float pulse = sin(d * 5.0 - iTime * 3.0) * 0.5 + 0.5;
col += float3(0.2, 0.5, 0.8) * pulse * hex * 0.5;

return float4(col, 1.0);
"""
