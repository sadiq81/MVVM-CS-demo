#if DEBUG

import Foundation

final class PreviewLoginService: LoginServiceType, @unchecked Sendable {

    func login(username: String, password: String) async throws {
        // no-op
    }

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws {
        // no-op
    }

    func forgotPassword(email: String) async throws {
        // no-op
    }

    func logOut() async throws {
        // no-op
    }

}

#endif
