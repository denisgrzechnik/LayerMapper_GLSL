//
//  ConcentricCircles.metal
//  LM_GLSL
//
//  Category: Patterns
//

let concentricCirclesCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float v = sin(r * 30.0 - iTime * 5.0);
float3 col = float3(v * 0.5 + 0.5);
col *= 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + r * 5.0 + iTime);
return float4(col, 1.0);
"""
