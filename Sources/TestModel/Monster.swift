import CoreData

internal class Monster: NSManagedObject {
  @NSManaged var recordName: String?
  @NSManaged var recordData: Data?

  @NSManaged var name: String?

  @NSManaged var expansion: Expansion?
  @NSManaged var levels: Set<MonsterLevel>?
}
