import Foundation

#if DEBUG

extension StreetAddressModel {

    static let mockData = StreetAddressModel(
        name: "Vesterbrogade",
        href: URL(string: "https://api.dataforsyningen.dk/vejnavne/Vesterbrogade")!
    )

}

extension AccessAddressModel {

    static let mockData = AccessAddressModel(
        id: "0a3f507a-1234-5678-9abc-def012345678",
        streetName: "Vesterbrogade",
        houseNumber: "42",
        floor: "3",
        door: "tv",
        postalCode: "1620",
        city: "K\u{00F8}benhavn V",
        accessAddressId: "0a3f507a-abcd-5678-9abc-def012345678",
        href: URL(string: "https://api.dataforsyningen.dk/adgangsadresser/0a3f507a-1234-5678-9abc-def012345678")!
    )

}

extension AddressModel {

    static let mockData = AddressModel(
        id: "0a3f507a-1234-5678-9abc-def012345678",
        streetName: "Vesterbrogade",
        houseNumber: "42",
        floor: "3",
        door: "tv",
        postalCode: "1620",
        city: "K\u{00F8}benhavn V",
        href: URL(string: "https://api.dataforsyningen.dk/adresser/0a3f507a-1234-5678-9abc-def012345678")!
    )

}

extension AddressSuggestionModel {

    static let mockData = AddressSuggestionModel(
        type: .streetName,
        text: "Vesterbrogade",
        suggestionText: "Vesterbrogade, K\u{00F8}benhavn",
        caretPosition: 14,
        streetAddressModel: StreetAddressModel.mockData
    )

    static let mockDataArray: [AddressSuggestionModel] = [
        mockData,
        AddressSuggestionModel(
            type: .accessAddress,
            text: "Vesterbrogade 42",
            suggestionText: "Vesterbrogade 42, 3. tv, 1620 K\u{00F8}benhavn V",
            caretPosition: 16,
            accessAddressModel: AccessAddressModel.mockData
        ),
        AddressSuggestionModel(
            type: .address,
            text: "N\u{00F8}rrebrogade 15",
            suggestionText: "N\u{00F8}rrebrogade 15, 2200 K\u{00F8}benhavn N",
            caretPosition: 17,
            addressModel: AddressModel.mockData
        )
    ]

}

#endif
