//
//  Cyberpunk.metal
//  LM_GLSL
//
//  Category: Gradient
//

let cyberpunkCode = """
float t = uv.y + sin(uv.x * 5.0 + iTime) * 0.1;
float3 col = mix(float3(0.0, 0.0, 0.0), float3(0.1, 0.0, 0.2), t);
float scanline = sin(uv.y * 200.0) * 0.05;
col += scanline;
float neon1 = smoothstep(0.01, 0.0, abs(fract(t * 5.0) - 0.5) - 0.45);
col += neon1 * float3(1.0, 0.0, 0.5);
float neon2 = smoothstep(0.01, 0.0, abs(fract(t * 3.0 + 0.3) - 0.5) - 0.45);
col += neon2 * float3(0.0, 1.0, 1.0);
return float4(col, 1.0);
"""
