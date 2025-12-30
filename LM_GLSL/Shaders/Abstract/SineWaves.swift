//
//  SineWaves.metal
//  LM_GLSL
//
//  Category: Abstract
//

let sineWavesCode = """
float2 p = uv;

float3 col = float3(0.0);

for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float freq = 3.0 + fi * 2.0;
    float amp = 0.1 - fi * 0.015;
    float speed = 1.0 + fi * 0.3;
    float phase = fi * 0.5;
    
    float wave = sin(p.x * freq + iTime * speed + phase) * amp;
    float line = smoothstep(0.02, 0.0, abs(p.y - 0.5 - wave));
    
    float3 lineColor = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi * 0.8 + iTime);
    col += lineColor * line;
}

return float4(col, 1.0);
"""
