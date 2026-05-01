import Foundation

struct LensLaunchPayload: Codable {
    let petId: String
    let petStage: String
    let mood: String
    let outfitId: String?
    let catchphrase: String?
    let memorySeed: String?
}

final class SnapShareService {
    func preparePetSnap(payload: LensLaunchPayload) {
        // Integrate Snap Creative Kit here after adding Snap SDK credentials.
        // Product rule: this creates a user-approved Snapchat handoff, not silent autonomous sending.
    }
}
