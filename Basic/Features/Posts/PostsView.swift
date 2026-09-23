import SwiftUI

struct PostsView: View {
    @Environment(\.services) private var services
    @State private var viewModel = PostsVM()

    var body: some View {
        List(viewModel.posts, id: \.self) { post in
            NavigationLink(value: post) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.title)
                        .lineLimit(2)
                    Text("Post #\(post.id)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Posts")
        .overlay {
            if viewModel.isLoading {
                ProgressView().controlSize(.large)
            }
        }
        .task {
            await viewModel.load(using: services.postsRepo)
        }
        .navigationDestination(for: Post.self) { post in
            EndpointDetailsView(title: "Post Details", source: .ready(post.details))
        }
    }
}

#Preview {
    NavigationStack {
        PostsView()
    }
}
