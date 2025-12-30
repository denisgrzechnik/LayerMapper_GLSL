//
//  ZoomBlur.metal
//  LM_GLSL
//
//  Category: Motion
//

let zoomBlurCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
float samples = 10.0;
for (int i = 0; i < 10; i++) {
    float fi = float(i) / samples;
    float scale = 1.0 - fi * 0.1;
    float2 sampleUV = p * scale * 0.5 + 0.5;
    float pattern = sin(sampleUV.x * 20.0) * sin(sampleUV.y * 20.0);
    col += (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + iTime + fi * 2.0)) * pattern * 0.5;
}
col /= samples;
return float4(col, 1.0);
"""
