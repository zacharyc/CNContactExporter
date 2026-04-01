import Foundation

#if canImport(Contacts)
import Contacts

/// Manages access to the system Contacts store and vends ``ContactModel`` values.
@MainActor
public final class ContactStore: ObservableObject {
    @Published public private(set) var contacts: [ContactModel] = []
    @Published public private(set) var authorizationStatus: CNAuthorizationStatus = .notDetermined
    @Published public private(set) var errorMessage: String?

    private let store = CNContactStore()

    public init() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }

    /// Requests access to Contacts and, if granted, fetches all contacts.
    public func requestAccessAndFetch() async {
        do {
            let granted = try await store.requestAccess(for: .contacts)
            authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            if granted {
                await fetch()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Fetches all contacts from the system store.
    public func fetch() async {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor
            // Note: CNContactNoteKey requires a special entitlement from Apple
        ]

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        let store = self.store

        do {
            let fetched: [ContactModel] = try await Task.detached {
                var results: [ContactModel] = []
                try store.enumerateContacts(with: request) { cnContact, _ in
                    results.append(ContactModel(cnContact: cnContact))
                }
                return results
            }.value
            contacts = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension ContactModel {
    /// Creates a ``ContactModel`` from a `CNContact`.
    init(cnContact: CNContact) {
        self.id = cnContact.identifier
        self.givenName = cnContact.givenName
        self.familyName = cnContact.familyName
        self.organizationName = cnContact.organizationName
        self.phoneNumbers = cnContact.phoneNumbers.map { $0.value.stringValue }
        self.emailAddresses = cnContact.emailAddresses.map { $0.value as String }
        self.postalAddresses = cnContact.postalAddresses.map { labeled in
            let addr = labeled.value
            return PostalAddressModel(
                street: addr.street,
                city: addr.city,
                state: addr.state,
                postalCode: addr.postalCode,
                country: addr.country
            )
        }
        if let components = cnContact.birthday {
            let year = components.year.map { String($0) } ?? "????"
            let month = components.month.map { String(format: "%02d", $0) } ?? "??"
            let day = components.day.map { String(format: "%02d", $0) } ?? "??"
            self.birthday = "\(year)-\(month)-\(day)"
        } else {
            self.birthday = nil
        }
        // Note: Reading notes requires com.apple.developer.contacts.notes entitlement
        self.note = ""
    }
}
#endif
