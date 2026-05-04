import SwiftUI

struct ClawWorldView: View {
    @ObservedObject var runtime: PetViewModel
    var petAnchor: CGPoint
    @State private var snacks: [Snack] = Snack.starter()
    @State private var clawState: ClawState = .idle(x: 0.5)
    @State private var heldSnack: Snack.Kind? = nil
    @State private var nextRespawnId: Int = 1000

    var body: some View {
        GeometryReader { geo in
            let snackArea = SnackArea(
                left: 30,
                right: geo.size.width - 30,
                top: geo.size.height * 0.18,
                bottom: geo.size.height * 0.42
            )

            ZStack(alignment: .topLeading) {
                ForEach(snacks) { snack in
                    SnackSpriteView(snack: snack, area: snackArea)
                        .onTapGesture { handleTap(snack: snack, area: snackArea) }
                        .opacity(snackVisible(snack) ? 1 : 0)
                        .allowsHitTesting(snackTappable(snack))
                }

                ClawSpriteView(
                    state: clawState,
                    heldSnack: heldSnack,
                    width: geo.size.width
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func snackVisible(_ snack: Snack) -> Bool {
        switch clawState {
        case .grabbing(let id, _),
             .returning(let id, _, _),
             .delivering(let id, _):
            return id != snack.id
        default:
            return true
        }
    }

    private func snackTappable(_ snack: Snack) -> Bool {
        if case .idle = clawState { return true }
        return false
    }

    private func handleTap(snack: Snack, area: SnackArea) {
        guard case .idle = clawState else { return }
        let target = snack.position(in: area, time: Date().timeIntervalSinceReferenceDate)
        clawState = .descending(targetId: snack.id, target: target)
        runScript(snack: snack, target: target, area: area)
    }

    private func runScript(snack: Snack, target: CGPoint, area: SnackArea) {
        let descend: Double = 0.55
        let grab: Double = 0.20
        let ret: Double = 0.50
        let deliver: Double = 0.45

        DispatchQueue.main.asyncAfter(deadline: .now() + descend) {
            heldSnack = snack.type
            clawState = .grabbing(targetId: snack.id, point: target)
            DispatchQueue.main.asyncAfter(deadline: .now() + grab) {
                let topPoint = CGPoint(x: target.x, y: 130)
                clawState = .returning(targetId: snack.id, fromPoint: target, toPoint: topPoint)
                DispatchQueue.main.asyncAfter(deadline: .now() + ret) {
                    clawState = .delivering(targetId: snack.id, toPet: petAnchor)
                    DispatchQueue.main.asyncAfter(deadline: .now() + deliver) {
                        runtime.resolveCapsule(type: snack.type.reward)
                        snacks.removeAll { $0.id == snack.id }
                        snacks.append(Snack.spawnReplacement(id: nextRespawnId, type: snack.type))
                        nextRespawnId += 1
                        heldSnack = nil
                        clawState = .idle(x: target.x / max(area.right, 1))
                    }
                }
            }
        }
    }
}

struct SnackArea {
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat

    var width: CGFloat { right - left }
    var height: CGFloat { bottom - top }
}

struct Snack: Identifiable, Equatable {
    enum Kind: String, CaseIterable {
        case apple, honey, leaf, berry, shell, mystery

        var sprite: PixelSprite {
            switch self {
            case .apple:   return .snackApple
            case .honey:   return .snackHoney
            case .leaf:    return .snackLeaf
            case .berry:   return .snackBerry
            case .shell:   return .snackShell
            case .mystery: return .snackMystery
            }
        }

        var reward: String {
            switch self {
            case .apple, .honey, .shell: return "food"
            case .leaf:                  return "toy"
            case .berry:                 return "outfit"
            case .mystery:               return "memory"
            }
        }
    }

    let id: Int
    let type: Kind
    let normalizedX: CGFloat
    let normalizedY: CGFloat
    let bobPhase: Double

    func position(in area: SnackArea, time: TimeInterval) -> CGPoint {
        let x = area.left + normalizedX * area.width
        let bob = sin(time * 0.9 + bobPhase) * 6
        let y = area.top + normalizedY * area.height + bob
        return CGPoint(x: x, y: y)
    }

    static func starter() -> [Snack] {
        let types: [Kind] = [.apple, .honey, .leaf, .berry, .shell, .mystery]
        let positions: [(CGFloat, CGFloat)] = [
            (0.10, 0.15), (0.32, 0.55), (0.55, 0.20),
            (0.78, 0.60), (0.20, 0.85), (0.70, 0.92)
        ]
        return zip(types, positions).enumerated().map { index, pair in
            Snack(
                id: index,
                type: pair.0,
                normalizedX: pair.1.0,
                normalizedY: pair.1.1,
                bobPhase: Double(index) * 1.1
            )
        }
    }

    static func spawnReplacement(id: Int, type: Kind) -> Snack {
        Snack(
            id: id,
            type: type,
            normalizedX: CGFloat.random(in: 0.10...0.90),
            normalizedY: CGFloat.random(in: 0.10...0.90),
            bobPhase: Double.random(in: 0...6.28)
        )
    }
}

enum ClawState: Equatable {
    case idle(x: CGFloat)
    case descending(targetId: Int, target: CGPoint)
    case grabbing(targetId: Int, point: CGPoint)
    case returning(targetId: Int, fromPoint: CGPoint, toPoint: CGPoint)
    case delivering(targetId: Int, toPet: CGPoint)
}

private struct SnackSpriteView: View {
    let snack: Snack
    let area: SnackArea

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let pos = snack.position(in: area, time: timeline.date.timeIntervalSinceReferenceDate)
            PixelArt(sprite: snack.type.sprite, scale: 4, dropShadow: true)
                .position(x: pos.x, y: pos.y)
        }
    }
}

private struct ClawSpriteView: View {
    let state: ClawState
    let heldSnack: Snack.Kind?
    let width: CGFloat

    var body: some View {
        let parkY: CGFloat = 130
        let topY: CGFloat = 70

        let clawPoint: CGPoint = {
            switch state {
            case .idle(let x):
                return CGPoint(x: x * width, y: parkY)
            case .descending(_, let target):
                return target
            case .grabbing(_, let point):
                return point
            case .returning(_, _, let to):
                return to
            case .delivering(_, let toPet):
                return CGPoint(x: toPet.x, y: toPet.y - 80)
            }
        }()

        let anim: Animation? = {
            switch state {
            case .idle:        return .easeInOut(duration: 0.20)
            case .descending:  return .linear(duration: 0.55)
            case .grabbing:    return nil
            case .returning:   return .linear(duration: 0.50)
            case .delivering:  return .easeIn(duration: 0.45)
            }
        }()

        let isClosed: Bool = {
            switch state {
            case .grabbing, .returning, .delivering: return true
            default: return false
            }
        }()
        let clawSprite: PixelSprite = isClosed ? .clawClosed : .claw

        let punchScale: CGFloat = {
            if case .grabbing = state { return 1.18 }
            return 1.0
        }()

        ZStack {
            ClawCableShape(topY: topY, clawY: clawPoint.y, x: clawPoint.x)
                .stroke(PixelPalette.outline, style: StrokeStyle(lineWidth: 2, lineCap: .square, dash: [4, 2]))
                .animation(anim, value: clawPoint)

            PixelArt(sprite: clawSprite, scale: 4, dropShadow: true)
                .scaleEffect(punchScale)
                .animation(.spring(response: 0.18, dampingFraction: 0.55), value: punchScale)
                .position(x: clawPoint.x, y: clawPoint.y)
                .animation(anim, value: clawPoint)

            if let kind = heldSnack {
                PixelArt(sprite: kind.sprite, scale: 4, dropShadow: false)
                    .position(x: clawPoint.x, y: clawPoint.y + 28)
                    .animation(anim, value: clawPoint)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ClawCableShape: Shape {
    var topY: CGFloat
    var clawY: CGFloat
    var x: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(x, clawY) }
        set { x = newValue.first; clawY = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x, y: topY))
        path.addLine(to: CGPoint(x: x, y: max(clawY - 12, topY)))
        return path
    }
}

extension PixelSprite {
    static let claw: PixelSprite = {
        let rows = [
            "ooooooooooo",
            "oWWWWWWWWWo",
            "oWWWoooWWWo",
            "oWWoWWWoWWo",
            "oWoWWWWWoWo",
            "oWoooooooWo",
            "ooo.....ooo",
            "..oo...oo..",
            "...o...o..."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "W": .white
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let clawClosed: PixelSprite = {
        let rows = [
            "ooooooooooo",
            "oWWWWWWWWWo",
            "oWWWoooWWWo",
            "oWWoWWWoWWo",
            "oWoWWWWWoWo",
            "oWoooooooWo",
            "ooooooooooo",
            "..ooooooo..",
            "....ooo...."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "W": .white
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()
}
