//
//  Terrain.metal
//  LM_GLSL
//
//  Category: 3DStyle
//

let terrainCode = """
float2 p = uv;
p.y = 1.0 - p.y;
float horizon = 0.5;
float3 col = mix(float3(0.5, 0.7, 0.9), float3(0.2, 0.4, 0.7), p.y / horizon);
if (p.y > horizon) {
    float z = (p.y - horizon) / (1.0 - horizon);
    float x = (p.x - 0.5) / z;
    float terrain = sin(x * 5.0 + iTime) * 0.1 + sin(x * 10.0) * 0.05;
    float height = terrain + 0.1;
    float ground = step(0.0, height - z * 0.5);
    col = mix(float3(0.2, 0.5, 0.2), float3(0.1, 0.3, 0.1), z);
}
return float4(col, 1.0);
"""
