import geos

extension Polygon.LinearRing: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.linearRing) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .linearRing)
        }
        try self.init(points: makePoints(from: geosObject))
    }
}

extension Polygon: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.polygon) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .polygon)
        }
        // returns null on exception
        guard let exteriorRing = GEOSGetExteriorRing_r(geosObject.context.handle, geosObject.pointer) else {
            throw GEOSError.libraryError(errorMessages: geosObject.context.errors)
        }
        let exteriorRingObject = GEOSObject(parent: geosObject, pointer: exteriorRing)
        let exterior = try LinearRing(geosObject: exteriorRingObject)
        // returns -1 on exception
        let numInteriorRings = GEOSGetNumInteriorRings_r(geosObject.context.handle, geosObject.pointer)
        guard numInteriorRings >= 0 else {
            throw GEOSError.libraryError(errorMessages: geosObject.context.errors)
        }
        let holes = try Array(0..<numInteriorRings).map { (index) -> LinearRing in
            // returns null on exception
            guard let interiorRing = GEOSGetInteriorRingN_r(
                geosObject.context.handle, geosObject.pointer, index) else {
                    throw GEOSError.libraryError(errorMessages: geosObject.context.errors)
            }
            let interiorRingObject = GEOSObject(parent: geosObject, pointer: interiorRing)
            return try LinearRing(geosObject: interiorRingObject)
        }
        self.init(exterior: exterior, holes: holes)
    }
}
