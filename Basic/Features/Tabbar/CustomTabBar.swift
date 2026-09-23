import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedIndex: Int

    private let items: [(icon: String, title: String)] = [
        ("house", "Home"),
        ("person", "Profile"),
        ("gearshape", "Settings"),
        ("message.fill", "SMS")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button {
                    selectedIndex = index
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 22))
                        Text(item.title)
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(index == selectedIndex ? Color.accentColor : .gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(index == selectedIndex ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(10)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 25))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }
}

#Preview {
    @Previewable @State var index = 0
    CustomTabBar(selectedIndex: $index)
}
