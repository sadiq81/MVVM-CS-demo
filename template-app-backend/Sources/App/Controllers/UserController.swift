import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("user") { user in
            
            user.post("", use: self.register)
            
            user.group(UserAuthenticator()) { authenticated in
                authenticated.get("", use: self.getCurrentUser)
                authenticated.put("", use: self.update)
                authenticated.put("password", use: self.updatePassword)

                authenticated.get("feature-flags", use: self.getFlags)
                authenticated.post("feature-flags", use: self.setFlag)

                authenticated.post("verify", use: self.verify)
                authenticated.post("remove-verification", use: self.removeVerification)
            }
        }
    }
    
    private func register(_ req: Request) async throws -> HTTPStatus {
        
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        guard registerRequest.password == registerRequest.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let passwordHash = try await req.password.async.hash(registerRequest.password).get()
        
        do {
            let user = try User(from: registerRequest, hash: passwordHash)
            try await req.users.create(user)
            
            
            let states = try OnboardingState.Step.allCases.map { step in
                let state = OnboardingState(userID: try user.requireID(), step: step, state: .pending)
                return state
            }
            try await req.onboardingStates.create(states)
            
        } catch {
            if let databaseError = error as? DatabaseError, databaseError.isConstraintFailure {
                throw AuthenticationError.emailAlreadyExists
            } else {
                throw error
            }
        }
        return .created
    }
    
    private func getCurrentUser(_ req: Request) async throws -> UserResponse {
        let payload = try req.auth.require(Payload.self)
        
        guard let user = try await req.users .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }
            
        let response = UserResponse(from: user)
        return response
    }
    
    private func update(_ req: Request) async throws -> UserResponse {
        
        let payload = try req.auth.require(Payload.self)
        
        guard let user = try await req.users .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }
        
        try UserRequest.validate(content: req)
        
        let userRequest = try req.content.decode(UserRequest.self)
        user.firstName = userRequest.firstName
        user.lastName = userRequest.lastName
        if user.birthDateVerified == false {
            user.birthDate = userRequest.birthDate
        } else if userRequest.birthDate != nil && user.birthDateVerified {
            throw AuthenticationError.userNotFound
        }
        user.phoneNumber = userRequest.phoneNumber
        user.email = userRequest.email
        user.street = userRequest.street
        user.zipCode = userRequest.zipCode
        user.city = userRequest.city
        user.country = userRequest.country

        do {
            try await req.users.update(user)
        } catch {
            if let databaseError = error as? DatabaseError, databaseError.isConstraintFailure {
                throw AuthenticationError.emailAlreadyExists
            } else {
                throw error
            }
        }
        let response = UserResponse(from: user)
        return response
    }

    private func updatePassword(_ req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(Payload.self)

        guard let user = try await req.users.find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try UpdatePasswordRequest.validate(content: req)
        let updatePasswordRequest = try req.content.decode(UpdatePasswordRequest.self)

        guard updatePasswordRequest.newPassword == updatePasswordRequest.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }

        let verified = try await req.password.async.verify(updatePasswordRequest.currentPassword, created: user.passwordHash).get()
        guard verified else {
            throw AuthenticationError.invalidEmailOrPassword
        }

        let newPasswordHash = try await req.password.async.hash(updatePasswordRequest.newPassword).get()
        user.passwordHash = newPasswordHash

        try await req.users.update(user)

        try await req.refreshTokens.delete(for: payload.userID)

        return .ok
    }

    private func setFlag(_ req: Request) async throws -> [FeatureFlagResponse] {
        let payload = try req.auth.require(Payload.self)
        
        try FeatureFlagRequest.validate(content: req)
        let flagRequest = try req.content.decode(FeatureFlagRequest.self)
        
        let existing = try await req.users.flags(for: payload.userID)
        
        if flagRequest.enabled && existing.contains(where: { $0.name == flagRequest.name }) {
            
            let response = existing.map { FeatureFlagResponse(from: $0) }
            return response
            
        } else if flagRequest.enabled {
            
            let flag = FeatureFlag(userID: payload.userID, name: flagRequest.name)
            
            try await req.users.create(flag: flag)
            
            let flags = try await req.users.flags(for: payload.userID)
            
            let response = flags.map { FeatureFlagResponse(from: $0) }
            return response
            
        } else if !flagRequest.enabled, let flag = existing.first(where: { $0.name == flagRequest.name }) {
            
            try await req.users.delete(flag: flag)
            
            let flags = try await req.users.flags(for: payload.userID)
            
            let response = flags.map { FeatureFlagResponse(from: $0) }
            return response
            
        } else {
            
            let response = existing.map { FeatureFlagResponse(from: $0) }
            return response
        }
        
        
    }
    
    private func getFlags(_ req: Request) async throws -> [FeatureFlagResponse] {
        let payload = try req.auth.require(Payload.self)
        
        let flags = try await req.users.flags(for: payload.userID)
        
        let response = flags.map { FeatureFlagResponse(from: $0) }
        return response
    }
    
    private func verify(_ req: Request) async throws -> HTTPStatus {

        let payload = try req.auth.require(Payload.self)

        guard let user = try await req.users .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }

        try VerifyRequest.validate(content: req)
        let requestContent = try req.content.decode(VerifyRequest.self)

        let brokerUserinfoURL = req.application.config.mitidBrokerUserinfoURL
        let userInfoResponse = try await req.client.get(URI(string: brokerUserinfoURL)) { (clientRequest: inout ClientRequest) in
            let authorization = BearerAuthorization(token: requestContent.userinfoToken)
            clientRequest.headers.bearerAuthorization = authorization
        }
        
        let userInfo = try userInfoResponse.content.decode(OIDUserinfoResponse.self)
        guard userInfo.cpr.count == 10 else { throw Abort(.internalServerError, reason: "invalid cpr count") }
        let cpr = userInfo.cpr
        
        let day = cpr[0..<2].int
        let month = cpr[2..<4].int
        var year = cpr[4..<6].int
        let checksum = cpr[6..<7].int

        switch (checksum, year) {
            case (0...3, 0...99): //1900-1999
                year += 1900
            case (4, 0...36): //2000-2036
                year += 2000
            case (4, 37...99):  //1937-1999
                year += 1900
            case (5...8, 0...57): //2000-2057
                year += 2000
            case (5...8, 58...99): //1858-1899
                year += 1800
            case (9, 0...36): // 2000-2036
                year += 2000
            case (9, 37...99): // 1937-1999
                year += 1900
            default:
                throw Abort(.internalServerError, reason: "invalid cpr checksum: \(checksum), year: \(year). See https://da.wikipedia.org/wiki/CPR-nummer")
        }
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar.daDK.date(from: components) else {
            throw Abort(.internalServerError, reason: "unable to parse date from \(components)")
        }
        
        user.birthDate = date
        user.birthDateVerified = true
        
        try await req.users.update(user)
        
        return .ok
    }
    
    private func removeVerification(_ req: Request) async throws -> UserResponse {
        
        let payload = try req.auth.require(Payload.self)
        
        guard let user = try await req.users .find(id: payload.userID) else {
            throw AuthenticationError.userNotFound
        }
        
        user.birthDate = nil
        user.birthDateVerified = false
        
        do {
            try await req.users.update(user)
        } catch {
            if let databaseError = error as? DatabaseError, databaseError.isConstraintFailure {
                throw AuthenticationError.emailAlreadyExists
            } else {
                throw error
            }
        }
        let response = UserResponse(from: user)
        return response
    }
    
}
