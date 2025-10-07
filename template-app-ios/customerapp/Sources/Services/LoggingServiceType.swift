import Foundation
import Firebase
import FirebaseAnalytics

protocol LoggingServiceType {

    func log(event: LoggingEvent)
}

class LoggingService: LoggingServiceType {

    func log(event: LoggingEvent) {

        if let event = event.firebaseEvent {
            let mirror = event.mirror
            let eventName = mirror.label
            let parameters = mirror.params
            Analytics.logEvent(eventName, parameters: parameters)
        }

    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

enum LoggingEvent {

    case login(success: Bool)
    case forgotPassword

    case onboardingLocation(state: OnboardingState)
    case onboardingNotification(state: OnboardingState)
    case onboardingCamera(state: OnboardingState)

    case dashboard
    case filter
    case feature1
    case products
    case more

    case profile

    var firebaseEvent: FirebaseLoggingEvent? {
        switch self {

            case .login(let success):
                return .login(success: success)
            case .forgotPassword:
                return .forgotPassword
            case .onboardingLocation(let state):
                return .onboardingLocation(state: state)
            case .onboardingNotification(let state):
                return .onboardingNotification(state: state)
            case .onboardingCamera(let state):
                return .onboardingCamera(state: state)
            case .dashboard:
                return .dashboard
            case .filter:
                return .filter
            case .feature1:
                return .feature1
            case .products:
                return .products
            case .more:
                return .more
            case .profile:
                return .profile
        }
    }
}

enum FirebaseLoggingEvent: MirrorableEnum {

    case login(success: Bool)
    case forgotPassword

    case onboardingLocation(state: OnboardingState)
    case onboardingNotification(state: OnboardingState)
    case onboardingCamera(state: OnboardingState)

    case dashboard
    case filter
    case feature1
    case products
    case more

    case profile

}

protocol MirrorableEnum {}

extension MirrorableEnum {

    var mirror: (label: String, params: [String: Any]) {
        get {
            let reflection = Mirror(reflecting: self)
            guard reflection.displayStyle == .enum,
                  let associated = reflection.children.first else {
                return ("\(self)", [:])
            }
            let values = Mirror(reflecting: associated.value).children
            var valuesArray = [String: Any]()
            for case let item in values where item.label != nil {
                valuesArray[item.label!] = item.value
            }
            return (associated.label!, valuesArray)
        }
    }
}
