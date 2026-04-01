import Foundation

/// Exports contacts as TOML (Tom's Obvious Minimal Language).
///
/// Each contact is serialised as an array-of-tables entry (`[[contacts]]`).
/// Postal addresses are represented as TOML inline tables.
public struct TOMLExporter: ContactExporter {
    public let fileExtension = "toml"
    public let formatName = "TOML"

    public init() {}

    public func export(_ contacts: [ContactModel]) throws -> String {
        var lines: [String] = []

        for (index, contact) in contacts.enumerated() {
            lines.append("[[contacts]]")
            lines.append("id = \(tomlString(contact.id))")
            lines.append("givenName = \(tomlString(contact.givenName))")
            lines.append("familyName = \(tomlString(contact.familyName))")
            lines.append("organizationName = \(tomlString(contact.organizationName))")
            lines.append("phoneNumbers = [\(contact.phoneNumbers.map { tomlString($0) }.joined(separator: ", "))]")
            lines.append("emailAddresses = [\(contact.emailAddresses.map { tomlString($0) }.joined(separator: ", "))]")
            if let birthday = contact.birthday {
                lines.append("birthday = \(tomlString(birthday))")
            }
            lines.append("note = \(tomlString(contact.note))")
            if !contact.postalAddresses.isEmpty {
                lines.append("postalAddresses = [\(inlinePostalAddresses(contact.postalAddresses))]")
            }
            if index < contacts.count - 1 {
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }

    private func inlinePostalAddresses(_ addresses: [PostalAddressModel]) -> String {
        addresses.map { addr in
            "{street = \(tomlString(addr.street)), city = \(tomlString(addr.city)), " +
            "state = \(tomlString(addr.state)), postalCode = \(tomlString(addr.postalCode)), " +
            "country = \(tomlString(addr.country))}"
        }.joined(separator: ", ")
    }

    /// Escapes a Swift string value for TOML basic string syntax.
    private func tomlString(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
}
