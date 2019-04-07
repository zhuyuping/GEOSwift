import XCTest
@testable import GEOSwift

extension GeometryCollection {
    static let testValue = GeometryCollection(
        geometries: [
            .point(.testValue1),
            .multiPoint(.testValue),
            .lineString(.testValue1),
            .multiLineString(.testValue),
            .polygon(.testValueWithHole),
            .multiPolygon(.testValue)])
    static let testJson = #"{"geometries":[\#(Point.testJson1),"#
        + #"\#(MultiPoint.testJson),\#(LineString.testJson1),"#
        + #"\#(MultiLineString.testJson),\#(Polygon.testJsonWithHole),"#
        + #"\#(MultiPolygon.testJson)],"type":"GeometryCollection"}"#

    static let testValueWithRecursion = GeometryCollection(
        geometries: [.geometryCollection(.testValue)])
    static let testJsonWithRecursion = #"{"geometries":[\#(testJson)],"type":""#
        + #"GeometryCollection"}"#
}

@available(iOS 11.0, *)
final class GeometryCollection_CodableTests: CodableTestCase {
    func testCodable() {
        verifyCodable(
            with: GeometryCollection.testValue,
            json: GeometryCollection.testJson)
    }

    func testCodableWithRecursion() {
        verifyCodable(
            with: GeometryCollection.testValueWithRecursion,
            json: GeometryCollection.testJsonWithRecursion)
    }

    func testDecodableThrowsWithTypeMismatch() {
        let json = #"{"coordinates":[1],"type":"Point"}"#

        verifyDecodable(with: GeometryCollection.self, json: json, expectedError: .mismatchedGeoJSONType)
    }

    func testDecodableThrowsWithInvalidType() {
        let json = #"{"coordinates":[1],"type":"p"}"#

        verifyDecodable(with: GeometryCollection.self, json: json, expectedError: .invalidGeoJSONType)
    }
}
