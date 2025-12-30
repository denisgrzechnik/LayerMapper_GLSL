//
//  InfiniteCubes.metal
//  LM_GLSL
//
//  Category: Geometric
//

let infiniteCubesCode = """
float2 p = uv * 2.0 - 1.0;
float t = iTime;
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float s = 1.0 - fi * 0.15;
    float2 q = p / s;
    q = abs(q);
    float box = max(q.x, q.y);
    float edge = smoothstep(0.9, 0.95, box) * smoothstep(1.0, 0.95, box);
    float phase = fract(t * 0.5 + fi * 0.1);
    col += edge * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi)) * (1.0 - phase);
}
return float4(col, 1.0);
"""
