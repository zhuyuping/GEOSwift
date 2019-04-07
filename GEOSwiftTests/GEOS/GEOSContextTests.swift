import XCTest
import geos
@testable import GEOSwift

final class GEOSContextTests: XCTestCase {

    var context: GEOSContext!

    override func setUp() {
        super.setUp()
        do {
            context = try GEOSContext()
        } catch {
            continueAfterFailure = false
            XCTFail("Unable to create context: \(error)")
        }
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testCapturesErrorMessages() {
        // pass in some invalid WKT
        let invalidWKT = "hello"
        let pointer = GEOSWKTReader_create_r(context.handle)

        if let geometry = invalidWKT.withCString({ GEOSWKTReader_read_r(context.handle, pointer, $0) }) {
            GEOSGeom_destroy(geometry)
            XCTFail("Expected WKT reading to fail")
        }

        XCTAssertEqual(context.errors.count, 1)

        GEOSWKTReader_destroy_r(context.handle, pointer)
    }
}
