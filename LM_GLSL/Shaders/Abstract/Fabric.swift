//
//  Fabric.metal
//  LM_GLSL
//
//  Category: Abstract
//

let fabricCode = """
float2 p = uv * 20.0;
float weave = sin(p.x) * sin(p.y);
weave += sin(p.x * 0.5 + iTime) * sin(p.y * 0.5) * 0.5;
float3 col = float3(0.6, 0.3, 0.2) * (weave * 0.3 + 0.7);
return float4(col, 1.0);
"""
