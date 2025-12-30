//
//  DataStream.metal
//  LM_GLSL
//
//  Category: Tech
//

let dataStreamCode = """
float2 p = uv;
float3 col = float3(0.02, 0.02, 0.05);
float lanes = 10.0;
float lane = floor(p.y * lanes);
float laneY = fract(p.y * lanes);
float speed = 0.5 + fract(sin(lane * 43.758) * 43758.5453) * 1.0;
float x = fract(p.x - iTime * speed);
float packet = step(0.8, fract(sin(lane * 12.9898 + floor(x * 10.0) * 43.758) * 43758.5453));
float vis = packet * step(0.2, laneY) * step(laneY, 0.8);
float3 laneCol = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + lane * 0.5);
col += vis * laneCol;
return float4(col, 1.0);
"""
