
import Foundation

extension Calendar {
    
    static var daDK: Calendar {
        var calender = Calendar(identifier: .gregorian)
        calender.locale = .daDK
        return calender
    }
}
