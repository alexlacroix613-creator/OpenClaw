import Foundation
import SwiftUI

@MainActor
final class PetViewModel: ObservableObject {
    @Published private(set) var petState: PetState
    @Published var lastBackendError: String?
    @Published var isBootstrapped = false
    @Published var isTeaching = false

    private let api = PetAPI()
    private let persistenceKey = "openclaw.petState.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let decoded = try? JSONDecoder().decode(PetState.self, from: data) {
            self.petState = decoded
        } else {
            self.petState = .newborn()
        }
    }

    func bootstrapIfNeeded() async {
        guard !isBootstrapped else { return }
        isBootstrapped = true
        save()

        do {
            let response = try await api.bootstrapPet(pet: petState)
            apply(response: response)
        } catch {
            lastBackendError = error.localizedDescription
            localReaction(animation: "egg_blink", text: "", moodDelta: 0.01)
        }
    }

    func handleTapPet() {
        if petState.stage == .egg {
            petState.stage = .hatchling
            localReaction(animation: "hatch_blink", text: "pi...?", moodDelta: 0.02, bondDelta: 0.01)
        } else {
            localReaction(animation: "look_at_user", text: petState.stage == .hatchling ? "mii" : "", moodDelta: 0.01, bondDelta: 0.005)
        }
        Task { await sendEvent(type: "tap_pet", text: nil) }
    }

    func resolveCapsule(type: String) {
        switch type {
        case "food":
            petState.hunger = (petState.hunger - 0.18).clamped01()
            localReaction(animation: "eat_sparkle", text: "", moodDelta: 0.04, bondDelta: 0.01)
        case "toy":
            localReaction(animation: "toy_bounce", text: "ki!", moodDelta: 0.05, bondDelta: 0.015)
        case "word":
            isTeaching = true
            localReaction(animation: "listen_glow", text: "?", moodDelta: 0.01, bondDelta: 0.005)
        case "memory":
            localReaction(animation: "memory_bubble", text: "...", moodDelta: 0.02)
        case "outfit":
            localReaction(animation: "outfit_spin", text: "!", moodDelta: 0.03, bondDelta: 0.01)
        default:
            localReaction(animation: "inspect_capsule", text: "", moodDelta: 0.005)
        }
        Task { await sendEvent(type: "claw_capsule", text: type) }
    }

    func handleClawMiss() {
        localReaction(animation: "claw_miss_sad_blink", text: "...", moodDelta: -0.01)
    }

    func beginTeaching() {
        isTeaching = true
        localReaction(animation: "listen_glow", text: "?", moodDelta: 0.005, bondDelta: 0.002)
    }

    func teach(text: String) async {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        isTeaching = false
        localReaction(animation: "mouth_trying_sound", text: "\(cleaned.prefix(3))...", moodDelta: 0.02, bondDelta: 0.02)
        await sendEvent(type: "teaching_text", text: cleaned)
    }

    private func sendEvent(type: String, text: String?) async {
        do {
            let request = PetEventRequest(
                petId: petState.id.uuidString,
                eventType: type,
                text: text,
                localTimestamp: Date()
            )
            let response = try await api.sendPetEvent(request)
            apply(response: response)
        } catch {
            lastBackendError = error.localizedDescription
        }
    }

    private func apply(response: PetVisibleResponse) {
        petState.visibleText = response.text
        petState.currentAnimation = response.animation
        petState.mood = (petState.mood + response.statePatch.moodDelta).clamped01()
        petState.bond = (petState.bond + response.statePatch.bondDelta).clamped01()
        petState.energy = (petState.energy + response.statePatch.energyDelta).clamped01()
        petState.hunger = (petState.hunger + response.statePatch.hungerDelta).clamped01()
        petState.lastInteractionAt = Date()
        save()
    }

    private func localReaction(
        animation: String,
        text: String,
        moodDelta: Double,
        bondDelta: Double = 0,
        energyDelta: Double = -0.002,
        hungerDelta: Double = 0.001
    ) {
        petState.currentAnimation = animation
        petState.visibleText = text
        petState.mood = (petState.mood + moodDelta).clamped01()
        petState.bond = (petState.bond + bondDelta).clamped01()
        petState.energy = (petState.energy + energyDelta).clamped01()
        petState.hunger = (petState.hunger + hungerDelta).clamped01()
        petState.lastInteractionAt = Date()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(petState) {
            UserDefaults.standard.set(data, forKey: persistenceKey)
        }
    }
}
