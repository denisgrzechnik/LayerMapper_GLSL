//
//  DeepOcean.metal
//  LM_GLSL
//
//  Category: Gradient
//

let deepOceanCode = """
float depth = uv.y;
float3 col = mix(float3(0.0, 0.3, 0.5), float3(0.0, 0.05, 0.1), depth);
float caustic = sin(uv.x * 20.0 + iTime) * sin(uv.y * 15.0 - iTime * 0.5);
col += caustic * 0.05 * (1.0 - depth);
float bubbles = smoothstep(0.98, 1.0, fract(sin(floor(uv.x * 20.0) * 43.758) + iTime * 0.2));
col += bubbles * float3(0.3, 0.5, 0.7) * (1.0 - uv.y);
return float4(col, 1.0);
"""
