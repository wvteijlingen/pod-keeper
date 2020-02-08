import XCTest
@testable import PodKeeper

class PodKeeperTests: XCTestCase {

    let podChecker = PodKeeper(
        mainBranchName: "master",
        updateBranchPrefix: "branch-prefix/",
        projectID: "1",
        privateToken: "secret"
    )

    func testRuft() {
        podChecker.shell = MockShell() { command
            XCTAssertEqual(command, "pod outdated")
            return (nil, 1)
        }
    }

    func testAvailablePodUpdates() {
        let output = """
Updating spec repo `trunk`

CocoaPods 1.9.0.beta.3 is available.
To update use: `gem install cocoapods --pre`
[!] This is a test version we'd love you to try.

For more information, see https://blog.cocoapods.org and the CHANGELOG for this version at https://github.com/CocoaPods/CocoaPods/releases/tag/1.9.0.beta.3

Analyzing dependencies
The color indicates what happens when you run `pod update`
<green>     - Will be updated to the newest version
<blue>     - Will be updated, but not to the newest version because of specified version in Podfile
<red>     - Will not be updated because of specified version in Podfile

The following pod updates are available:
- SwiftLint 0.38.0 -> 0.38.2 (latest version 0.38.2)
- SwiftSoup 2.2.0 -> 2.2.2 (latest version 2.3.0)

[!] Automatically assigning platform `iOS` with version `13.2` on target `test` because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.
"""

        let actual = CocoaPodsParser.parseOutDatedPods(fromCommandOutput: output)
        let expected = [
            PodUpdate(podName: "SwiftLint", fromVersion: "0.38.0", toVersion: "0.38.2"),
            PodUpdate(podName: "SwiftSoup", fromVersion: "2.2.0", toVersion: "2.2.2")
        ]
        XCTAssertEqual(actual, expected)
    }
}

struct MockShell: Shell {
    var handler = (String) -> (String?, Int32)

    func run(_ command: String) -> (String?, Int32) {
        return handler(command)
    }
}
