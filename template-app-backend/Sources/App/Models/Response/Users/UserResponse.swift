import Vapor

struct UserResponse: Content {
    
    let id: UUID?
    let firstName: String?
    let lastName: String?
    let birthDate: Date?
    let birthDateVerified: Bool
    let phoneCountry: String?
    let phoneNumber: String?
    let email: String?
    let street: String?
    let zipCode: String?
    let city: String?
    let country: String?
    let imageURL: URL?
    
    init(id: UUID?, firstName: String? = nil, lastName: String? = nil, birthDate: Date? = nil, birthDateVerified: Bool = false, phoneCountry: String? = nil, phoneNumber: String? = nil, email: String? = nil, street: String? = nil, zipCode: String? = nil, city: String? = nil, country: String? = nil, imageURL: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.birthDateVerified = birthDateVerified
        self.phoneCountry = phoneCountry
        self.phoneNumber = phoneNumber
        self.email = email
        self.street = street
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.imageURL = imageURL
    }
    
    init(from user: User) {
        self.init(id: user.id,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  birthDate: user.birthDate,
                  birthDateVerified: user.birthDateVerified,
                  phoneCountry: user.phoneCountry,
                  phoneNumber: user.phoneNumber,
                  email: user.email,
                  street: user.street,
                  zipCode: user.zipCode,
                  city: user.city,
                  country: user.country,
                  imageURL: user.imageURL)
    }
}


