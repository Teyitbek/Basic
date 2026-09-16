import SwiftUI

/// Decides what the app shows first, and owns the single navigation stack.
///
/// Every push in the app happens inside this stack, from whichever view wants
/// it — there is no coordinator handing screens to each other.
struct RootView: View {
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                TabbarView()
            } else {
                LoginView { isLoggedIn = true }
            }
        }
    }
}

#Preview {
    RootView()
}
