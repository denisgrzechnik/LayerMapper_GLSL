//
//  Supernova.metal
//  LM_GLSL
//
//  Category: Cosmic
//

let supernovaCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float t = iTime * 2.0;
float burst = exp(-r * 2.0) * (0.5 + 0.5 * sin(a * 8.0 + t));
float3 col = float3(1.0, 0.6, 0.2) * burst;
col += float3(1.0, 0.9, 0.5) * exp(-r * 5.0);
col += float3(0.5, 0.2, 0.8) * smoothstep(0.5, 0.0, r) * sin(r * 20.0 - t * 5.0);
return float4(col, 1.0);
"""
