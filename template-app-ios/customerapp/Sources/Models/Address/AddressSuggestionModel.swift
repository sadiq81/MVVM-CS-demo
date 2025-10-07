import Foundation

// TODO: Give variables english names
struct StreetAddressModel: Hashable, Codable {
    
    let navn: String
    let href: URL
    
}

struct AdgangsAdresseModel: Hashable, Codable {
    
    let id: String
    let vejnavn: String
    let husnr: String
    let etage: String?
    let dør: String?
    let postnr: String
    let postnrnavn: String
    let adgangsadresseid: String?
    let href: URL
    
    var readableStreetAddress: String {
        var string = "\(self.vejnavn) \(self.husnr)"
        if let etage = self.etage {
            string += ", \(etage)"
        }
        if let dør = self.dør {
            string += " \(dør)"
        }
        return string
    }
    
}

struct AddressModel: Hashable, Codable {
    let id: String
    let vejnavn: String
    let husnr: String
    let etage: String?
    let dør: String?
    let postnr: String
    let postnrnavn: String
    let href: URL
    
    var readableStreetAddress: String {
        var string = "\(self.vejnavn) \(self.husnr)"
        if let etage = self.etage {
            string += ", \(etage)"
        }
        if let dør = self.dør {
            string += " \(dør)"
        }
        return string
    }
}

struct AddressSuggestionModel: Hashable, Codable {
    
    let type: AddressSuggestionType
    let tekst: String
    let forslagstekst: String
    let caretpos: Int
    
    var streetAddressModel: StreetAddressModel? = nil
    var adgangsAdresseModel: AdgangsAdresseModel? = nil
    var addressModel: AddressModel? = nil
    
    
    
}

enum AddressSuggestionType: String, Hashable, Codable {
    
    case vejnavn
    case adresse
    case adgangsadresse
    case unknown
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        switch stringValue {
            case "vejnavn":
                self = .vejnavn
            case "adresse":
                self = .adresse
            case "adgangsadresse":
                self = .adgangsadresse
            default:
                self = .unknown
        }
    }
}
