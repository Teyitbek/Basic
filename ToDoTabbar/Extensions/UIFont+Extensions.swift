import UIKit

extension UIFont {
    /// A fixed-size font that still grows with the user's text size setting.
    ///
    /// `UIFont.preferredFont(forTextStyle:)` scales, but forces the system's
    /// own sizes. `UIFontMetrics` lets a design keep its point size at the
    /// default setting and scale from there, so Dynamic Type costs nothing
    /// visually. `textStyle` only decides how fast it scales.
    static func scaled(size: CGFloat,
                       weight: UIFont.Weight,
                       textStyle: UIFont.TextStyle) -> UIFont {
        UIFontMetrics(forTextStyle: textStyle)
            .scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
}
