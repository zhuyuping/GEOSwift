extension LineString: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.lineString) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .lineString)
        }
        try self.init(points: makePoints(from: geosObject))
    }
}
