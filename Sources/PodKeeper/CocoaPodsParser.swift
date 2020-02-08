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

private extension String {
    func groups(for regex: NSRegularExpression) -> [[String]] {
        let text = self
        let matches = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return matches.map { match in
            return (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        }
    }
}
