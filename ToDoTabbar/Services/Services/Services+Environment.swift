import SwiftUI

// Views reach the repositories through the environment instead of being
// handed them by a factory. A screen deep in the stack can read what it
// needs without every screen above it passing it along.

private struct ServicesKey: EnvironmentKey {
    static let defaultValue: Services = .live
}

extension EnvironmentValues {
    var services: Services {
        get { self[ServicesKey.self] }
        set { self[ServicesKey.self] = newValue }
    }
}
