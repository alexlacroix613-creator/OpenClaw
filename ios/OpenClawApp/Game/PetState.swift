import Foundation

enum PetStage: String, Codable, Sendable, CaseIterable {
    case egg, hatchling, learner, toddler, buddy, bff
}

struct LearnedToken: Codable, Sendable, Identifiable, Hashable {
    let id: UUID
    var surface: String
    var phoneticHint: String?
    var meaning: String?
    var confidence: Double
    var examples: [String]
    var firstLearnedAt: Date
    var lastReinforcedAt: Date

    init(surface: String, meaning: String? = nil, confidence: Double = 0.05) {
        self.id = UUID()
        self.surface = surface
        self.meaning = meaning
        self.confidence = confidence
        self.phoneticHint = nil
        self.examples = []
        self.firstLearnedAt = Date()
        self.lastReinforcedAt = Date()
    }
}

struct PetState: Codable, Sendable, Hashable {
    var id: UUID
    var name: String?
    var stage: PetStage
    var hunger: Double
    var mood: Double
    var bond: Double
    var energy: Double
    var autonomy: Double
    var knownTokens: [LearnedToken]
    var currentAnimation: String
    var visibleText: String
    var lastInteractionAt: Date
    var memoryDigest: String?

    static func newborn() -> PetState {
        PetState(
            id: UUID(),
            name: nil,
            stage: .egg,
            hunger: 0.20,
            mood: 0.55,
            bond: 0.00,
            energy: 0.85,
            autonomy: 0.00,
            knownTokens: [],
            currentAnimation: "egg_pulse",
            visibleText: "",
            lastInteractionAt: Date(),
            memoryDigest: nil
        )
    }
}

extension Double {
    func clamped01() -> Double {
        min(max(self, 0), 1)
    }
}
