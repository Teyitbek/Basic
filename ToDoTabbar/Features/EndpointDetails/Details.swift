import Foundation

/// Presentation model for the details screen, so any entity can be shown by it.
struct Details {
    let icon: String
    let title: String
    let subtitle: String
    let sections: [DetailsSection]
}

struct DetailsSection {
    let title: String
    let rows: [DetailsRow]
}

struct DetailsRow {
    let title: String
    let value: String
}
