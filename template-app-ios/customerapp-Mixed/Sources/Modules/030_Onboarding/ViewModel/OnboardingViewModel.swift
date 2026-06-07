
import Combine
import SwiftUI

@preconcurrency import MustacheServices

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: Services

    @Injected(\.permissionsService)
    private var permissionsService: any PermissionsServiceType

    @Injected(\.notificationService)
    private var notificationService: any NotificationServiceType

    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    // MARK: State

    @Published var currentStep: Int = 0
    @Published var isLoading: Bool = false

    // MARK: Computed Properties

    var onboardingSteps: [OnboardingStep] {
        return self.onboardingService.onboardingStates
            .filter { $0.value == .pending || $0.value == .skipped }
            .map(\.key)
            .sorted { OnboardingType.login.steps.firstIndex(of: $0) ?? 0 < OnboardingType.login.steps.firstIndex(of: $1) ?? 0 }
    }

    var hasSteps: Bool {
        return !self.onboardingSteps.isEmpty
    }

    var isLastStep: Bool {
        return self.currentStep >= self.onboardingSteps.count - 1
    }

    // MARK: Functions

    func requestPermissionAndUpdate() async {
        guard self.currentStep < self.onboardingSteps.count else { return }

        let step = self.onboardingSteps[self.currentStep]
        let permissionsService = self.permissionsService
        let notificationService = self.notificationService
        let onboardingService = self.onboardingService

        self.isLoading = true
        defer { self.isLoading = false }

        do {
            let allowed: Bool

            switch step {
                case .location:
                    allowed = try await permissionsService.locationPermission()
                case .notification:
                    allowed = try await permissionsService.notificationPermission()
                    if allowed { notificationService.register() }
                case .camera:
                    allowed = try await permissionsService.cameraRecordPermission()
            }

            let state: OnboardingState = allowed ? .completed : .skipped
            try await onboardingService.updateOnboardingStates(step: step, state: state)
        } catch {
            debugPrint("Onboarding permission error: \(error)")
        }
    }

    func advanceOrComplete() -> Bool {
        if self.isLastStep {
            return true
        } else {
            self.currentStep += 1
            return false
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
