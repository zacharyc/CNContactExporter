import Foundation

/// Exports contacts as an XML property list using `Foundation`'s `PropertyListEncoder`.
public struct PropertyListExporter: ContactExporter {
    public let fileExtension = "plist"
    public let formatName = "Property List"

    public init() {}

    public func export(_ contacts: [ContactModel]) throws -> String {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(contacts)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
