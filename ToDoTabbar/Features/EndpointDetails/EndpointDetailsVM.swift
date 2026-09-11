import Foundation
import Combine

enum DetailsSource {
    /// Details already at hand, e.g. an entity picked from a list.
    case ready(Details)
    /// Details that still have to be loaded from an endpoint.
    case remote(() async throws -> Details)
}

final class EndpointDetailsVM: VMProtocol {
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
