//
//  Tropical.metal
//  LM_GLSL
//
//  Category: Gradient
//

let tropicalCode = """
float t = uv.x + uv.y * 0.5 + sin(iTime * 0.5) * 0.2;
float3 c1 = float3(1.0, 0.4, 0.7);
float3 c2 = float3(0.2, 0.8, 0.9);
float3 c3 = float3(1.0, 0.9, 0.3);
float3 col = mix(c1, c2, smoothstep(0.0, 0.5, t));
col = mix(col, c3, smoothstep(0.5, 1.0, t));
return float4(col, 1.0);
"""
