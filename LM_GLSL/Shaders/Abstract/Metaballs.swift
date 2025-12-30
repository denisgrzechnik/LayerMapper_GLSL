//
//  Metaballs.metal
//  LM_GLSL
//
//  Category: Abstract
//

let metaballsCode = """
float2 p = uv * 2.0 - 1.0;

float v = 0.0;

for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 center = float2(
        sin(iTime * (0.5 + fi * 0.2) + fi * 2.0),
        cos(iTime * (0.3 + fi * 0.3) + fi * 1.5)
    ) * 0.6;
    
    float d = length(p - center);
    v += 0.1 / d;
}

float3 col = float3(0.0);
col.r = smoothstep(1.0, 1.2, v);
col.g = smoothstep(1.2, 1.5, v);
col.b = smoothstep(0.8, 1.0, v);

col += float3(0.8, 0.2, 0.3) * smoothstep(1.5, 2.0, v);

return float4(col, 1.0);
"""
