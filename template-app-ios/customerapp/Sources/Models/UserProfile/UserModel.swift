import Foundation

class UserModel: Codable {

    var id: String
    var firstName: String?
    var lastName: String?
    var birthDate: Date?
    var isBirthDateValidated: Bool
    var phoneCountry: String?
    var phoneNumber: String?
    var email: String?
    var street: String?
    var zipCode: String?
    var city: String?
    var country: String?
    var imageURL: URL?

    init(id: String, firstName: String? = nil, lastName: String? = nil, birthDate: Date? = nil, isBirthDateValidated: Bool = false, phoneCountry: String? = nil, phoneNumber: String? = nil, email: String? = nil, street: String? = nil, zipCode: String? = nil, city: String? = nil, country: String? = nil, imageURL: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.isBirthDateValidated = isBirthDateValidated
        self.phoneCountry = phoneCountry
        self.phoneNumber = phoneNumber
        self.email = email
        self.street = street
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.imageURL = imageURL
    }

}

extension UserModel {

    var searchText: String {
        return "\(self.firstName ?? "") \(self.street ?? "") \(self.phoneNumber ?? "") \(self.email ?? "")"
    }

}

extension UserModel: Hashable {

    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.firstName == rhs.firstName else { return false }
        guard lhs.lastName == rhs.lastName else { return false }
        guard lhs.birthDate == rhs.birthDate else { return false }
        guard lhs.isBirthDateValidated == rhs.isBirthDateValidated else { return false }
        guard lhs.phoneCountry == rhs.phoneCountry else { return false }
        guard lhs.phoneNumber == rhs.phoneNumber else { return false }
        guard lhs.email == rhs.email else { return false }
        guard lhs.street == rhs.street else { return false }
        guard lhs.zipCode == rhs.zipCode else { return false }
        guard lhs.city == rhs.city else { return false }
        guard lhs.country == rhs.country else { return false }
        guard lhs.imageURL == rhs.imageURL else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension UserModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "UserModel(id: \(self.id), firstName: \(String(describing: self.firstName)))"
    }

}
