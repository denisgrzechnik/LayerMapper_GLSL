//
//  SynthwaveGrid.metal
//  LM_GLSL
//
//  Category: Retro
//

let synthwaveGridCode = """
float2 p = uv;
p.y = 1.0 - p.y;

// Perspective grid
float horizon = 0.4;
float3 col = float3(0.0);

if (p.y < horizon) {
    // Sky gradient
    float3 skyTop = float3(0.0, 0.0, 0.2);
    float3 skyBottom = float3(0.5, 0.0, 0.5);
    col = mix(skyBottom, skyTop, p.y / horizon);
    
    // Sun
    float2 sunPos = float2(0.5, horizon - 0.1);
    float sunDist = length(p - sunPos);
    float sun = smoothstep(0.15, 0.0, sunDist);
    col += float3(1.0, 0.5, 0.2) * sun;
} else {
    // Grid
    float depth = (p.y - horizon) * 5.0;
    float2 grid = p;
    grid.y = 1.0 / (p.y - horizon + 0.01);
    grid.x = (p.x - 0.5) * grid.y;
    grid.y -= iTime * 2.0;
    
    float lineX = smoothstep(0.05, 0.0, abs(fract(grid.x) - 0.5));
    float lineY = smoothstep(0.05, 0.0, abs(fract(grid.y * 0.5) - 0.5));
    float lines = max(lineX, lineY);
    
    col = float3(1.0, 0.0, 0.5) * lines * (1.0 - depth * 0.15);
    col += float3(0.1, 0.0, 0.2);
}

return float4(col, 1.0);
"""
