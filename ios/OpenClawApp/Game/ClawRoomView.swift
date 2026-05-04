import SwiftUI

struct ClawRoomView: View {
    @EnvironmentObject private var runtime: PetViewModel
    @State private var teachingText = ""

    var body: some View {
        GeometryReader { geo in
            let petAnchor = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.66)

            ZStack {
                PixelHabitat(pixelScale: 4)

                ClawWorldView(runtime: runtime, petAnchor: petAnchor)
                    .frame(width: geo.size.width, height: geo.size.height)

                ZStack {
                    PixelArt(sprite: .platform, scale: 6)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.78)

                    PixelPetView(
                        state: runtime.petState,
                        hatchFlashUntil: runtime.hatchFlashUntil,
                        tapPulseToken: runtime.tapPulseToken,
                        eatSparkleUntil: runtime.eatSparkleUntil
                    )
                    .position(x: petAnchor.x, y: petAnchor.y)
                    .onTapGesture { runtime.handleTapPet() }
                }

                VStack(spacing: 0) {
                    PetStatusPanel(state: runtime.petState)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                    Spacer()
                }

                VStack {
                    Spacer()
                    TeachButton {
                        runtime.beginTeaching()
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }

                if let until = runtime.eatSparkleUntil {
                    EatSparkle(anchor: petAnchor, endTime: until)
                }

                if !runtime.petState.visibleText.isEmpty {
                    PixelSpeechBubble(text: runtime.petState.visibleText)
                        .position(x: petAnchor.x, y: petAnchor.y - 70)
                        .transition(.opacity)
                }

                if !runtime.hasOnboarded && runtime.petState.stage == .egg {
                    HintPanel(
                        text: "tap the egg",
                        anchor: CGPoint(x: petAnchor.x, y: petAnchor.y - 30),
                        glowAnchor: petAnchor
                    )
                    .transition(.opacity)
                }

                if runtime.hasOnboarded
                    && !runtime.firstFeedDone
                    && runtime.petState.stage != .egg {
                    HintPanel(
                        text: "tap a snack to feed",
                        anchor: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.50),
                        glowAnchor: nil
                    )
                    .transition(.opacity)
                }

                if runtime.isTeaching {
                    PixelTeachingPanel(teachingText: $teachingText, runtime: runtime)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: runtime.isTeaching)
        .animation(.easeInOut(duration: 0.20), value: runtime.petState.visibleText)
        .animation(.easeInOut(duration: 0.30), value: runtime.hasOnboarded)
        .animation(.easeInOut(duration: 0.30), value: runtime.firstFeedDone)
    }
}

private struct EatSparkle: View {
    let anchor: CGPoint
    let endTime: Date
    private let totalDuration: Double = 0.6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let now = timeline.date
            let remaining = endTime.timeIntervalSince(now)
            let progress = max(0, min(1, 1 - (remaining / totalDuration)))
            let alive = remaining > 0

            ZStack {
                if alive {
                    ForEach(0..<6, id: \.self) { i in
                        let angle = Double(i) * (.pi * 2 / 6) + .pi / 6
                        let distance = CGFloat(progress) * 38
                        let dx = CGFloat(cos(angle)) * distance
                        let dy = CGFloat(sin(angle)) * distance - 24
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .overlay(Rectangle().stroke(PixelPalette.outline, lineWidth: 1))
                            .position(x: anchor.x + dx, y: anchor.y + dy)
                            .opacity(1 - progress)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct HintPanel: View {
    let text: String
    let anchor: CGPoint
    let glowAnchor: CGPoint?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let glow = (sin(t * 1.6) + 1) / 2
            ZStack {
                if let glowAnchor {
                    Circle()
                        .fill(PixelPalette.Cloud.fill)
                        .frame(width: 96 + glow * 24, height: 96 + glow * 24)
                        .blur(radius: 8)
                        .opacity(0.45 + glow * 0.20)
                        .position(x: glowAnchor.x, y: glowAnchor.y)
                        .allowsHitTesting(false)
                }

                Text(text)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(PixelPalette.outline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PixelPalette.Panel.fill)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(PixelPalette.outline, lineWidth: 2))
                    )
                    .shadow(color: PixelPalette.outlineSoft, radius: 0, x: 2, y: 2)
                    .position(x: anchor.x, y: anchor.y - 80)
                    .opacity(0.85 + glow * 0.15)
                    .allowsHitTesting(false)
            }
        }
    }
}

private struct PixelPetView: View {
    let state: PetState
    let hatchFlashUntil: Date?
    let tapPulseToken: Int
    let eatSparkleUntil: Date?

