//
//  Noise.metal
//  LM_GLSL
//
//  Category: Basic
//

let noiseCode = """
float n = fract(sin(dot(uv, float2(12.9898, 78.233)) + iTime) * 43758.5453);
return float4(float3(n), 1.0);
"""
