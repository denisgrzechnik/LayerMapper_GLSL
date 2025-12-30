//
//  Cells.metal
//  LM_GLSL
//
//  Category: Organic
//

let cellsCode = """
float2 p = uv * 5.0;
float3 col = float3(0.0);
float minD = 10.0;
for (int i = 0; i < 15; i++) {
    float fi = float(i);
    float2 center = float2(sin(fi * 1.2 + iTime * 0.5), cos(fi * 0.9 + iTime * 0.3)) * 2.0 + 2.5;
    float d = length(p - center);
    minD = min(minD, d);
}
col = float3(0.2, 0.7, 0.3) * (1.0 - smoothstep(0.0, 0.5, minD));
col += float3(0.1, 0.3, 0.1) * smoothstep(0.3, 0.35, minD);
return float4(col, 1.0);
"""
