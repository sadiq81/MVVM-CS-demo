

import Foundation

extension OnboardingStateResponse  {

    static let mockData = [
        OnboardingStateResponse(step: .location, state: .pending),
        OnboardingStateResponse(step: .notification, state: .pending),
        OnboardingStateResponse(step: .camera, state: .pending),
    ]

}