    @State private var blinkVisible = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        let bodyColor = PixelPalette.Pet.pink
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let now = timeline.date
            let t = now.timeIntervalSinceReferenceDate
            let bob = CGFloat(sin(t * 1.4)) * 3
            let breathing = 1.0 + sin(t * 1.0) * 0.025

            let isEating = eatSparkleUntil.map { now < $0 } ?? false
            let sprite: PixelSprite = {
                if state.stage == .egg { return .egg }
                if isEating { return PixelSprite.petHappy(bodyColor: bodyColor) }
                if blinkVisible { return PixelSprite.petBlinking(bodyColor: bodyColor) }
                return PixelSprite.pet(bodyColor: bodyColor)
            }()

            let flashing = hatchFlashUntil.map { now < $0 } ?? false
            let flashAlpha: Double = flashing ? 0.85 : 0

            ZStack {
                PixelArt(sprite: sprite, scale: 5, dropShadow: true)
                    .scaleEffect(breathing * pulseScale)
                    .offset(y: bob)

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .blendMode(.plusLighter)
                    .opacity(flashAlpha)
                    .allowsHitTesting(false)
            }
            .onChange(of: blinkTriggerKey(for: t)) { _, _ in
                blinkVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                    blinkVisible = false
                }
            }
            .onChange(of: tapPulseToken) { _, _ in
                withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
                    pulseScale = 1.10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                        pulseScale = 1.0
                    }
                }
            }
        }
    }

    private func blinkTriggerKey(for time: TimeInterval) -> Int {
        Int(time / 4.0)
    }
}

private struct PixelSpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .black, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(PixelPalette.outline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(PixelPalette.Panel.fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(PixelPalette.outline, lineWidth: 2)
                    )
            )
            .shadow(color: PixelPalette.outlineSoft, radius: 0, x: 2, y: 2)
    }
}

struct PetStatusPanel: View {
    let state: PetState

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(state.name ?? "no name yet")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(PixelPalette.outline)
                Text(state.stage.rawValue.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(PixelPalette.outline.opacity(0.65))
            }
            Spacer()
            PixelStatPill(label: "BOND", value: state.bond)
            PixelStatPill(label: "MOOD", value: state.mood)
            PixelStatPill(label: "FULL", value: 1.0 - state.hunger)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(PixelPalette.Panel.fill)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(PixelPalette.outline, lineWidth: 2))
        )
        .shadow(color: PixelPalette.outlineSoft, radius: 0, x: 2, y: 2)
    }
}

struct PixelStatPill: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(PixelPalette.outline)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(PixelPalette.Panel.accent.opacity(0.5))
                    .frame(width: 36, height: 6)
                    .overlay(Rectangle().stroke(PixelPalette.outline, lineWidth: 1))
                Rectangle()
                    .fill(PixelPalette.Snack.apple)
                    .frame(width: max(2, CGFloat(value) * 36), height: 6)
                    .overlay(Rectangle().stroke(PixelPalette.outline, lineWidth: 1))
            }
        }
    }
}

private struct TeachButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("TEACH")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(PixelPalette.outline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(PixelPalette.Snack.honey.opacity(0.92))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(PixelPalette.outline, lineWidth: 2))
                )
        }
        .buttonStyle(PixelPressStyle())
    }
}

private struct PixelPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
            .shadow(color: configuration.isPressed ? .clear : PixelPalette.outlineSoft, radius: 0, x: 2, y: 2)
    }
}

private struct PixelTeachingPanel: View {
    @Binding var teachingText: String
    let runtime: PetViewModel

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            VStack(spacing: 10) {
                Text("TEACH IT A SOUND")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(PixelPalette.outline)

                HStack(spacing: 8) {
                    TextField("say or type a sound", text: $teachingText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(PixelPalette.Panel.fill)
                                .overlay(RoundedRectangle(cornerRadius: 2).stroke(PixelPalette.outline, lineWidth: 2))
                        )
                        .font(.system(size: 14, weight: .black, design: .rounded))

                    Button("OK") {
                        let text = teachingText
                        teachingText = ""
                        Task { await runtime.teach(text: text) }
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(PixelPalette.outline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(PixelPalette.Snack.honey.opacity(0.9))
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(PixelPalette.outline, lineWidth: 2))
                    )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(PixelPalette.Panel.fill)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(PixelPalette.outline, lineWidth: 2))
            )
            .shadow(color: PixelPalette.outlineSoft, radius: 0, x: 2, y: 2)
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(Color.black.opacity(0.18).ignoresSafeArea())
        .onTapGesture {
            runtime.cancelTeaching()
        }
    }
}
