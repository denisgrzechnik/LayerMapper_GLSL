//
//  Clouds3D.metal
//  LM_GLSL
//
//  Category: 3DStyle
//

let clouds3DCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.3, 0.5, 0.8);
float3 ro = float3(0.0, 0.0, iTime);
float3 rd = normalize(float3(p, 1.0));
float t = 0.0;
float density = 0.0;
for (int i = 0; i < 30; i++) {
    float3 pos = ro + rd * t;
    float n = fract(sin(dot(floor(pos), float3(12.9898, 78.233, 45.164))) * 43758.5453);
    density += n * 0.02 * (1.0 - t / 20.0);
    t += 0.5;
}
col = mix(col, float3(1.0), density);
return float4(col, 1.0);
"""
