import Foundation

#if DEBUG

extension FeatureFlag {

    static let mockData: FeatureFlag = .feature1

    static let mockDataArray: [FeatureFlag] = [.feature1, .feature2]

}

#endif
