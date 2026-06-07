import Foundation

#if DEBUG

extension AlbumModel {

    static let mockData = AlbumModel(
        id: 1,
        title: "Summer Vacation 2024"
    )

    static let mockDataArray: [AlbumModel] = [
        mockData,
        AlbumModel(id: 2, title: "Family Portraits"),
        AlbumModel(id: 3, title: "Wedding Photos"),
        AlbumModel(id: 4, title: "Nature Photography"),
        AlbumModel(id: 5, title: "City Nights")
    ]

}

#endif
