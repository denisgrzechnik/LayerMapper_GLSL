//
//  NorthernLights.metal
//  LM_GLSL
//
//  Category: Gradient
//

let northernLightsCode = """
float2 p = uv;
float3 col = float3(0.0, 0.05, 0.1);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float wave = sin(p.x * 3.0 + iTime + fi) * 0.1 + 0.5 + fi * 0.1;
    float light = smoothstep(0.1, 0.0, abs(p.y - wave));
    float3 c = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi * 1.5 + iTime);
    col += light * c * 0.3;
}
return float4(col, 1.0);
"""
