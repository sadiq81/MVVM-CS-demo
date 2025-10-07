
import Foundation

// TODO: Give variables english names
struct AddressSuggestionResponse: Codable {
    
    let type: String
    let tekst: String
    let forslagstekst: String
    let caretpos: Int
    let data: Data
 
    struct Data : Codable {
        let navn: String?

        let id: String?
        let vejnavn: String?
        let husnr: String?
        let etage: String?
        let dør: String?
        let postnr: String?
        let postnrnavn: String?
        let adgangsadresseid: String?
        let x: Double?
        let y: Double?
        
        let href: URL
    }
}

