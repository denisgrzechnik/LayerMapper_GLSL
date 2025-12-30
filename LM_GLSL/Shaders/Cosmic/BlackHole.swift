//
//  BlackHole.metal
//  LM_GLSL
//
//  Category: Cosmic
//

let blackHoleCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float warp = 1.0 / (r + 0.1);
a += warp * 0.5 + iTime;
float3 col = float3(0.0);
float ring = smoothstep(0.3, 0.35, r) * smoothstep(0.5, 0.45, r);
col += float3(1.0, 0.5, 0.2) * ring * (0.5 + 0.5 * sin(a * 10.0));
col *= 1.0 - smoothstep(0.2, 0.0, r);
return float4(col, 1.0);
"""
