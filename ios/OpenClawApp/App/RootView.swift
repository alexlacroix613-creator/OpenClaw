import SwiftUI

struct RootView: View {
    @EnvironmentObject private var runtime: PetViewModel

    var body: some View {
        ClawRoomView()
            .task {
                await runtime.bootstrapIfNeeded()
            }
    }
}
