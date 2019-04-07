import geos

public extension GEOSGeometry {
    init(wkt: String) throws {
        let context = try GEOSContext()
        let reader = try WKTReader(context: context)
        try self.init(geosObject: try reader.read(wkt))
    }
}

public extension Geometry {
    // Use this for convenience if you don't need to identify standalone LinearRings in the WKT
    init(wkt: String) throws {
        self.init(geosGeometry: try GEOSGeometry(wkt: wkt))
    }
}

private final class WKTReader {
    private let context: GEOSContext
    private let pointer: OpaquePointer

    init(context: GEOSContext) throws {
        guard let pointer = GEOSWKTReader_create_r(context.handle) else {
            throw GEOSError.libraryError(errorMessages: context.errors)
        }
        self.context = context
        self.pointer = pointer
    }

    deinit {
        GEOSWKTReader_destroy_r(context.handle, pointer)
    }

    func read(_ wkt: String) throws -> GEOSObject {
        guard let geometryPointer = wkt.withCString({
            GEOSWKTReader_read_r(context.handle, pointer, $0) }) else {
                throw GEOSError.libraryError(errorMessages: context.errors)
        }
        return GEOSObject(context: context, pointer: geometryPointer)
    }
}
