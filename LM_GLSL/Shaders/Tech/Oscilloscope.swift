//
//  Oscilloscope.metal
//  LM_GLSL
//
//  Category: Tech
//

let oscilloscopeCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05, 0.1, 0.05);
float gridX = smoothstep(0.02, 0.0, abs(fract(uv.x * 10.0) - 0.5) - 0.48);
float gridY = smoothstep(0.02, 0.0, abs(fract(uv.y * 10.0) - 0.5) - 0.48);
col += (gridX + gridY) * 0.05 * float3(0.0, 0.5, 0.0);
float wave = sin(p.x * 10.0 + iTime * 5.0) * 0.3;
wave += sin(p.x * 20.0 - iTime * 3.0) * 0.15;
float d = abs(p.y - wave);
col += smoothstep(0.03, 0.0, d) * float3(0.0, 1.0, 0.3);
col += exp(-d * 20.0) * float3(0.0, 0.5, 0.15);
return float4(col, 1.0);
"""
