//
//  BloodCells.metal
//  LM_GLSL
//
//  Category: Organic
//

let bloodCellsCode = """
float2 p = uv * 6.0;
float3 col = float3(0.4, 0.0, 0.0);
for (int i = 0; i < 12; i++) {
    float fi = float(i);
    float2 c = float2(fract(sin(fi * 12.34) * 43758.5) * 6.0, fract(cos(fi * 56.78) * 23421.6) * 6.0);
    c.x += sin(iTime * 0.5 + fi) * 0.5;
    float d = length(p - c);
    float cell = smoothstep(0.4, 0.35, d) * smoothstep(0.1, 0.15, d);
    col += float3(0.8, 0.1, 0.1) * cell;
}
return float4(col, 1.0);
"""
