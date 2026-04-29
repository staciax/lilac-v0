import ArgumentParser
import Foundation
import LilacCore

struct ChangeDirectoryCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cd",
        abstract: ""
    )

    func run() async throws {}
}
