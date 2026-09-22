import SwiftUI

struct SettingsView: View {
    @AppStorage("isOnRuLanguage") private var isOnRuLanguage = false
    @AppStorage("isOnDarkMode") private var isOnDarkMode = false
    @State private var isOnNotifications: Bool = false
    @State private var exampleTexts: [String] = [
        "hello everybody",
        "see the future",
        "fly as bird",
        "read a book",
        "write in note"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Updated to lowercase keys to match your catalog file perfectly
            Text("settings")
                .font(.system(size: 32, weight: .bold))
                .frame(maxHeight: 60)
                .padding()
            
            VStack(spacing: 10) {
                Toggle("russian language", isOn: $isOnRuLanguage)
                Toggle("dark mode", isOn: $isOnDarkMode)
                Toggle("notifications available", isOn: $isOnNotifications)
            }
            .padding(10)
            
            List(exampleTexts, id: \.self) { text in
                Text(text)
            }
        }
    }
}

// FIX: This container captures the switch toggle and instantly translates the preview canvas
#Preview {
    PreviewContainer()
}

struct PreviewContainer: View {
    @AppStorage("isOnRuLanguage") private var isOnRuLanguage = false
    @AppStorage("isOnDarkMode") private var isOnDarkMode = false
    
    var body: some View {
        NavigationStack {
            SettingsView()
                .environment(\.locale, Locale(identifier: isOnRuLanguage ? "ru" : "en"))
                .preferredColorScheme(isOnDarkMode ? .dark : .light)
        }
    }
}
