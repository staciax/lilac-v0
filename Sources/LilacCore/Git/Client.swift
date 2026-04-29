import Foundation
import SwiftGitX


public class GitClient {
    let repository: SwiftGitX.Repository

    public init(url: URL, createIfNotExists: Bool = false) throws {
        let repo = try SwiftGitX.Repository.init(at: url, createIfNotExists: createIfNotExists)
        
        self.repository = repo
    }

    public func clone(url: String) async throws {
        

        guard let gitURL = URL(string: url) else {
            throw GitError.cloneFailed(reason: "Invalid URL format.")
        }
        // SwiftGitX.Repository.clone(from: URL, to: URL)
        // do {
        //     let repository = try await Repository.clone(from: gitURL, to: "self.localPath")
        // } catch {
        //     throw GitError.cloneFailed(reason: error.localizedDescription)
        // }
    }

    public func add(files: [String]) async throws {
        // implement add logic here
    }

    public func commit(message: String) async throws {
        // implement commit logic here
    }

    public func pull() async throws {
        // implement pull logic here
    }

    public func push() async throws {
        // implement push logic here
    }

    public func status() async throws {
        // implement status logic here
    }

    public func diff() async throws {
        // implement diff logic here
    }

}
