import Foundation
import Rainbow

let LilacLogURL = URL(fileURLWithPath: "/Users/stacia/.local/share/lilac/")

public enum LogLevel: UInt8, Sendable {
    case noset = 0
    case debug = 1
    case info = 2
    case warn = 3
    case error = 4
    case critical = 5

    /* Properties: Type Properties */
    static let warning = warn
    static let fatal = critical

    var name: String {
        switch self {
        case .noset: return "NOSET"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warn: return "WARN"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
}

public enum MetadataValue: Sendable {
    case string(String)
    case dictionary([String: MetadataValue])
    case array([MetadataValue])

    var rendered: String {
        switch self {
        case .string(let value):
            return value
        case .dictionary(let value):
            return value.mapValues(\.rendered).description
        case .array(let value):
            return value.map(\.rendered).description
        }
    }
}

public typealias Metadata = [String: MetadataValue]

public struct Record {
    let level: LogLevel
    let name: String
    let message: String
    let timestamp: Date
    let metadata: Metadata
}

enum FormatterError: Error {
    case missingField(key: String, template: String)
    case reservedMetadataKey(key: String)
}

public class Formatter: @unchecked Sendable {

    static let builtInFields: [Substring: @Sendable (Record) -> String] = [
        "timestamp": {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatter.timeZone = .autoupdatingCurrent
            return formatter.string(from: $0.timestamp)
        },
        "level": { $0.level.name.padding(toLength: 8, withPad: " ", startingAt: 0) },
        "name": { $0.name },
        "message": { $0.message },
    ]

    let template: String
    var defaults: Metadata

    public init(template: String, defaults: Metadata? = nil) {
        self.template = template
        self.defaults = defaults ?? [:]
    }

    public subscript(metadataKey key: String) -> MetadataValue? {
        get { defaults[key] }
        set {
            guard !Self.builtInFields.keys.contains(Substring(key)) else { return }
            defaults[key] = newValue
        }
    }

    func decorate(value: String, key: Substring, record: Record) -> String {
        value
    }

    func format(record: Record) throws(FormatterError) -> String {
        if let reservedKey = record.metadata.keys.first(where: {
            Self.builtInFields.keys.contains(Substring($0))
        }) {
            throw FormatterError.reservedMetadataKey(key: reservedKey)
        }

        var result = ""

        var index = template.startIndex
        while index < template.endIndex {
            if template[index] == "{" {
                guard let close = template[index...].firstIndex(of: "}") else {
                    result.append(template[index])
                    index = template.index(after: index)
                    continue
                }

                let keyStart = template.index(after: index)
                let key = template[keyStart..<close]

                result.append(try value(for: key, in: record))

                index = template.index(after: close)
                continue
            }

            result.append(template[index])
            index = template.index(after: index)
        }

        return result
    }

    func value(for key: Substring, in record: Record) throws(FormatterError) -> String {
        let rawValue: String

        // level

        if let converter = Self.builtInFields[key] {
            rawValue = converter(record)
        }

        /* Optional Chaining: Accessing Subscripts Through Optional Chaining*/
        else if let customValue = record.metadata[String(key)]?.rendered {
            rawValue = customValue
        }

        /* Optional Chaining: Accessing Subscripts Through Optional Chaining  */
        else if let value = defaults[String(key)]?.rendered {
            rawValue = value
        } else {
            throw .missingField(
                key: String(key),
                template: self.template,
            )
        }

        return decorate(value: rawValue, key: key, record: record)
    }

}

public typealias ColorTransform = (String, Record) -> String

public class ColourFormatter: Formatter, @unchecked Sendable {

    static let keyColors: [String: @Sendable (String) -> String] = [
        "timestamp": { $0.black },
        "name": { $0.magenta },
    ]

    static let levelColors: [LogLevel: @Sendable (String) -> String] = [
        .info: { $0.blue },
        .debug: { $0.onBlack },
        .warn: { $0.yellow },
        .error: { $0.red },
        .critical: { $0.onRed },
    ]

    override func decorate(value: String, key: Substring, record: Record) -> String {
        if key == "level", let color = Self.levelColors[record.level] {
            return color(value)
        }
        if let color = Self.keyColors[String(key)] {
            return color(value)
        }
        return value
    }
}

public class Handler: @unchecked Sendable {
    let formatter: Formatter

    public init(formatter: Formatter) {
        self.formatter = formatter
    }

    func log(record: Record) throws {
        fatalError("Subclasses must implement the log(record:) method.")
    }
}

public final class StreamHandler: Handler, @unchecked Sendable {
    override func log(record: Record) throws {
        let formattedMessage = try self.formatter.format(record: record)
        print(formattedMessage)
    }
}

public class FileHandler: Handler, @unchecked Sendable {

    let filename: String
    let fileHandle: FileHandle?

    public init(filename: String, formatter: Formatter) {
        self.filename = filename

        let logURL = LilacLogURL.appendingPathComponent(filename)
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: logURL.path) {
            fileManager.createFile(atPath: logURL.path, contents: nil)
        }

        self.fileHandle = try? FileHandle(forWritingTo: logURL)
        _ = try? self.fileHandle?.seekToEnd()

        super.init(formatter: formatter)
    }

    /* deinit */
    deinit {
        try? fileHandle?.close()
    }

    override func log(record: Record) throws {
        var formattedMessage = try self.formatter.format(record: record)
        if !formattedMessage.hasSuffix("\n") {
            formattedMessage += "\n"
        }
        if let data = formattedMessage.data(using: .utf8) {
            fileHandle?.write(data)
        }
    }
}

public class BaseLogger: @unchecked Sendable {
    let label: String
    var handlers: [Handler]

    public init(label: String, handlers: [Handler]? = nil) {
        self.label = label
        self.handlers = handlers ?? []
    }

    func _log(level: LogLevel, message: String, metadata: Metadata = [:]) throws {
        let record = Record(
            level: level,
            name: label,
            message: message,
            timestamp: Date(),
            metadata: metadata
        )
        for handler in handlers {
            try handler.log(record: record)
        }
    }

    public func addHandler(_ handler: Handler) {
        handlers.append(handler)
    }
}

public final class LilacLogger: BaseLogger, @unchecked Sendable {

    // info

    public func info(_ message: String) {
        try? _log(level: .info, message: message)
    }
    public func info(_ message: String, metadata: Metadata = [:]) throws {
        try _log(level: .info, message: message, metadata: metadata)
    }

    // debug

    public func debug(_ message: String) {
        try? _log(level: .debug, message: message)
    }
    public func debug(_ message: String, metadata: Metadata = [:]) throws {
        try _log(level: .debug, message: message, metadata: metadata)
    }

    // warn

    public func warn(_ message: String) {
        try? _log(level: .warn, message: message)
    }
    public func warn(_ message: String, metadata: Metadata = [:]) throws {
        try _log(level: .warn, message: message, metadata: metadata)
    }

    // error

    public func error(_ message: String) {
        try? _log(level: .error, message: message)
    }
    public func error(_ message: String, metadata: Metadata = [:]) throws {
        try _log(level: .error, message: message, metadata: metadata)
    }

    // critical

    public func critical(_ message: String) {
        try? _log(level: .critical, message: message)
    }
    public func critical(_ message: String, metadata: Metadata = [:]) throws {
        try _log(level: .critical, message: message, metadata: metadata)
    }
}
