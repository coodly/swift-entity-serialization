import CoreData

extension NSManagedObjectContext {
    internal func createTestLevel(modify: Int = 0) -> MonsterLevel {
        let level: MonsterLevel = NSEntityDescription.insertNewObject(forEntityName: "MonsterLevel", into: self) as! MonsterLevel
        level.level = NSNumber(value: 1 + modify)
        level.positionSurvivors = NSNumber(value: 2 + modify)
        level.positionMonster = NSNumber(value: 3 + modify)
        level.baseMovement = NSNumber(value: 4 + modify)
        level.baseToughness = NSNumber(value: 5 + modify)
        level.tokenMovement = NSNumber(value: 6 + modify)
        return level
    }
    
    internal func existingLevel() throws -> MonsterLevel? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "MonsterLevel")
        return try fetch(request).first as? MonsterLevel
    }

}
