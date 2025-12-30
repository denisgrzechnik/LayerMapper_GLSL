//
//  MorphingShapes.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let morphingShapesCode = """
float2 p = uv * 2.0 - 1.0;
float t = iTime;
float shape = sin(t) * 0.5 + 0.5;
float circle = length(p);
float square = max(abs(p.x), abs(p.y));
float d = mix(circle, square, shape);
float3 col = smoothstep(0.5, 0.45, d) * (0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + t));
return float4(col, 1.0);
"""
