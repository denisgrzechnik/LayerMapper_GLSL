//
//  RayMarchSphere.metal
//  LM_GLSL
//
//  Category: 3DStyle
//

let rayMarchSphereCode = """
float2 p = uv * 2.0 - 1.0;
float3 ro = float3(0.0, 0.0, -3.0);
float3 rd = normalize(float3(p, 1.0));
float t = 0.0;
for (int i = 0; i < 50; i++) {
    float3 pos = ro + rd * t;
    float d = length(pos) - 1.0;
    if (d < 0.01) break;
    t += d;
}
float3 col = float3(0.0);
if (t < 10.0) {
    float3 pos = ro + rd * t;
    float3 nor = normalize(pos);
    float3 light = normalize(float3(sin(iTime), 1.0, cos(iTime)));
    float dif = max(0.0, dot(nor, light));
    col = float3(0.3, 0.5, 0.8) * dif + float3(0.1);
}
return float4(col, 1.0);
"""
