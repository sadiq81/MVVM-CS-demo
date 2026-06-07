import Combine

import MustacheFoundation
import MustacheServices

protocol OnboardingViewModelType: Sendable {
    
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

final class OnboardingViewModel: OnboardingViewModelType, @unchecked Sendable {

    // MARK: Variables
    
    var onboardingSteps: [OnboardingStep] {
        return self.onboardingService.onboardingStates.filter { $0.value == .pending || $0.value == .skipped }.map(\.key)
    }
    
    var userPublisher: AnyPublisher<UserModel, Never> {
        return self.userService.userPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: Services

    @Injected(\.userService)
    private var userService: any UserServiceType

    @Injected(\.permissionsService)
    private var permissionsService: any PermissionsServiceType

    @Injected(\.notificationService)
    private var notificationService: any NotificationServiceType

    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType
    
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

// MARK: - Preview

#if DEBUG

final class PreviewOnboardingViewModel: OnboardingViewModelType, @unchecked Sendable {

    // MARK: Variables

    var onboardingSteps: [OnboardingStep] {
        return OnboardingStep.mockDataArray
    }

    var userPublisher: AnyPublisher<UserModel, Never> {
        return Just(UserModel.mockData).eraseToAnyPublisher()
    }

    // MARK: functions

    @discardableResult
    func requestLocationPermissions() async throws -> Bool {
        return true
    }

    @discardableResult
    func requestNotificationPermissions() async throws -> Bool {
        return true
    }

    @discardableResult
    func requestCameraPermissions() async throws -> Bool {
        return true
    }

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws {}

}

#endif
