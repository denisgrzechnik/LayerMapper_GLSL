//
//  NeonText.metal
//  LM_GLSL
//
//  Category: Neon
//

let neonTextCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05);
float d = abs(p.y - sin(p.x * 5.0 + iTime) * 0.2);
float line = smoothstep(0.03, 0.0, d);
float3 neon = float3(1.0, 0.2, 0.5);
col += line * neon;
col += exp(-d * 10.0) * neon * 0.5;
col += exp(-d * 30.0) * float3(1.0) * 0.3;
return float4(col, 1.0);
"""
