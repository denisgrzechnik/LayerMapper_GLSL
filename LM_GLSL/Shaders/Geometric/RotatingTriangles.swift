//
//  RotatingTriangles.metal
//  LM_GLSL
//
//  Category: Geometric
//

let rotatingTrianglesCode = """
float2 p = uv * 2.0 - 1.0;
float a = iTime;
float c = cos(a); float s = sin(a);
p = float2(p.x * c - p.y * s, p.x * s + p.y * c);
float3 col = float3(0.0);
float tri = max(abs(p.x) * 0.866 + p.y * 0.5, -p.y) - 0.5;
col += float3(1.0, 0.5, 0.2) * smoothstep(0.02, 0.0, abs(tri));
p = -p;
tri = max(abs(p.x) * 0.866 + p.y * 0.5, -p.y) - 0.3;
col += float3(0.2, 0.5, 1.0) * smoothstep(0.02, 0.0, abs(tri));
return float4(col, 1.0);
"""
