import CoreData

extension NSManagedObjectContext {
    internal func createMonster(named: String) -> Monster {
        let monster: Monster = NSEntityDescription.insertNewObject(forEntityName: "Monster", into: self) as! Monster
        monster.name = named
        
        return monster
    }
}
