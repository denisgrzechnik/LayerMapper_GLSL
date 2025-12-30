//
//  Starfield.metal
//  LM_GLSL
//
//  Category: Cosmic
//

let starfieldCode = """
float3 col = float3(0.0);
for (int i = 0; i < 50; i++) {
    float fi = float(i);
    float2 star = float2(fract(sin(fi * 123.456) * 43758.5), fract(cos(fi * 789.012) * 23421.6));
    float z = fract(fi * 0.1 + iTime * 0.1);
    float2 pos = (star - 0.5) / z + 0.5;
    float brightness = (1.0 - z) * smoothstep(0.02 / z, 0.0, length(uv - pos));
    col += brightness;
}
return float4(col, 1.0);
"""
