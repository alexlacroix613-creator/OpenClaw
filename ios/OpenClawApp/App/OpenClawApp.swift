import SwiftUI

@main
struct OpenClawApp: App {
    @StateObject private var runtime = PetViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(runtime)
        }
    }
}
