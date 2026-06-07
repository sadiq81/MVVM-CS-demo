import Foundation

extension TodoResponse {
    
    static let mockData: [TodoResponse] = [
        TodoResponse(id: 1, title: "Complete project documentation", completed: true),
        TodoResponse(id: 2, title: "Review pull requests", completed: true),
        TodoResponse(id: 3, title: "Update dependencies", completed: false),
        TodoResponse(id: 4, title: "Write unit tests for new features", completed: false),
        TodoResponse(id: 5, title: "Refactor networking layer", completed: false),
        TodoResponse(id: 6, title: "Design new app icon", completed: true),
        TodoResponse(id: 7, title: "Optimize app performance", completed: false),
        TodoResponse(id: 8, title: "Implement push notifications", completed: false)
    ]
}
