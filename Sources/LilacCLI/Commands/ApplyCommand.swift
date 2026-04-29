import ArgumentParser
import Foundation
import LilacCore
import Rainbow

struct ApplyCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "apply",
        abstract: "Apply tracked dotfiles from Lilac source-dir to your home directory"
    )

    func run() throws {}
}
