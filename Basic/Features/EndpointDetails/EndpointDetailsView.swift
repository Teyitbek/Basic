import SwiftUI

struct EndpointDetailsView: View {
    let title: String
    /// Held by this struct rather than by the view model: a class storing an
    /// `async` closure gets an isolated `deinit` under the target's MainActor
    /// default isolation, and releasing one crashes in the Swift runtime.
    let source: DetailsSource

    @State private var viewModel = EndpointDetailsVM()

    var body: some View {
        Group {
            if viewModel.isLoading {
                SkeletonView()
            } else if let details = viewModel.details, !details.sections.isEmpty {
                content(for: details)
            } else {
                // Nothing came back. The alert explains why when there was an
                // error; this stays behind it either way, so the screen is
                // never just a blank rectangle.
                emptyState
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(from: source)
        }
        .alert("Something went wrong", isPresented: $viewModel.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView("No Data",
                               systemImage: "tray",
                               description: Text("This endpoint returned nothing to show."))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
    }

    private func content(for details: Details) -> some View {
        VStack(spacing: 16) {
            header(for: details)
            List {
                ForEach(details.sections, id: \.self) { section in
                    Section(section.title) {
                        ForEach(section.rows, id: \.self) { row in
                            self.row(row)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(.systemBackground))
    }

    private func header(for details: Details) -> some View {
        VStack(spacing: 5) {
            Image(systemName: details.icon)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .foregroundStyle(Color.accentColor)

            Text(details.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if !details.subtitle.isEmpty {
                Text(details.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        // Read as ONE element. Without this VoiceOver stops at the icon, then
        // the title, then the subtitle; grouped it reads them in one swipe.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(details.accessibilityLabel)
        // `.isHeader` also lets users jump straight here with the rotor.
        .accessibilityAddTraits(.isHeader)
        // Press and hold to magnify, for users on accessibility text sizes.
        .accessibilityShowsLargeContentViewer {
            Label(details.largeContentTitle, systemImage: details.icon)
        }
    }

    private func row(_ row: DetailsRow) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(row.value)
                .font(.body)
        }
        // The label names the field and the value is the content, so VoiceOver
        // reads "Username, Bret" and re-announces just the value if it changes.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
        .accessibilityValue(row.accessibilityValue)
        .accessibilityShowsLargeContentViewer {
            Text(row.largeContentTitle)
        }
    }
}

#Preview("Ready") {
    NavigationStack {
        EndpointDetailsView(title: "Post Details",
                            source: .ready(Post(id: 1,
                                                userId: 1,
                                                title: "A post title",
                                                body: "The body of the post").details))
    }
}

#Preview("Loading") {
    NavigationStack {
        EndpointDetailsView(title: "GET /posts/1", source: .remote {
            try await Task.sleep(for: .seconds(30))
            return Post(id: 1, userId: 1, title: "", body: "").details
        })
    }
}
