//
//  GradientSweep.metal
//  LM_GLSL
//
//  Category: Minimal
//

let gradientSweepCode = """
float t = fract(uv.x + iTime * 0.2);
float3 col = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + t * 6.28318);
return float4(col, 1.0);
"""
