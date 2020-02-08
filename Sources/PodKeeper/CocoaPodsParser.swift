import Foundation

struct CocoaPodsParser {
    static func parseOutdatedPods(fromCommandOutput output: String) -> [PodUpdate] {
        let regex = try! NSRegularExpression(pattern: #"- ([-\w]+) ([\d\.]+) -> ([\d\.]+) .*"#)
        return output.split { $0.isNewline }.compactMap { (line) -> PodUpdate? in
            let captures = String(line).groups(for: regex)
            if captures.count == 1 && captures[0].count == 4 {
                return PodUpdate(podName: captures[0][1], fromVersion: captures[0][2], toVersion: captures[0][3])
            }
            return nil
        }
    }
}
