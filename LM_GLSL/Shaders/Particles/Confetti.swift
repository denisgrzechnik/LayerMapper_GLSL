//
//  Confetti.metal
//  LM_GLSL
//
//  Category: Particles
//

let confettiCode = """
float3 col = float3(0.1);
for (int i = 0; i < 40; i++) {
    float fi = float(i);
    float x = fract(sin(fi * 43.758) * 0.5 + 0.5 + sin(iTime + fi) * 0.1);
    float y = fract(sin(fi * 12.9898) * 0.5 - iTime * 0.3 * (0.5 + fract(fi * 0.1)));
    float rot = iTime * 3.0 + fi;
    float2 p = uv - float2(x, y);
    float c = cos(rot); float s = sin(rot);
    p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
    float rect = step(abs(p.x), 0.01) * step(abs(p.y), 0.015);
    col += rect * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""
