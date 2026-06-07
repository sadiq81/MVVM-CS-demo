import Foundation

#if DEBUG

extension PostModel {

    static let mockData = PostModel(
        id: 1,
        title: "Getting Started with Swift",
        body: "Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS. Writing Swift code is interactive and fun, the syntax is concise yet expressive."
    )

    static let mockDataArray: [PostModel] = [
        mockData,
        PostModel(
            id: 2,
            title: "Understanding SwiftUI",
            body: "SwiftUI is an innovative way to build user interfaces across all Apple platforms with the power of Swift."
        ),
        PostModel(
            id: 3,
            title: "Networking Best Practices",
            body: "When building iOS apps, proper networking implementation is crucial. This includes handling errors gracefully and implementing proper caching strategies."
        ),
        PostModel(
            id: 4,
            title: "Core Data vs Realm",
            body: "Choosing the right persistence layer for your app is important. Core Data is Apple's native solution, while Realm offers a simpler API."
        ),
        PostModel(
            id: 5,
            title: "App Architecture Patterns",
            body: "From MVC to MVVM, VIPER, and beyond, choosing the right architecture pattern depends on your team size and project complexity."
        )
    ]

}

#endif
