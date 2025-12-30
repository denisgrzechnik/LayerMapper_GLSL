//
//  DotsGrid.metal
//  LM_GLSL
//
//  Category: Patterns
//

let dotsGridCode = """
float2 p = fract(uv * 10.0) - 0.5;
float d = length(p);
float pulse = 0.2 + 0.1 * sin(iTime * 3.0 + uv.x * 10.0 + uv.y * 10.0);
float dot = smoothstep(pulse, pulse - 0.05, d);
float3 col = float3(dot) * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + iTime));
return float4(col, 1.0);
"""
