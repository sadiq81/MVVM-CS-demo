import Foundation

#if DEBUG

extension TodoModel {

    static let mockData = TodoModel(
        id: 1,
        title: "Complete project documentation",
        completed: true
    )

    static let mockDataArray: [TodoModel] = [
        mockData,
        TodoModel(id: 2, title: "Review pull requests", completed: true),
        TodoModel(id: 3, title: "Update dependencies", completed: false),
        TodoModel(id: 4, title: "Write unit tests for new features", completed: false),
        TodoModel(id: 5, title: "Refactor networking layer", completed: false)
    ]

}

#endif
