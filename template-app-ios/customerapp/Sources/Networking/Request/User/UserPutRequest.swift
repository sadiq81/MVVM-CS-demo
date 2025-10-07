import Foundation

struct UserPutRequest: Encodable {

    var firstName: String?
    var lastName: String?
    var birthDate: Date?
    var phoneNumber: String?
    var email: String?
    var street: String?
    var zipCode: String?
    var city: String?
    var country: String?
    var imageURL: URL?

}

extension UserPutRequest {

    init(model: UserModel) {
        self.init(firstName: model.firstName,
                  lastName: model.lastName,
                  birthDate: model.birthDate,
                  phoneNumber: model.phoneNumber,
                  email: model.email,
                  street: model.street,
                  zipCode: model.zipCode,
                  city: model.city,
                  country: model.country,
                  imageURL: model.imageURL)
    }
}
