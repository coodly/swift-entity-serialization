import CoreData

internal class MonsterLevel: NSManagedObject {
  @NSManaged var level: NSNumber
  @NSManaged var positionMonster: NSNumber
  @NSManaged var positionSurvivors: NSNumber
    
  @NSManaged var baseMovement: NSNumber
  @NSManaged var baseToughness: NSNumber
    
  @NSManaged var tokenMovement: NSNumber
    
  @NSManaged var monster: Monster?
}
