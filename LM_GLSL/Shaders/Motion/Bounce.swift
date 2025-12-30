//
//  Bounce.metal
//  LM_GLSL
//
//  Category: Motion
//

let bounceCode = """
float3 col = float3(0.1);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float phase = iTime * 2.0 + fi * 1.2;
    float y = abs(sin(phase)) * 0.6 + 0.2;
    float x = 0.2 + fi * 0.15;
    float2 pos = float2(x, y);
    float d = length(uv - pos);
    float ball = smoothstep(0.08, 0.05, d);
    float3 ballCol = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi);
    col += ball * ballCol;
    float shadow = smoothstep(0.1, 0.0, length(uv - float2(x, 0.1))) * 0.3;
    col -= shadow;
}
return float4(col, 1.0);
"""
