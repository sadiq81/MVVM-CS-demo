import Foundation

extension NumberFormatter {

    static let integer: NumberFormatter = {

        let formatter = NumberFormatter()

        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 0
        formatter.roundingMode = .down

        return formatter
    }()

    static let decimal: NumberFormatter = {

        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 0

        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        formatter.roundingMode = .down

        return formatter
    }()

}
