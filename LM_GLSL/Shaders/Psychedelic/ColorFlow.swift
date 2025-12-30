//
//  ColorFlow.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let colorFlowCode = """
float2 p = uv;
float t = iTime;
float3 col;
col.r = sin(p.x * 10.0 + t) * 0.5 + 0.5;
col.g = sin(p.y * 10.0 + t * 1.3) * 0.5 + 0.5;
col.b = sin((p.x + p.y) * 5.0 + t * 0.7) * 0.5 + 0.5;
col = pow(col, float3(0.8));
return float4(col, 1.0);
"""
