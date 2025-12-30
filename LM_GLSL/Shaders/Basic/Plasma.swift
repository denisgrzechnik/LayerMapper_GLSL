//
//  Plasma.metal
//  LM_GLSL
//
//  Category: Basic
//

let plasmaCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);
float c = sin(r * 10.0 - iTime * 2.0) * 0.5 + 0.5;
float3 col = float3(
    0.5 + 0.5 * sin(c * 6.28 + 0.0),
    0.5 + 0.5 * sin(c * 6.28 + 2.0),
    0.5 + 0.5 * sin(c * 6.28 + 4.0)
);
return float4(col, 1.0);
"""
