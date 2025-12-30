//
//  DreamWeaver.metal
//  LM_GLSL
//
//  Category: Psychedelic
//

let dreamWeaverCode = """
float2 p = uv * 4.0 - 2.0;
float3 col = float3(0.0);
for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float2 q = p;
    q.x += sin(q.y * 2.0 + iTime + fi) * 0.5;
    q.y += cos(q.x * 2.0 + iTime * 0.7 + fi) * 0.5;
    float d = sin(length(q) * 3.0 + iTime) * 0.5 + 0.5;
    col += (0.5 + 0.5 * sin(float3(0.3, 0.5, 0.7) + fi + iTime)) * d * 0.3;
}
return float4(col, 1.0);
"""
