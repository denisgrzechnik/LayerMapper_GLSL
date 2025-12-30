//
//  Fireflies.metal
//  LM_GLSL
//
//  Category: Particles
//

let firefliesCode = """
float3 col = float3(0.02, 0.03, 0.05);
for (int i = 0; i < 30; i++) {
    float fi = float(i);
    float2 pos = float2(
        0.5 + 0.4 * sin(fi * 1.23 + iTime * 0.3),
        0.5 + 0.4 * cos(fi * 0.87 + iTime * 0.2)
    );
    float flicker = 0.5 + 0.5 * sin(iTime * 5.0 + fi * 10.0);
    float d = length(uv - pos);
    float glow = 0.003 / d * flicker;
    col += glow * float3(1.0, 0.9, 0.3);
}
return float4(col, 1.0);
"""
