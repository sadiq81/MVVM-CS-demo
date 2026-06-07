import Foundation

extension CommentResponse {
    
    static let mockData: [CommentResponse] = [
        CommentResponse(
            id: 1,
            name: "Great post!",
            email: "john.doe@example.com",
            body: "This is exactly what I was looking for. Thanks for sharing!"
        ),
        CommentResponse(
            id: 2,
            name: "Question about implementation",
            email: "sarah.smith@example.com",
            body: "Could you elaborate more on the technical details? I'm particularly interested in the architecture."
        ),
        CommentResponse(
            id: 3,
            name: "Helpful information",
            email: "mike.jones@example.com",
            body: "Very informative article. I've bookmarked it for future reference."
        ),
        CommentResponse(
            id: 4,
            name: "Follow-up thoughts",
            email: "emma.wilson@example.com",
            body: "I tried this approach and it worked perfectly. One suggestion though: consider adding error handling for edge cases."
        ),
        CommentResponse(
            id: 5,
            name: "Thanks!",
            email: "alex.brown@example.com",
            body: "Simple and straightforward. Exactly what I needed."
        )
    ]
    
    
}
