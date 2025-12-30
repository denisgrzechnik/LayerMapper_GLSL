//
//  Radar.metal
//  LM_GLSL
//
//  Category: Tech
//

let radarCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.0, 0.1, 0.0);
for (int i = 1; i <= 4; i++) {
    float radius = float(i) * 0.2;
    col += smoothstep(0.02, 0.0, abs(r - radius)) * float3(0.0, 0.3, 0.1);
}
col += smoothstep(0.01, 0.0, abs(p.x)) * step(r, 0.8) * float3(0.0, 0.2, 0.1);
col += smoothstep(0.01, 0.0, abs(p.y)) * step(r, 0.8) * float3(0.0, 0.2, 0.1);
float sweep = mod(iTime * 2.0, 6.28318);
float sweepAngle = a + 3.14159;
float sweepDist = mod(sweep - sweepAngle, 6.28318);
float sweepBright = (1.0 - sweepDist / 1.0) * step(sweepDist, 1.0) * step(r, 0.8);
col += sweepBright * float3(0.0, 1.0, 0.3);
return float4(col, 1.0);
"""
