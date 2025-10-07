import Combine
import Foundation
import MustacheFoundation
import MustacheServices
import MustacheCombine


protocol OnboardingServiceType {

    var onboardingStates: [OnboardingStep: OnboardingState] { get }

    var onboardingStatesPublisher: AnyPublisher<[OnboardingStep: OnboardingState], Never> { get }

    func onboarded(step: OnboardingStep) -> OnboardingState

    func onboardedCompleted(for: OnboardingType) -> OnboardingState

    func refresh() async throws

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws

    func clearState()

}

class OnboardingService: OnboardingServiceType {

    @StorageCombineDefault("OnboardingService.onboardingStates", mode: .userDefaults(), defaultValue: [:])
    var onboardingStates: [OnboardingStep: OnboardingState]

    var onboardingStatesPublisher: AnyPublisher<[OnboardingStep: OnboardingState], Never> {
        return self.$onboardingStates
    }

    @Injected
    private var networkService: AsyncNetworkServiceType

    func onboardedCompleted(for type: OnboardingType) -> OnboardingState {
        let completed: Set<OnboardingStep> = self.onboardingStates
            .filter { $0.value == .completed }
            .map({ $0.key })
            .set

        let state: OnboardingState = (type.steps.set == completed) ? .completed : .skipped
        return state
    }

    func onboarded(step: OnboardingStep) -> OnboardingState {
        let state = self.onboardingStates[step] ?? .pending
        return state
    }

    func refresh() async throws {
        let response: OnboardingStateResponseList = try await self.networkService.getOnboardingStates()
        let list = response.map { ($0.step, $0.state) }
        let onboardingStates: [OnboardingStep: OnboardingState] = Dictionary(uniqueKeysWithValues: list)
        self.onboardingStates = onboardingStates
    }

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws {
        let response: OnboardingStateResponseList = try await self.networkService.updateOnboardingStates(step: step, state: state)
        let list = response.map { ($0.step, $0.state) }
        let onboardingStates: [OnboardingStep: OnboardingState] = Dictionary(uniqueKeysWithValues: list)
        self.onboardingStates = onboardingStates
    }

    func clearState() {
        self.onboardingStates = [:]
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
