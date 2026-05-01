import ActivityKit
import Foundation

struct PetLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var moodLabel: String
        var hunger: Double
        var energy: Double
        var stage: String
    }

    var petID: String
    var petName: String
}
