import ArgumentParser
import Foundation
import LilacCore

struct EditCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Edit tracked source files"
    )

    func run() async throws {}
}
