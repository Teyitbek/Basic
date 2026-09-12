import Foundation

// MARK: - Accessibility text
//
// The wording VoiceOver speaks is content, not layout, so it is built here
// next to the model rather than inside the views. That keeps the views simple
// and makes the wording unit-testable.

extension Details {
    /// Spoken as a single phrase for the header, so VoiceOver announces the
    /// screen in one stop instead of three ("icon", "name", "email").
    var accessibilityLabel: String {
        subtitle.isEmpty ? title : "\(title), \(subtitle)"
    }

    /// What the large content viewer shows when the header is long-pressed.
    var largeContentTitle: String {
        subtitle.isEmpty ? title : "\(title)\n\(subtitle)"
    }
}

extension DetailsRow {
    /// VoiceOver reads label then value, pausing between them: "Username, Bret".
    /// Splitting them this way (rather than one long label) is the convention:
    /// the label names the field, the value is the content that can change.
    var accessibilityLabel: String { title }

    var accessibilityValue: String { value }

    /// What the large content viewer shows when the row is long-pressed.
    var largeContentTitle: String { "\(title): \(value)" }
}
