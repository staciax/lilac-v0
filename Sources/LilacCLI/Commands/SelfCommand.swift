import ArgumentParser
import Foundation
import LilacCore

struct SelfCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "self",
        abstract: "Manage the Lilac executable itself",
        subcommands: [
            SelfUpdateCommand.self,
            SelfVersionCommand.self,
        ]
    )
}

struct SelfUpdateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update the Lilac executable to the latest version"
    )

    func run() async throws {
        print("Checking for updates...")
    }
}

struct SelfVersionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Show the current version of the Lilac executable"
    )

    func run() async throws {
        print("Lilac CLI version: \(lilac.version.versionString)")
    }
}