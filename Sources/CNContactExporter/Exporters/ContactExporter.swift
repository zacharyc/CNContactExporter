import Foundation

/// A type that can export an array of ``ContactModel`` values to a string.
public protocol ContactExporter {
    /// The file extension associated with this export format (e.g. `"json"`, `"csv"`).
    var fileExtension: String { get }

    /// A human-readable name for this format (e.g. `"JSON"`, `"CSV"`).
    var formatName: String { get }

    /// Export the given contacts to a string in the target format.
    /// - Parameter contacts: The contacts to export.
    /// - Returns: A string representation of the contacts.
    /// - Throws: Any error encountered during serialisation.
    func export(_ contacts: [ContactModel]) throws -> String
}
