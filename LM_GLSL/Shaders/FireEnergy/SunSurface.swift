//
//  SunSurface.metal
//  LM_GLSL
//
//  Category: FireEnergy
//

let sunSurfaceCode = """
float2 p = uv * 2.0 - 1.0;
float r = length(p);
float3 col = float3(0.0);
float sun = smoothstep(0.8, 0.7, r);
float n = sin(p.x * 20.0 + iTime * 2.0) * sin(p.y * 20.0 + iTime * 1.5) * 0.1;
col += float3(1.0, 0.8, 0.2) * sun * (0.8 + n);
col += float3(1.0, 0.5, 0.1) * smoothstep(0.5, 0.0, r);
col += float3(1.0, 0.3, 0.0) * exp(-r * 2.0) * (1.0 - sun);
return float4(col, 1.0);
"""
