import SwiftUI

struct ClawRoomView: View {
    @EnvironmentObject private var runtime: PetViewModel
    @State private var clawX: Double = 0.5
    @State private var teachingText = ""
    private let scene = ClawMachineScene(size: CGSize(width: 390, height: 620))

    var body: some View {
        ZStack {
            AeroBackdrop()

            VStack(spacing: 14) {
                PetStatusBar(state: runtime.petState)

                ZStack {
                    RoundedRectangle(cornerRadius: 36)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 36).stroke(.white.opacity(0.38), lineWidth: 1))
                        .shadow(radius: 18)

                    VStack(spacing: 10) {
                        PetAvatarView(state: runtime.petState)
                            .onTapGesture { runtime.handleTapPet() }
                            .padding(.top, 18)

                        ClawMachineView(scene: scene)
                            .frame(height: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 12)

                        clawControls
                    }
                }

                if runtime.isTeaching {
                    teachingPanel
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: runtime.isTeaching)
        .onReceive(NotificationCenter.default.publisher(for: .clawGrabbedCapsule)) { event in
            guard let type = event.object as? String else { return }
            runtime.resolveCapsule(type: type)
        }
        .onReceive(NotificationCenter.default.publisher(for: .clawMissed)) { _ in
            runtime.handleClawMiss()
        }
    }

    private var clawControls: some View {
        HStack(spacing: 14) {
            Slider(value: $clawX, in: 0...1)
                .onChange(of: clawX) { _, newValue in
                    scene.moveClaw(to: CGFloat(newValue))
                }

            Button("DROP") {
                scene.dropClaw()
            }
            .buttonStyle(GlossyCapsuleButtonStyle())
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }

    private var teachingPanel: some View {
        VStack(spacing: 10) {
            Text("Teach it a sound")
                .font(.system(size: 18, weight: .black, design: .rounded))

            HStack {
                TextField("say or type the sound", text: $teachingText)
                    .textFieldStyle(.roundedBorder)

                Button("TEACH") {
                    let text = teachingText
                    teachingText = ""
                    Task { await runtime.teach(text: text) }
                }
                .buttonStyle(GlossyCapsuleButtonStyle())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

struct PetStatusBar: View {
    let state: PetState

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(state.name ?? "Unnamed")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Text(state.stage.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .opacity(0.7)
            }

            Spacer()
            StatPill(label: "bond", value: state.bond)
            StatPill(label: "mood", value: state.mood)
            StatPill(label: "hungry", value: state.hunger)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

struct StatPill: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
            ProgressView(value: value)
                .frame(width: 42)
        }
    }
}

struct PetAvatarView: View {
    let state: PetState

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.24))
                    .frame(width: 122, height: 122)
                    .blur(radius: 6)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 112, height: 112)
                    .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 2))

                HStack(spacing: 20) {
                    Circle().frame(width: 12, height: 16)
                    Circle().frame(width: 12, height: 16)
                }
                .offset(y: -4)
            }
            .scaleEffect(state.currentAnimation.contains("bounce") ? 1.05 : 1.0)

            Text(state.visibleText)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .frame(height: 28)
        }
    }
}

struct GlossyCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .black, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.white.opacity(configuration.isPressed ? 0.8 : 0.45), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
