import Foundation

#if DEBUG

extension CommentModel {

    static let mockData = CommentModel(
        id: 1,
        name: "Great post!",
        email: "john.doe@example.com",
        body: "This is exactly what I was looking for. Thanks for sharing!"
    )

    static let mockDataArray: [CommentModel] = [
        mockData,
        CommentModel(
            id: 2,
            name: "Question about implementation",
            email: "sarah.smith@example.com",
            body: "Could you elaborate more on the technical details? I'm particularly interested in the architecture."
        ),
        CommentModel(
            id: 3,
            name: "Helpful information",
            email: "mike.jones@example.com",
            body: "Very informative article. I've bookmarked it for future reference."
        ),
        CommentModel(
            id: 4,
            name: "Follow-up thoughts",
            email: "emma.wilson@example.com",
            body: "I tried this approach and it worked perfectly. One suggestion though: consider adding error handling for edge cases."
        ),
        CommentModel(
            id: 5,
            name: "Thanks!",
            email: "alex.brown@example.com",
            body: "Simple and straightforward. Exactly what I needed."
        )
    ]

}

#endif
