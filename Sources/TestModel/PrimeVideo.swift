import CoreData

public class PrimeVideo: NSManagedObject {
  @NSManaged var recordName: String?
  @NSManaged var recordData: Data?
  @NSManaged var modifiedAt: Date?
  @NSManaged var status: String?
  @NSManaged var tag: String?
  @NSManaged var title: String?
  @NSManaged var tmdbID: NSNumber?
}
