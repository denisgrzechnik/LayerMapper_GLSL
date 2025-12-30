//
//  WarpTunnel.metal
//  LM_GLSL
//
//  Category: Tunnels & Warp
//

let warpTunnelCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);
float z = iTime * 2.0;

float tunnel = 0.5 / r;
float twist = a * 3.0 + z;

float c1 = sin(tunnel * 10.0 - z * 5.0 + twist) * 0.5 + 0.5;
float c2 = sin(tunnel * 8.0 - z * 3.0 - twist * 0.5) * 0.5 + 0.5;

float3 col = float3(c1 * 0.3, c1 * 0.5 + c2 * 0.3, c2 * 0.8);
col *= 1.0 - r * 0.5;

return float4(col, 1.0);
"""
