//
//  KochSnowflake.metal
//  LM_GLSL
//
//  Category: Fractals
//

let kochSnowflakeCode = """
float2 p = uv * 2.0 - 1.0;
float d = 1.0;
for (int i = 0; i < 5; i++) {
    p = abs(p);
    p -= 0.5;
    p *= 1.5;
    d *= 1.5;
}
float line = length(p) / d;
float3 col = float3(0.7, 0.8, 0.9) * smoothstep(0.1, 0.0, line);
col += float3(0.5, 0.6, 0.8) * (1.0 - smoothstep(0.0, 0.2, line));
return float4(col, 1.0);
"""
