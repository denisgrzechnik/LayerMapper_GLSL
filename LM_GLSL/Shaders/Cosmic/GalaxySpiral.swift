//
//  GalaxySpiral.metal
//  LM_GLSL
//
//  Category: Cosmic
//

let galaxySpiralCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = sin(a * 3.0 - r * 10.0 + iTime * 2.0);
float3 col = float3(0.1, 0.1, 0.3);
col += float3(0.8, 0.6, 1.0) * smoothstep(0.0, 0.5, spiral) * (1.0 - r);
col += float3(1.0, 0.9, 0.7) * exp(-r * 5.0);
return float4(col, 1.0);
"""
