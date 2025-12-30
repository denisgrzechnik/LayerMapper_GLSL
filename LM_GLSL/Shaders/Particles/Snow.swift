//
//  Snow.metal
//  LM_GLSL
//
//  Category: Particles
//

let snowCode = """
float3 col = float3(0.1, 0.1, 0.2);
for (int layer = 0; layer < 3; layer++) {
    float fl = float(layer);
    float speed = 0.3 + fl * 0.2;
    float size = 0.01 - fl * 0.002;
    for (int i = 0; i < 20; i++) {
        float fi = float(i) + fl * 20.0;
        float x = fract(sin(fi * 43.758) * 0.5 + 0.5 + sin(iTime * 0.5 + fi) * 0.05);
        float y = fract(sin(fi * 12.9898) * 0.5 + 0.5 - iTime * speed);
        float d = length(uv - float2(x, y));
        col += smoothstep(size, 0.0, d) * float3(0.8, 0.9, 1.0);
    }
}
return float4(col, 1.0);
"""
