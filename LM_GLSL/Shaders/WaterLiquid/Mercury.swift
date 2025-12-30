//
//  Mercury.metal
//  LM_GLSL
//
//  Category: WaterLiquid
//

let mercuryCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float a = atan2(p.y, p.x);
float n = sin(a * 5.0 + iTime * 2.0 + r * 10.0) * 0.1;
float sphere = smoothstep(0.8 + n, 0.7 + n, r);
float3 col = float3(0.7, 0.7, 0.75) * sphere;
col += float3(0.9, 0.9, 0.95) * smoothstep(0.5, 0.0, r) * sphere;
col += float3(0.3, 0.3, 0.35) * (1.0 - sphere) * 0.2;
return float4(col, 1.0);
"""
