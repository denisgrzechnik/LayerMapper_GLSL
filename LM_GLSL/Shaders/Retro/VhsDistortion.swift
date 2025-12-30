//
//  VhsDistortion.metal
//  LM_GLSL
//
//  Category: Retro
//

let vhsDistortionCode = """
float2 p = uv;
float t = iTime;
p.x += sin(p.y * 50.0 + t * 10.0) * 0.01;
p.y += sin(t * 5.0) * 0.005 * step(0.98, fract(t * 0.5));
float3 col;
col.r = sin(p.x * 10.0 + t) * 0.5 + 0.5;
col.g = sin(p.x * 10.0 + t + 0.02) * 0.5 + 0.5;
col.b = sin(p.x * 10.0 + t + 0.04) * 0.5 + 0.5;
col *= 0.8 + 0.2 * sin(p.y * 300.0);
col *= 0.95 + 0.05 * fract(sin(floor(p.y * 100.0) + t * 100.0) * 43758.5);
return float4(col, 1.0);
"""
