import geos

public extension GEOSGeometry {
    init(wkb: Data) throws {
        let context = try GEOSContext()
        let reader = WKBReader(context: context)
        try self.init(geosObject: try reader.read(wkb))
    }
}

public extension Geometry {
    // Use this for convenience if you don't need to identify standalone LinearRings in the WKB
    init(wkb: Data) throws {
        self.init(geosGeometry: try GEOSGeometry(wkb: wkb))
    }
}

private final class WKBReader {
    private let context: GEOSContext

    init(context: GEOSContext) {
        self.context = context
    }

    func read(_ wkb: Data) throws -> GEOSObject {
        let pointer = try wkb.withUnsafeBytes { (unsafeRawBufferPointer) -> OpaquePointer in
            guard let unsafePointer = unsafeRawBufferPointer.baseAddress?
                .bindMemory(to: UInt8.self, capacity: unsafeRawBufferPointer.count) else {
                    throw GEOSError.wkbDataWasEmpty
            }
            guard let pointer = GEOSGeomFromWKB_buf_r(
                context.handle, unsafePointer, unsafeRawBufferPointer.count) else {
                    throw GEOSError.libraryError(errorMessages: context.errors)
            }
            return pointer
        }
        return GEOSObject(context: context, pointer: pointer)
    }
}
