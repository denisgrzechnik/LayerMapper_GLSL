//
//  Glitch.metal
//  LM_GLSL
//
//  Category: Retro
//

let glitchCode = """
float2 p = uv;

// Random block glitch
float blockY = floor(p.y * 20.0);
float glitchTime = floor(iTime * 10.0);
float rand = fract(sin(blockY * 123.456 + glitchTime) * 43758.5453);

float2 offset = float2(0.0);
if (rand > 0.9) {
    offset.x = (fract(sin(glitchTime * 789.123) * 43758.5453) - 0.5) * 0.1;
}

float2 uv2 = p + offset;

// RGB split
float3 col;
col.r = sin((uv2.x + 0.01) * 20.0 + iTime * 2.0) * 0.5 + 0.5;
col.g = sin(uv2.x * 20.0 + iTime * 2.0) * 0.5 + 0.5;
col.b = sin((uv2.x - 0.01) * 20.0 + iTime * 2.0) * 0.5 + 0.5;

// Noise bands
float noise = fract(sin(dot(floor(p * 100.0), float2(12.9898, 78.233)) + iTime) * 43758.5453);
if (rand > 0.95) col = float3(noise);

return float4(col, 1.0);
"""
