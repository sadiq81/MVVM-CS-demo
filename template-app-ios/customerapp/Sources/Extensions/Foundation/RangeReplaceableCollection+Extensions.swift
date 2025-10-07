import Foundation

extension RangeReplaceableCollection where Element: Hashable {

    var duplicates: Self {
        var set: Set<Element> = []
        var filtered: Set<Element> = []
        return filter { !set.insert($0).inserted && filtered.insert($0).inserted }
    }
}
