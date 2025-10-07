
import Foundation

extension String {
    
    subscript (range: Range<Int>) -> String {
        let checkedRange = Range(uncheckedBounds: (lower: max(0, min(count, range.lowerBound)),
                                                   upper: min(count, max(0, range.upperBound))))
        
        let start = index(startIndex, offsetBy: checkedRange.lowerBound)
        let end = index(start, offsetBy: checkedRange.upperBound - checkedRange.lowerBound)
        
        return String(self[start ..< end])
    }
    
    var int: Int {
        return Int(self) ?? 0
    }
}
