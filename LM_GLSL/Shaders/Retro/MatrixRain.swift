//
//  MatrixRain.metal
//  LM_GLSL
//
//  Category: Retro
//

let matrixRainCode = """
float2 p = uv;
p.x = floor(p.x * 30.0) / 30.0;

float drop = fract(p.x * 123.456 + iTime * (0.5 + fract(p.x * 7.89) * 0.5));
float brightness = 1.0 - fract(p.y + drop);
brightness = pow(brightness, 8.0);

float flicker = fract(sin(floor(iTime * 10.0) + p.x * 100.0) * 43758.5453);
brightness *= 0.7 + flicker * 0.3;

float3 col = float3(0.0, brightness, brightness * 0.3);

return float4(col, 1.0);
"""
