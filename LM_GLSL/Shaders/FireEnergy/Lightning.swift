//
//  Lightning.metal
//  LM_GLSL
//
//  Category: FireEnergy
//

let lightningCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05, 0.05, 0.1);
float x = 0.0;
float y = -1.0;
for (int i = 0; i < 20; i++) {
    float fi = float(i);
    float t = floor(iTime * 10.0);
    x += (fract(sin(fi * 123.456 + t) * 43758.5) - 0.5) * 0.2;
    y += 0.1;
    float d = length(p - float2(x, y));
    col += float3(0.7, 0.8, 1.0) * smoothstep(0.05, 0.0, d);
}
return float4(col, 1.0);
"""
