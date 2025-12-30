//
//  Waveform.metal
//  LM_GLSL
//
//  Category: AudioReactive
//

let waveformCode = """
float2 p = uv * 2.0 - 1.0;
float wave = sin(p.x * 10.0 + iTime * 5.0) * 0.3;
wave += sin(p.x * 20.0 - iTime * 3.0) * 0.1;
wave += sin(p.x * 5.0 + iTime * 2.0) * 0.2;
float d = abs(p.y - wave);
float3 col = float3(0.2, 0.8, 0.4) * smoothstep(0.05, 0.0, d);
col += float3(0.1, 0.4, 0.2) * smoothstep(0.15, 0.05, d);
return float4(col, 1.0);
"""
