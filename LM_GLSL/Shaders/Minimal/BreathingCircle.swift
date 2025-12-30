//
//  BreathingCircle.metal
//  LM_GLSL
//
//  Category: Minimal
//

let breathingCircleCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float size = 0.3 + 0.2 * sin(iTime * 1.5);
float circle = smoothstep(size + 0.02, size, r);
float3 col = circle * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + iTime));
return float4(col, 1.0);
"""
