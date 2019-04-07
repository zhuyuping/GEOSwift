import geos

func makeGeometries<T>(geometry: GEOSObject) throws -> [T] where T: GEOSObjectInitializable {
    let numGeometries = GEOSGetNumGeometries_r(geometry.context.handle, geometry.pointer)
    guard numGeometries >= 0 else {
        throw GEOSError.libraryError(errorMessages: geometry.context.errors)
    }
    return try Array(0..<numGeometries).map { (index) -> T in
        // returns null on exception
        guard let pointer = GEOSGetGeometryN_r(geometry.context.handle, geometry.pointer, index) else {
            throw GEOSError.libraryError(errorMessages: geometry.context.errors)
        }
        return try T(geosObject: GEOSObject(parent: geometry, pointer: pointer))
    }
}

func makePoints(from geometry: GEOSObject) throws -> [Point] {
    guard let sequence = GEOSGeom_getCoordSeq_r(geometry.context.handle, geometry.pointer) else {
        throw GEOSError.libraryError(errorMessages: geometry.context.errors)
    }
    var count: UInt32 = 0
    // returns 0 on exception
    guard GEOSCoordSeq_getSize_r(geometry.context.handle, sequence, &count) != 0 else {
        throw GEOSError.libraryError(errorMessages: geometry.context.errors)
    }
    return try Array(0..<count).map { (index) -> Point in
        var point = Point(x: 0, y: 0)
        // returns 0 on exception
        guard GEOSCoordSeq_getX_r(geometry.context.handle, sequence, index, &point.x) != 0,
            GEOSCoordSeq_getY_r(geometry.context.handle, sequence, index, &point.y) != 0 else {
                throw GEOSError.libraryError(errorMessages: geometry.context.errors)
        }
        return point
    }
}
