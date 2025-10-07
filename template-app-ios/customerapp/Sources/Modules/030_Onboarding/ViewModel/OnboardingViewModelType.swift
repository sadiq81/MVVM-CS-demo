import MustacheFoundation
import MustacheServices

import Combine

protocol OnboardingViewModelType {
    
    var onboardingSteps: [OnboardingStep] { get }
    
    var userPublisher: AnyPublisher<UserModel, Never> { get }

    @discardableResult
    func requestLocationPermissions() async throws -> Bool

    @discardableResult
    func requestNotificationPermissions() async throws -> Bool

    @discardableResult
    func requestCameraPermissions() async throws -> Bool

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws
}

class OnboardingViewModel: OnboardingViewModelType {

    // MARK: Variables
    
    var onboardingSteps: [OnboardingStep] {
        return self.onboardingService.onboardingStates.filter { $0.value == .pending || $0.value == .skipped }.map(\.key)
    }
    
    var userPublisher: AnyPublisher<UserModel, Never> {
        return self.userService.userPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: Services

    @Injected
    private var userService: UserServiceType

    @Injected
    private var permissionsService: PermissionsServiceType

    @Injected
    private var notificationService: NotificationServiceType

    @Injected
    private var onboardingService: OnboardingServiceType
    
    // MARK: State variables

    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions
    
    @discardableResult
    func requestLocationPermissions() async throws -> Bool {
        return try await self.permissionsService.locationPermission()
    }

    @discardableResult
    func requestNotificationPermissions() async throws -> Bool {
        let permission = try await self.permissionsService.notificationPermission()
        if permission { self.notificationService.register() }
        return permission
    }

    @discardableResult
    func requestCameraPermissions() async throws -> Bool {
        return try await self.permissionsService.cameraRecordPermission()
    }

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws {
        return try await self.onboardingService.updateOnboardingStates(step: step, state: state)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
