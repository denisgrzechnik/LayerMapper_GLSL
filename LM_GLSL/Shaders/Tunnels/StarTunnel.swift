//
//  StarTunnel.metal
//  LM_GLSL
//
//  Category: Tunnels & Warp
//

let starTunnelCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);

float stars = 0.0;
for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float depth = 0.5 + fi * 0.3;
    float speed = 1.0 + fi * 0.5;
    float size = 0.02 - fi * 0.005;
    
    float2 sp = float2(a * 5.0, 1.0 / (r + 0.1) - iTime * speed);
    float2 grid = fract(sp * (3.0 + fi)) - 0.5;
    float star = smoothstep(size, 0.0, length(grid));
    stars += star * depth;
}

float3 col = float3(stars) * float3(0.8, 0.9, 1.0);
col += float3(0.0, 0.0, 0.1) * (1.0 - r);

return float4(col, 1.0);
"""
