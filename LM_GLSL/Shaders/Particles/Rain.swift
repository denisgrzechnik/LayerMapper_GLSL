//
//  Rain.metal
//  LM_GLSL
//
//  Category: Particles
//

let rainCode = """
float3 col = float3(0.1, 0.1, 0.15);
for (int i = 0; i < 50; i++) {
    float fi = float(i);
    float x = fract(sin(fi * 43.758) * 0.5 + 0.5);
    float y = fract(sin(fi * 12.9898) * 0.5 - iTime * 2.0);
    float2 pos = float2(x, y);
    float2 end = pos + float2(0.0, -0.03);
    float2 p = uv - pos;
    float2 d = end - pos;
    float t = clamp(dot(p, d) / dot(d, d), 0.0, 1.0);
    float dist = length(p - d * t);
    col += smoothstep(0.002, 0.0, dist) * float3(0.5, 0.6, 0.8);
}
return float4(col, 1.0);
"""
