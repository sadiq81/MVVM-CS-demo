import Combine
import Foundation

import MustacheServices

protocol SecretViewModelType: Sendable {

    var data: Data! { get set }
    
    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> { get }

    func enable(flag: FeatureFlag) async throws
    
    func disable(flag: FeatureFlag) async throws
}

@MainActor
final class SecretViewModel: @preconcurrency SecretViewModelType {

    // MARK: Variables
    
    var data: Data!
    
    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> {
        return self.userService.featureFlagsPublisher
    }
    
    // MARK: Services
    
    @Injected(\.userService)
    private var userService: any UserServiceType
    
    // MARK: State variables
    
    // MARK: Init
        
    // MARK: Configure
    
    // MARK: functions
    
    func enable(flag: FeatureFlag) async throws {
        try await self.userService.save(flag: flag)
    }
    
    func disable(flag: FeatureFlag) async throws {
        try await self.userService.delete(flag: flag)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Preview

#if DEBUG

final class PreviewSecretViewModel: SecretViewModelType, @unchecked Sendable {

    // MARK: Variables

    var data: Data! = Data("Secret preview content".utf8)

    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> {
        return Just(FeatureFlag.mockDataArray).eraseToAnyPublisher()
    }

    // MARK: functions

    func enable(flag: FeatureFlag) async throws {}

    func disable(flag: FeatureFlag) async throws {}

}

#endif
