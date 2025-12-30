//
//  AsciiArt.metal
//  LM_GLSL
//
//  Category: Retro
//

let asciiArtCode = """
float2 p = floor(uv * 30.0) / 30.0;
float v = sin(p.x * 10.0 + iTime) * cos(p.y * 10.0 + iTime * 0.7);
v = v * 0.5 + 0.5;
float3 col = float3(0.0, v, 0.0);
return float4(col, 1.0);
"""
