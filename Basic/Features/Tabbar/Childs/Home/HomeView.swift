import SwiftUI

struct HomeView: View {
    @Environment(\.services) private var services

    private let viewModel = HomeVM()

    var body: some View {
        List(viewModel.endpoints, id: \.self) { endpoint in
            NavigationLink(value: endpoint) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(endpoint.listTitle)
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .lineLimit(nil)
                    
                    Text(endpoint.url)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                }
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(endpoint.title)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Endpoints")
        .navigationDestination(for: Endpoint.self, destination: destination)
    }

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
