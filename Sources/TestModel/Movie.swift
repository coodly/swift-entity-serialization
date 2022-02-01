import CoreData

internal class Movie: NSManagedObject {
    @NSManaged var recordName: String?
    @NSManaged var recordData: Data?
    
    @NSManaged var internalGenres: String?
    @NSManaged var name: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var runtime: NSNumber?
    @NSManaged var tmdbID: NSNumber?
    @NSManaged var year: NSNumber?
    
    internal var genres: [Int] {
        get {
            internalGenres?.components(separatedBy: "#").compactMap(Int.init) ?? []
        }
        set {
            internalGenres = newValue.map(String.init).joined(separator: "#")
        }
    }
}
