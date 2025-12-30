//
//  Sunset.metal
//  LM_GLSL
//
//  Category: Gradient
//

let sunsetCode = """
float t = uv.y;
float3 sky = mix(float3(1.0, 0.5, 0.2), float3(0.3, 0.1, 0.5), t);
float sun = smoothstep(0.3, 0.25, length(uv - float2(0.5, 0.3)));
sky = mix(sky, float3(1.0, 0.9, 0.3), sun);
float clouds = sin(uv.x * 10.0 + iTime) * sin(uv.y * 5.0) * 0.1;
sky += clouds * float3(0.5);
return float4(sky, 1.0);
"""
