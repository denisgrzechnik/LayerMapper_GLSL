//
//  MushroomVision.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let mushroomVisionCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
a += sin(r * 10.0 - iTime * 2.0) * 0.5;
r += sin(a * 5.0 + iTime) * 0.1;
float3 col = 0.5 + 0.5 * sin(float3(0.5, 0.3, 0.8) + r * 5.0 + a * 2.0 + iTime);
return float4(col, 1.0);
"""
