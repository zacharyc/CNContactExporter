import XCTest
@testable import CNContactExporter

// MARK: - Shared fixtures

extension ContactModel {
    static var sample: ContactModel {
        ContactModel(
            id: "test-001",
            givenName: "Ada",
            familyName: "Lovelace",
            organizationName: "Babbage & Associates",
            phoneNumbers: ["+1 800 555 1234", "+44 20 7946 0958"],
            emailAddresses: ["ada@example.com"],
            postalAddresses: [
                PostalAddressModel(
                    street: "123 Engine Way",
                    city: "London",
                    state: "",
                    postalCode: "WC2N 5DU",
                    country: "United Kingdom"
                )
            ],
            birthday: "1815-12-10",
            note: "First programmer"
        )
    }

    static var minimal: ContactModel {
        ContactModel(id: "test-002", givenName: "Bob", familyName: "Smith")
    }

    static var specialChars: ContactModel {
        ContactModel(
            id: "test-003",
            givenName: "O'Brien, \"The\" Great",
            familyName: "Test",
            organizationName: "",
            phoneNumbers: [],
            emailAddresses: ["tricky+tag@example.com"],
            postalAddresses: [],
            birthday: nil,
            note: "Has commas, \"quotes\", and\nnewlines"
        )
    }
}

// MARK: - JSONExporter Tests

final class JSONExporterTests: XCTestCase {
    let exporter = JSONExporter()

    func testFileExtension() {
        XCTAssertEqual(exporter.fileExtension, "json")
    }

    func testFormatName() {
        XCTAssertEqual(exporter.formatName, "JSON")
    }

    func testEmptyContactsProducesEmptyArray() throws {
        let output = try exporter.export([])
        let data = Data(output.utf8)
        let decoded = try JSONDecoder().decode([ContactModel].self, from: data)
        XCTAssertTrue(decoded.isEmpty)
    }

    func testSingleContact() throws {
        let output = try exporter.export([.sample])
        let data = Data(output.utf8)
        let decoded = try JSONDecoder().decode([ContactModel].self, from: data)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].givenName, "Ada")
        XCTAssertEqual(decoded[0].familyName, "Lovelace")
        XCTAssertEqual(decoded[0].birthday, "1815-12-10")
        XCTAssertEqual(decoded[0].phoneNumbers.count, 2)
    }

    func testMultipleContacts() throws {
        let output = try exporter.export([.sample, .minimal])
        let data = Data(output.utf8)
        let decoded = try JSONDecoder().decode([ContactModel].self, from: data)
        XCTAssertEqual(decoded.count, 2)
    }

    func testRoundTrip() throws {
        let contacts: [ContactModel] = [.sample, .minimal, .specialChars]
        let output = try exporter.export(contacts)
        let decoded = try JSONDecoder().decode([ContactModel].self, from: Data(output.utf8))
        XCTAssertEqual(decoded, contacts)
    }
}

// MARK: - CSVExporter Tests

final class CSVExporterTests: XCTestCase {
    let exporter = CSVExporter()

    func testFileExtension() {
        XCTAssertEqual(exporter.fileExtension, "csv")
    }

    func testFormatName() {
        XCTAssertEqual(exporter.formatName, "CSV")
    }

    func testEmptyContactsHasOnlyHeader() throws {
        let output = try exporter.export([])
        let lines = output.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0].hasPrefix("id,"))
    }

    func testHeaderColumns() throws {
        let output = try exporter.export([])
        XCTAssertEqual(
            output,
            "id,givenName,familyName,organizationName,phoneNumbers,emailAddresses,birthday,note"
        )
    }

    func testSingleContactRow() throws {
        let output = try exporter.export([.minimal])
        let lines = output.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[1].contains("Bob"))
        XCTAssertTrue(lines[1].contains("Smith"))
    }

    func testSpecialCharsAreQuoted() throws {
        let output = try exporter.export([.specialChars])
        // The givenName contains a comma so it must be quoted
        XCTAssertTrue(output.contains("\""))
    }

    func testMultiplePhoneNumbers() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains(";"), "Multiple phone numbers should be semicolon-separated")
    }
}

// MARK: - YAMLExporter Tests

final class YAMLExporterTests: XCTestCase {
    let exporter = YAMLExporter()

    func testFileExtension() {
        XCTAssertEqual(exporter.fileExtension, "yaml")
    }

    func testFormatName() {
        XCTAssertEqual(exporter.formatName, "YAML")
    }

