import Foundation

struct AddressSuggestionResponse: Codable {

    let type: String
    let text: String
    let suggestionText: String
    let caretPosition: Int
    let data: Data

    private enum CodingKeys: String, CodingKey {
        case type
        case text = "tekst"
        case suggestionText = "forslagstekst"
        case caretPosition = "caretpos"
        case data
    }

    struct Data: Codable {
        let name: String?
        let id: String?
        let streetName: String?
        let houseNumber: String?
        let floor: String?
        let door: String?
        let postalCode: String?
        let city: String?
        let accessAddressId: String?
        let x: Double?
        let y: Double?
        let href: URL

        private enum CodingKeys: String, CodingKey {
            case name = "navn"
            case id
            case streetName = "vejnavn"
            case houseNumber = "husnr"
            case floor = "etage"
            case door = "dør"
            case postalCode = "postnr"
            case city = "postnrnavn"
            case accessAddressId = "adgangsadresseid"
            case x, y
            case href
        }
    }
}
