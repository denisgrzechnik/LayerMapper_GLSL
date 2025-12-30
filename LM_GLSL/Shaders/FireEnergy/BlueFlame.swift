//
//  BlueFlame.metal
//  LM_GLSL
//
//  Category: FireEnergy
//

let blueFlameCode = """
float2 p = uv;
p.x = p.x * 2.0 - 1.0;
p.y = 1.0 - p.y;
float flame = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float n = sin(p.x * 10.0 + iTime * 3.0 + fi) * 0.1;
    flame += smoothstep(0.5 + fi * 0.1, 0.0, p.y + n) * smoothstep(0.3 + fi * 0.05, 0.5, abs(p.x));
}
float3 col = float3(0.1, 0.3, 0.9) * flame;
col += float3(0.5, 0.7, 1.0) * flame * flame;
return float4(col, 1.0);
"""
