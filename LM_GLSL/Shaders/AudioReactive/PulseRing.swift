//
//  PulseRing.metal
//  LM_GLSL
//
//  Category: AudioReactive
//

let pulseRingCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float radius = 0.2 + fi * 0.15;
    float pulse = sin(iTime * 4.0 + fi * 1.5) * 0.05;
    float ring = smoothstep(0.02, 0.0, abs(r - radius - pulse));
    col += ring * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""
