import SwiftUI

/// Placeholder shown while the details are loading.
///
/// The blocks deliberately mirror the real layout — icon, title, subtitle,
/// then rows — so the screen keeps its shape and nothing jumps when the
/// content arrives.
struct SkeletonView: View {
    /// One full sweep of the shimmer, and the minimum time the skeleton is
    /// kept on screen (see `EndpointDetailsVM.load`).
    static let shimmerDuration: TimeInterval = 1

    private let rowCount = 5

    var body: some View {
        // One reader gives every block a width relative to the screen, which
        // keeps the placeholder in proportion on any device.
        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 28) {
                header(width: width)
                rows(width: width)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .shimmer()
        // VoiceOver should say the screen is busy, not read out a pile of
        // meaningless empty shapes.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func header(width: CGFloat) -> some View {
        VStack(spacing: 10) {
            block(height: 80, cornerRadius: 40)
                .frame(width: 80)
            block(height: 22)
                .frame(width: width * 0.7)
            block(height: 16)
                .frame(width: width * 0.4)
        }
    }

    private func rows(width: CGFloat) -> some View {
        VStack(spacing: 22) {
            ForEach(0..<rowCount, id: \.self) { _ in
                // One row of the table: a short caption above a longer value.
                VStack(alignment: .leading, spacing: 8) {
                    block(height: 10)
                        .frame(width: width * 0.25)
                    block(height: 18)
                        .frame(width: width * 0.6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func block(height: CGFloat, cornerRadius: CGFloat = 6) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.secondarySystemFill))
            .frame(height: height)
    }
}

#Preview {
    SkeletonView()
}
