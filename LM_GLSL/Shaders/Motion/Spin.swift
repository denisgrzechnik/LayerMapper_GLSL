//
//  Spin.metal
//  LM_GLSL
//
//  Category: Motion
//

let spinCode = """
float2 p = uv * 2.0 - 1.0;
float angle = iTime * 2.0;
float c = cos(angle); float s = sin(angle);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float r = length(p);
float a = atan2(p.y, p.x);
float spiral = sin(a * 5.0 + r * 10.0 - iTime * 5.0);
float3 col = (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + r * 3.0)) * spiral;
return float4(col, 1.0);
"""
