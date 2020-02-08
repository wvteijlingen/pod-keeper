import Foundation

typealias ShellResult = (output: String?, status: Int32)

protocol Shell {
    @discardableResult
    func run(_ command: String) -> ShellResult
}

struct DefaultShell: Shell {
    @discardableResult
    func run(_ command: String) -> ShellResult {
        print(command)

        let task = Process()

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        task.waitUntilExit()
        return (output: output, status: task.terminationStatus)
    }
}
