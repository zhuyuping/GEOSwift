// GEOS includes the non-standard linear ring as a standalone geometry type. Modeling this separately
// avoids losing information when parsing WKT and WKB, while avoiding polluting the standard Geometry
// type's set of cases.
// The typical workflow after you receive a GEOSGeometry is to convert it to Geometry, which
// has the effect of converting all standalone LinearRing values to LineString values.
// However, if you application needs to distinguish between standalone LinearRings and LineStrings, this
// interface provides that capability.
public enum GEOSGeometry: Hashable, GEOSObjectInitializable {
    case point(Point)
    case multiPoint(MultiPoint)
    case lineString(LineString)
    case multiLineString(MultiLineString)
    case linearRing(Polygon.LinearRing)
    case polygon(Polygon)
    case multiPolygon(MultiPolygon)
    case geometryCollection(GEOSGeometryCollection)

    init(geosObject: GEOSObject) throws {
        guard let type = geosObject.type else {
            throw GEOSError.libraryError(errorMessages: geosObject.context.errors)
        }
        switch type {
        case .point:
            self = .point(try Point(geosObject: geosObject))
        case .lineString:
            self = .lineString(try LineString(geosObject: geosObject))
        case .linearRing:
            self = .linearRing(try Polygon.LinearRing(geosObject: geosObject))
        case .polygon:
            self = .polygon(try Polygon(geosObject: geosObject))
        case .multiPoint:
            self = .multiPoint(try MultiPoint(geosObject: geosObject))
        case .multiLineString:
            self = .multiLineString(try MultiLineString(geosObject: geosObject))
        case .multiPolygon:
            self = .multiPolygon(try MultiPolygon(geosObject: geosObject))
        case .geometryCollection:
            self = .geometryCollection(try GEOSGeometryCollection(geosObject: geosObject))
        }
    }
}

extension Geometry {
    public init(geosGeometry: GEOSGeometry) {
        switch geosGeometry {
        case let .point(point):
            self = .point(point)
        case let .multiPoint(multiPoint):
            self = .multiPoint(multiPoint)
        case let .lineString(lineString):
            self = .lineString(lineString)
        case let .multiLineString(multiLineString):
            self = .multiLineString(multiLineString)
        case let .linearRing(linearRing):
            // convert LinearRing to LineString
            self = .lineString(LineString(linearRing))
        case let .polygon(polygon):
            self = .polygon(polygon)
        case let .multiPolygon(multiPolygon):
            self = .multiPolygon(multiPolygon)
        case let .geometryCollection(geometryCollection):
            // convert GEOSGeometryCollection to GeometryCollection
            // (converts nested LinearRings to LineStrings)
            self = .geometryCollection(GeometryCollection(geometryCollection))
        }
    }
}
