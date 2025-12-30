//
//  EnergyBall.metal
//  LM_GLSL
//
//  Category: FireEnergy
//

let energyBallCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.0);
float glow = exp(-r * 3.0);
col += float3(0.2, 0.6, 1.0) * glow;
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float ray = smoothstep(0.1, 0.0, abs(sin(a * 4.0 + fi + iTime * 2.0)));
    col += float3(0.3, 0.7, 1.0) * ray * glow * 0.5;
}
return float4(col, 1.0);
"""
