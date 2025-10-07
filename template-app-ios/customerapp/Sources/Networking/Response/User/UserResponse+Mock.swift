import Foundation

extension UserResponse {
    
    static let mockData = UserResponse(id: "1",
                                       firstName: "John",
                                       lastName: "Snow",
                                       birthDate: Date(),
                                       birthDateVerified: false,
                                       phoneNumber: "+33 612-345-678",
                                       email: "john.snow@winterfell.com",
                                       street: "Winterfell",
                                       zipCode: "12345",
                                       city: "Winterfell",
                                       country: "Westeros",
                                       imageURL: URL(string: "https://example.com/image.png")!)
    
}


