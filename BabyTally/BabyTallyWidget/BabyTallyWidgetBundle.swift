import WidgetKit
import SwiftUI

@main
struct BabyTallyWidgetBundle: WidgetBundle {
    var body: some Widget {
        BabyTallyWidget()
    }
}

struct BabyTallyWidget: Widget {
    let kind = "BabyTallyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BabyStatusProvider()) { entry in
            BabyTallyWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BabyTally")
        .description("See time since the last feed and diaper change. No subscription required.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}
