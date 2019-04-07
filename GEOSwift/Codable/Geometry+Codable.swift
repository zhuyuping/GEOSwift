extension Geometry: Codable {
    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueContainer = try decoder.singleValueContainer()
        switch try keyedContainer.geoJSONType(forKey: .type) {
        case .point:
            self = try .point(singleValueContainer.decode(Point.self))
        case .multiPoint:
            self = try .multiPoint(singleValueContainer.decode(MultiPoint.self))
        case .lineString:
            self = try .lineString(singleValueContainer.decode(LineString.self))
        case .multiLineString:
            self = try .multiLineString(singleValueContainer.decode(MultiLineString.self))
        case .polygon:
            self = try .polygon(singleValueContainer.decode(Polygon.self))
        case .multiPolygon:
            self = try .multiPolygon(singleValueContainer.decode(MultiPolygon.self))
        case .geometryCollection:
            self = try .geometryCollection(singleValueContainer.decode(GeometryCollection.self))
        case .feature, .featureCollection:
            throw GEOSwiftError.mismatchedGeoJSONType
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .point(point):
            try container.encode(point)
        case let .multiPoint(multiPoint):
            try container.encode(multiPoint)
        case let .lineString(lineString):
            try container.encode(lineString)
        case let .multiLineString(multiLineString):
            try container.encode(multiLineString)
        case let .polygon(polygon):
            try container.encode(polygon)
        case let .multiPolygon(multiPolygon):
            try container.encode(multiPolygon)
        case let .geometryCollection(geometryCollection):
            try container.encode(geometryCollection)
        }
    }
}
