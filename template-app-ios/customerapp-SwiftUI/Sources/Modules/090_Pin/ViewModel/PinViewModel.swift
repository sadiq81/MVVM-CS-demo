
import Combine
import Foundation
import LocalAuthentication

@preconcurrency import MustacheServices

// MARK: - Pin Completion

enum PinCompletion: Equatable {
    case enrolled(Data)
    case validated(Data)
    case changePin
}

@MainActor
final class PinViewModel: ObservableObject {

    // MARK: State

    @Published var pin: String = ""
    @Published var repeatPin: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showBiometricAlert: Bool = false
    @Published var showResetAlert: Bool = false
    @Published var showSuccess: Bool = false
    @Published var phase: EnrollPhase = .enter
    @Published var completion: PinCompletion?
    @Published var isFinished: Bool = false
    @Published var didReset: Bool = false

    func dismiss() {
        self.isFinished = true
    }

    enum EnrollPhase {
        case enter
        case confirm
    }

    var data: Data!

    // MARK: Services

    @Injected(\.secureStorageService)
    private var secureStorageService: any SecureStorageServiceType

    // MARK: Init

    init(data: Data? = nil) {
        self.data = data
    }

    // MARK: Computed

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    var biometricTitle: String {
        self.biometricType == .faceID ? Strings.Alert.Pin.FaceId.title : Strings.Alert.Pin.TouchId.title
    }

    var biometricMessage: String {
        self.biometricType == .faceID ? Strings.Alert.Pin.FaceId.message : Strings.Alert.Pin.TouchId.message
    }

    var dataStoredWithPin: Bool {
        self.secureStorageService.dataStoredWithPin
    }

    // MARK: Enroll Functions

    func store() {
        guard self.pin.count == 4, self.pin == self.repeatPin else {
            self.errorMessage = Strings.Alert.Pin.NotMatching.message
            self.showError = true
            self.resetPins()
            return
        }

        guard let data = self.data else { return }

        self.isLoading = true

        do {
            try self.secureStorageService.store(data: data, with: self.pin)
            self.isLoading = false
            self.showBiometricAlert = true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.resetPins()
        }
    }

    func storeWithBiometric() {
        Task {
            do {
                try await self.secureStorageService.enableBiometrics()
                if let data = self.data {
                    try self.secureStorageService.store(data: data)
                }
            } catch {
                // Biometric enrollment failed — continue without it
            }
            self.completeEnroll()
        }
    }

    func declineBiometric() {
        self.completeEnroll()
    }

    private func completeEnroll() {
        self.showSuccess = true
        guard let data = self.data else { return }
        let secretViewModel = Container.shared.secretViewModel()
        secretViewModel.data = data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.completion = .enrolled(data)
        }
    }

    // MARK: Validate Functions

    func validate() {
        guard self.pin.count == 4 else { return }

        self.isLoading = true

        Task {
            do {
                let data = try await self.secureStorageService.getData(with: self.pin)
                self.isLoading = false
                self.showSuccess = true
                let secretViewModel = Container.shared.secretViewModel()
                secretViewModel.data = data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.completion = .validated(data)
                }
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.resetPins()
            }
        }
    }

    // MARK: Change Pin
    // This method should only be call from a context where
    // the data has already been unlocked and set on the view model
    func update() {
        guard self.pin.count == 4, self.pin == self.repeatPin else {
            self.errorMessage = Strings.Alert.Pin.NotMatching.message
            self.showError = true
            self.resetPins()
            return
        }

        self.isLoading = true

        Task {
            do {
                let hadBiometry = self.secureStorageService.dataStoredWithBiometry
                self.secureStorageService.reset()

                guard let data = self.data else { return }
                try self.secureStorageService.store(data: data, with: self.pin)

                if hadBiometry {
                    try await self.secureStorageService.enableBiometrics()
                    try self.secureStorageService.store(data: data)
                }

                self.isLoading = false
                self.showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.completion = .changePin
                }
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.resetPins()
            }
        }
    }

    // MARK: Reset

    func reset() {
        self.secureStorageService.reset()
        NotificationCenter.default.post(name: .logOut, object: nil)
        self.didReset = true
    }

    func resetPins() {
        self.pin = ""
        self.repeatPin = ""
        self.phase = .enter
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
