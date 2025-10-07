import Foundation

enum OnboardingType: String, Codable {
    case login

    var steps: [OnboardingStep] {
        switch self {
            case .login: return [.location, .notification, .camera]
        }
    }
}

enum OnboardingStep: String, Codable {

    case location
    case notification
    case camera

}

enum OnboardingState: String, Codable {

    case pending
    case completed
    case skipped
    
}
