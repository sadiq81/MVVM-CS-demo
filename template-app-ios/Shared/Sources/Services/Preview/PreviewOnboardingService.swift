#if DEBUG

import Combine
import Foundation

final class PreviewOnboardingService: OnboardingServiceType, @unchecked Sendable {

    var onboardingStates: [OnboardingStep: OnboardingState] = [
        .location: .pending,
        .notification: .pending,
        .camera: .pending
    ]

    var onboardingStatesPublisher: AnyPublisher<[OnboardingStep: OnboardingState], Never> {
        return Just(self.onboardingStates).eraseToAnyPublisher()
    }

    func onboarded(step: OnboardingStep) -> OnboardingState {
        return self.onboardingStates[step] ?? .pending
    }

    func onboardedCompleted(for type: OnboardingType) -> OnboardingState {
        let completed = Set(self.onboardingStates.filter { $0.value == .completed }.map { $0.key })
        let state: OnboardingState = (Set(type.steps) == completed) ? .completed : .skipped
        return state
    }

    func refresh() async throws {
        // no-op
    }

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws {
        self.onboardingStates[step] = state
    }

    func clearState() {
        self.onboardingStates = [:]
    }

}

#endif
