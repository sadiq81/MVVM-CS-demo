#if DEBUG

import Foundation

final class PreviewAddressService: AddressServiceType, @unchecked Sendable {

    func suggestions(for query: String) async throws -> [AddressSuggestionModel] {
        return AddressSuggestionModel.mockDataArray
    }

}

#endif
