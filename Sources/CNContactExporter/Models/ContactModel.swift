import Foundation

/// A platform-independent model representing a single contact.
public struct ContactModel: Codable, Identifiable, Sendable, Equatable {
    public let id: String
    public var givenName: String
    public var familyName: String
    public var organizationName: String
    public var phoneNumbers: [String]
    public var emailAddresses: [String]
    public var postalAddresses: [PostalAddressModel]
    public var birthday: String?
    public var note: String

    public init(
        id: String = UUID().uuidString,
        givenName: String = "",
        familyName: String = "",
        organizationName: String = "",
        phoneNumbers: [String] = [],
        emailAddresses: [String] = [],
        postalAddresses: [PostalAddressModel] = [],
        birthday: String? = nil,
        note: String = ""
    ) {
        self.id = id
        self.givenName = givenName
        self.familyName = familyName
        self.organizationName = organizationName
        self.phoneNumbers = phoneNumbers
        self.emailAddresses = emailAddresses
        self.postalAddresses = postalAddresses
        self.birthday = birthday
        self.note = note
    }

    /// The full name formed by joining given and family name.
    public var fullName: String {
        [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

/// A platform-independent model representing a postal address.
public struct PostalAddressModel: Codable, Sendable, Equatable {
    public var street: String
    public var city: String
    public var state: String
    public var postalCode: String
    public var country: String

    public init(
        street: String = "",
        city: String = "",
        state: String = "",
        postalCode: String = "",
        country: String = ""
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}
