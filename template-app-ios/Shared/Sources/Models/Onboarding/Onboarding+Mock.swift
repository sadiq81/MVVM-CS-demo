import Foundation

#if DEBUG

extension OnboardingType {

    static let mockData: OnboardingType = .login

}

extension OnboardingStep {

    static let mockData: OnboardingStep = .location

    static let mockDataArray: [OnboardingStep] = [.location, .notification, .camera]

}

extension OnboardingState {

    static let mockData: OnboardingState = .pending

}

#endif
