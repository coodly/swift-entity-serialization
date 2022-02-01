import CoreData

extension NSManagedObjectContext {
    internal func createTestLevel() -> MonsterLevel {
        let level: MonsterLevel = NSEntityDescription.insertNewObject(forEntityName: "MonsterLevel", into: self) as! MonsterLevel
        level.level = NSNumber(value: 1)
        level.positionSurvivors = NSNumber(value: 2)
        level.positionMonster = NSNumber(value: 3)
        level.baseMovement = NSNumber(value: 4)
        level.baseToughness = NSNumber(value: 5)
        level.tokenMovement = NSNumber(value: 6)
        return level
    }
}
