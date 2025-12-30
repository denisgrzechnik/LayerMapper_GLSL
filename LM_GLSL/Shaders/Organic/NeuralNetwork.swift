//
//  NeuralNetwork.metal
//  LM_GLSL
//
//  Category: Organic
//

let neuralNetworkCode = """
float2 p = uv * 4.0;
float3 col = float3(0.05, 0.1, 0.15);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float2 node = float2(fract(sin(fi * 45.67) * 12345.6) * 4.0, fract(cos(fi * 89.01) * 67890.1) * 4.0);
    float d = length(p - node);
    col += float3(0.2, 0.5, 0.8) * smoothstep(0.15, 0.0, d);
    for (int j = i + 1; j < 10; j++) {
        float fj = float(j);
        float2 node2 = float2(fract(sin(fj * 45.67) * 12345.6) * 4.0, fract(cos(fj * 89.01) * 67890.1) * 4.0);
        float2 line = node2 - node;
        float t = clamp(dot(p - node, line) / dot(line, line), 0.0, 1.0);
        float ld = length(p - node - line * t);
        float pulse = 0.5 + 0.5 * sin(iTime * 3.0 + fi + fj);
        col += float3(0.1, 0.3, 0.5) * smoothstep(0.02, 0.0, ld) * pulse;
    }
}
return float4(col, 1.0);
"""
