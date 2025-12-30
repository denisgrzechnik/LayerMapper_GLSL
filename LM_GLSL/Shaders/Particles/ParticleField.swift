//
//  ParticleField.metal
//  LM_GLSL
//
//  Category: Particles
//

let particleFieldCode = """
float3 col = float3(0.0);
for (int i = 0; i < 50; i++) {
    float fi = float(i);
    float2 pos = fract(float2(sin(fi * 43.758), cos(fi * 12.9898)) * 0.5 + 0.5 + iTime * 0.05 * float2(sin(fi), cos(fi)));
    float d = length(uv - pos);
    float brightness = 0.002 / d;
    col += brightness * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""
