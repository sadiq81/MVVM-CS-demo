import Vapor
import Queues

struct PasswordResetter {
    let queue: Queue
    let repository: PasswordTokenRepository
    let eventLoop: EventLoop
    let config: AppConfig
    let generator: RandomGenerator
    
    /// Sends a email to the user with a reset-password URL
    func reset(for user: User) async throws {
        let token = self.generator.generate(bits: 256)
        let resetPasswordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash(token))
        let url = self.resetURL(for: token)
        let email = ResetPasswordEmail(resetURL: url)
        try await self.repository.create(resetPasswordToken)
//        try await self.queue.dispatch(EmailJob.self, .init(email, to: user.email), maxRetryCount: 3)
    }
    
    private func resetURL(for token: String) -> String {
        "\(self.config.frontendURL)/auth/reset-password?token=\(token)"
    }
}

extension Request {
    var passwordResetter: PasswordResetter {
        .init(queue: self.queue, repository: self.passwordTokens, eventLoop: self.eventLoop, config: self.application.config, generator: self.application.random)
    }
}
