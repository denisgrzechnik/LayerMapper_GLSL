//
//  ShaderCodes_Parametric.swift
//  LM_GLSL
//
//  Shaders with adjustable parameters for real-time control
//

import Foundation

// MARK: - Parametric Shader Codes

/// Pulsing Circle - kontrolowany rozmiar i prędkość pulsowania
let pulsingCircleParamCode = """
float2 center = float2(0.5, 0.5);
float dist = length(uv - center);
float pulse = sin(iTime * speed) * 0.5 + 0.5;
float circle = smoothstep(radius + pulse * 0.1, radius - 0.01 + pulse * 0.1, dist);
float glow = exp(-dist * glowIntensity);
float3 col = mix(float3(0.0), float3(0.2, 0.6, 1.0), circle + glow * 0.3);
return float4(col, 1.0);
"""

/// Color Waves - kontrolowane kolory i częstotliwość fal
let colorWavesParamCode = """
float wave1 = sin(uv.x * frequency + iTime * speed) * 0.5 + 0.5;
float wave2 = sin(uv.y * frequency * 0.8 + iTime * speed * 1.2) * 0.5 + 0.5;
float wave3 = sin((uv.x + uv.y) * frequency * 0.6 + iTime * speed * 0.8) * 0.5 + 0.5;
float3 col = float3(wave1 * redAmount, wave2 * greenAmount, wave3 * blueAmount);
return float4(col, 1.0);
"""

/// Zoom Tunnel - kontrolowana prędkość i głębokość
let zoomTunnelParamCode = """
float2 p = uv - 0.5;
float angle = atan2(p.y, p.x);
float dist = length(p);
float tunnel = fmod(1.0 / (dist + 0.001) - iTime * zoomSpeed, depth);
float rings = sin(tunnel * ringCount) * 0.5 + 0.5;
float3 col = mix(
    float3(0.1, 0.0, 0.2),
    float3(0.0, 0.8, 1.0),
    rings
);
col *= smoothstep(0.0, 0.1, dist);
return float4(col, 1.0);
"""

/// Morphing Blob - kontrolowany kształt i płynność
let morphingBlobParamCode = """
float2 p = (uv - 0.5) * 2.0;
float angle = atan2(p.y, p.x);
float dist = length(p);
float morph = sin(angle * blobCount + iTime * morphSpeed) * blobSize;
float blob = smoothstep(0.5 + morph, 0.48 + morph, dist);
float3 col = mix(
    float3(0.1, 0.1, 0.2),
    float3(1.0, 0.3, 0.5),
    blob
);
return float4(col, 1.0);
"""

/// Grid Pattern - kontrolowana siatka
let gridPatternParamCode = """
float2 grid = fmod(uv * gridSize, 1.0);
float line = step(lineWidth, grid.x) * step(lineWidth, grid.y);
float pulse = sin(iTime * pulseSpeed) * 0.3 + 0.7;
float3 gridColor = float3(0.0, brightness * pulse, brightness * pulse);
float3 bgColor = float3(0.02, 0.02, 0.05);
float3 col = mix(gridColor, bgColor, line);
return float4(col, 1.0);
"""

/// Plasma Effect - kontrolowane kolory i prędkość
let plasmaParamCode = """
float v1 = sin(uv.x * scale + iTime * speed);
float v2 = sin(uv.y * scale + iTime * speed);
float v3 = sin((uv.x + uv.y) * scale + iTime * speed);
float v4 = sin(length(uv - 0.5) * scale * 2.0 + iTime * speed);
float v = (v1 + v2 + v3 + v4) / 4.0;
float3 col = float3(
    sin(v * 3.14159 * colorShift) * 0.5 + 0.5,
    sin(v * 3.14159 * colorShift + 2.094) * 0.5 + 0.5,
    sin(v * 3.14159 * colorShift + 4.188) * 0.5 + 0.5
);
return float4(col * intensity, 1.0);
"""

/// Rotating Rings - kontrolowane pierścienie
let rotatingRingsParamCode = """
float2 p = uv - 0.5;
float angle = atan2(p.y, p.x) + iTime * rotationSpeed;
float dist = length(p);
float rings = sin(dist * ringCount - iTime * expandSpeed) * 0.5 + 0.5;
float spiral = sin(angle * spiralArms + dist * 10.0) * 0.5 + 0.5;
float3 col = mix(
    float3(0.1, 0.0, 0.3),
    float3(0.0, 1.0, 0.8),
    rings * spiral
);
return float4(col, 1.0);
"""

/// XY Pad Demo - kontrolowany przez XY pad
let xyPadDemoCode = """
float2 center = float2(padX, padY);
float dist = length(uv - center);
float circle = smoothstep(0.15, 0.14, dist);
float glow = exp(-dist * 5.0) * 0.5;
float trail = 0.0;
for (int i = 0; i < 5; i++) {
    float t = float(i) * 0.1;
    float2 trailPos = center + float2(sin(iTime + t), cos(iTime + t)) * 0.1;
    trail += exp(-length(uv - trailPos) * 10.0) * 0.2;
}
float3 col = float3(0.2, 0.6, 1.0) * (circle + glow + trail);
return float4(col, 1.0);
"""
