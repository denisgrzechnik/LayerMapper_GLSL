//
//  Mandelbrot.metal
//  LM_GLSL
//
//  Category: Fractals
//

let mandelbrotCode = """
float2 c = (uv - 0.5) * 3.0 - float2(0.5, 0.0);
float2 z = float2(0.0);
float iter = 0.0;
for (int i = 0; i < 50; i++) {
    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > 4.0) break;
    iter += 1.0;
}
float3 col = 0.5 + 0.5 * sin(float3(0.0, 0.5, 1.0) * iter * 0.1 + iTime);
if (iter >= 49.0) col = float3(0.0);
return float4(col, 1.0);
"""
