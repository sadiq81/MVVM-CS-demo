import Foundation

extension DateFormatter {

    static let dMMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
        return formatter
    }()

}
