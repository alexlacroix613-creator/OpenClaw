import ActivityKit
import Foundation

@MainActor
final class PetLiveActivityManager: ObservableObject {
    private var activity: Activity<PetLiveActivityAttributes>?

    func start(pet: PetState) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = PetLiveActivityAttributes(
            petID: pet.id.uuidString,
            petName: pet.name ?? "OpenClaw"
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState(for: pet), staleDate: Date().addingTimeInterval(30 * 60)),
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }

    func update(pet: PetState) async {
        guard let activity else { return }
        await activity.update(.init(state: contentState(for: pet), staleDate: Date().addingTimeInterval(30 * 60)))
    }

    func end() async {
        guard let activity else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
        self.activity = nil
    }

    private func contentState(for pet: PetState) -> PetLiveActivityAttributes.ContentState {
        .init(
            moodLabel: moodLabel(for: pet),
            hunger: pet.hunger,
            energy: pet.energy,
            stage: pet.stage.rawValue
        )
    }

    private func moodLabel(for pet: PetState) -> String {
        if pet.energy < 0.20 { return "sleepy" }
        if pet.hunger > 0.72 { return "hungry" }
        if pet.bond > 0.70 { return "bonded" }
        if pet.mood > 0.74 { return "glowy" }
        return "curious"
    }
}
