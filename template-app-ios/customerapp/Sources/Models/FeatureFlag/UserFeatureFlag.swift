import Foundation

enum FeatureFlag: String, Codable, Equatable {
    
    case feature1
    case feature2

    init?(_ int: Int) {
        switch int {
            case 1:
                self = .feature1
            case 2:
                self = .feature2
            default:
                return nil
        }
    }
    
}
