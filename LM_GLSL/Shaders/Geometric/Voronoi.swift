//
//  Voronoi.metal
//  LM_GLSL
//
//  Category: Geometric
//

let voronoiCode = """
float2 p = uv * 5.0;

float minDist = 1.0;
float3 cellColor = float3(0.0);

for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
        float2 neighbor = float2(float(x), float(y));
        float2 cell = floor(p) + neighbor;
        
        float2 r = fract(sin(float2(dot(cell, float2(127.1, 311.7)), 
                                     dot(cell, float2(269.5, 183.3)))) * 43758.5453);
        r = 0.5 + 0.5 * sin(iTime + 6.2831 * r);
        
        float2 diff = neighbor + r - fract(p);
        float d = length(diff);
        
        if (d < minDist) {
            minDist = d;
            cellColor = 0.5 + 0.5 * sin(float3(0.0, 2.0, 4.0) + cell.x + cell.y + iTime);
        }
    }
}

float3 col = cellColor * (1.0 - minDist);
col += float3(1.0) * smoothstep(0.05, 0.0, minDist - 0.02);

return float4(col, 1.0);
"""
