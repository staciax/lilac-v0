import Foundation
import TOML

public func loadPreset(for name: String, baseURL: URL) async throws -> Preset {
    let presetURL = baseURL.appendingPathComponent("presets/\(name).toml")

    guard FileManager.default.fileExists(atPath: presetURL.path) else {
        throw LilacError.fileNotFound(path: presetURL.path(percentEncoded: false))
    }

    let data = try Data(contentsOf: presetURL)
    
    let decoder = TOMLDecoder()
    let preset = try decoder.decode(Preset.self, from: data)

    return preset
}

public class Preset: Codable {
    public let name: String
    public let aliases: [String]?
    public let paths: PresetPathConfig
    public let filters: FilterConfig?

    public struct PresetPathConfig: Codable {
        public let macOS: String?
        public let linux: String?
        public let windows: String?
    }

    public struct FilterConfig: Codable {
        public let include: [String]?
        public let exclude: [String]?
    }

}

// ----

public class PresetSource {
    let name: String
    init(name: String) {
        self.name = name
    }

}

public class LocalPreset: PresetSource {
    let url: URL
    init(name: String, url: URL) {
        self.url = url

        // Initialization: Initializer Delegation for Class Types
        super.init(name: name)
    }
}

public class RemotePreset: PresetSource {
    let host: String
    let owner: String
    let repo: String
    let ref: String?

    init(name: String, host: String, owner: String, repo: String, ref: String? = nil) {
        self.host = host
        self.owner = owner
        self.repo = repo
        self.ref = ref
        super.init(name: name)
    }

    func buildURL() throws -> URL {
        fatalError("\(#function) must be implemented by subclass of RemotePreset")
    }
}

public class GitHubPreset: RemotePreset {

    // Initialization: Initializer Inheritance
    override func buildURL() throws -> URL {
        var urlString =
            "https://api.github.com/repos/\(owner)/\(repo)/contents/presets/\(name).toml"
        if let ref {
            urlString += "?ref=\(ref)"
        }
        return URL(string: urlString)!
    }
}
