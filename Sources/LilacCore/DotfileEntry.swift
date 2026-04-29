import Foundation
import Rainbow

public class DotfileEntry {

    public enum Kind {
        case symlink
        case copy
    }

    public enum State {
        case unchanged
        case added
        case deleted
        case modified
        case missing

        public struct Symbol {
            public let label: String
            public let color: (String) -> String
        }

        public var symbol: Symbol {
            switch self {
            case .unchanged: return Symbol(label: "-", color: { $0 })
            case .added: return Symbol(label: "Added", color: { $0.green })
            case .deleted: return Symbol(label: "Deleted", color: { $0.red })
            case .modified: return Symbol(label: "Modified", color: { $0.yellow })
            case .missing: return Symbol(label: "Missing", color: { $0.red })
            }
        }

    }

    public struct Status {
        public let source: State
        public let target: State

        public init(source: State, target: State) {
            self.source = source
            self.target = target
        }
    }

    public let sourceURL: URL
    public let targetURL: URL
    public var status: Status?

    public lazy var kind: Kind = {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: targetURL.path(percentEncoded: false)) {
            let targetResourceValues = try? targetURL.resourceValues(forKeys: [.isSymbolicLinkKey])
            let sourceResourceValues = try? sourceURL.resourceValues(forKeys: [.isSymbolicLinkKey])

            if targetResourceValues?.isSymbolicLink == true
                && sourceResourceValues?.isSymbolicLink != true
            {
                return .symlink
            }
        }
        return .copy
    }()

    public init(sourceURL: URL, targetURL: URL) {
        self.sourceURL = sourceURL
        self.targetURL = targetURL
    }

    public convenience init(sourceURL: URL, targetURL: URL, status: Status) {
        self.init(sourceURL: sourceURL, targetURL: targetURL)
        self.status = status
    }

}
