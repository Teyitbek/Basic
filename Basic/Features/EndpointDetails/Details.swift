import Foundation

/// Presentation model for the details screen, so any entity can be shown by it.
struct Details: Hashable {
    let icon: String
    let title: String
    let subtitle: String
    let sections: [DetailsSection]
}

struct DetailsSection: Hashable {
    let title: String
    let rows: [DetailsRow]
}

struct DetailsRow: Hashable {
    let title: String
    let value: String
}
