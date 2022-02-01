import CoreData
import Foundation

public class DecodeEntity {
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    
    public init() {
        
    }
    
    public func decode(data: Data, into context: NSManagedObjectContext) throws -> [NSManagedObject]? {
        let values: [EntityDescription]
        if let single = try? decoder.decode(EntityDescription.self, from: data) {
            values = [single]
        } else {
            values = try decoder.decode([EntityDescription].self, from: data)
        }
        
        var loaded = [NSManagedObject]()
        for value in values {
            let saved = NSEntityDescription.insertNewObject(
                forEntityName: value.name,
                into: context
            )
            
            for field in value.values {
                switch field.type {
                case .int64:
                    let number = NSNumber(value: field.int64!)
                    saved.setValue(number, forKey: field.name)
                default:
                    throw SerializationError.unhandledTransformation(field.type)
                }
            }
            
            loaded.append(saved)
        }
        return loaded
    }
}
