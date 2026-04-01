import Foundation

/// Exports contacts as JSON using `Foundation`'s `JSONEncoder`.
public struct JSONExporter: ContactExporter {
    public let fileExtension = "json"
    public let formatName = "JSON"

    private let encoder: JSONEncoder

    /// - Parameter prettyPrinted: When `true` (the default), the output is formatted
    ///   for human readability.
    public init(prettyPrinted: Bool = true) {
        let enc = JSONEncoder()
        if prettyPrinted {
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        self.encoder = enc
    }

    public func export(_ contacts: [ContactModel]) throws -> String {
        let data = try encoder.encode(contacts)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
