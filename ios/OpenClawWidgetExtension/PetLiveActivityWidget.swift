import ActivityKit
import SwiftUI
import WidgetKit

struct PetLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetLiveActivityAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.petName)
                        .font(.caption.bold())
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.moodLabel)
                        .font(.caption2.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("stage: \(context.state.stage)")
                        Spacer()
                        Text("energy \(Int(context.state.energy * 100))%")
                    }
                    .font(.caption2)
                }
            } compactLeading: {
                Text("◍")
            } compactTrailing: {
                Text(String(context.state.moodLabel.prefix(1)))
            } minimal: {
                Text("◍")
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<PetLiveActivityAttributes>) -> some View {
        HStack {
            Text("◍")
                .font(.title2)
            VStack(alignment: .leading) {
                Text(context.attributes.petName)
                    .font(.headline)
                Text(context.state.moodLabel)
                    .font(.caption)
            }
            Spacer()
            Text(context.state.stage)
                .font(.caption.bold())
        }
        .padding()
    }
}

@main
struct OpenClawWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetLiveActivityWidget()
    }
}
