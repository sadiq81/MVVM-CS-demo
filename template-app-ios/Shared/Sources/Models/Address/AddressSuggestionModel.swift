import Foundation

struct StreetAddressModel: Hashable, Codable {

    let name: String
    let href: URL

    private enum CodingKeys: String, CodingKey {
        case name = "navn"
        case href
    }
}

struct AccessAddressModel: Hashable, Codable {

    let id: String
    let streetName: String
    let houseNumber: String
    let floor: String?
    let door: String?
    let postalCode: String
    let city: String
    let accessAddressId: String?
    let href: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case streetName = "vejnavn"
        case houseNumber = "husnr"
        case floor = "etage"
        case door = "dør"
        case postalCode = "postnr"
        case city = "postnrnavn"
        case accessAddressId = "adgangsadresseid"
        case href
    }

    var readableStreetAddress: String {
        var string = "\(self.streetName) \(self.houseNumber)"
        if let floor = self.floor {
            string += ", \(floor)"
        }
        if let door = self.door {
            string += " \(door)"
        }
        return string
    }
}

struct AddressModel: Hashable, Codable {

    let id: String
    let streetName: String
    let houseNumber: String
    let floor: String?
    let door: String?
    let postalCode: String
    let city: String
    let href: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case streetName = "vejnavn"
        case houseNumber = "husnr"
        case floor = "etage"
        case door = "dør"
        case postalCode = "postnr"
        case city = "postnrnavn"
        case href
    }

    var readableStreetAddress: String {
        var string = "\(self.streetName) \(self.houseNumber)"
        if let floor = self.floor {
            string += ", \(floor)"
        }
        if let door = self.door {
            string += " \(door)"
        }
        return string
    }
}

struct AddressSuggestionModel: Hashable, Codable {

    let type: AddressSuggestionType
    let text: String
    let suggestionText: String
    let caretPosition: Int

    var streetAddressModel: StreetAddressModel? = nil
    var accessAddressModel: AccessAddressModel? = nil
    var addressModel: AddressModel? = nil

    private enum CodingKeys: String, CodingKey {
        case type
        case text = "tekst"
        case suggestionText = "forslagstekst"
        case caretPosition = "caretpos"
        case streetAddressModel
        case accessAddressModel
        case addressModel
    }
}

enum AddressSuggestionType: String, Hashable, Codable {

    case streetName
    case address
    case accessAddress
    case unknown

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        switch stringValue {
            case "vejnavn":
                self = .streetName
            case "adresse":
                self = .address
            case "adgangsadresse":
                self = .accessAddress
            default:
                self = .unknown
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .streetName:
                try container.encode("vejnavn")
            case .address:
                try container.encode("adresse")
            case .accessAddress:
                try container.encode("adgangsadresse")
            case .unknown:
                try container.encode("unknown")
        }
    }
}
