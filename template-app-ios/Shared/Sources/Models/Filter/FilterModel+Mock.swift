import Foundation

#if DEBUG

extension BrandFilter {

    static let mockData = BrandFilter(value: "Apple")

    static let mockDataArray: [BrandFilter] = [
        mockData,
        BrandFilter(value: "Samsung"),
        BrandFilter(value: "Sony"),
        BrandFilter(value: "Nike"),
        BrandFilter(value: "Gucci")
    ]

}

extension FilterModel {

    static let mockData = FilterModel(
        categories: [.smartphones, .laptops, .fragrances, .furniture, .sunglasses],
        brands: BrandFilter.mockDataArray
    )

}

#endif
