import Vapor

extension Request {
    
    // MARK: Repositories
    var users: UserRepository { application.repositories.users.for(self) }
    var refreshTokens: RefreshTokenRepository { application.repositories.refreshTokens.for(self) }
    var emailTokens: EmailTokenRepository { application.repositories.emailTokens.for(self) }
    var passwordTokens: PasswordTokenRepository { application.repositories.passwordTokens.for(self) }
    var onboardingStates: OnboardingStateRepository { application.repositories.onboardingStates.for(self) }
    var installations: InstallationRepository { application.repositories.installations.for(self) }
    
}
