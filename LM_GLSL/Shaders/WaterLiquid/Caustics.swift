//
//  Caustics.metal
//  LM_GLSL
//
//  Category: WaterLiquid
//

let causticsCode = """
float2 p = uv * 5.0;
float3 col = float3(0.0, 0.2, 0.4);
float v = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 q = p + float2(sin(iTime * 0.5 + fi), cos(iTime * 0.3 + fi * 0.7));
    v += sin(q.x * 3.0 + iTime) * sin(q.y * 3.0 + iTime * 0.8);
}
v = v * 0.5 + 0.5;
col += float3(0.3, 0.6, 0.9) * v * v;
return float4(col, 1.0);
"""
