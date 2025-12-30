//
//  PlasmaBall.metal
//  LM_GLSL
//
//  Category: FireEnergy
//

let plasmaBallCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float3 col = float3(0.0);
float core = exp(-r * 5.0);
col += float3(1.0, 0.3, 0.8) * core;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float arc = sin(a * 3.0 + iTime * 3.0 + fi * 2.0);
    float beam = smoothstep(0.1, 0.0, abs(arc)) * smoothstep(0.8, 0.3, r);
    col += float3(0.8, 0.2, 1.0) * beam * 0.5;
}
return float4(col, 1.0);
"""
