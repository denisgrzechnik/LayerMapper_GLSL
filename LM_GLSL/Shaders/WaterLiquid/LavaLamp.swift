//
//  LavaLamp.metal
//  LM_GLSL
//
//  Category: WaterLiquid
//

let lavaLampCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1, 0.0, 0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float y = sin(iTime * 0.3 + fi * 2.0) * 0.8;
    float2 c = float2(sin(fi * 1.5) * 0.5, y);
    float d = length(p - c);
    float blob = smoothstep(0.4, 0.1, d);
    col += float3(0.9, 0.3, 0.1) * blob;
}
return float4(col, 1.0);
"""
