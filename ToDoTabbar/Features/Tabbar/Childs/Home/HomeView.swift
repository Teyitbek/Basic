import SwiftUI

struct HomeView: View {
    @Environment(\.services) private var services

    private let viewModel = HomeVM()

    var body: some View {
        List(viewModel.endpoints, id: \.self) { endpoint in
            // The row IS the navigation: tapping pushes the value, and the
            // destination below decides what to build from it.
            NavigationLink(value: endpoint) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(endpoint.listTitle)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    Text(endpoint.url)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(endpoint.title)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Endpoints")
        .navigationDestination(for: Endpoint.self, destination: destination)
    }

    /// One place that maps an endpoint to the screen it opens. This is the
    /// job the coordinator used to do, now sitting next to the list itself.
    @ViewBuilder
    private func destination(for endpoint: Endpoint) -> some View {
        switch endpoint.kind {
        case .users:
            UsersView()

        case .posts:
            PostsView()

        case .post(let id):
            EndpointDetailsView(title: endpoint.title, source: .remote { [services] in
                try await services.postsRepo.getPost(id: id).details
            })

        case .createPost:
            EndpointDetailsView(title: endpoint.title, source: .remote { [services] in
                try await services.postsRepo.createPost(.sample).details
            })
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
