//
//  ColorExplosion.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let colorExplosionCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);

float3 col = float3(0.0);

for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float angle = a + fi * 1.047 + iTime * (0.5 + fi * 0.1);
    float ray = pow(max(0.0, cos(angle * 3.0)), 10.0);
    
    float3 rayColor = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi * 1.2);
    col += rayColor * ray * (1.0 - r);
}

float center = smoothstep(0.3, 0.0, r);
col += float3(1.0, 0.9, 0.7) * center;

return float4(col, 1.0);
"""
