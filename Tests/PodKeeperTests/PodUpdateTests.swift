import XCTest
import class Foundation.Bundle
@testable import PodKeeper

final class PodUpdateTests: XCTestCase {
    func testIsApplicable() throws {
        let nonApplicableUpdate = PodUpdate(podName: "TestPod", fromVersion: "1.0.0", toVersion: "1.0.0")
        XCTAssertFalse(update.isApplicable)

        let applicableUpdate = PodUpdate(podName: "TestPod", fromVersion: "1.0.0", toVersion: "1.1.0")
        XCTAssertTrue(update.isApplicable)
    }

    static var allTests = [
        ("testIsApplicable", testIsApplicable),
    ]
}
