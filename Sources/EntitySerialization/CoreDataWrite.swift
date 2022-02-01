import CloudKit
import CoreData

public class CoreDataWrite {
    private let context: NSManagedObjectContext
    private let serialize: [RecordSerialize]
    public init(context: NSManagedObjectContext, serlialize: [RecordSerialize]) {
        self.context = context
        self.serialize = serlialize
    }
    
    public func write(record: CKRecord) throws {
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
        
        saved.setValue(record.recordID.recordName, forKey: SystemField.recordName)
        saved.setValue(record.archived, forKey: SystemField.recordData)
        
        for field in serialization.fields {
            guard let value = record.value(forKey: field.field.name) else {
                continue
            }
            
            if field.field.valueType == field.attribute.valueType, field.field.valueType == .reference {
                guard let reference = value as? CKRecord.Reference else {
                    throw SerializationError.couldNotGetReference(field.field.name)
                }
                try saved.mark(reference: reference, on: field)
                continue
            }
            
            try saved.mark(value: value, on: field)
        }
        
        serialization.loaded(entity: saved, in: context)
    }
}

extension NSManagedObject {
    fileprivate func mark(value: Any, on field: RecordField) throws {
        if field.field.valueType == field.attribute.valueType {
            setValue(value, forKey: field.attribute.name)
            return
        }
        
        switch (field.field.valueType, field.attribute.valueType) {
        case (.int64List, .string):
            let numbers = value as! [NSNumber]
            let transformed = numbers.map(\.int64Value).map(String.init).joined(separator: SystemValue.numberSeparator)
            setValue(transformed, forKey: field.attribute.name)
        default:
            throw SerializationError.unhandledTransformation(field.field.valueType, field.attribute.valueType)
        }
    }
    
    fileprivate func mark(reference: CKRecord.Reference, on field: RecordField) throws {
        guard let relatsionship = entity.relationshipsByName[field.attribute.name], let destination = relatsionship.destinationEntity else {
            throw SerializationError.noReferenceRelationship(field.attribute.name)
        }
        
        guard let referenced = managedObjectContext?.entity(named: destination.name ?? "-", recordName: reference.recordID.recordName) else {
            throw SerializationError.noDestinationEntity(destination.name, reference.recordID.recordName)
        }
        
        setValue(referenced, forKey: field.field.name)
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
        request.predicate = NSPredicate(format: "%K = %@", SystemField.recordName, recordName)
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
