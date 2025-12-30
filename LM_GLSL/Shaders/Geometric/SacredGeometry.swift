//
//  SacredGeometry.metal
//  LM_GLSL
//
//  Category: Geometric
//

let sacredGeometryCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.0);
for (int i = 0; i < 6; i++) {
    float a = float(i) * 3.14159 / 3.0 + iTime * 0.2;
    float2 c = float2(cos(a), sin(a)) * 0.5;
    float d = length(p - c);
    col += float3(0.8, 0.7, 0.2) * smoothstep(0.52, 0.48, d) * smoothstep(0.45, 0.48, d);
}
float d0 = length(p);
col += float3(0.8, 0.7, 0.2) * smoothstep(0.52, 0.48, d0) * smoothstep(0.45, 0.48, d0);
return float4(col, 1.0);
"""
