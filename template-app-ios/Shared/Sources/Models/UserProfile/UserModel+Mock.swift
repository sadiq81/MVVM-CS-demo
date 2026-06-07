import Foundation

#if DEBUG

extension UserModel {

    static let mockData = UserModel(
        id: "usr_a1b2c3d4",
        firstName: "Tommy",
        lastName: "Nielsen",
        birthDate: DateComponents(calendar: .current, year: 1990, month: 6, day: 15).date,
        isBirthDateValidated: true,
        phoneCountry: "+45",
        phoneNumber: "12345678",
        email: "tommy@example.com",
        street: "Vesterbrogade 42",
        zipCode: "1620",
        city: "Copenhagen",
        country: "DK",
        imageURL: URL(string: "https://example.com/avatar.jpg")
    )

    static let mockDataMinimal = UserModel(
        id: "usr_e5f6g7h8",
        firstName: "Jane",
        email: "jane@example.com"
    )

}

#endif
