import ArgumentParser
import Foundation
import LilacCore

struct ForgotCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "forgot",
        abstract: "Remove a tracked dotfile or directory from Lilac source-dir"
    )

    func run() async throws {}
}
