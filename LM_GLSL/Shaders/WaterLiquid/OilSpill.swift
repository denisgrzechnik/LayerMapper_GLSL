//
//  OilSpill.metal
//  LM_GLSL
//
//  Category: WaterLiquid
//

let oilSpillCode = """
float2 p = uv * 3.0;
float n = sin(p.x * 5.0 + iTime) * cos(p.y * 5.0 + iTime * 0.7);
float3 col = 0.5 + 0.5 * sin(float3(1.0, 2.0, 3.0) * n * 2.0 + iTime + p.x + p.y);
col = pow(col, float3(0.8));
return float4(col, 1.0);
"""
