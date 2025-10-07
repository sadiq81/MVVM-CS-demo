import Foundation
import LocalAuthentication

import MustacheServices

protocol PinViewModelType {

    var data: Data? { get set }
    
    var biometricType: LABiometryType { get  }

    func store(pin: String) async throws
    
    func storeWithBiometric() async throws

    func validate(pin: String) async throws -> Data

    func reset()

    func update(pin: String) async throws

}

extension PinViewModelType {
    
    var biometricType: LABiometryType {
        let context = LAContext()
        return context.biometryType
    }
    
}

class PinViewModel: PinViewModelType {
    
    // MARK: Variables
    
    var data: Data?
    
    // MARK: Services
    
    @Injected
    private var storageService: SecureStorageServiceType
    
    // MARK: State variables
    
    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions
    
    func store(pin: String) async throws {
        /**
         This method should only be call from a context where
         the data has already been unlocked and set on the view model
         */
        guard let data = self.data else { throw PinError.missingData }
        try self.storageService.store(data: data, with: pin)
        
    }
    
    func storeWithBiometric() async throws {
        /**
         This method should only be call from a context where
         the data has already been unlocked and set on the view model
         */
        try await self.storageService.enableBiometrics()
        guard let data = self.data else { throw PinError.missingData }
        try self.storageService.store(data: data)
    }
    
    func validate(pin: String) async throws -> Data {
        let data = try await self.storageService.getData(with: pin)
        return data
    }
    
    func reset() {
        self.storageService.reset()        
        NotificationCenter.default.post(name: .logOut, object: nil)
    }
    
    func update(pin: String) async throws {
        // This method should only be call from a context where
        // the data has already been unlocked and set on the view model
        guard let _ = self.data else { throw PinError.missingData }
        let dataStoredWithBiometry =  self.storageService.dataStoredWithBiometry
        
        self.storageService.reset()
        
        try await self.store(pin: pin)
        
        if dataStoredWithBiometry {
            try await self.storeWithBiometric()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

enum PinError: Swift.Error {
    case missingData
}
