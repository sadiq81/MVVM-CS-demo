import Combine
import Foundation

import MustacheServices

protocol SecretViewModelType {

    var data: Data! { get set }
    
    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> { get }

    func enable(flag: FeatureFlag) async throws
    
    func disable(flag: FeatureFlag) async throws
}

class SecretViewModel: SecretViewModelType {

    // MARK: Variables
    
    var data: Data!
    
    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> {
        return self.userService.featureFlagsPublisher
    }
    
    // MARK: Services
    
    @Injected
    private var userService: UserServiceType
    
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
