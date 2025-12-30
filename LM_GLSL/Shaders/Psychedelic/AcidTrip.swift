//
//  AcidTrip.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let acidTripCode = """
float2 p = uv * 2.0 - 1.0;
float a = atan2(p.y, p.x);
float r = length(p);
float v = sin(a * 5.0 + iTime * 2.0) * sin(r * 10.0 - iTime * 3.0);
float3 col = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + v * 5.0 + iTime);
col = pow(col, float3(0.7));
return float4(col, 1.0);
"""
