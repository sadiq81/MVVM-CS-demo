import Foundation

extension Int {

    static func getUniqueRandomNumbers(min: Int, max: Int, count: Int, existing: Set<Int> = Set()) -> [Int] {
        var set = existing
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }

}
