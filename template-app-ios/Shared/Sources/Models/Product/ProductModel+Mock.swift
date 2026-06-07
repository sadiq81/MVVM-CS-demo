import Foundation

#if DEBUG

extension ProductModel {

    static let mockData = ProductModel(
        id: 1,
        title: "iPhone 15 Pro",
        description: "The latest iPhone with A17 Pro chip, titanium design, and advanced camera system.",
        price: 999.99,
        discountPercentage: 5.0,
        rating: 4.8,
        stock: 42,
        brand: "Apple",
        category: "smartphones",
        thumbnail: URL(string: "https://dummyjson.com/image/i/products/1/thumbnail.jpg"),
        images: [
            URL(string: "https://dummyjson.com/image/i/products/1/1.jpg")!,
            URL(string: "https://dummyjson.com/image/i/products/1/2.jpg")!
        ]
    )

    static let mockDataArray: [ProductModel] = [
        mockData,
        ProductModel(
            id: 2,
            title: "MacBook Pro 16\"",
            description: "Supercharged by M3 Pro or M3 Max chip for exceptional performance.",
            price: 2499.99,
            discountPercentage: 3.5,
            rating: 4.9,
            stock: 18,
            brand: "Apple",
            category: "laptops",
            thumbnail: URL(string: "https://dummyjson.com/image/i/products/2/thumbnail.jpg"),
            images: [
                URL(string: "https://dummyjson.com/image/i/products/2/1.jpg")!
            ]
        ),
        ProductModel(
            id: 3,
            title: "Samsung Galaxy S24 Ultra",
            description: "Premium Android smartphone with S Pen support and advanced AI features.",
            price: 1199.99,
            discountPercentage: 8.0,
            rating: 4.6,
            stock: 35,
            brand: "Samsung",
            category: "smartphones",
            thumbnail: URL(string: "https://dummyjson.com/image/i/products/3/thumbnail.jpg"),
            images: [
                URL(string: "https://dummyjson.com/image/i/products/3/1.jpg")!
            ]
        ),
        ProductModel(
            id: 4,
            title: "Sony WH-1000XM5",
            description: "Industry-leading noise canceling headphones with exceptional sound quality.",
            price: 349.99,
            discountPercentage: 12.0,
            rating: 4.7,
            stock: 67,
            brand: "Sony",
            category: "accessories",
            thumbnail: URL(string: "https://dummyjson.com/image/i/products/4/thumbnail.jpg"),
            images: [
                URL(string: "https://dummyjson.com/image/i/products/4/1.jpg")!
            ]
        ),
        ProductModel(
            id: 5,
            title: "Nike Air Max 90",
            description: "Classic sneaker with visible Air cushioning and retro design.",
            price: 129.99,
            discountPercentage: 15.0,
            rating: 4.5,
            stock: 120,
            brand: "Nike",
            category: "mensShoes",
            thumbnail: URL(string: "https://dummyjson.com/image/i/products/5/thumbnail.jpg"),
            images: [
                URL(string: "https://dummyjson.com/image/i/products/5/1.jpg")!
            ]
        )
    ]

}

#endif
