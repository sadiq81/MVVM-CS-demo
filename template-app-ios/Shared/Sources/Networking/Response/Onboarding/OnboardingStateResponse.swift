import Foundation

typealias OnboardingStateResponseList = [OnboardingStateResponse]

struct OnboardingStateResponse: Decodable {

    var step: OnboardingStep
    var state: OnboardingState

}
