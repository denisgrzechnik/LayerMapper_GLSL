//
//  Rorschach.metal
//  LM_GLSL
//
//  Category: Abstract
//

let rorschachCode = """
float2 p = uv * 2.0 - 1.0;
p.x = abs(p.x);
float n = 0.0;
for (int i = 0; i < 4; i++) {
    float fi = float(i);
    n += sin(p.x * (5.0 + fi * 3.0) + p.y * (7.0 + fi * 2.0) + iTime * (0.5 + fi * 0.2)) * (0.5 - fi * 0.1);
}
float blob = step(0.0, n);
float3 col = float3(blob);
return float4(col, 1.0);
"""
