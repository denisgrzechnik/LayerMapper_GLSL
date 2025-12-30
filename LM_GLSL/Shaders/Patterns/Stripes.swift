//
//  Stripes.metal
//  LM_GLSL
//
//  Category: Patterns
//

let stripesCode = """
float2 p = uv;
float angle = iTime * 0.5;
float2 r = float2(cos(angle), sin(angle));
float v = dot(p, r) * 20.0;
float stripe = sin(v) * 0.5 + 0.5;
float3 col = mix(float3(0.2, 0.3, 0.8), float3(0.9, 0.8, 0.2), stripe);
return float4(col, 1.0);
"""
