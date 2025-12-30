//
//  InfiniteCorridor.metal
//  LM_GLSL
//
//  Category: 3DStyle
//

let infiniteCorridorCode = """
float2 p = uv * 2.0 - 1.0;
float z = mod(iTime * 2.0, 1.0);
float3 col = float3(0.0);
for (int i = 0; i < 10; i++) {
    float fi = float(i);
    float depth = fi + z;
    float scale = 1.0 / depth;
    float2 box = abs(p * scale) - 0.8;
    float d = max(box.x, box.y);
    float line = smoothstep(0.02, 0.0, abs(d));
    col += line * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + depth));
}
return float4(col, 1.0);
"""
