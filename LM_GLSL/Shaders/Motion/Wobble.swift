//
//  Wobble.metal
//  LM_GLSL
//
//  Category: Motion
//

let wobbleCode = """
float2 p = uv;
p.x += sin(p.y * 10.0 + iTime * 3.0) * 0.05;
p.y += cos(p.x * 10.0 + iTime * 2.0) * 0.05;
float2 grid = fract(p * 5.0) - 0.5;
float d = length(grid);
float circle = smoothstep(0.3, 0.25, d);
float3 col = circle * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + floor(p.x * 5.0) + floor(p.y * 5.0)));
return float4(col, 1.0);
"""
