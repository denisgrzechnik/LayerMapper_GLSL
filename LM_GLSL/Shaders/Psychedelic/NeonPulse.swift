//
//  NeonPulse.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let neonPulseCode = """
float2 p = uv * 2.0 - 1.0;

float pulse = sin(iTime * 2.0) * 0.5 + 0.5;
float r = length(p);

float ring1 = abs(r - 0.3 - pulse * 0.2);
float ring2 = abs(r - 0.5);
float ring3 = abs(r - 0.7 + pulse * 0.1);

float3 col = float3(0.0);
col += float3(1.0, 0.0, 0.5) * smoothstep(0.05, 0.0, ring1);
col += float3(0.0, 1.0, 1.0) * smoothstep(0.05, 0.0, ring2);
col += float3(1.0, 1.0, 0.0) * smoothstep(0.05, 0.0, ring3);

// Glow
col += float3(1.0, 0.0, 0.5) * smoothstep(0.2, 0.0, ring1) * 0.3;
col += float3(0.0, 1.0, 1.0) * smoothstep(0.2, 0.0, ring2) * 0.3;
col += float3(1.0, 1.0, 0.0) * smoothstep(0.2, 0.0, ring3) * 0.3;

return float4(col, 1.0);
"""
