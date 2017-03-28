import Foundation
import RealmSwift
import JASON

public protocol Termable: class {
    
    var id: Int { get set }
    var name: String { get set }
    var slug: String { get set }
    var taxonomy: String { get set }
    var parent: Int { get set }
    var count: Int { get set }
}

public class Term: Object, Termable {
    
    public dynamic var id = 0
    public dynamic var name = ""
    public dynamic var slug = ""
    public dynamic var taxonomy = ""
    public dynamic var parent = 0
    public dynamic var count = 0
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    public override static func indexedProperties() -> [String] {
        return [
            "name",
            "slug",
            "taxonomy"
        ]
    }
    
    public convenience init(json: JSON) {
        self.init()
        
        id = json[.id]
        name = json[.name]
        slug = json[.slug]
        taxonomy = json[.taxonomy]
        parent = json[.parent]
        count = json[.count]
    }
    
}
