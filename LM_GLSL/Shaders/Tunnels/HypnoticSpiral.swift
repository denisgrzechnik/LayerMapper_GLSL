//
//  HypnoticSpiral.metal
//  LM_GLSL
//
//  Category: Tunnels & Warp
//

let hypnoticSpiralCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);

float spiral = sin(a * 5.0 - r * 10.0 + iTime * 3.0);
float rings = sin(r * 20.0 - iTime * 2.0);

float pattern = spiral * 0.5 + rings * 0.5;
pattern = smoothstep(-0.2, 0.2, pattern);

float3 col = mix(float3(0.0), float3(1.0), pattern);
col *= 1.0 - r * 0.3;

return float4(col, 1.0);
"""
