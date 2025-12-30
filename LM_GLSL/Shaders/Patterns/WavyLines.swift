//
//  WavyLines.metal
//  LM_GLSL
//
//  Category: Patterns
//

let wavyLinesCode = """
float2 p = uv;
float3 col = float3(0.0);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float y = 0.1 * fi + 0.05;
    float wave = sin(p.x * 20.0 + iTime * 2.0 + fi) * 0.02;
    float line = smoothstep(0.01, 0.0, abs(p.y - y - wave));
    col += line * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""
