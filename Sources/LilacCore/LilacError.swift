import Foundation

public enum LilacError: Swift.Error {
    case fileNotFound(path: String)
    case copyFailed(source: URL, destination: URL, error: Error)
    case destinationExists(path: URL)
    case unsupportedOS(presetName: String, os: String)
}