//
//  BinaryRain.metal
//  LM_GLSL
//
//  Category: Tech
//

let binaryRainCode = """
float2 p = uv;
float3 col = float3(0.0);
float columns = 30.0;
float colIdx = floor(p.x * columns);
float speed = 0.5 + fract(sin(colIdx * 43.758) * 43758.5453) * 0.5;
float offset = fract(sin(colIdx * 12.9898) * 43758.5453);
float y = fract(p.y + iTime * speed + offset);
float charIdx = floor(y * 20.0);
float bit = step(0.5, fract(sin(colIdx * 43.758 + charIdx * 12.9898) * 43758.5453));
float brightness = 1.0 - y;
float char_vis = step(0.1, fract(p.x * columns));
col += brightness * float3(0.0, 0.8, 0.3) * char_vis;
return float4(col, 1.0);
"""
