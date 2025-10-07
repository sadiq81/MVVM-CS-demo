import Foundation
import UIKit

// Credits https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/

@available(macOS 10.15, *)
extension Task where Failure == Error {
    
    @discardableResult
    static func loading(button: UIButton, priority: TaskPriority? = nil, operation: @Sendable @escaping () async throws -> Success) -> Task {
        Task { @MainActor in
            button.isBusy = true
            let result = try await operation()
            button.isBusy = false
            return result
        }
    }
}
