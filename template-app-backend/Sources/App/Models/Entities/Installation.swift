import Vapor
import Fluent

final class Installation: Model {
    
    static let schema = "user_installation"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalParent(key: "user_id")
    var user: User?
    
    @Field(key: "device_model")
    var deviceModel: String
    
    @Field(key: "identifier_for_vendor")
    var identifierForVendor: String?
    
    @Field(key: "fcm_token")
    var fcmToken: String?
    
    init() {}
    
    init(id: UUID? = nil,
         userID: UUID? = nil,
         deviceModel: String,
         identifierForVendor: String?,
         fcmToken: String? = nil) {
        self.id = id
        self.$user.id = userID
        self.deviceModel = deviceModel
        self.identifierForVendor = identifierForVendor
        self.fcmToken = fcmToken
    }
}
