extension MultiPolygon: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.multiPolygon) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .multiPolygon)
        }
        self.init(polygons: try makeGeometries(geometry: geosObject))
    }
}
