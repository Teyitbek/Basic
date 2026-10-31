import Foundation

/// Where a details screen gets its content.
///
/// The closure is held by the *view* — a struct — and only passed in to
/// `load(from:)`, never stored on this class.
enum DetailsSource {
    /// Already at hand, e.g. an entity picked from a list.
    case ready(Details)
    /// Still has to be fetched from an endpoint.
    case remote(() async throws -> Details)
}

@Observable
final class EndpointDetailsVM {
    private(set) var details: Details?
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    /// Drives the alert. Writable so dismissing it clears the message —
    /// an alert bound to a constant can never be closed by the system.
    var isShowingError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    /// True once loading has finished with nothing to show.
    var isEmpty: Bool {
        !isLoading && (details?.sections.isEmpty ?? true)
    }

    func load(from source: DetailsSource) async {
        switch source {
        case .ready(let details):
            // Nothing to wait for, so no skeleton: showing one would just
            // flash a placeholder over content we already have.
            self.details = details

        case .remote(let loader):
            // `.task` re-runs on reappearance; don't refetch what we have.
            guard details == nil, errorMessage == nil else { return }

            isLoading = true
            defer { isLoading = false }

            // The fetch and the minimum skeleton time run side by side, so the
            // placeholder is always visible for one full shimmer sweep. A fast
            // response would otherwise flash it for a frame or two, which
            // reads as a glitch rather than as loading.
            async let minimumDisplay: Void = Self.minimumSkeletonDelay()

            do {
                let loaded = try await loader()
                await minimumDisplay
                details = loaded
            } catch {
                await minimumDisplay
                errorMessage = error.localizedDescription
            }
        }
    }

    private static func minimumSkeletonDelay() async {
        try? await Task.sleep(for: .seconds(SkeletonView.shimmerDuration))
    }
}
