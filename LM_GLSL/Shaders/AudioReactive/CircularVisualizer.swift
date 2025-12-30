//
//  CircularVisualizer.metal
//  LM_GLSL
//
//  Category: AudioReactive
//

let circularVisualizerCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);
float bars = 32.0;
float barIdx = floor((a + 3.14159) / 6.28318 * bars);
float barHeight = 0.3 + 0.5 * fract(sin(barIdx * 12.9898 + iTime * 3.0) * 43758.5453);
float bar = step(r, barHeight) * step(0.2, r);
float3 col = bar * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + a * 2.0 + iTime));
return float4(col, 1.0);
"""
