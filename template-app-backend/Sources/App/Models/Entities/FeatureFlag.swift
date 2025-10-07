import Vapor
import Fluent

final class FeatureFlag: Model {
    
    static let schema = "user_feature_flags"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "name")
    var name: String
    
    init() {}
    
    init(id: UUID? = nil,
         userID: UUID,
         name: String) {
        self.id = id
        self.$user.id = userID
        self.name = name
    }
}
