//
//  Checkerboard.metal
//  LM_GLSL
//
//  Category: Patterns
//

let checkerboardCode = """
float2 p = uv * 8.0;
float c = mod(floor(p.x) + floor(p.y), 2.0);
float pulse = 0.5 + 0.5 * sin(iTime * 2.0);
float3 col = mix(float3(0.1), float3(0.9), c * pulse);
return float4(col, 1.0);
"""
