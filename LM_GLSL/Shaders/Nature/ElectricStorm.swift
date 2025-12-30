//
//  ElectricStorm.metal
//  LM_GLSL
//
//  Category: Nature
//

let electricStormCode = """
float2 p = uv * 2.0 - 1.0;

float bolt = 0.0;
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float offset = sin(iTime * (2.0 + fi) + fi * 1.5) * 0.3;
    float x = p.x + offset;
    float thickness = 0.02 + sin(iTime * 10.0 + fi) * 0.01;
    bolt += smoothstep(thickness, 0.0, abs(x)) * (1.0 - abs(p.y));
}

float flash = pow(sin(iTime * 15.0) * 0.5 + 0.5, 8.0);
float3 col = float3(0.5, 0.5, 1.0) * bolt;
col += float3(0.8, 0.8, 1.0) * flash * 0.3;

// Background clouds
float clouds = sin(p.x * 3.0 + iTime * 0.5) * sin(p.y * 2.0 + iTime * 0.3);
col += float3(0.1, 0.0, 0.2) * (clouds * 0.5 + 0.5);

return float4(col, 1.0);
"""
