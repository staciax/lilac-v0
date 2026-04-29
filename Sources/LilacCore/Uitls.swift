import Foundation
import Glob
import SystemPackage

public func resolvePath(path: String) -> URL {
    // handle home directory (~)
    if path.hasPrefix("~") {
        let relativePath = String(path.drop(while: { $0 == "~" || $0 == "/" }))
        return URL.homeDirectory.appending(path: relativePath).standardizedFileURL
    }

    // handle absolute paths (/) and relative paths
    return URL(filePath: path, relativeTo: .currentDirectory()).standardizedFileURL
}

public func safeCopy(
    from sourceURL: URL,
    to destinationURL: URL,
    replacingExisting: Bool = false,
    include: [String] = [],
    exclude: [String] = [],
) async throws -> URL {
    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: sourceURL.path(percentEncoded: false)) {
        throw LilacError.fileNotFound(path: sourceURL.path(percentEncoded: false))
    }

    // /Users/stacia/.zshrc

    let homeURL = fileManager.homeDirectoryForCurrentUser
    let sourceRelativePath = sourceURL.path(percentEncoded: false)
        .trimmingPrefix(homeURL.path(percentEncoded: false))
        .trimmingPrefix("/")

    // .zshrc

    // /Users/stacia/.local/share/lilac/home

    let targetURL = destinationURL.appending(path: String(sourceRelativePath))

    // /Users/stacia/.local/share/lilac/home/.zshrc

    let targetExists = fileManager.fileExists(atPath: targetURL.path(percentEncoded: false))

    if !replacingExisting && targetExists {
        throw LilacError.destinationExists(path: targetURL)
    }

    let tempFileName = sourceURL.lastPathComponent + ".tmp_" + UUID().uuidString
    let tempURL = destinationURL.appending(path: tempFileName)

    // /Users/stacia/.local/share/lilac/home/.zshrc.tmp_000b4ec5-476a-4e6d-bea9-5bf07e6e7aa5

    let isSourceDirectory =
        (try sourceURL.resourceValues(forKeys: [.isDirectoryKey])).isDirectory == true

    // /Users/stacia/.local/share/lilac/home/
    let targetDir = targetURL.deletingLastPathComponent()

    try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true)

    defer {
        try? fileManager.removeItem(at: tempURL)
    }

    do {
        if isSourceDirectory {
            try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)

            let files = try Glob.search(
                directory: sourceURL,
                include: include.map { try Glob.Pattern($0) },
                exclude: exclude.map { try Glob.Pattern($0) },
            )

            for try await fileURL in files {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                if resourceValues.isDirectory == true { continue }

                // /Users/stacia/Library/Application Support/Code/User
                // /Users/stacia/Library/Application Support/Code/User/settings.json

                let relativePath = fileURL.path(percentEncoded: false)
                    .trimmingPrefix(sourceURL.path(percentEncoded: false))
                    .trimmingPrefix("/")

                // settings.json

                // /Users/stacia/.local/share/lilac/home/Library/Application Support/Code/User.temp
                let destItemTempURL = tempURL.appending(path: String(relativePath))
                // /Users/stacia/.local/share/lilac/home/Library/Application Support/Code/User.temp-dsada/settings.json

                let destParentDir = destItemTempURL.deletingLastPathComponent()
                // /Users/stacia/.local/share/lilac/home/Library/Application Support/Code/User.temp-dsada/dsadas/settings.json

                try fileManager.createDirectory(
                    at: destParentDir,
                    withIntermediateDirectories: true
                )

                try fileManager.copyItem(at: fileURL, to: destItemTempURL)
            }

        } else {
            try fileManager.copyItem(at: sourceURL, to: tempURL)
        }

        if targetExists {
            // generate a backup name with timestamp to avoid overwriting existing backups
            let timestamp = ISO8601DateFormatter().string(from: Date())
                .replacing(":", with: "")
                .replacing("-", with: "")

            let backupName = "\(targetURL.lastPathComponent)_\(timestamp).bak"

            let replacedURL = try fileManager.replaceItemAt(
                targetURL,
                withItemAt: tempURL,
                backupItemName: backupName,
                options: [.usingNewMetadataOnly],  // withoutDeletingBackupItem
            )

            return replacedURL ?? targetURL
        } else {

            try fileManager.moveItem(at: tempURL, to: targetURL)

            return targetURL
        }

    } catch {
        throw LilacError.copyFailed(source: sourceURL, destination: targetURL, error: error)
    }
}
