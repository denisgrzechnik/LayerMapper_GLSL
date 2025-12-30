//
//  TruchetPattern.metal
//  LM_GLSL
//
//  Category: Geometric
//

let truchetPatternCode = """
float2 p = uv * 8.0;
float2 id = floor(p);
float2 f = fract(p);
float r = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453);
float3 col = float3(0.0);
float d1, d2;
if (r > 0.5) {
    d1 = length(f);
    d2 = length(f - 1.0);
} else {
    d1 = length(f - float2(1.0, 0.0));
    d2 = length(f - float2(0.0, 1.0));
}
float arc = smoothstep(0.55, 0.5, d1) * smoothstep(0.45, 0.5, d1);
arc += smoothstep(0.55, 0.5, d2) * smoothstep(0.45, 0.5, d2);
col = float3(arc);
return float4(col, 1.0);
"""
