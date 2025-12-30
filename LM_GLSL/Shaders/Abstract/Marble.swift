//
//  Marble.metal
//  LM_GLSL
//
//  Category: Abstract
//

let marbleCode = """
float2 p = uv * 5.0;
float n = sin(p.x + sin(p.y * 2.0 + iTime) * 2.0);
n += sin(p.y * 3.0 + sin(p.x * 2.0 + iTime * 0.5)) * 0.5;
float3 col = mix(float3(0.9, 0.9, 0.9), float3(0.3, 0.3, 0.4), n * 0.5 + 0.5);
return float4(col, 1.0);
"""
