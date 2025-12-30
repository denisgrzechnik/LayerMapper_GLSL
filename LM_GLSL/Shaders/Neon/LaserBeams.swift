//
//  LaserBeams.metal
//  LM_GLSL
//
//  Category: Neon
//

let laserBeamsCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float angle = fi * 3.14159 / 3.0 + iTime * 0.5;
    float2 dir = float2(cos(angle), sin(angle));
    float d = abs(dot(p, float2(-dir.y, dir.x)));
    float beam = smoothstep(0.02, 0.0, d) * step(0.0, dot(p, dir));
    float3 beamCol = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi);
    col += beam * beamCol;
    col += exp(-d * 20.0) * beamCol * 0.3;
}
return float4(col, 1.0);
"""
