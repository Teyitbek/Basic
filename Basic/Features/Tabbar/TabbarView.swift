import SwiftUI

struct TabbarView: View {
    @State private var selectedIndex = 0

    // MARK: - iPhone Duo
    //
    // Everything from here to `selectedTab` exists only so a wide screen gets
    // the side rail. The standard mode is the `false` arm of `usesSideRail`:
    // a plain VStack with the bar across the bottom.

    /// Above this width-to-height ratio the screen is wide enough that a bar
    /// across the bottom wastes space, and a rail down the trailing edge
    /// reads better.
    ///
    /// Shape, not model name, is the signal here. The size class cannot help:
    /// an unfolded iPhone Duo reports `.compact`, exactly like any other
    /// phone. But its screen is 466x678 — a ratio of 0.69, against roughly
    /// 0.46 for a phone in portrait — so the proportions separate them
    /// cleanly, and the rule keeps working for the folded state, for
    /// landscape, for iPads, and for whatever ships next.
    private static let sideRailAspectRatio: CGFloat = 0.6

    var body: some View {
        GeometryReader { geometry in
            let usesSideRail = geometry.size.width / geometry.size.height >= Self.sideRailAspectRatio
            // `AnyLayout` swaps the stack without rebuilding the children, so
            // the selected tab and its state survive a fold or a rotation.
            let stack = usesSideRail ? AnyLayout(HStackLayout(spacing: 0))
                                     : AnyLayout(VStackLayout(spacing: 0))

            stack {
                selectedTab
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedIndex: $selectedIndex,
                             axis: usesSideRail ? .vertical : .horizontal)
            }
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
