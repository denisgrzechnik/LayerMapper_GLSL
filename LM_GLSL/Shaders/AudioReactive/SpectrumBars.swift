//
//  SpectrumBars.metal
//  LM_GLSL
//
//  Category: AudioReactive
//

let spectrumBarsCode = """
float2 p = uv;
float bars = 16.0;
float barIdx = floor(p.x * bars);
float barHeight = 0.3 + 0.7 * fract(sin(barIdx * 43.758 + iTime) * 43758.5453);
float bar = step(p.y, barHeight) * step(0.1, fract(p.x * bars));
float3 col = bar * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + barIdx * 0.5));
return float4(col, 1.0);
"""
