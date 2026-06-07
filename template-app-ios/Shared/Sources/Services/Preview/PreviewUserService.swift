#if DEBUG

import Combine
import Foundation

final class PreviewUserService: UserServiceType, @unchecked Sendable {

    var user: UserModel? = UserModel.mockData

    var userPublisher: AnyPublisher<UserModel?, Never> {
        return Just(self.user).eraseToAnyPublisher()
    }

    var featureFlags: [FeatureFlag] = FeatureFlag.mockDataArray

    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> {
        return Just(self.featureFlags).eraseToAnyPublisher()
    }

    func refresh() async throws {
        // no-op
    }

    func refreshProfile() async throws {
        // no-op
    }

    func refreshFeatureFlags() async throws {
        // no-op
    }

    func save(model: UserModel) async throws {
        self.user = model
    }

    func update(oldPassword: String, password: String, repeatPassword: String) async throws {
        // no-op
    }

    func save(flag: FeatureFlag) async throws {
        if !self.featureFlags.contains(flag) {
            self.featureFlags.append(flag)
        }
    }

    func delete(flag: FeatureFlag) async throws {
        self.featureFlags.removeAll { $0 == flag }
    }

    func verifyAge(userInfoToken: String, idToken: String) async throws {
        // no-op
    }

    func removeVerification() async throws {
        // no-op
    }

    func clearState() {
        self.user = nil
        self.featureFlags = []
    }

}

#endif
