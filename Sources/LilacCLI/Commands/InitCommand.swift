import ArgumentParser
import Foundation
import LilacCore
import Rainbow
import SwiftGitX
import TOML

enum LilacInitError: Error {
    case alreadyInitialized(path: URL)
    case initializationFailed(reason: String)
    case configWriteFailed(reason: String)
    case versionFileWriteFailed(reason: String)
}

struct InitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize Lilac repository and local config"
    )

    func run() async throws {
        let fileManager = FileManager.default

        let lilacURL = lilac.url

        if !fileManager.fileExists(atPath: lilacURL.path) {
            try fileManager.createDirectory(
                at: lilacURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        let repo = try? Repository(at: lilacURL, createIfNotExists: false)

        guard repo == nil else {
            throw LilacInitError.alreadyInitialized(path: lilacURL)
        }

        do {
            let newRepo = try Repository.init(at: lilacURL, createIfNotExists: true)
            let fullPath = newRepo.path.path(percentEncoded: false)
            let homePath = fileManager.homeDirectoryForCurrentUser.path

            let relativePath = fullPath.replacing(homePath, with: "~")

            print("Initialized a new Lilac project at \(relativePath)".green)
        } catch {
            throw LilacInitError.initializationFailed(reason: error.localizedDescription)
        }

        let configURL = lilacURL.appendingPathComponent("lilac.toml")

        // TODO: lilac source-dir for different os
        let config = LilacLocalConfig(
            sourceDir: "~/.local/share/lilac",
            root: ""
        )

        // TODO: something adapter for different toml library to avoid coupling with specific library
        let encoder = TOMLEncoder()
        let tomlData = try encoder.encode(config)
        let tomlString = String(data: tomlData, encoding: .utf8)!

        /*
        source-dir = "./local/share/lilac"
        root = ""
        */

        do {
            try tomlString.write(to: configURL, atomically: true, encoding: .utf8)
        } catch {
            throw LilacInitError.configWriteFailed(reason: error.localizedDescription)
        }

        // dot version file to indicate the directory is a lilac project
        let versionURL = lilacURL.appendingPathComponent(".lilac-version")
        let version = lilac.version.versionString

        do {
            try version.write(to: versionURL, atomically: true, encoding: .utf8)
        } catch {
            throw LilacInitError.versionFileWriteFailed(reason: error.localizedDescription)
        }
    }
}
