//
//  RainbowGradient.metal
//  LM_GLSL
//
//  Category: Basic
//

let rainbowGradientCode = """
float3 col = float3(
    0.5 + 0.5 * sin(iTime + uv.x * 3.0),
    0.5 + 0.5 * sin(iTime + uv.y * 3.0 + 2.0),
    0.5 + 0.5 * sin(iTime + 4.0)
);
return float4(col, 1.0);
"""
