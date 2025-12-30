//
//  InkBlot.metal
//  LM_GLSL
//
//  Category: Abstract
//

let inkBlotCode = """
float2 p = uv * 2.0 - 1.0;
p.x = abs(p.x);
float n = sin(p.x * 10.0 + p.y * 10.0 + iTime) * 0.5;
n += sin(p.x * 5.0 - p.y * 8.0 + iTime * 0.7) * 0.3;
float blob = smoothstep(0.3 + n * 0.2, 0.2 + n * 0.2, length(p));
float3 col = float3(0.1, 0.1, 0.2) * blob;
return float4(col, 1.0);
"""
