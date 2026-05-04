import SwiftUI

struct ClawRoomView: View {
    @EnvironmentObject private var runtime: PetViewModel
    @State private var clawX: Double = 0.5
    @State private var teachingText = ""
    @StateObject private var sceneHolder = SceneHolder()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                PixelHabitat(pixelScale: 4)

                VStack(spacing: 0) {
                    PetStatusPanel(state: runtime.petState)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)

                    Spacer()
                }

                VStack {
                    Spacer()
                    ZStack {
                        PixelArt(sprite: .platform, scale: 6)
                            .frame(width: 320)

                        PixelPetView(state: runtime.petState)
                            .offset(y: -52)
                            .onTapGesture { runtime.handleTapPet() }
                    }
                    .padding(.bottom, 220)
                }

                ClawMachineView(scene: sceneHolder.scene)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    PixelHud(clawX: $clawX, runtime: runtime, scene: sceneHolder.scene)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 22)
                }

                if runtime.isTeaching {
                    PixelTeachingPanel(teachingText: $teachingText, runtime: runtime)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: runtime.isTeaching)
        .onReceive(NotificationCenter.default.publisher(for: .clawGrabbedCapsule)) { event in
            guard let type = event.object as? String else { return }
            runtime.resolveCapsule(type: type)
        }
        .onReceive(NotificationCenter.default.publisher(for: .clawMissed)) { _ in
            runtime.handleClawMiss()
        }
    }
}

private final class SceneHolder: ObservableObject {
    let scene: ClawMachineScene
    init() {
        self.scene = ClawMachineScene(size: CGSize(width: 390, height: 760))
        self.scene.scaleMode = .resizeFill
    }
}

private struct PixelPetView: View {
    let state: PetState
    @State private var blinkPhase = false

    var body: some View {
        let bodyColor = PixelPalette.Pet.pink
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let bob = CGFloat(sin(t * 1.4)) * 3
            let breathing = 1.0 + sin(t * 1.0) * 0.025

            ZStack {
                let sprite: PixelSprite = state.stage == .egg
                    ? .egg
                    : (blinkPhase ? PixelSprite.petBlinking(bodyColor: bodyColor) : PixelSprite.pet(bodyColor: bodyColor))

                PixelArt(sprite: sprite, scale: 5, dropShadow: true)
                    .scaleEffect(breathing)
                    .offset(y: bob)

                if !state.visibleText.isEmpty {
                    PixelSpeechBubble(text: state.visibleText)
                        .offset(y: -64)
                }
            }
            .onChange(of: Int(t.truncatingRemainder(dividingBy: 5)) == 0) { _, isBlink in
                if isBlink && !blinkPhase {
                    blinkPhase = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { blinkPhase = false }
                }
            }
        }
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
                RoundedRectangle(cornerRadius: 1)
                    .fill(PixelPalette.Panel.accent.opacity(0.5))
                    .frame(width: 36, height: 6)
                    .overlay(RoundedRectangle(cornerRadius: 1).stroke(PixelPalette.outline, lineWidth: 1))
                RoundedRectangle(cornerRadius: 1)
                    .fill(PixelPalette.Snack.apple)
                    .frame(width: max(2, CGFloat(value) * 36), height: 6)
                    .overlay(RoundedRectangle(cornerRadius: 1).stroke(PixelPalette.outline, lineWidth: 1))
            }
        }
    }
}

private struct PixelHud: View {
    @Binding var clawX: Double
    let runtime: PetViewModel
    let scene: ClawMachineScene

    var body: some View {
        VStack(spacing: 8) {
            PixelTrack(value: $clawX) { newValue in
                scene.moveClaw(to: CGFloat(newValue))
            }

            HStack(spacing: 10) {
                PixelButton(title: "DROP", accentColor: PixelPalette.Snack.apple) {
                    scene.dropClaw()
                }
                PixelButton(title: "TEACH", accentColor: PixelPalette.Snack.berry) {
                    runtime.beginTeaching()
                }
                PixelButton(title: "FEED", accentColor: PixelPalette.Snack.honey) {
                    runtime.resolveCapsule(type: "food")
                }
            }
        }
    }
}

private struct PixelButton: View {
    let title: String
    let accentColor: Color
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(PixelPalette.outline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accentColor.opacity(0.85))
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

private struct PixelTrack: View {
    @Binding var value: Double
    let onChange: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(PixelPalette.Panel.fill)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(PixelPalette.outline, lineWidth: 2))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 1)
                    .fill(PixelPalette.outline)
                    .frame(width: 14, height: 22)
                    .offset(x: max(0, min(geo.size.width - 14, CGFloat(value) * (geo.size.width - 14))), y: -4)
            }
            .frame(height: 22)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let normalized = max(0, min(1, Double(drag.location.x / geo.size.width)))
                        value = normalized
                        onChange(normalized)
                    }
            )
        }
        .frame(height: 22)
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

                    Button("TEACH") {
                        let text = teachingText
                        teachingText = ""
                        Task { await runtime.teach(text: text) }
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(PixelPalette.outline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(PixelPalette.Snack.honey.opacity(0.85))
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
    }
}
