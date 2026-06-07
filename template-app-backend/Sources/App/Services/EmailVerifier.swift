import Vapor
import Queues

struct EmailVerifier {
    
    let emailTokenRepository: EmailTokenRepository
    let config: AppConfig
    let queue: Queue
    let eventLoop: EventLoop
    let generator: RandomGenerator
    
    func verify(for user: User) async throws  {
        let token = self.generator.generate(bits: 256)
        let emailToken = try EmailToken(userID: user.requireID(), token: SHA256.hash(token))
        let verifyUrl = self.url(token: token)
        try await self.emailTokenRepository.create(emailToken)
//        try await self.queue.dispatch(EmailJob.self, .init(VerificationEmail(verifyUrl: verifyUrl), to: user.email), maxRetryCount: 3)
    }
    
    private func url(token: String) -> String {
        #"\#(self.config.apiURL)/auth/email-verification?token=\#(token)"#
    }
}

extension Application {
    var emailVerifier: EmailVerifier {
        .init(emailTokenRepository: self.repositories.emailTokens, config: self.config, queue: self.queues.queue, eventLoop: eventLoopGroup.next(), generator: self.random)
    }
}

extension Request {
    var emailVerifier: EmailVerifier {
        .init(emailTokenRepository: self.emailTokens, config: application.config, queue: self.queue, eventLoop: eventLoop, generator: self.application.random)
    }
}

