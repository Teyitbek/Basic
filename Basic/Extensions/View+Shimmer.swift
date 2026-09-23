import SwiftUI

extension View {
    /// Sweeps a bright band across the view, on a loop.
    ///
    /// The band is a gradient used as a **mask over the whole view**, not an
    /// animation on each subview. That is what makes it read as one wave
    /// crossing the screen instead of several independent blinks.
    func shimmer(duration: TimeInterval = SkeletonView.shimmerDuration) -> some View {
        modifier(ShimmerModifier(duration: duration))
    }
}

private struct ShimmerModifier: ViewModifier {
    let duration: TimeInterval

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        // A moving shimmer is exactly what Reduce Motion asks us not to do.
        // The static blocks alone still read as "loading".
        if reduceMotion {
            content
        } else {
            content
                .mask { mask }
                .onAppear {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        }
    }

    private var mask: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            // As a mask these opacities decide what shows through: the blocks
            // sit at 40% and a fully opaque band travels across them.
            LinearGradient(colors: [.white.opacity(0.4), .white, .white.opacity(0.4)],
                           startPoint: .leading,
                           endPoint: .trailing)
                // Three times as wide as the view, so whatever the offset the
                // mask still covers it — an uncovered area would vanish.
                .frame(width: width * 3)
                .offset(x: (phase - 1) * 2 * width)
        }
    }
}
