import Foundation

extension Array {

    func safe(range: Range<Index>) -> [Element]? {
        guard range.startIndex >= self.startIndex else { return nil }
        guard range.endIndex <= self.endIndex else { return nil }

        return Array(self[range])
    }
}
