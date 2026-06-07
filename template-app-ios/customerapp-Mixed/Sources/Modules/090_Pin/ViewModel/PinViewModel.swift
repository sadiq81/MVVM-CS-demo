
import Combine
import Foundation
import LocalAuthentication

@preconcurrency import MustacheServices

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

    func store() async {
        guard self.pin.count == 4, self.pin == self.repeatPin else {
            self.errorMessage = Strings.Alert.Pin.NotMatching.message
            self.showError = true
            self.resetPins()
            return
        }

        guard let data = self.data else { return }

        self.isLoading = true
        defer { self.isLoading = false }

        do {
            try self.secureStorageService.store(data: data, with: self.pin)
            self.showBiometricAlert = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.resetPins()
        }
    }

    func storeWithBiometric() async {
        do {
            try await self.secureStorageService.enableBiometrics()
            if let data = self.data {
                try self.secureStorageService.store(data: data)
            }
        } catch {
            // Biometric enrollment failed — continue without it
        }
    }

    // MARK: Validate Functions

    func validate() async -> Data? {
        guard self.pin.count == 4 else { return nil }

        self.isLoading = true
        defer { self.isLoading = false }

        do {
            let data = try await self.secureStorageService.getData(with: self.pin)
            self.showSuccess = true
            return data
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.resetPins()
            return nil
        }
    }

    func validateWithBiometrics() async -> Data? {
        guard self.secureStorageService.dataStoredWithBiometry,
              !self.secureStorageService.isBiometricsLocked
        else { return nil }

        do {
            let data = try await self.secureStorageService.getData()
            return data
        } catch {
            return nil
        }
    }

    // MARK: Change Pin
    // This method should only be call from a context where
    // the data has already been unlocked and set on the view model
    func update() async {
        guard self.pin.count == 4, self.pin == self.repeatPin else {
            self.errorMessage = Strings.Alert.Pin.NotMatching.message
            self.showError = true
            self.resetPins()
            return
        }

        self.isLoading = true
        defer { self.isLoading = false }

        do {
            // Check if biometrics was previously enabled
            let hadBiometry = self.secureStorageService.dataStoredWithBiometry
            self.secureStorageService.reset()

            // Re-store with new PIN
            guard let data = self.data else { return }
            try self.secureStorageService.store(data: data, with: self.pin)

            // Re-enable biometrics if previously enabled
            if hadBiometry {
                try await self.secureStorageService.enableBiometrics()
                try self.secureStorageService.store(data: data)
            }

            self.showSuccess = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.resetPins()
        }
    }

    // MARK: Reset

    func reset() {
        self.secureStorageService.reset()
        NotificationCenter.default.post(name: .logOut, object: nil)
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
