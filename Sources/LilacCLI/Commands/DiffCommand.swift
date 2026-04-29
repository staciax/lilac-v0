import ArgumentParser
import Foundation
import LilacCore

struct DiffCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Show differences between tracked source files and home files"
    )

    func run() async throws {}
}
