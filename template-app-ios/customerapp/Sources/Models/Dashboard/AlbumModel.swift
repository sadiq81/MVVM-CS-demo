import Foundation

class AlbumModel: Codable {

    var id: Int
    var title: String

    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}

extension AlbumModel: Hashable {

    static func == (lhs: AlbumModel, rhs: AlbumModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension AlbumModel: Comparable {

    static func < (lhs: AlbumModel, rhs: AlbumModel) -> Bool {
        return lhs.id < rhs.id
    }

}

extension AlbumModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "AlbumModel(id: \(self.id), title: \(self.title))"
    }

}
