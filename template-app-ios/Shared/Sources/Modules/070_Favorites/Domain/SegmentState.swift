
enum SegmentState: Int {
    case am
    case nz

    var filterString: String {
        switch self {
            case .am: return "abcdefghijklm"
            case .nz: return "nopqrstuwvxyz"
        }
    }

    func include(_ product: ProductModel) -> Bool {
        let first = String(product.title.first ?? "a").lowercased()
        let include = self.filterString.contains(first)
        return include
    }
}
