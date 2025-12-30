//
//  Nebula.metal
//  LM_GLSL
//
//  Category: Cosmic
//

let nebulaCode = """
float2 p = uv * 3.0;
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 q = p + float2(sin(iTime * 0.3 + fi), cos(iTime * 0.2 + fi * 0.7));
    float n = sin(q.x * 2.0 + iTime) * cos(q.y * 2.0 + iTime * 0.5);
    col += 0.5 + 0.5 * sin(float3(0.5, 0.3, 0.8) * n * 3.0 + fi + iTime);
}
col /= 5.0;
col = pow(col, float3(1.5));
return float4(col, 1.0);
"""
