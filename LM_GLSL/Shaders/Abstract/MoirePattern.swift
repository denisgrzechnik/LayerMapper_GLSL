//
//  MoirePattern.metal
//  LM_GLSL
//
//  Category: Abstract
//

let moirePatternCode = """
float2 p = uv * 2.0 - 1.0;

float2 center1 = float2(sin(iTime * 0.5), cos(iTime * 0.3)) * 0.3;
float2 center2 = float2(sin(iTime * 0.7 + 2.0), cos(iTime * 0.4 + 1.0)) * 0.3;

float d1 = length(p - center1);
float d2 = length(p - center2);

float pattern1 = sin(d1 * 40.0) * 0.5 + 0.5;
float pattern2 = sin(d2 * 40.0) * 0.5 + 0.5;

float moire = pattern1 * pattern2;

float3 col = float3(moire);
col = mix(float3(0.0), float3(1.0), moire);

return float4(col, 1.0);
"""
