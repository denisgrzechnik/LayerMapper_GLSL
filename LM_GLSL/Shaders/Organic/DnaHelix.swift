//
//  DnaHelix.metal
//  LM_GLSL
//
//  Category: Organic
//

let dnaHelixCode = """
float2 p = uv * 2.0 - 1.0;
float y = p.y * 10.0 + iTime * 3.0;
float x1 = sin(y) * 0.3;
float x2 = -sin(y) * 0.3;
float d1 = abs(p.x - x1);
float d2 = abs(p.x - x2);
float3 col = float3(0.0);
col += float3(0.2, 0.5, 1.0) * smoothstep(0.05, 0.0, d1);
col += float3(1.0, 0.3, 0.5) * smoothstep(0.05, 0.0, d2);
float bar = step(0.5, fract(y * 0.5)) * smoothstep(0.3, 0.0, min(d1, d2));
col += float3(0.5) * bar;
return float4(col, 1.0);
"""
