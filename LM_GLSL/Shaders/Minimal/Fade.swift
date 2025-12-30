//
//  Fade.metal
//  LM_GLSL
//
//  Category: Minimal
//

let fadeCode = """
float t = sin(iTime) * 0.5 + 0.5;
float3 c1 = float3(0.1, 0.1, 0.3);
float3 c2 = float3(0.9, 0.8, 0.6);
float3 col = mix(c1, c2, t);
return float4(col, 1.0);
"""
