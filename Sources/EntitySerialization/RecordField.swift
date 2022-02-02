public struct RecordField {
    public let attribute: FieldDefinition // Core Data attribute
    public let field: FieldDefinition // CKRecord field

    public init(attribute: FieldDefinition, field: FieldDefinition) {
        self.attribute = attribute
        self.field = field
    }
}

extension RecordField {
    public init(attribute: String, field: String, valueType: ValueType) {
        self.attribute = FieldDefinition(name: attribute, valueType: valueType)
        self.field = FieldDefinition(name: field, valueType: valueType)
    }

    public init(_ name: String, valueType: ValueType) {
        self.attribute = FieldDefinition(name: name, valueType: valueType)
        self.field = FieldDefinition(name: name, valueType: valueType)
    }
}
