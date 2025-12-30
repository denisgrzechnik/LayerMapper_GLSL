//
//  LiquidMetal.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let liquidMetalCode = """
float2 p = uv * 2.0 - 1.0;

float3 col = float3(0.0);

for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 q = p;
    q += float2(sin(iTime * 0.5 + fi), cos(iTime * 0.3 + fi * 0.7)) * 0.5;
    q *= 1.0 + fi * 0.2;
    
    float d = length(q);
    float ripple = sin(d * 10.0 - iTime * 2.0 + fi * 2.0) * 0.5 + 0.5;
    ripple = pow(ripple, 3.0);
    
    col += float3(0.7, 0.75, 0.8) * ripple * (1.0 - fi * 0.15);
}

col = pow(col, float3(1.5));

return float4(col, 1.0);
"""
