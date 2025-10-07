import Foundation
import MustacheFoundation

import MustacheServices
import Combine
import MustacheCombine

protocol AddressServiceType {
    
    func suggestions(for: String) async throws -> [AddressSuggestionModel]
        
}

class AddressService: AddressServiceType {
    
    @LazyInjected
    private var networkService: AsyncNetworkServiceType
    
    func suggestions(for query: String) async throws -> [AddressSuggestionModel] {
        let response = try await self.networkService.addresses(query: query)
        let models: [AddressSuggestionModel] = response.compactMap { AddressSuggestionModel(from: $0) }
        return models
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}

extension AddressSuggestionModel {
    
    init?(from response: AddressSuggestionResponse) {
        guard let type = AddressSuggestionType(rawValue: response.type),
              type != .unknown
        else { return nil}
        
        self.type = type
        self.tekst = response.tekst
        self.forslagstekst = response.forslagstekst
        self.caretpos = response.caretpos
        
        switch type {
            case .adgangsadresse:
                self.adgangsAdresseModel = AdgangsAdresseModel(from: response)
            case .adresse:
                self.addressModel = AddressModel(from: response)
            case .vejnavn:
                self.streetAddressModel = StreetAddressModel(from: response)
            case .unknown:
                break
        }
    }
}

extension StreetAddressModel {
    init?(from response: AddressSuggestionResponse) {
        guard let navn = response.data.navn else { return nil }
        self.navn = navn
        self.href = response.data.href
    }
}

extension AdgangsAdresseModel {
    init?(from response: AddressSuggestionResponse) {
        guard
            let id = response.data.id,
            let vejnavn = response.data.vejnavn,
            let husnr = response.data.husnr,
            let postnr = response.data.postnr,
            let postnrnavn = response.data.postnrnavn,
            let adgangsadresseid = response.data.adgangsadresseid
        else { return nil }
        self.id = id
        self.vejnavn = vejnavn
        self.husnr = husnr
        self.etage = response.data.etage
        self.dør = response.data.dør
        self.postnr = postnr
        self.postnrnavn = postnrnavn
        self.adgangsadresseid = adgangsadresseid
        self.href = response.data.href
    }
}

extension AddressModel {
    init?(from response: AddressSuggestionResponse) {
        guard
            let id = response.data.id,
            let vejnavn = response.data.vejnavn,
            let husnr = response.data.husnr,
            let postnr = response.data.postnr,
            let postnrnavn = response.data.postnrnavn
        else { return nil }
        self.id = id
        self.vejnavn = vejnavn
        self.husnr = husnr
        self.etage = response.data.etage
        self.dør = response.data.dør
        self.postnr = postnr
        self.postnrnavn = postnrnavn
        self.href = response.data.href
    }
}
