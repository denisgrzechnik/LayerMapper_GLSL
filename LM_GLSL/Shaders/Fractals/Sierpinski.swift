//
//  Sierpinski.metal
//  LM_GLSL
//
//  Category: Fractals
//

let sierpinskiCode = """
float2 p = uv;
float3 col = float3(1.0);
for (int i = 0; i < 8; i++) {
    p *= 2.0;
    float2 f = fract(p);
    if (f.x > 0.5 && f.y > 0.5) {
        col *= 0.0;
        break;
    }
    p = fract(p * 0.5) * 2.0;
}
col *= 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + iTime);
return float4(col, 1.0);
"""
