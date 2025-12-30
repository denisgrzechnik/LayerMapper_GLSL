//
//  MovingLine.metal
//  LM_GLSL
//
//  Category: Minimal
//

let movingLineCode = """
float linePos = fract(iTime * 0.3);
float d = abs(uv.x - linePos);
float line = smoothstep(0.02, 0.0, d);
float3 col = line * float3(1.0, 1.0, 1.0);
col += smoothstep(0.1, 0.0, d) * 0.2 * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + iTime));
return float4(col, 1.0);
"""
