import CoreData

extension NSManagedObjectContext {
    internal func createExpansion(named: String) -> Expansion {
        let monster: Expansion = NSEntityDescription.insertNewObject(forEntityName: "Expansion", into: self) as! Expansion
        monster.name = named
        
        return monster
    }
}
