enum GEOSwiftError: Error {
    case invalidJSON
    case invalidGeoJSONType
    case invalidCoordinates
    case mismatchedGeoJSONType
    case tooFewPoints
    case ringNotClosed
    case tooFewRings
    case invalidFeatureId
}
