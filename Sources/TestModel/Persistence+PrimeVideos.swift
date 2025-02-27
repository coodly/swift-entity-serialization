import CoreData

extension NSManagedObjectContext {
  internal func createPrimeVideo() -> PrimeVideo {
    NSEntityDescription.insertNewObject(forEntityName: "PrimeVideo", into: self) as! PrimeVideo
  }
}
