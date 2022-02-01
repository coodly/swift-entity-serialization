public struct FieldDefinition {
    internal let name: String
    internal let valueType: ValueType
    
    public init(name: String, valueType: ValueType) {
        self.name = name
        self.valueType = valueType
    }
}
