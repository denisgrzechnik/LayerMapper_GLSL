//
//  Pendulum.metal
//  LM_GLSL
//
//  Category: Motion
//

let pendulumCode = """
float2 p = uv * 2.0 - 1.0;
float3 col = float3(0.1);
float2 pivot = float2(0.0, 0.8);
float angle = sin(iTime * 2.0) * 0.8;
float length_p = 0.6;
float2 bobPos = pivot + float2(sin(angle), -cos(angle)) * length_p;
float2 lineDir = bobPos - pivot;
float2 toP = p - pivot;
float t = clamp(dot(toP, lineDir) / dot(lineDir, lineDir), 0.0, 1.0);
float lineDist = distance(p, pivot + lineDir * t);
col += smoothstep(0.02, 0.0, lineDist) * float3(0.5);
float bobDist = length(p - bobPos);
col += smoothstep(0.12, 0.1, bobDist) * float3(0.8, 0.3, 0.2);
col += smoothstep(0.03, 0.0, length(p - pivot)) * float3(0.5);
return float4(col, 1.0);
"""
