import Darwin
import Alamofire

struct PodKeeper {
    var shell: Shell = DefaultShell()
    private let mainBranch: String
    private let platform: Platform
    private let updateBranchPrefix: String
    private let dryRun: Bool

    init(mainBranch: String, platform: Platform, updateBranchPrefix: String = "pod-update/", dryRun: Bool = false) {
        self.mainBranch = mainBranch
        self.platform = platform
        self.updateBranchPrefix = updateBranchPrefix
        self.dryRun = true
    }

    func run() {
        let updates = availablePodUpdates()
        if dryRun {
            print("The following will be updated:")
            updates.forEach(dryRunPodUpdate)
        } else {
            print("Found \(updates.count) outdated pods.")
            updates.forEach(runPodUpdate)
        }
        switchToBranch(named: mainBranch, createIfDoesNotExist: false)
    }

    private func availablePodUpdates() -> [PodUpdate] {
        let result = runOrExit("pod outdated")

        guard let output = result.output else {
            print("Could not retrieve output from CocoaPods")
            exit(1)
        }

        return CocoaPodsParser.parseOutdatedPods(fromCommandOutput: output).filter { $0.isApplicable }
    }

    private func runPodUpdate(_ update: PodUpdate) {
        let branchName = "\(updateBranchPrefix)\(update.podName)"
        print("Updating \(update.podName) from \(update.fromVersion) to \(update.toVersion) in branch \(branchName)")

        switchToBranch(named: mainBranch, createIfDoesNotExist: false)
        switchToBranch(named: branchName, createIfDoesNotExist: true)
        updatePod(named: update.podName)
        createCommit(forUpdate: update)
        pushBranch(named: branchName)
        createMergeRequest(forBranchNamed: branchName, update: update)
    }

    private func dryRunPodUpdate(_ update: PodUpdate) {
        let branchName = "\(updateBranchPrefix)\(update.podName)"
        print("Will update \(update.podName) from \(update.fromVersion) to \(update.toVersion) in branch \(branchName)")
    }

    private func switchToBranch(named branchName: String, createIfDoesNotExist: Bool) {
        if createIfDoesNotExist {
            runOrExit("git checkout \(branchName) || git checkout -b \(branchName)")
        } else {
            runOrExit("git checkout \(branchName)")
        }
    }

    private func updatePod(named podName: String) {
        runOrExit("pod update \(podName)")
    }

    private func createCommit(forUpdate update: PodUpdate) {
        runOrExit("git add Podfile Podfile.lock")
        runOrExit("git commit -m \"Updated \(update.podName) from \(update.fromVersion) to \(update.toVersion)\"")
    }

    private func pushBranch(named branchName: String) {
        runOrExit("git push -u origin \(branchName):\(branchName)")
    }

    private func createMergeRequest(forBranchNamed branchName: String, update: PodUpdate) {
        platform.checkForExistingMergeRequest(from: branchName, into: mainBranch) { hasExistingMergeRequest in
            if hasExistingMergeRequest {
                print("Has existing merge request for \(update.podName)")
            } else {
                let mergeRequestTitle = "🤖 Dependency update: \(update.podName)"
                self.platform.createMergeRequest(from: branchName, into: self.mainBranch, title: mergeRequestTitle) { error in
                    if let error = error {
                        print("Platform reported error \(error)")
                    } else {
                        print("Created merge request for \(update.podName)")
                    }
                }
            }
        }
    }

    @discardableResult
    private func runOrExit(_ command: String) -> ShellResult {
        let result = shell.run(command)
        if result.status != 0 {
            print("Error running: \(command)")
            print(result.output as Any)
            exit(1)
        }
        return result
    }
}
