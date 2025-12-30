//
//  WoodGrain.metal
//  LM_GLSL
//
//  Category: Abstract
//

let woodGrainCode = """
float2 p = uv * 10.0;
float grain = sin(p.y * 2.0 + sin(p.x * 0.5 + iTime * 0.5) * 5.0);
grain += sin(p.y * 10.0) * 0.1;
float3 col = mix(float3(0.4, 0.2, 0.1), float3(0.6, 0.4, 0.2), grain * 0.5 + 0.5);
return float4(col, 1.0);
"""
