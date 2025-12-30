//
//  CircuitBoard.metal
//  LM_GLSL
//
//  Category: Tech
//

let circuitBoardCode = """
float2 p = uv * 20.0;
float2 id = floor(p);
float2 f = fract(p);
float h = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453);
float3 col = float3(0.0, 0.1, 0.05);
float lineH = step(0.48, f.x) * step(f.x, 0.52) * step(h, 0.5);
float lineV = step(0.48, f.y) * step(f.y, 0.52) * step(h, 0.7);
col += (lineH + lineV) * float3(0.0, 0.8, 0.3);
float node = smoothstep(0.15, 0.1, length(f - 0.5)) * step(0.8, h);
col += node * float3(0.0, 1.0, 0.5);
float pulse = sin(iTime * 5.0 + id.x + id.y) * 0.5 + 0.5;
col *= 0.7 + 0.3 * pulse;
return float4(col, 1.0);
"""
