//
//  FractalWarp.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let fractalWarpCode = """
float2 p = uv * 2.0 - 1.0;

for (int i = 0; i < 6; i++) {
    p = abs(p) / dot(p, p) - 1.0;
    p *= 1.0 + sin(iTime * 0.5) * 0.1;
}

float r = length(p);
float a = atan2(p.y, p.x);

float3 col = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + r * 2.0 + a + iTime);
col *= smoothstep(2.0, 0.0, r);

return float4(col, 1.0);
"""
