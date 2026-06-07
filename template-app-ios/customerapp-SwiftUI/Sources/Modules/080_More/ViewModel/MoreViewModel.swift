
import Combine
import SwiftUI

@preconcurrency import MustacheServices

/// Domain result of resolving secure-content access — carries no navigation types.
/// The View maps this to the appropriate destination.
enum SecureContentRoute {
    case secret
    case validate
    case enroll(Data)
}

@MainActor
final class MoreViewModel: ObservableObject {

    // MARK: State

    @Published var user: UserModel?
    @Published var featureFlags: [FeatureFlag] = []
    @Published var secureContentRoute: SecureContentRoute?
    @Published var didLogout: Bool = false

    /// Constant external link shown for Feature 2 (domain data, not navigation).
    var feature2URL: URL? { URL(string: "https://www.claude.ai") }

    // MARK: Services
    
    @Injected(\.userService)
    private var userService: any UserServiceType
    
    @Injected(\.loginService)
    private var loginService: any LoginServiceType
    
    @Injected(\.secureStorageService)
    private var secureStorageService: any SecureStorageServiceType
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    
    init() {
        self.userService.userPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$user)
        
        self.userService.featureFlagsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$featureFlags)
    }
    
    // MARK: Functions

    /// Resolves which secure-content experience the user should get, based on
    /// secure-storage state. Publishes a domain result; the View performs navigation.
    func requestSecureContent() {
        if self.secureStorageService.dataStoredWithPin {
            if self.secureStorageService.dataStoredWithBiometry,
               !self.secureStorageService.isBiometricsLocked {
                Task {
                    do {
                        let data = try await self.secureStorageService.getData()
                        let secretViewModel = Container.shared.secretViewModel()
                        secretViewModel.data = data
                        self.secureContentRoute = .secret
                    } catch {
                        self.secureContentRoute = .validate
                    }
                }
            } else {
                self.secureContentRoute = .validate
            }
        } else {
            guard let secret = "some-secret".data(using: .utf8) else { return }
            self.secureContentRoute = .enroll(secret)
        }
    }

    func logOut() { Task {
        try await self.loginService.logOut()
        self.userService.clearState()
        NotificationCenter.default.post(name: .logOut, object: nil)
        self.didLogout = true
    }}

    deinit {
        debugPrint("deinit \(self)")
    }
}
