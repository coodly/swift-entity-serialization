import CoreData

extension NSManagedObjectContext {
    internal func createTestMovie(recordName: String = "move-1234") -> Movie {
        let movie: Movie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: self) as! Movie
        movie.recordName = recordName
        movie.name = "Test movie one"
        movie.genres = [1, 2, 3, 4]
        movie.rating = NSNumber(value: 7)
        movie.runtime = NSNumber(value: 8)
        movie.tmdbID = NSNumber(value: 1234)
        movie.year = NSNumber(value: 2022)
        return movie
    }
    
    internal func existingMovie() throws -> Movie? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        return try fetch(request).first as? Movie
    }
}
