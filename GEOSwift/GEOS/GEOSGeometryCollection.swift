public struct GEOSGeometryCollection: Hashable, GEOSObjectInitializable {
    public let geometries: [GEOSGeometry]

    // Internal use only
    init(geosObject: GEOSObject) throws {
        guard case .some(.geometryCollection) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .geometryCollection)
        }
        self.geometries = try makeGeometries(geometry: geosObject)
    }
}

extension GeometryCollection {
    public init(_ geosGeometryCollection: GEOSGeometryCollection) {
        self.geometries = geosGeometryCollection.geometries.map(Geometry.init)
    }
}
