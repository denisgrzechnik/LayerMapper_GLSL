//
//  Bacteria.metal
//  LM_GLSL
//
//  Category: Organic
//

let bacteriaCode = """
float2 p = uv * 4.0 - 2.0;
float3 col = float3(0.1, 0.2, 0.1);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float2 c = float2(sin(iTime * 0.5 + fi * 2.0), cos(iTime * 0.3 + fi * 1.5)) * 1.5;
    float d = length(p - c);
    float blob = smoothstep(0.4, 0.2, d);
    col += float3(0.3, 0.7, 0.2) * blob;
}
return float4(col, 1.0);
"""
