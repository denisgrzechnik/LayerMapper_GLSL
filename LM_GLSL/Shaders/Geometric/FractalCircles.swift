//
//  FractalCircles.metal
//  LM_GLSL
//
//  Category: Geometric
//

let fractalCirclesCode = """
float2 p = uv * 2.0 - 1.0;

float3 col = float3(0.0);

for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float scale = 1.0 + fi * 0.5;
    float speed = 1.0 + fi * 0.2;
    
    float2 offset = float2(sin(iTime * speed), cos(iTime * speed * 0.7)) * 0.3;
    float2 q = p * scale + offset;
    
    float r = length(q);
    float circle = smoothstep(0.5, 0.48, r) - smoothstep(0.48, 0.46, r);
    
    float3 circleColor = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi * 0.8);
    col += circleColor * circle * (1.0 - fi * 0.1);
}

return float4(col, 1.0);
"""
