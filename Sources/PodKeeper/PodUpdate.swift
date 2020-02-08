struct PodUpdate {
    var podName: String
    var fromVersion: String
    var toVersion: String
    var isApplicable: Bool {
        fromVersion != toVersion
    }
}
