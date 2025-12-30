//
//  Fire.metal
//  LM_GLSL
//
//  Category: Nature
//

let fireCode = """
float2 p = uv;
p.y = 1.0 - p.y;

float noise1 = fract(sin(dot(p * 10.0 + iTime, float2(12.9898, 78.233))) * 43758.5453);
float noise2 = fract(sin(dot(p * 20.0 + iTime * 1.5, float2(93.9898, 67.345))) * 43758.5453);
float noise3 = fract(sin(dot(p * 5.0 + iTime * 0.5, float2(45.233, 97.113))) * 43758.5453);

float fire = noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2;
fire *= 1.0 - p.y;
fire = pow(fire, 1.5);

float3 col = float3(fire * 2.0, fire * 0.7, fire * 0.2);
col = clamp(col, 0.0, 1.0);

return float4(col, 1.0);
"""
