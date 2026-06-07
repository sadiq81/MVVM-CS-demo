import Vapor
import Fluent

final class User: Model, Authenticatable {
   
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String?
    
    @Field(key: "last_name")
    var lastName: String?
    
    @Field(key: "birth_date")
    var birthDate: Date?
    
    @Field(key: "birth_date_verified")
    var birthDateVerified: Bool
    
    @Field(key: "phone_country")
    var phoneCountry: String?
    
    @Field(key: "phone_number")
    var phoneNumber: String?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "street")
    var street: String?
    
    @Field(key: "zip_code")
    var zipCode: String?
    
    @Field(key: "city")
    var city: String?
    
    @Field(key: "country")
    var country: String?
    
    @Field(key: "image_url")
    var imageURL: URL?
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    @Field(key: "is_email_verified")
    var isEmailVerified: Bool
    
    init() {}
    
    internal init(id: UUID? = nil,
                  firstName: String? = nil,
                  lastName: String? = nil,
                  birthDate: Date? = nil,
                  birthDateVerified: Bool = false,
                  phoneCountry: String? = nil,
                  phoneNumber: String? = nil,
                  email: String,
                  street: String? = nil,
                  zipCode: String? = nil,
                  city: String? = nil,
                  country: String? = nil,
                  imageURL: URL? = nil,
                  passwordHash: String,
                  isAdmin: Bool = false,
                  isEmailVerified: Bool = true) {
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
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
    }
    
}
