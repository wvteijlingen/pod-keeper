import Alamofire

protocol Platform {
    /// Checks whether a merge request already exists.
    /// - Parameters:
    ///   - sourceBranch: The source branch that is merged.
    ///   - targetBranch: The target branch that receives the merge.
    ///   - callback: A callback that is called with true if a merge request already exists.
    func checkForExistingMergeRequest(from sourceBranch: String, into targetBranch: String, callback: @escaping (Bool) -> Void)

    /// Creates a merge request.
    /// - Parameters:
    ///   - sourceBranch: The source branch that is merged.
    ///   - targetBranch: The target branch that receives the merge.
    ///   - title: The title of the merge request.
    ///   - callback: A callback that is called with an optional error. If `error` is nil, the operation was succesful.
    func createMergeRequest(from sourceBranch: String, into targetBranch: String, title: String, callback: @escaping (Error?) -> Void)
}

struct GitLab: Platform {
    let privateToken: String
    let projectID: String

    func checkForExistingMergeRequest(from sourceBranch: String, into targetBranch: String, callback: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = ["Private-Token": privateToken]
        let parameters: [String: Any] = [
            "source_branch": sourceBranch,
            "target_branch": targetBranch,
        ]

        AF.request("https://gitlab.com/api/v4/projects/\(projectID)/merge_requests", parameters: parameters, headers: headers)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let string):
                    // Cheating
                    callback(string != "[]")
                case let .failure(error):
                    print(error)
                }
            }
    }

    func createMergeRequest(from sourceBranch: String, into targetBranch: String, title: String, callback: @escaping (Error?) -> Void) {
        let headers: HTTPHeaders = ["Private-Token": privateToken]

        let parameters: [String: Any] = [
            "source_branch": sourceBranch,
            "target_branch": targetBranch,
            "title": title,
            "remove_source_branch": true,
            "squash": true
        ]

        AF.request("https://gitlab.com/api/v4/projects/\(projectID)/merge_requests",
            method: .post,
            parameters: parameters,
            headers: headers
        ).validate().responseData { response in
            switch response.result {
            case .success:
                callback(nil)
            case let .failure(error):
                callback(error)
            }
        }
    }
}
