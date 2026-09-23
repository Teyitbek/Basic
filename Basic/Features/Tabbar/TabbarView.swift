import SwiftUI

struct TabbarView: View {
    @State private var selectedIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            selectedTab
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedIndex: $selectedIndex)
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var selectedTab: some View {
        switch selectedIndex {
        case 0: HomeView()
        case 1: ProfileView()
        case 2: SettingsView()
        default: MessagesView()
        }
    }
}

#Preview {
    NavigationStack {
        TabbarView()
    }
}
