import SpriteKit

final class ClawMachineScene: SKScene, SKPhysicsContactDelegate {
    private let claw = SKShapeNode()
    private let cable = SKShapeNode()
    private var isDropping = false
    private var capsulesSpawned = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -5.2)
        physicsWorld.contactDelegate = self
        setupBounds()
        setupClaw()
        if !capsulesSpawned {
            spawnCapsules()
            capsulesSpawned = true
        }
    }

    private func setupBounds() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
    }

    private func setupClaw() {
        claw.path = CGPath(roundedRect: CGRect(x: -34, y: -18, width: 68, height: 36), cornerWidth: 18, cornerHeight: 18, transform: nil)
        claw.fillColor = SKColor.white.withAlphaComponent(0.42)
        claw.strokeColor = SKColor.white.withAlphaComponent(0.9)
        claw.lineWidth = 3
        claw.position = CGPoint(x: size.width / 2, y: size.height - 92)
        claw.zPosition = 20
        addChild(claw)

        cable.strokeColor = SKColor.white.withAlphaComponent(0.45)
        cable.lineWidth = 3
        cable.zPosition = 19
        addChild(cable)
        redrawCable()
    }

    private func redrawCable() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: claw.position.x, y: size.height))
        path.addLine(to: claw.position)
        cable.path = path
    }

    private func spawnCapsules() {
        let types = ["food", "toy", "word", "memory", "outfit"]
        for index in 0..<14 {
            let type = types[index % types.count]
            let node = makeCapsule(type: type)
            node.position = CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: CGFloat.random(in: 80...(size.height * 0.48))
            )
            addChild(node)
        }
    }

    private func makeCapsule(type: String) -> SKShapeNode {
        let node = SKShapeNode(ellipseOf: CGSize(width: 54, height: 54))
        node.name = "capsule:\(type)"
        node.fillColor = color(for: type).withAlphaComponent(0.78)
        node.strokeColor = SKColor.white.withAlphaComponent(0.85)
        node.lineWidth = 3
        node.physicsBody = SKPhysicsBody(circleOfRadius: 27)
        node.physicsBody?.restitution = 0.55
        node.physicsBody?.friction = 0.35
        node.physicsBody?.linearDamping = 0.55

        let label = SKLabelNode(text: symbol(for: type))
        label.fontSize = 20
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        node.addChild(label)
        return node
    }

    private func color(for type: String) -> SKColor {
        switch type {
        case "food": return .systemGreen
        case "toy": return .systemPink
        case "word": return .systemCyan
        case "memory": return .systemPurple
        case "outfit": return .systemYellow
        default: return .white
        }
    }

    private func symbol(for type: String) -> String {
        switch type {
        case "food": return "◍"
        case "toy": return "✧"
        case "word": return "Aa"
        case "memory": return "∞"
        case "outfit": return "◆"
        default: return "?"
        }
    }

    func moveClaw(to normalizedX: CGFloat) {
        guard !isDropping else { return }
        let x = min(max(normalizedX, 0), 1) * size.width
        claw.run(.moveTo(x: min(max(x, 44), size.width - 44), duration: 0.10)) { [weak self] in
            self?.redrawCable()
        }
    }

    func dropClaw() {
        guard !isDropping else { return }
        isDropping = true

        let startY = size.height - 92
        let down = SKAction.customAction(withDuration: 0.62) { [weak self] node, elapsed in
            guard let self else { return }
            let progress = elapsed / 0.62
            node.position.y = startY - (self.size.height * 0.50 * progress)
            self.redrawCable()
        }

        let grab = SKAction.run { [weak self] in self?.attemptGrab() }

        let up = SKAction.customAction(withDuration: 0.70) { [weak self] node, elapsed in
            guard let self else { return }
            let progress = elapsed / 0.70
            let currentY = node.position.y
            node.position.y = currentY + ((startY - currentY) * progress)
            self.redrawCable()
        }

        let finish = SKAction.run { [weak self] in
            self?.claw.position.y = startY
            self?.redrawCable()
            self?.isDropping = false
        }

        claw.run(.sequence([down, grab, up, finish]))
    }

    private func attemptGrab() {
        let candidates = children.compactMap { node -> SKShapeNode? in
            guard let shape = node as? SKShapeNode,
                  shape.name?.hasPrefix("capsule:") == true else { return nil }
            let dx = shape.position.x - claw.position.x
            let dy = shape.position.y - claw.position.y
            return sqrt(dx * dx + dy * dy) < 74 ? shape : nil
        }

        guard let prize = candidates.first else {
            NotificationCenter.default.post(name: .clawMissed, object: nil)
            return
        }

        let type = prize.name?.replacingOccurrences(of: "capsule:", with: "") ?? "unknown"
        prize.removeFromParent()
        NotificationCenter.default.post(name: .clawGrabbedCapsule, object: type)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            let replacement = self.makeCapsule(type: type)
            replacement.position = CGPoint(x: CGFloat.random(in: 50...(self.size.width - 50)), y: 80)
            self.addChild(replacement)
        }
    }
}

extension Notification.Name {
    static let clawMissed = Notification.Name("OpenClaw.clawMissed")
    static let clawGrabbedCapsule = Notification.Name("OpenClaw.clawGrabbedCapsule")
}
