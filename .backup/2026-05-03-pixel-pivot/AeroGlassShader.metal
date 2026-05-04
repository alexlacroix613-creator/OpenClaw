#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]]
half4 aeroGlass(float2 position, SwiftUI::Layer layer, float time, float2 size) {
    float2 uv = position / size;
    float waveX = sin((uv.y * 18.0) + time * 1.7) * 0.006;
    float waveY = cos((uv.x * 14.0) + time * 1.3) * 0.006;
    float2 warped = position + float2(waveX, waveY) * size;
    half4 base = layer.sample(warped);
    float highlight = smoothstep(0.92, 0.15, distance(uv, float2(0.28, 0.18)));
    half3 gloss = half3(0.25h, 0.45h, 0.55h) * half(highlight);
    float scan = sin((uv.y + time * 0.15) * 220.0) * 0.018;
    return half4(base.rgb + gloss + half3(scan), base.a);
}
