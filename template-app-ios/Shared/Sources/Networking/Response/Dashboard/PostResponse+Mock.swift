import Foundation

extension PostResponse {
    
    static let mockData: [PostResponse] = [
        PostResponse(
            id: 1,
            title: "Getting Started with Swift",
            body: "Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS. Writing Swift code is interactive and fun, the syntax is concise yet expressive."
        ),
        PostResponse(
            id: 2,
            title: "Understanding SwiftUI",
            body: "SwiftUI is an innovative way to build user interfaces across all Apple platforms with the power of Swift. Build user interfaces for any Apple device using just one set of tools and APIs."
        ),
        PostResponse(
            id: 3,
            title: "Networking Best Practices",
            body: "When building iOS apps, proper networking implementation is crucial. This includes handling errors gracefully, implementing proper caching strategies, and ensuring secure communication."
        ),
        PostResponse(
            id: 4,
            title: "Core Data vs Realm",
            body: "Choosing the right persistence layer for your app is important. Core Data is Apple's native solution, while Realm offers a simpler API and better performance in many cases."
        ),
        PostResponse(
            id: 5,
            title: "App Architecture Patterns",
            body: "From MVC to MVVM, VIPER, and beyond, choosing the right architecture pattern depends on your team size, project complexity, and long-term maintenance goals."
        )
    ]
    
}
