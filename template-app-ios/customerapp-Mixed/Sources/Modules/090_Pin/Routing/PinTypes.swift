
import Combine
import Foundation

@preconcurrency import MustacheServices

// MARK: - Pin Transition

enum PinTransition: MustacheServices.Transition {
    case enroll(PinDelegate, Data)
    case validate(PinDelegate)
    case changePin(PinDelegate)
    
}

// MARK: - Pin Completion

public enum PinCompletion: Completion {
    case enrolled(Data)
    case validated(Data)
    case changePin
}

// MARK: - Pin Delegate

@MainActor
protocol PinDelegate: AnyObject {
    func didEnroll(data: Data)
    func didFail(with error: Error)
    func didAuthenticate(data: Data)
    func didChangePin()
    func didCancel()
}

extension PinDelegate {
    func didEnroll(data: Data) {}
    func didFail(with error: Error) {}
    func didAuthenticate(data: Data) {}
    func didChangePin() {}
    func didCancel() {}
}

// MARK: - Pin Sheet Type

enum PinSheetType: Identifiable {
    
    case enroll(Data)
    case validate
    case changePin

    var id: String {
        switch self {
            case .enroll: return "enroll"
            case .validate: return "validate"
            case .changePin: return "changePin"
        }
    }
}
