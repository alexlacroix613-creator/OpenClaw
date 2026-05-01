import SwiftUI

struct AeroBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .cyan.opacity(0.45),
                    .purple.opacity(0.28),
                    .pink.opacity(0.30),
                    .white.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.34))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: -130, y: -230)

            Circle()
                .fill(.cyan.opacity(0.25))
                .frame(width: 320, height: 320)
                .blur(radius: 44)
                .offset(x: 160, y: 260)

            PixelCharmGrid()
                .opacity(0.20)
        }
    }
}

struct PixelCharmGrid: View {
    private let columns = Array(repeating: GridItem(.fixed(22), spacing: 16), count: 9)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(0..<90, id: \.self) { index in
                Text(index % 5 == 0 ? "✧" : index % 7 == 0 ? "◆" : "·")
                    .font(.system(size: index % 5 == 0 ? 12 : 10, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
            }
        }
        .rotationEffect(.degrees(-8))
        .scaleEffect(1.3)
    }
}
