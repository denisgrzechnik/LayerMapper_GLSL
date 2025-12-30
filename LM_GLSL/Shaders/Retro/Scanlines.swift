//
//  Scanlines.metal
//  LM_GLSL
//
//  Category: Retro
//

let scanlinesCode = """
float2 p = uv;
float3 col = float3(sin(p.x * 5.0 + iTime) * 0.5 + 0.5);
col *= 0.8 + 0.2 * sin(p.y * 400.0);
col *= 0.95 + 0.05 * sin(iTime * 60.0);
return float4(col, 1.0);
"""
