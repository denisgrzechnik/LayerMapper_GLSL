//
//  OceanWaves.metal
//  LM_GLSL
//
//  Category: Nature
//

let oceanWavesCode = """
float2 p = uv;

float wave1 = sin(p.x * 10.0 + iTime * 2.0 + sin(p.y * 5.0 + iTime)) * 0.02;
float wave2 = sin(p.x * 15.0 - iTime * 1.5 + sin(p.y * 8.0 - iTime * 0.5)) * 0.015;
float wave3 = sin(p.x * 20.0 + iTime * 3.0) * 0.01;

float waves = wave1 + wave2 + wave3;
float depth = p.y + waves;

float3 deepColor = float3(0.0, 0.1, 0.3);
float3 surfaceColor = float3(0.1, 0.4, 0.6);
float3 foamColor = float3(0.7, 0.9, 1.0);

float3 col = mix(deepColor, surfaceColor, depth);

float foam = smoothstep(0.48, 0.52, depth + sin(p.x * 50.0 + iTime * 5.0) * 0.02);
col = mix(col, foamColor, foam * 0.5);

float sparkle = fract(sin(dot(p * 100.0, float2(12.9898, 78.233)) + iTime * 10.0) * 43758.5453);
sparkle = pow(sparkle, 20.0) * (1.0 - p.y);
col += float3(sparkle * 0.3);

return float4(col, 1.0);
"""
