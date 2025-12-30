//
//  Commodore64.metal
//  LM_GLSL
//
//  Category: Retro
//

let commodore64Code = """
float2 p = floor(uv * 40.0) / 40.0;
float v = sin(p.x * 8.0 + iTime * 2.0) * cos(p.y * 8.0 + iTime);
float3 col;
if (v > 0.3) col = float3(0.4, 0.4, 0.9);
else if (v > 0.0) col = float3(0.5, 0.3, 0.8);
else if (v > -0.3) col = float3(0.3, 0.5, 0.8);
else col = float3(0.2, 0.2, 0.6);
return float4(col, 1.0);
"""
