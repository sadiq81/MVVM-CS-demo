import UIKit

extension UICollectionView {

    var indexPaths: [IndexPath] {
        var indexPaths: [IndexPath] = []
        for section in 0..<self.numberOfSections {
            for item in 0..<self.numberOfItems(inSection: section) {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }

}
