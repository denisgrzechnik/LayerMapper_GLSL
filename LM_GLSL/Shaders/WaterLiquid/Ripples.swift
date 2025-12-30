//
//  Ripples.metal
//  LM_GLSL
//
//  Category: WaterLiquid
//

let ripplesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1, 0.3, 0.6);
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float2 c = float2(sin(fi * 2.0 + iTime), cos(fi * 1.5 + iTime * 0.7)) * 0.5;
    float d = length(p - c);
    float ripple = sin(d * 20.0 - iTime * 5.0) * exp(-d * 2.0);
    col += float3(0.3, 0.5, 0.8) * ripple * 0.3;
}
return float4(col, 1.0);
"""
