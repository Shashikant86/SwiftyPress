protocol Serviceable {
    associatedtype DataType
    
    func get(completion: @escaping ([DataType]) -> Void)
}
