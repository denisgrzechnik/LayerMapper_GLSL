//
//  CrtTV.metal
//  LM_GLSL
//
//  Category: Retro
//

let crtTVCode = """
float2 p = uv;

// Curvature
float2 curved = p * 2.0 - 1.0;
curved *= 1.0 + pow(length(curved), 2.0) * 0.1;
curved = curved * 0.5 + 0.5;

// Scanlines
float scanline = sin(curved.y * 400.0) * 0.1;

// RGB offset
float3 col;
col.r = sin(curved.x * 10.0 + iTime) * 0.5 + 0.5;
col.g = sin(curved.x * 10.0 + iTime + 2.0) * 0.5 + 0.5;
col.b = sin(curved.x * 10.0 + iTime + 4.0) * 0.5 + 0.5;

col -= scanline;

// Vignette
float vignette = 1.0 - pow(length(p - 0.5) * 1.5, 2.0);
col *= vignette;

// Flicker
col *= 0.95 + 0.05 * sin(iTime * 60.0);

return float4(col, 1.0);
"""
