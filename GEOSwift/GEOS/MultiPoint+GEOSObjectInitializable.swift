extension MultiPoint: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.multiPoint) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .multiPoint)
        }
        self.init(points: try makeGeometries(geometry: geosObject))
    }
}
