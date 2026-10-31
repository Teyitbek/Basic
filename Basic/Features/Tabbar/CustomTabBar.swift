import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedIndex: Int

    /// `.horizontal` is the usual bar across the bottom; `.vertical` is the
    /// rail down the trailing edge used on wide screens.
    var axis: Axis = .horizontal

    private let items: [(icon: String, title: String)] = [
        ("house", "Home"),
        ("person", "Profile"),
        ("gearshape", "Settings"),
        ("message.fill", "SMS")
    ]

    var body: some View {
        layout {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                button(for: item, at: index)
            }
        }
        .padding(10)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 25))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }

    /// `AnyLayout` swaps the stack without rebuilding the buttons, so the
    /// selection and any animation carry across the change.
    private var layout: AnyLayout {
        switch axis {
        case .horizontal: AnyLayout(HStackLayout(spacing: 0))
        case .vertical: AnyLayout(VStackLayout(spacing: 0))
        }
    }

    private func button(for item: (icon: String, title: String), at index: Int) -> some View {
        Button {
            selectedIndex = index
        } label: {
            // Side by side along the bottom, stacked in the rail — a rail is
            // narrow, so the label goes under the icon rather than beside it.
            itemLayout {
                Image(systemName: item.icon)
                    .font(.system(size: 22))
                Text(item.title)
                    .font(.system(size: 12))
            }
            .foregroundStyle(index == selectedIndex ? Color.accentColor : .gray)
            .frame(minWidth: axis == .vertical ? 72 : nil,
                   maxWidth: axis == .horizontal ? .infinity : nil,
                   maxHeight: axis == .vertical ? .infinity : nil)
            .padding(.vertical, axis == .vertical ? 12 : 0)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(index == selectedIndex ? [.isButton, .isSelected] : .isButton)
    }

    private var itemLayout: AnyLayout {
        switch axis {
        case .horizontal: AnyLayout(HStackLayout(spacing: 4))
        case .vertical: AnyLayout(VStackLayout(spacing: 4))
        }
    }
}

#Preview("Bottom bar") {
    @Previewable @State var index = 0
    CustomTabBar(selectedIndex: $index)
}

#Preview("Side rail") {
    @Previewable @State var index = 0
    CustomTabBar(selectedIndex: $index, axis: .vertical)
}
