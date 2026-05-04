import SwiftUI

struct PixelHabitat: View {
    var pixelScale: CGFloat = 4

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PixelPalette.Sky.top, PixelPalette.Sky.bot],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    DriftingCloud(sprite: .cloudWide, scale: pixelScale, baseY: geo.size.height * 0.10, amplitude: 12, period: 24, hue: 1.0)
                        .position(x: geo.size.width * 0.32, y: geo.size.height * 0.10)
                    DriftingCloud(sprite: .cloudSmall, scale: pixelScale, baseY: geo.size.height * 0.18, amplitude: 8, period: 18, hue: 0.92)
                        .position(x: geo.size.width * 0.78, y: geo.size.height * 0.18)
                    DriftingCloud(sprite: .cloudSmall, scale: pixelScale * 0.75, baseY: geo.size.height * 0.34, amplitude: 6, period: 30, hue: 0.85)
                        .position(x: geo.size.width * 0.16, y: geo.size.height * 0.34)

                    PixelArt(sprite: .tree, scale: pixelScale * 0.85, dropShadow: true)
                        .position(x: geo.size.width * 0.18, y: geo.size.height * 0.62)

                    PixelArt(sprite: .tree, scale: pixelScale * 0.65, dropShadow: true)
                        .position(x: geo.size.width * 0.86, y: geo.size.height * 0.58)
                }
            }
        }
    }
}

private struct DriftingCloud: View {
    let sprite: PixelSprite
    let scale: CGFloat
    let baseY: CGFloat
    let amplitude: CGFloat
    let period: Double
    let hue: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let dx = CGFloat(sin(t / period * 2 * .pi)) * amplitude
            PixelArt(sprite: sprite, scale: scale, dropShadow: false)
                .opacity(hue)
                .offset(x: dx)
        }
    }
}
