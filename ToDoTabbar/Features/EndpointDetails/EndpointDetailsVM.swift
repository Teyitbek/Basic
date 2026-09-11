import Foundation
import Combine

enum DetailsSource {
    /// Details already at hand, e.g. an entity picked from a list.
    case ready(Details)
    /// Details that still have to be loaded from an endpoint.
    case remote(() async throws -> Details)
}

// `nonisolated` is required here. The target builds with
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor, which makes every type
// @MainActor and gives this class an isolated deinit. Releasing a class
// that stores an async closure (the `.remote` case below) through that
// isolated-deinit path crashes in the Swift runtime. The view model is
// only ever touched from the main thread anyway, and `getDetails()` hops
// to @MainActor explicitly before mutating state.
nonisolated final class EndpointDetailsVM: VMProtocol {
    let title: String
    
    let successGetDetails = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    
    private(set) var details: Details?
    private let source: DetailsSource
    
    init(title: String, source: DetailsSource) {
        self.title = title
        self.source = source
        if case .ready(let details) = source {
            self.details = details
        }
    }
    
    var isReady: Bool {
        details != nil
    }
    
    func getDetails() {
        guard case .remote(let load) = source else { return }
        Task { @MainActor in
            do {
                self.details = try await load()
                successGetDetails.send(())
            } catch {
                errorMessage.send(error.localizedDescription)
            }
        }
    }
}
