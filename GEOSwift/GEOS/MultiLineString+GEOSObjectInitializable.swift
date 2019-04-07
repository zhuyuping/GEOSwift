extension MultiLineString: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.multiLineString) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .multiLineString)
        }
        self.init(lineStrings: try makeGeometries(geometry: geosObject))
    }
}
