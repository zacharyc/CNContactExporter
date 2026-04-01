import Foundation

/// Exports contacts as RFC 4180-compliant CSV.
///
/// Columns: `id`, `givenName`, `familyName`, `organizationName`,
/// `phoneNumbers` (semicolon-separated), `emailAddresses` (semicolon-separated),
/// `birthday`, `note`.
public struct CSVExporter: ContactExporter {
    public let fileExtension = "csv"
    public let formatName = "CSV"

    public init() {}

    public func export(_ contacts: [ContactModel]) throws -> String {
        var rows: [String] = []
        rows.append("id,givenName,familyName,organizationName,phoneNumbers,emailAddresses,birthday,note")

        for contact in contacts {
            let row = [
                escape(contact.id),
                escape(contact.givenName),
                escape(contact.familyName),
                escape(contact.organizationName),
                escape(contact.phoneNumbers.joined(separator: ";")),
                escape(contact.emailAddresses.joined(separator: ";")),
                escape(contact.birthday ?? ""),
                escape(contact.note)
            ].joined(separator: ",")
            rows.append(row)
        }

        return rows.joined(separator: "\n")
    }

    /// Wraps a field in double-quotes if it contains a comma, double-quote, or newline,
    /// and escapes any internal double-quotes by doubling them.
    private func escape(_ value: String) -> String {
        let needsQuoting = value.contains(",") || value.contains("\"") || value.contains("\n")
        guard needsQuoting else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
