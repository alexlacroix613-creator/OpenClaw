import Foundation

struct PetEventRequest: Codable {
    let petId: String
    let eventType: String
    let text: String?
    let localTimestamp: Date
}

struct PetVisibleResponse: Codable {
    struct StatePatch: Codable {
        let moodDelta: Double
        let bondDelta: Double
        let energyDelta: Double
        let hungerDelta: Double
    }

    let mode: String
    let text: String
    let animation: String
    let emotion: String
    let statePatch: StatePatch
}

struct PetBootstrapRequest: Codable {
    let petId: String
    let installToken: String
    let localTimestamp: Date
}

final class PetAPI {
    // Local dev backend. 8989 was chosen because :8787 and :8788 were
    // already taken on this machine. Override per-build via Info.plist
    // OPENCLAW_API_BASE_URL if you want to point at a remote server.
    private let baseURL: URL = {
        if let override = Bundle.main.object(forInfoDictionaryKey: "OPENCLAW_API_BASE_URL") as? String,
           let url = URL(string: override) {
            return url
        }
        return URL(string: "http://127.0.0.1:8989")!
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func bootstrapPet(pet: PetState) async throws -> PetVisibleResponse {
        let body = PetBootstrapRequest(
            petId: pet.id.uuidString,
            installToken: DeviceIdentity.installToken,
            localTimestamp: Date()
        )
        return try await post(path: "/v1/pet/bootstrap", body: body)
    }

    func sendPetEvent(_ event: PetEventRequest) async throws -> PetVisibleResponse {
        try await post(path: "/v1/pet/event", body: event)
    }

    private func post<T: Encodable, R: Decodable>(path: String, body: T) async throws -> R {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DeviceIdentity.installToken, forHTTPHeaderField: "X-Install-Token")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(R.self, from: data)
    }
}

enum DeviceIdentity {
    static var installToken: String {
        let key = "openclaw.installToken"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let token = UUID().uuidString
        UserDefaults.standard.set(token, forKey: key)
        return token
    }
}
