import CoreData

extension NSManagedObjectContext {
    internal func createExpansion(named: String) -> Expansion {
        let expansion: Expansion = NSEntityDescription.insertNewObject(forEntityName: "Expansion", into: self) as! Expansion
        expansion.name = named
        expansion.recordName = "expansion-\(named.lowercased())"
        
        return expansion
    }
}
