public struct RecordName {
    public let entityName: String
    public let recordType: String
    
    public init(entityName: String, recordType: String) {
        self.entityName = entityName
        self.recordType = recordType
    }
}

extension RecordName {
    public init(name: String) {
        self.entityName = name
        self.recordType = name
    }
}
