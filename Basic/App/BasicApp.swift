import SwiftUI

@main
struct BasicApp: App {
    @AppStorage("isOnRuLanguage") private var isOnRuLanguage = false
    @AppStorage("isOnDarkMode") private var isOnDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, Locale(identifier: isOnRuLanguage ? "ru" : "en"))
                .preferredColorScheme(isOnDarkMode ? .dark : .light)
        }
    }
}
