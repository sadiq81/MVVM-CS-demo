import Combine
import Foundation

import MustacheCombine
import MustacheFoundation
import MustacheServices

protocol AddressServiceType: Sendable {

    func suggestions(for: String) async throws -> [AddressSuggestionModel]

}

final class AddressService: AddressServiceType, @unchecked Sendable {

    @LazyInjected(\.asyncNetworkService)
    private var networkService: any AsyncNetworkServiceType

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
        guard let type = AddressSuggestionType(apiValue: response.type),
              type != .unknown
        else { return nil }

        self.type = type
        self.text = response.text
        self.suggestionText = response.suggestionText
        self.caretPosition = response.caretPosition

        switch type {
            case .accessAddress:
                self.accessAddressModel = AccessAddressModel(from: response)
            case .address:
                self.addressModel = AddressModel(from: response)
            case .streetName:
                self.streetAddressModel = StreetAddressModel(from: response)
            case .unknown:
                break
        }
    }
}

extension StreetAddressModel {
    init?(from response: AddressSuggestionResponse) {
        guard let name = response.data.name else { return nil }
        self.name = name
        self.href = response.data.href
    }
}

extension AccessAddressModel {
    init?(from response: AddressSuggestionResponse) {
        guard
            let id = response.data.id,
            let streetName = response.data.streetName,
            let houseNumber = response.data.houseNumber,
            let postalCode = response.data.postalCode,
            let city = response.data.city,
            let accessAddressId = response.data.accessAddressId
        else { return nil }
        self.id = id
        self.streetName = streetName
        self.houseNumber = houseNumber
        self.floor = response.data.floor
        self.door = response.data.door
        self.postalCode = postalCode
        self.city = city
        self.accessAddressId = accessAddressId
        self.href = response.data.href
    }
}

extension AddressModel {
    init?(from response: AddressSuggestionResponse) {
        guard
            let id = response.data.id,
            let streetName = response.data.streetName,
            let houseNumber = response.data.houseNumber,
            let postalCode = response.data.postalCode,
            let city = response.data.city
        else { return nil }
        self.id = id
        self.streetName = streetName
        self.houseNumber = houseNumber
        self.floor = response.data.floor
        self.door = response.data.door
        self.postalCode = postalCode
        self.city = city
        self.href = response.data.href
    }
}

private extension AddressSuggestionType {
    init?(apiValue: String) {
        switch apiValue {
            case "vejnavn": self = .streetName
            case "adresse": self = .address
            case "adgangsadresse": self = .accessAddress
            default: self = .unknown
        }
    }
}
