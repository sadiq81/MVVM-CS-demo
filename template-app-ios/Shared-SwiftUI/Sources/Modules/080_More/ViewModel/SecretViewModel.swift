
import Combine
import Foundation

import MustacheServices

@MainActor
final class SecretViewModel: ObservableObject {

    // MARK: State

    @Published var feature1Enabled: Bool = false
    @Published var feature2Enabled: Bool = false
    @Published var isLoading: Bool = false

    var data: Data?

    var secretText: String {
        guard let data = self.data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    // MARK: Services

    @Injected(\.userService)
    private var userService: any UserServiceType

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    private func configure() {
        self.userService.featureFlagsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] flags in
                guard let self else { return }
                self.feature1Enabled = flags.contains(.feature1)
                self.feature2Enabled = flags.contains(.feature2)
            }
            .store(in: &self.cancellables)
    }

    // MARK: Functions

    func toggleFeature(_ feature: FeatureFlag, isOn: Bool) {
        Task {
            self.isLoading = true
            defer { self.isLoading = false }

            do {
                if isOn {
                    try await self.userService.save(flag: feature)
                } else {
                    try await self.userService.delete(flag: feature)
                }
            } catch {
                // Revert on failure
                switch feature {
                    case .feature1:
                        self.feature1Enabled = !isOn
                    case .feature2:
                        self.feature2Enabled = !isOn
                }
            }
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
