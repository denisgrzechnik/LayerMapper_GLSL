//
//  FloatingCubes.metal
//  LM_GLSL
//
//  Category: 3DStyle
//

let floatingCubesCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.05);
for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float2 offset = float2(sin(fi * 2.0 + iTime), cos(fi * 1.5 + iTime)) * 0.5;
    float size = 0.1 + 0.05 * sin(iTime + fi);
    float2 box = abs(p - offset) - size;
    float d = max(box.x, box.y);
    float cube = smoothstep(0.01, 0.0, d);
    col += cube * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + fi));
}
return float4(col, 1.0);
"""
