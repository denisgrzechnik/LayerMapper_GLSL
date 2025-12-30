//
//  BeatGrid.metal
//  LM_GLSL
//
//  Category: AudioReactive
//

let beatGridCode = """
float2 p = fract(uv * 8.0);
float2 id = floor(uv * 8.0);
float beat = sin(iTime * 8.0 + id.x + id.y * 8.0) * 0.5 + 0.5;
float d = length(p - 0.5);
float circle = smoothstep(0.3 * beat + 0.1, 0.0, d);
float3 col = circle * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + id.x + id.y));
return float4(col, 1.0);
"""
