
enum CountrySelectionMode: Identifiable {
    case phone
    case address

    var id: String {
        switch self {
            case .phone: return "phone"
            case .address: return "address"
        }
    }
}
