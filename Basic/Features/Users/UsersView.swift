import SwiftUI

struct UsersView: View {
    @Environment(\.services) private var services
    @State private var viewModel = UsersVM()

    var body: some View {
        List(viewModel.users, id: \.self) { user in
            NavigationLink(value: user) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                    Text(user.email)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Users")
        .overlay {
            if viewModel.isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .task {
            await viewModel.load(using: services.usersRepo)
        }
        .navigationDestination(for: User.self) { user in
            EndpointDetailsView(title: "User Details", source: .ready(user.details))
        }
    }
}

#Preview {
    NavigationStack {
        UsersView()
    }
}
