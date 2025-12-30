//
//  NeonGrid.metal
//  LM_GLSL
//
//  Category: Neon
//

let neonGridCode = """
float2 p = uv * 10.0;
float2 f = fract(p);
float gridX = smoothstep(0.02, 0.0, abs(f.x - 0.5) - 0.48);
float gridY = smoothstep(0.02, 0.0, abs(f.y - 0.5) - 0.48);
float grid = max(gridX, gridY);
float3 col = grid * float3(1.0, 0.0, 0.8);
col += grid * float3(0.0, 1.0, 1.0) * sin(iTime * 3.0) * 0.5;
float glow = (gridX + gridY) * 0.3;
col += glow * float3(0.5, 0.0, 0.5);
return float4(col, 1.0);
"""
