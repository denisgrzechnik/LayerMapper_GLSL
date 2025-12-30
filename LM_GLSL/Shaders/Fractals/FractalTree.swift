//
//  FractalTree.metal
//  LM_GLSL
//
//  Category: Fractals
//

let fractalTreeCode = """
float2 p = uv * 2.0 - 1.0;
p.y += 0.8;
float3 col = float3(0.1, 0.2, 0.1);
float w = 0.05;
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    if (abs(p.x) < w && p.y > 0.0 && p.y < 0.3) {
        col = float3(0.3, 0.2, 0.1);
    }
    p.y -= 0.3;
    float angle = 0.5 + 0.2 * sin(iTime + fi);
    float c = cos(angle); float s = sin(angle);
    if (p.x > 0.0) p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    else p = float2(p.x * c + p.y * s, -p.x * s + p.y * c);
    p *= 1.4;
    w *= 0.7;
}
return float4(col, 1.0);
"""
