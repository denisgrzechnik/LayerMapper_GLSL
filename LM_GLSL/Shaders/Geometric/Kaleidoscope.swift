//
//  Kaleidoscope.metal
//  LM_GLSL
//
//  Category: Geometric
//

let kaleidoscopeCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);

float segments = 8.0;
a = fmod(abs(a), 3.14159 * 2.0 / segments);

float2 q = float2(cos(a), sin(a)) * r;
q += float2(sin(iTime), cos(iTime * 0.7)) * 0.3;

float c1 = sin(q.x * 10.0 + iTime) * 0.5 + 0.5;
float c2 = sin(q.y * 10.0 + iTime * 1.3) * 0.5 + 0.5;
float c3 = sin((q.x + q.y) * 8.0 + iTime * 0.8) * 0.5 + 0.5;

float3 col = float3(c1, c2, c3);
col *= 1.0 - r * 0.5;

return float4(col, 1.0);
"""
