//
//  GlowWorm.metal
//  LM_GLSL
//
//  Category: Neon
//

let glowWormCode = """
float3 col = float3(0.02);
float2 prev = float2(0.5, 0.5);
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float t = iTime - fi * 0.1;
    float2 pos = float2(
        0.5 + 0.3 * sin(t * 2.0) * cos(t * 0.7),
        0.5 + 0.3 * cos(t * 1.5) * sin(t * 0.9)
    );
    float d = length(uv - pos);
    float glow = 0.005 / d;
    float3 c = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi * 0.3);
    col += glow * c * (1.0 - fi / 20.0);
    prev = pos;
}
return float4(col, 1.0);
"""
