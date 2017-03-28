import Foundation
import RealmSwift
import JASON

public class User: Object {
    
    public dynamic var id = 0
    public dynamic var username = ""
    public dynamic var name = ""
    public dynamic var email = ""
    public dynamic var link = ""
    public dynamic var avatar = ""
    public dynamic var content = ""
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    public override static func indexedProperties() -> [String] {
        return [
            "username",
            "email"
        ]
    }
    
    public convenience init(json: JSON) {
        self.init()
        
        id = json[.id]
        username = json[.username]
        name = json[.name]
        email = json[.email]
        link = json[.link]
        avatar = json[.avatar]
        content = json[.description]
    }
    
}
