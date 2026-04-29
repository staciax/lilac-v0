import Configuration
import ConfigurationTOML
import SystemPackage

public struct LilacLocalConfig: Codable {
    private enum CodingKeys: String, CodingKey {
        case sourceDir = "source-dir"
        case root
    }

    public let sourceDir: String
    public let root: String

    // Initialization: Customizing Initialization
    public init(sourceDir: String, root: String) {
        self.sourceDir = sourceDir
        self.root = root
    }

    // Initialization: Initializer Parameters Without Argument Labels
    public init(_ sourceDir: String) {
        self.init(sourceDir: sourceDir, root: "")
    }

    // Initialization: Initializer Delegation for Value Type
    public init() {
        self.init(sourceDir: "~/.local/share/lilac", root: "")
    }

    static func load() async throws -> Self {
        let lilacURL = lilac.url

        let url = lilacURL.appendingPathComponent("lilac.toml")
        let absoluteFilePath = FilePath(url.path)

        let provider = try await TOMLProvider(filePath: absoluteFilePath)
        let config = ConfigReader(provider: provider)

        return LilacLocalConfig(
            sourceDir: config.string(forKey: "source-dir", default: ""),
            root: config.string(forKey: "root", default: "")
        )
    }
}

public let loadLocalConfig = LilacLocalConfig.load
