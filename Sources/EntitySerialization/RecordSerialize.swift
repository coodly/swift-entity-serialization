import CoreData

public struct RecordSerialize {
    public let recordName: RecordName
    internal let fields: [RecordField]
    internal var afterLoad: ((NSManagedObject, NSManagedObjectContext) -> Void)?
    
    public init(recordName: RecordName, fields: [RecordField]) {
        self.recordName = recordName
        self.fields = fields
    }
    
    public func with(load: @escaping ((NSManagedObject, NSManagedObjectContext) -> Void)) -> Self {
        var modified = self
        modified.afterLoad = load
        return  modified
    }
    
    internal func loaded(entity: NSManagedObject, in context: NSManagedObjectContext) {
        afterLoad?(entity, context)
    }
    
    public func without(attribute: String) -> RecordSerialize {
        RecordSerialize(recordName: recordName, fields: fields.filter({ $0.attribute.name != attribute }))
    }
}
