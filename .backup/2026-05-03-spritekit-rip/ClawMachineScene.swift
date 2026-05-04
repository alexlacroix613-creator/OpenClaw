import SpriteKit
import SwiftUI
import UIKit

final class ClawMachineScene: SKScene, SKPhysicsContactDelegate {
    private let claw = SKNode()
    private let cable = SKShapeNode()
    private var isDropping = false
    private var capsulesSpawned = false

    private let snackTypes = ["apple", "leaf", "honey", "berry", "shell", "mystery"]

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.6)
        physicsWorld.contactDelegate = self
        setupBounds()
        setupClaw()
        spawnIfReady()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        spawnIfReady()
    }

    private func spawnIfReady() {
        guard !capsulesSpawned, view != nil, size.width > 200, size.height > 200 else { return }
        spawnSnacks()
        capsulesSpawned = true
    }

    private func setupBounds() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
    }

    private func setupClaw() {
        let texture = ClawMachineScene.clawTexture(in: view!)
        let sprite = SKSpriteNode(texture: texture)
        sprite.setScale(2.6)
        sprite.zPosition = 30
        claw.addChild(sprite)
        claw.position = CGPoint(x: size.width / 2, y: size.height - 56)
        addChild(claw)

        cable.strokeColor = PixelUIColor.outline
        cable.fillColor = .clear
        cable.lineWidth = 2
        cable.lineCap = .square
        cable.lineJoin = .miter
        cable.zPosition = 28
        cable.isAntialiased = false
        addChild(cable)
        redrawCable()
    }

    private func redrawCable() {
        let path = CGMutablePath()
        let topY = size.height + 8
        let cx = claw.position.x
        path.move(to: CGPoint(x: cx, y: topY))
        var y = topY
        while y > claw.position.y + 14 {
            y -= 8
            path.addLine(to: CGPoint(x: cx, y: y))
        }
        cable.path = path
    }

    private func spawnSnacks() {
        let inset: CGFloat = 60
        let xLow = min(size.width - inset, inset)
        let xHigh = max(size.width - inset, inset)
        let yLow = size.height * 0.55 - 90
        let yHigh = size.height * 0.55 + 60
        for index in 0..<8 {
            let type = snackTypes[index % snackTypes.count]
            let node = makeSnack(type: type)
            node.position = CGPoint(
                x: xLow == xHigh ? xLow : CGFloat.random(in: xLow...xHigh),
                y: yLow == yHigh ? yLow : CGFloat.random(in: yLow...yHigh)
            )
            addChild(node)

            let drift = SKAction.sequence([
                .moveBy(x: CGFloat.random(in: -10...10), y: 6, duration: 1.4),
                .moveBy(x: CGFloat.random(in: -10...10), y: -6, duration: 1.4)
            ])
            node.run(.repeatForever(drift))
        }
    }

    private func makeSnack(type: String) -> SKSpriteNode {
        let texture = ClawMachineScene.snackTexture(for: type, in: view!)
        let node = SKSpriteNode(texture: texture)
        node.name = "capsule:\(type)"
        node.setScale(2.6)
        node.zPosition = 10
        node.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.linearDamping = 0.9
        return node
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

        let startY = size.height - 56
        let down = SKAction.customAction(withDuration: 0.62) { [weak self] node, elapsed in
            guard let self else { return }
            let progress = elapsed / 0.62
            node.position.y = startY - (self.size.height * 0.42 * progress)
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
        let candidates = children.compactMap { node -> SKSpriteNode? in
            guard let sprite = node as? SKSpriteNode,
                  sprite.name?.hasPrefix("capsule:") == true else { return nil }
            let dx = sprite.position.x - claw.position.x
            let dy = sprite.position.y - claw.position.y
            return sqrt(dx * dx + dy * dy) < 60 ? sprite : nil
        }

        guard let prize = candidates.first else {
            NotificationCenter.default.post(name: .clawMissed, object: nil)
            return
        }

        let type = prize.name?.replacingOccurrences(of: "capsule:", with: "") ?? "unknown"
        prize.removeFromParent()
        let mappedReward = ClawMachineScene.rewardCategory(for: type)
        NotificationCenter.default.post(name: .clawGrabbedCapsule, object: mappedReward)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            let replacement = self.makeSnack(type: type)
            let xLow = min(self.size.width - 60, 60)
            let xHigh = max(self.size.width - 60, 60)
            let yLow = self.size.height * 0.55 - 90
            let yHigh = self.size.height * 0.55 + 60
            replacement.position = CGPoint(
                x: xLow == xHigh ? xLow : CGFloat.random(in: xLow...xHigh),
                y: yLow == yHigh ? yLow : CGFloat.random(in: yLow...yHigh)
            )
            self.addChild(replacement)
        }
    }

    private static func rewardCategory(for snackType: String) -> String {
        switch snackType {
        case "apple", "honey", "shell": return "food"
        case "leaf":                    return "toy"
        case "berry":                   return "outfit"
        case "mystery":                 return "memory"
        default:                        return "food"
        }
    }
}

