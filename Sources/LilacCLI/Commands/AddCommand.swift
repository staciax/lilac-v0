import ArgumentParser
import Foundation
import LilacCore
import Rainbow

struct AddCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a dotfile or directory to Lilac source-dir"
    )

    @Argument(help: "Path to a dotfile or directory to track")
    var path: String

    @Flag(name: .shortAndLong, help: "Use path as a preset name to load from 'presets/<name>.toml'")
    var preset: Bool = false

    @Option(
        name: .shortAndLong,
        help: "Comma-separated glob patterns to include.")
    var include: String?

    @Option(
        name: .shortAndLong,
        help: "Comma-separated glob patterns to exclude.")
    var exclude: String?

    @Flag(
        name: .shortAndLong,
        help: "Show what would be copied without writing files")
    var dryRun: Bool = false

    @Flag(
        name: .shortAndLong,
        help: "Overwrite existing tracked target.")
    var force: Bool = false

    func run() async throws {
        let config = try! await loadLocalConfig()

        let fileManager = FileManager.default

        let destinationSourceURL = resolvePath(path: config.sourceDir)
        // ~/.local/share/lilac

        let destinationSourceRootURL = destinationSourceURL.appendingPathComponent(config.root)
        // ~/.local/share/lilac/home

        let globInclude: [String]
        let globExclude: [String]

        let originalSourceURL: URL

        if preset {
            let preset = try await loadPreset(for: path, baseURL: destinationSourceURL)
            print("Using preset:".green, preset.name.blue)

            #if os(macOS)
                guard let sourcePath = preset.paths.macOS else {
                    throw LilacError.unsupportedOS(presetName: preset.name, os: "macOS")
                }
            #elseif os(Linux)
                guard let sourcePath = preset.paths.linux else {
                    throw LilacError.unsupportedOS(presetName: preset.name, os: "Linux")
                }
            #else
                throw LilacError.unsupportedOS(presetName: preset.name, os: "Unknown")
            #endif

            originalSourceURL = resolvePath(path: sourcePath)

            globInclude = preset.filters?.include ?? []
            globExclude = preset.filters?.exclude ?? []

        } else {
            originalSourceURL = resolvePath(path: path)

            // TODO: should validate include and exclude patterns??
            globInclude = include?.split(separator: ",").map { String($0) } ?? []
            globExclude = exclude?.split(separator: ",").map { String($0) } ?? []
        }

        print("Source:".green, originalSourceURL.path(percentEncoded: false).magenta)

        if dryRun {

            let homeDirectoryURL = fileManager.homeDirectoryForCurrentUser

            // /Users/stacia/.vim
            let sourceRelativePath = originalSourceURL.path(percentEncoded: false)
                .trimmingPrefix(homeDirectoryURL.path(percentEncoded: false))
            // .vim

            // print("original source path:".green, originalSourceURL.path(percentEncoded: false).magenta)
            // print("relative source path:".green, String(sourceRelativePath).magenta)

            // /Users/stacia/.local/share/lilac/home/.vim
            let previewTargetURL = destinationSourceRootURL.appending(
                path: String(sourceRelativePath)
            ).path(percentEncoded: false)
                .trimmingPrefix(homeDirectoryURL.path(percentEncoded: false))

            // .local/share/lilac/home/.vim
            // print("destination source root:".green, destinationSourceRootURL.path(percentEncoded: false).magenta)
            // print("preview target path:".green, String(previewTargetURL).magenta)

            // ~/.local/share/lilac/home/.vim
            let finalPreviewURL = "~/\(previewTargetURL)"

            print("[dry-run] no files were written, target:".yellow, finalPreviewURL.magenta)
        } else {

            let targetURL = try await safeCopy(
                from: originalSourceURL,
                to: destinationSourceRootURL,
                replacingExisting: force,
                include: globInclude,
                exclude: globExclude,
            )

            print("Tracked successfully:".green, targetURL.path(percentEncoded: false).magenta)
        }
    }
}