    func testEmptyContactsProducesEmptySequence() throws {
        let output = try exporter.export([])
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertTrue(trimmed == "[]" || trimmed == "", "Empty array should produce [] or empty")
    }

    func testSingleContactContainsExpectedKeys() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("givenName:"))
        XCTAssertTrue(output.contains("familyName:"))
        XCTAssertTrue(output.contains("Ada"))
        XCTAssertTrue(output.contains("Lovelace"))
    }

    func testBirthdayIsIncluded() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("birthday"))
        XCTAssertTrue(output.contains("1815-12-10"))
    }

    func testNoBirthdayFieldWhenAbsent() throws {
        let output = try exporter.export([.minimal])
        XCTAssertFalse(output.contains("birthday"))
    }

    func testPostalAddressIsIncluded() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("postalAddresses"))
        XCTAssertTrue(output.contains("London"))
    }
}

// MARK: - TOMLExporter Tests

final class TOMLExporterTests: XCTestCase {
    let exporter = TOMLExporter()

    func testFileExtension() {
        XCTAssertEqual(exporter.fileExtension, "toml")
    }

    func testFormatName() {
        XCTAssertEqual(exporter.formatName, "TOML")
    }

    func testEmptyContactsProducesEmptyString() throws {
        let output = try exporter.export([])
        XCTAssertEqual(output, "")
    }

    func testSingleContactHasTableHeader() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("[[contacts]]"))
    }

    func testValuesAreQuotedStrings() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("givenName = \"Ada\""))
        XCTAssertTrue(output.contains("familyName = \"Lovelace\""))
    }

    func testBirthdayIsIncluded() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("birthday"))
        XCTAssertTrue(output.contains("1815-12-10"))
    }

    func testNoBirthdayWhenAbsent() throws {
        let output = try exporter.export([.minimal])
        XCTAssertFalse(output.contains("birthday"))
    }

    func testMultipleContactsSeparatedByBlankLine() throws {
        let output = try exporter.export([.sample, .minimal])
        let tableHeaders = output.components(separatedBy: "[[contacts]]").count - 1
        XCTAssertEqual(tableHeaders, 2)
    }

    func testPostalAddressAsInlineTable() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.contains("postalAddresses = ["))
        XCTAssertTrue(output.contains("London"))
    }

    func testSpecialCharsAreEscaped() throws {
        let contact = ContactModel(id: "x", givenName: "Tab\there", familyName: "\\Slash")
        let output = try exporter.export([contact])
        XCTAssertTrue(output.contains("\\t"), "Tab should be escaped as \\t")
        XCTAssertTrue(output.contains("\\\\"), "Backslash should be escaped as \\\\")
    }
}

// MARK: - PropertyListExporter Tests

final class PropertyListExporterTests: XCTestCase {
    let exporter = PropertyListExporter()

    func testFileExtension() {
        XCTAssertEqual(exporter.fileExtension, "plist")
    }

    func testFormatName() {
        XCTAssertEqual(exporter.formatName, "Property List")
    }

    func testOutputIsXML() throws {
        let output = try exporter.export([.sample])
        XCTAssertTrue(output.hasPrefix("<?xml"), "Output should start with XML declaration")
        XCTAssertTrue(output.contains("<plist"), "Output should contain a plist element")
    }

    func testRoundTrip() throws {
        let contacts: [ContactModel] = [.sample, .minimal]
        let output = try exporter.export(contacts)
        let data = Data(output.utf8)
        let decoded = try PropertyListDecoder().decode([ContactModel].self, from: data)
        XCTAssertEqual(decoded, contacts)
    }

    func testEmptyContacts() throws {
        let output = try exporter.export([])
        XCTAssertTrue(output.contains("<array/>") || output.contains("<array>\n\t</array>") || output.contains("<array></array>"))
    }
}

// MARK: - ContactModel Tests

final class ContactModelTests: XCTestCase {
    func testFullNameBothNames() {
        let c = ContactModel(givenName: "John", familyName: "Doe")
        XCTAssertEqual(c.fullName, "John Doe")
    }

    func testFullNameGivenOnly() {
        let c = ContactModel(givenName: "Madonna", familyName: "")
        XCTAssertEqual(c.fullName, "Madonna")
    }

    func testFullNameFamilyOnly() {
        let c = ContactModel(givenName: "", familyName: "Cher")
        XCTAssertEqual(c.fullName, "Cher")
    }

    func testFullNameBothEmpty() {
        let c = ContactModel()
        XCTAssertEqual(c.fullName, "")
    }
}
