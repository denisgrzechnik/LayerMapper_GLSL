//
//  SolidColorPulse.metal
//  LM_GLSL
//
//  Category: Minimal
//

let solidColorPulseCode = """
float pulse = sin(iTime * 2.0) * 0.5 + 0.5;
float3 col = float3(pulse, pulse * 0.5, 1.0 - pulse);
return float4(col, 1.0);
"""
