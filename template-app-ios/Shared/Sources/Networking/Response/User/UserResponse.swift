import Foundation

struct UserResponse: Decodable {

    var id: String
    var firstName: String?
    var lastName: String?
    var birthDate: Date?
    var birthDateVerified: Bool
    var phoneNumber: String?
    var email: String?
    var street: String?
    var zipCode: String?
    var city: String?
    var country: String?
    var imageURL: URL?

}

