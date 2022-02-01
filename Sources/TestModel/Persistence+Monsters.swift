import CoreData

extension NSManagedObjectContext {
    internal func existingMonster() throws -> Monster? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Monster")
        return try fetch(request).first as? Monster
    }
    
    internal func createMonster(named: String) -> Monster {
        let monster: Monster = NSEntityDescription.insertNewObject(forEntityName: "Monster", into: self) as! Monster
        monster.name = named
        
        return monster
    }
}
