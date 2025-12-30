//
//  PenroseTiles.metal
//  LM_GLSL
//
//  Category: Geometric
//

let penroseTilesCode = """
float2 p = uv * 10.0;
float3 col = float3(0.1);
float2 id = floor(p);
float2 f = fract(p) - 0.5;
float checker = mod(id.x + id.y, 2.0);
float d = length(f);
if (checker > 0.5) {
    col = float3(0.8, 0.6, 0.2) * smoothstep(0.4, 0.35, d);
} else {
    col = float3(0.2, 0.4, 0.8) * smoothstep(0.4, 0.35, d);
}
col += 0.2 * sin(iTime + id.x * 0.5 + id.y * 0.3);
return float4(col, 1.0);
"""
