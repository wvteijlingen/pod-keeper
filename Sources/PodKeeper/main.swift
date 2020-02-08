import TSCUtility

let argumentParser = ArgumentParser(usage: "podkeeper --branch develop --project <project id> --private-token <token>", overview: "")

let projectID = argumentParser.add(
    option: "--project",
    shortName: nil,
    kind: String.self,
    usage: "The project ID of the project in GitLab.",
    completion: nil
)

let mainBranchName = argumentParser.add(
    option: "--branch",
    shortName: nil,
    kind: String.self,
    usage: "The branch that PodKeeper will checkout to scan your project.",
    completion: nil
)

let privateToken = argumentParser.add(
    option: "--token",
    shortName: nil,
    kind: String.self,
    usage: "A GitLab private token that has access to the project.",
    completion: nil
)

let dryRun = argumentParser.add(
    option: "--dry",
    shortName: nil,
    kind: Bool.self,
    usage: "When set, PodKeeper will do a dry run without making any actual changes.",
    completion: nil
)

let args = Array(CommandLine.arguments.dropFirst())
let result = try argumentParser.parse(args)

let checker = PodKeeper(
    mainBranch: result.get(mainBranchName)!,
    platform: GitLab(
        privateToken: result.get(privateToken)!,
        projectID: result.get(projectID)!
    ),
    dryRun: result.get(dryRun) ?? false
)
checker.run()
