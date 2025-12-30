//
//  Aurora.metal
//  LM_GLSL
//
//  Category: Nature
//

let auroraCode = """
float2 p = uv;

float wave1 = sin(p.x * 3.0 + iTime) * 0.1;
float wave2 = sin(p.x * 5.0 - iTime * 1.3) * 0.08;
float wave3 = sin(p.x * 7.0 + iTime * 0.7) * 0.05;

float aurora = wave1 + wave2 + wave3 + 0.5;
float mask = smoothstep(0.3, 0.7, p.y + aurora * 0.5);
mask *= smoothstep(1.0, 0.5, p.y);

float3 green = float3(0.1, 0.8, 0.3);
float3 blue = float3(0.1, 0.3, 0.8);
float3 purple = float3(0.5, 0.1, 0.8);

float colorMix = sin(p.x * 2.0 + iTime) * 0.5 + 0.5;
float3 auroraColor = mix(green, mix(blue, purple, colorMix), colorMix);

float3 sky = float3(0.02, 0.02, 0.08);
float3 col = mix(sky, auroraColor, mask * 0.8);

// Stars
float stars = fract(sin(dot(floor(uv * 200.0), float2(12.9898, 78.233))) * 43758.5453);
stars = pow(stars, 20.0) * (1.0 - mask);
col += float3(stars * 0.5);

return float4(col, 1.0);
"""
