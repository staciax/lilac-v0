import Foundation

public struct Version: Sendable {
    public var major: Int
    public var minor: Int
    public var patch: Int
    public var prerelease: String?
    public var build: String?

    public var fullVersionString: String {
        var v = "\(major).\(minor).\(patch)-\(prerelease ?? "stable")"
        if let build {
            v += " (\(build))"
        }
        return v
    }

    public var versionString: String {
        "\(major).\(minor).\(patch)"
    }

    // TODO: failable init (maybe parse veersion from string)
}

public struct Lilac: Sendable {
    public let name: String
    public let version: Version
    public let url: URL
}

public let lilac = Lilac(
    name: "Lilac",
    version: Version(major: 0, minor: 0, patch: 1, prerelease: "release", build: nil),
    url: resolvePath(path: "~/.local/share/lilac")
)
