import SwiftUI

/// The tab bar's outline: a rounded rectangle whose leading edge dips in a
/// smooth notch around the centre button.
///
/// The dip is an arc concentric with the button, so the gap between the two is
/// the same all the way round. A plain circular cut-out would meet the
/// straight edge at a right angle; the two `shoulder` arcs either side curve
/// the edge into the dip and back out again, tangent at both ends, so the
/// outline has no corners.
struct NotchedBarShape: Shape {
    /// Which edge the notch sits on: the top in the standard mode, the
    /// leading edge for the iPhone Duo's side rail.
    var axis: Axis

    /// Distance from the button's centre to the edge of the dip. Make it the
    /// button's radius plus the gap you want around it.
    var notchRadius: CGFloat

    /// How far below the edge the dip's centre sits. Must match how far the
    /// button itself is dropped, or the gap stops being even.
    var notchDrop: CGFloat = 0

    /// How gently the straight edge turns into the dip.
    var shoulderRadius: CGFloat

    var cornerRadius: CGFloat = 25

    func path(in rect: CGRect) -> Path {
        switch axis {
        case .horizontal:
            return notchedPath(in: rect)

        // iPhone Duo: the rail.
        case .vertical:
            // Build it with the notch on top in a transposed rect, then turn
            // it a quarter turn so the notch lands on the leading edge.
            let transposed = CGRect(x: 0, y: 0, width: rect.height, height: rect.width)
            let rotation = CGAffineTransform(rotationAngle: -.pi / 2)
                .concatenating(CGAffineTransform(translationX: 0, y: rect.height))
            return notchedPath(in: transposed).applying(rotation)
        }
    }

    private func notchedPath(in rect: CGRect) -> Path {
        let centreX = rect.midX
        let notch = notchRadius
        let shoulder = shoulderRadius
        let drop = notchDrop

        // Where the shoulder meets the straight edge. Each shoulder circle is
        // tangent to that edge and tangent to the notch circle, so their
        // centres sit `notch + shoulder` apart. The shoulder's centre is
        // `shoulder` below the edge and the notch's is `drop` below it, so
        // solving that distance for the horizontal gap gives:
        let offset = ((notch + shoulder) * (notch + shoulder)
                      - (drop - shoulder) * (drop - shoulder)).squareRoot()
        // Angle from a shoulder's centre to the notch's centre.
        let phi = atan2(drop - shoulder, offset)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))

        path.addLine(to: CGPoint(x: centreX - offset, y: rect.minY))
        path.addArc(center: CGPoint(x: centreX - offset, y: rect.minY + shoulder),
                    radius: shoulder,
                    startAngle: .radians(-.pi / 2),
                    endAngle: .radians(phi),
                    clockwise: false)

        path.addArc(center: CGPoint(x: centreX, y: rect.minY + drop),
                    radius: notch,
                    startAngle: .radians(.pi + phi),
                    endAngle: .radians(-phi),
                    clockwise: true)

        path.addArc(center: CGPoint(x: centreX + offset, y: rect.minY + shoulder),
                    radius: shoulder,
                    startAngle: .radians(.pi - phi),
                    endAngle: .radians(-.pi / 2),
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .radians(-.pi / 2),
                    endAngle: .zero,
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .zero,
                    endAngle: .radians(.pi / 2),
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .radians(.pi / 2),
                    endAngle: .radians(.pi),
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .radians(.pi),
                    endAngle: .radians(3 * .pi / 2),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}

#Preview {
    NotchedBarShape(axis: .horizontal, notchRadius: 34, shoulderRadius: 16)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        .frame(height: 64)
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(Color(.secondarySystemBackground))
}
