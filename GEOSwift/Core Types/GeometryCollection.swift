public struct GeometryCollection: Hashable {
    public var geometries: [Geometry]

    public init(geometries: [Geometry]) {
        self.geometries = geometries
    }
}