extension Notification.Name {
    static let clawMissed = Notification.Name("OpenClaw.clawMissed")
    static let clawGrabbedCapsule = Notification.Name("OpenClaw.clawGrabbedCapsule")
}

private enum PixelUIColor {
    static let outline = UIColor(red: 0x2A/255.0, green: 0x1B/255.0, blue: 0x4D/255.0, alpha: 1.0)
}

private extension ClawMachineScene {
    static func snackTexture(for type: String, in view: SKView) -> SKTexture {
        let sprite: PixelSprite
        switch type {
        case "apple":   sprite = .snackApple
        case "honey":   sprite = .snackHoney
        case "leaf":    sprite = .snackLeaf
        case "berry":   sprite = .snackBerry
        case "shell":   sprite = .snackShell
        case "mystery": sprite = .snackMystery
        default:        sprite = .snackApple
        }
        let texture = renderToTexture(sprite: sprite, pixelSize: 2)
        texture.filteringMode = .nearest
        return texture
    }

    static func clawTexture(in view: SKView) -> SKTexture {
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
        let palette: [Character: UIColor] = [
            "o": PixelUIColor.outline,
            "W": .white
        ]
        let texture = renderToTextureUI(rows: rows, palette: palette, pixelSize: 4)
        texture.filteringMode = .nearest
        return texture
    }

    static func renderToTexture(sprite: PixelSprite, pixelSize: CGFloat) -> SKTexture {
        let width = CGFloat(sprite.width) * pixelSize
        let height = CGFloat(sprite.height) * pixelSize
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.interpolationQuality = .none
            cg.setShouldAntialias(false)
            for (rowIndex, row) in sprite.rows.enumerated() {
                for (colIndex, character) in row.enumerated() {
                    guard character != "." else { continue }
                    guard let swiftColor = sprite.palette[character] else { continue }
                    let uiColor = UIColor(swiftColor)
                    cg.setFillColor(uiColor.cgColor)
                    let rect = CGRect(
                        x: CGFloat(colIndex) * pixelSize,
                        y: CGFloat(rowIndex) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    cg.fill(rect)
                }
            }
        }
        return SKTexture(image: image)
    }

    static func renderToTextureUI(rows: [String], palette: [Character: UIColor], pixelSize: CGFloat) -> SKTexture {
        let width = CGFloat(rows.first?.count ?? 0) * pixelSize
        let height = CGFloat(rows.count) * pixelSize
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.interpolationQuality = .none
            cg.setShouldAntialias(false)
            for (rowIndex, row) in rows.enumerated() {
                for (colIndex, character) in row.enumerated() {
                    guard character != "." else { continue }
                    guard let uiColor = palette[character] else { continue }
                    cg.setFillColor(uiColor.cgColor)
                    let rect = CGRect(
                        x: CGFloat(colIndex) * pixelSize,
                        y: CGFloat(rowIndex) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    cg.fill(rect)
                }
            }
        }
        return SKTexture(image: image)
    }
}
