import Foundation
import Yams

/// Exports contacts as YAML using the [Yams](https://github.com/jpsim/Yams) library.
public struct YAMLExporter: ContactExporter {
    public let fileExtension = "yaml"
    public let formatName = "YAML"

    public init() {}

    public func export(_ contacts: [ContactModel]) throws -> String {
        let dicts = contacts.map { contactToDict($0) }
        return try Yams.dump(object: dicts)
    }

    private func contactToDict(_ contact: ContactModel) -> [String: Any] {
        var dict: [String: Any] = [
            "id": contact.id,
            "givenName": contact.givenName,
            "familyName": contact.familyName,
            "organizationName": contact.organizationName,
            "phoneNumbers": contact.phoneNumbers,
            "emailAddresses": contact.emailAddresses,
            "note": contact.note
        ]
        if let birthday = contact.birthday {
            dict["birthday"] = birthday
        }
        if !contact.postalAddresses.isEmpty {
            dict["postalAddresses"] = contact.postalAddresses.map { addr in
                [
                    "street": addr.street,
                    "city": addr.city,
                    "state": addr.state,
                    "postalCode": addr.postalCode,
                    "country": addr.country
                ] as [String: Any]
            }
        }
        return dict
    }
}
