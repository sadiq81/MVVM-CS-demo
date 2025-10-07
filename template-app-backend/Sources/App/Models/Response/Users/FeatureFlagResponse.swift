import Vapor

struct FeatureFlagResponse: Content {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(from featureFlag: FeatureFlag) {
        self.init(name: featureFlag.name)
    }
}
