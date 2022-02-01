import CloudKit
import CoreData

public class CoreDataWrite {
    private let context: NSManagedObjectContext
    private let serialize: [RecordSerialize]
    public init(context: NSManagedObjectContext, serlialize: [RecordSerialize]) {
        self.context = context
        self.serialize = serlialize
    }
    
    public func write(record: CKRecord) {
        context.performAndWait {
            guard let serialization = serialize.first(where: { $0.recordName.recordType == record.recordType }) else {
                fatalError()
            }
            
            let saved: NSManagedObject
            if let existing = context.entity(named: serialization.recordName.entityName, recordName: record.recordID.recordName) {
                saved = existing
            } else {
                saved = NSEntityDescription.insertNewObject(
                    forEntityName: serialization.recordName.entityName,
                    into: context
                )
            }
            
            saved.setValue(record.recordID.recordName, forKey: "recordName")
            saved.setValue(record.archived, forKey: "recordData")
            
            for field in serialization.fields {
                guard let value = record.value(forKey: field.field.name) else {
                    continue
                }
                saved.mark(value: value, on: field)
            }
            
            serialization.loaded(entity: saved, in: context)
        }
    }
}

extension NSManagedObject {
    fileprivate func mark(value: Any, on field: RecordField) {
        if field.field.valueType == field.attribute.valueType {
            setValue(value, forKey: field.attribute.name)
            return
        }
        
        switch (field.field.valueType, field.attribute.valueType) {
        case (.int64List, .string):
            let numbers = value as! [NSNumber]
            let transformed = numbers.map(\.int64Value).map(String.init).joined(separator: "#")
            setValue(transformed, forKey: field.attribute.name)
        default:
            fatalError()
        }
    }
}

extension NSAttributeDescription {
    fileprivate var isString: Bool {
        if #available(iOS 15, macOS 12, *) {
            return type == .string
        } else {
           return attributeType == .stringAttributeType
        }
    }
}

extension NSManagedObjectContext {
    fileprivate func entity(named: String, recordName: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: named)
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        return try? fetch(request).first
    }
}

extension CKRecord {
    internal var archived: Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        encodeSystemFields(with: coder)
        return coder.encodedData
    }
}
