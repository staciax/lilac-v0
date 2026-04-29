import ArgumentParser
import Foundation
import Glob
import LilacCore
import Rainbow

struct StatusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show tracked dotfile status (source-dir vs home)"
    )

    func run() async throws {
        let config = try! await loadLocalConfig()

        let sourceURL = resolvePath(path: config.sourceDir)
        // /Users/stacia/.local/share/lilac

        let sourceRootURL = sourceURL.appendingPathComponent(config.root)
        // /Users/stacia/.local/share/lilac/home

        let files = Glob.search(directory: sourceRootURL)
        // /Users/stacia/.local/share/lilac/home

        let fileManager = FileManager.default
        let homeDirectoryURL = fileManager.homeDirectoryForCurrentUser

        var dotfiles: [DotfileEntry] = []

        for try await fileURL in files {

            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues.isDirectory == true { continue }

            let targetRelativePath = fileURL.path(percentEncoded: false)
                .trimmingPrefix(sourceRootURL.path(percentEncoded: false))
                .trimmingPrefix("/")

            let targetAbsoluteURL = homeDirectoryURL.appendingPathComponent(
                String(targetRelativePath))

            let fileStatus: DotfileEntry.Status

            let targetExists = fileManager.fileExists(atPath: targetAbsoluteURL.path)

            if !targetExists {
                fileStatus = .init(source: .unchanged, target: .missing)
            } else {
                let sourceData = try? Data(contentsOf: fileURL)
                let targetData = try? Data(contentsOf: targetAbsoluteURL)

                if sourceData == targetData {
                    fileStatus = .init(source: .unchanged, target: .unchanged)
                } else {
                    fileStatus = .init(source: .modified, target: .modified)
                }
            }

            let dotfile: DotfileEntry = DotfileEntry(
                sourceURL: fileURL,
                targetURL: targetAbsoluteURL,
                status: fileStatus
            )

            dotfiles.append(dotfile)
        }

        print(
            "Source".padding(toLength: 8, withPad: " ", startingAt: 0).green.bold,
            "\t",
            "Target".padding(toLength: 8, withPad: " ", startingAt: 0).green.bold,
            "\t",
            "Path".green.bold,
        )
        for dotfile in dotfiles {
            let sourceStatus = dotfile.status?.source ?? .unchanged
            let targetStatus = dotfile.status?.target ?? .unchanged

            let sourceSymbolLabel = sourceStatus.symbol.color(
                sourceStatus.symbol.label.padding(toLength: 8, withPad: " ", startingAt: 0))
            
            let targetSymbolLabel = targetStatus.symbol.color(
                targetStatus.symbol.label.padding(toLength: 8, withPad: " ", startingAt: 0)
                )

            let relativePath = dotfile.sourceURL.path(percentEncoded: false)
                .trimmingPrefix(sourceRootURL.path(percentEncoded: false))
                .trimmingPrefix("/")

            print(sourceSymbolLabel, "\t", targetSymbolLabel, "\t", String(relativePath).magenta)
        }
    }
}
