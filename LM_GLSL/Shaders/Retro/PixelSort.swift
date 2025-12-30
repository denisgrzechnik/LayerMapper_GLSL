//
//  PixelSort.metal
//  LM_GLSL
//
//  Category: Retro
//

let pixelSortCode = """
float2 p = uv;
float2 id = floor(p * 20.0);
float r = fract(sin(id.y * 123.456 + floor(iTime * 2.0)) * 43758.5);
if (r > 0.7) p.x = fract(p.x * 20.0 + iTime * 2.0) / 20.0 + id.x / 20.0;
float3 col = 0.5 + 0.5 * sin(float3(1.0, 2.0, 3.0) + p.x * 10.0 + p.y * 5.0 + iTime);
return float4(col, 1.0);
"""
