import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedIndex: Int

    /// `.horizontal` is the standard mode: the bar across the bottom.
    ///
    /// `.vertical` is the rail down the trailing edge, used only on wide
    /// screens such as an unfolded iPhone Duo. Everything specific to it is
    /// marked `// iPhone Duo` below, so the standard mode can be read on its
    /// own.
    var axis: Axis = .horizontal

    /// What the raised centre button does. It is an action, not a tab, so it
    /// never changes `selectedIndex`.
    var onScan: () -> Void = {}

    private let items: [(icon: String, title: String)] = [
        ("house", "Home"),
        ("person", "Profile"),
        ("gearshape", "Settings"),
        ("message.fill", "SMS")
    ]

    private let scanButtonSize: CGFloat = 64
    /// Even gap between the button and the dip in the bar's edge.
    private let scanButtonGap: CGFloat = 6
    /// How far the button sits *into* the bar, measured from the bar's edge to
    /// the button's centre. At 0 the centre would sit exactly on the edge and
    /// the button would look as if it were floating on top; dropping it a
    /// little settles it into the notch.
    private let scanButtonDrop: CGFloat = 12

    /// The bar's own thickness, measured rather than guessed, so the centre
    /// button can be pushed out by exactly half of it.
    @State private var barThickness: CGFloat = 0

    var body: some View {
        layout {
            // Two tabs, the scan button, then two more: five equal slots, with
            // the button in the middle.
            tabButton(at: 0)
            tabButton(at: 1)
            scanButton
            tabButton(at: 2)
            tabButton(at: 3)
        }
        .padding(10)
        .background {
            let shape = NotchedBarShape(axis: axis,
                                        notchRadius: scanButtonSize / 2 + scanButtonGap,
                                        notchDrop: scanButtonDrop,
                                        shoulderRadius: 16)
            shape
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                // The bar and the screen behind it are both the background
                // colour, so without an outline the notch is invisible: it
                // would be white cut out of white. A hairline draws the edge.
                .overlay {
                    shape.stroke(Color(.separator), lineWidth: 0.5)
                }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            // Height of the bottom bar; width of the rail. // iPhone Duo
            axis == .horizontal ? proxy.size.height : proxy.size.width
        } action: { thickness in
            barThickness = thickness
        }
    }

    /// `AnyLayout` swaps the stack without rebuilding the buttons, so the
    /// selection and any animation carry across the change.
    private var layout: AnyLayout {
        switch axis {
        case .horizontal: AnyLayout(HStackLayout(spacing: 0))
        case .vertical: AnyLayout(VStackLayout(spacing: 0)) // iPhone Duo
        }
    }

    // MARK: - Tabs

    private func tabButton(at index: Int) -> some View {
        let item = items[index]

        return Button {
            selectedIndex = index
        } label: {
            slot {
                label(icon: item.icon, title: item.title)
                    .foregroundStyle(index == selectedIndex ? Color.accentColor : .gray)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(index == selectedIndex ? [.isButton, .isSelected] : .isButton)
    }

    /// The label always sits under the icon, in the bar and the rail alike.
    private func label(icon: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(title)
                .font(.system(size: 12))
        }
    }

    /// One of the five equal shares of the bar. In the standard mode they
    /// divide the width; the `.vertical` arms divide the rail's height
    /// instead, and give it a sensible minimum width.
    private func slot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(minWidth: axis == .vertical ? 72 : nil)              // iPhone Duo
            .padding(.vertical, axis == .vertical ? 12 : 0)             // iPhone Duo
            .frame(maxWidth: axis == .horizontal ? .infinity : nil,
                   maxHeight: axis == .vertical ? .infinity : nil)      // iPhone Duo
            .contentShape(.rect)
    }

    // MARK: - Scan button

    /// A slot sized by a hidden tab label, so it matches the others exactly
    /// and the bar's thickness is still set by the tabs. The circle itself is
    /// an overlay, which takes no part in layout — that is what lets it be
    /// bigger than a tab and hang outside the bar without making it taller.
    private var scanButton: some View {
        slot {
            label(icon: "qrcode.viewfinder", title: " ")
                .hidden()
        }
        .overlay {
            Button(action: onScan) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: scanButtonSize, height: scanButtonSize)
                    .background(Color.accentColor, in: .circle)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Scan QR code")
            // Half the bar's thickness lifts the circle's centre onto the
            // bar's leading edge; the drop then settles it into the notch.
            // The shape is given the same drop, so the gap stays even.
            .offset(x: axis == .vertical ? -barThickness / 2 + scanButtonDrop : 0, // iPhone Duo
                    y: axis == .horizontal ? -barThickness / 2 + scanButtonDrop : 0)
        }
    }
}

#Preview("Bottom bar") {
    @Previewable @State var index = 0

    VStack {
        Spacer()
        CustomTabBar(selectedIndex: $index)
    }
    .background(Color(.secondarySystemBackground))
}

#Preview("Side rail") {
    @Previewable @State var index = 0

    HStack {
        Spacer()
        CustomTabBar(selectedIndex: $index, axis: .vertical)
    }
    .background(Color(.secondarySystemBackground))
}
