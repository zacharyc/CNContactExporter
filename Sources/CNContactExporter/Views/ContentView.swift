#if canImport(SwiftUI) && canImport(Contacts)
import SwiftUI

/// The root view: shows a list of contacts and an export toolbar button.
public struct ContentView: View {
    @StateObject private var store = ContactStore()

    public init() {}
    @State private var exportFormat: ExportFormatOption = .json
    @State private var exportedText: String = ""
    @State private var showingExport = false
    @State private var exportError: String?
    @State private var sortOrder = [KeyPathComparator(\ContactModel.fullName)]

    private let exporters: [ExportFormatOption] = ExportFormatOption.allCases

    public var body: some View {
        NavigationStack {
            Group {
                switch store.authorizationStatus {
                case .notDetermined:
                    requestAccessView
                case .authorized:
                    contactTableView
                case .denied, .restricted:
                    accessDeniedView
                @unknown default:
                    accessDeniedView
                }
            }
            .navigationTitle("Contacts: (\(store.contacts.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(exporters) { option in
                            Button(option.title) {
                                exportFormat = option
                                performExport()
                            }
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .disabled(store.contacts.isEmpty)
                }
            }
            .sheet(isPresented: $showingExport) {
                ExportPreviewView(
                    title: exportFormat.title,
                    content: $exportedText
                )
            }
            .alert("Export Error", isPresented: .constant(exportError != nil), actions: {
                Button("OK") { exportError = nil }
            }, message: {
                Text(exportError ?? "")
            })
        }
        .task {
            if store.authorizationStatus == .notDetermined {
                await store.requestAccessAndFetch()
            } else if store.authorizationStatus == .authorized {
                await store.fetch()
            }
        }
    }

    // MARK: - Sub-views

    private var requestAccessView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Contacts Access Required")
                .font(.title2).bold()
            Text("CNContactExporter needs access to your contacts to list and export them.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Allow Access") {
                Task { await store.requestAccessAndFetch() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var accessDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Access Denied")
                .font(.title2).bold()
            Text("Please enable Contacts access in Settings.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var contactListView: some View {
        List(store.contacts) { contact in
            ContactRow(contact: contact)
        }
        .refreshable {
            await store.fetch()
        }
        .overlay {
            if store.contacts.isEmpty {
                ContentUnavailableView("No Contacts", systemImage: "person.crop.circle")
            }
        }
    }

    private var contactTableView: some View {
        Table(store.contacts.sorted(using: sortOrder), sortOrder: $sortOrder) {
            TableColumn("Name", value: \.fullName)
            TableColumn("Company", value: \.organizationName)
            TableColumn("Email") { item in
                Text(item.emailAddresses.joined(separator: ", "))}
            TableColumn("Phone") { item in
                Text(item.phoneNumbers.joined(separator: ", "))
            }
//            TableColumn("email", value: \.emailAddresses.first ?? "")
        }
    }

    // MARK: - Export

    private func performExport() {
        do {
            exportedText = try exportFormat.exporter.export(store.contacts)
            showingExport = true
            print(exportedText.lengthOfBytes(using: .utf8))
        } catch {
            exportError = error.localizedDescription
            print("Error with Export: \(error.localizedDescription)")
        }
    }
}

// MARK: - ContactRow

struct ContactRow: View {
    let contact: ContactModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(contact.fullName.isEmpty ? contact.organizationName : contact.fullName)
                .font(.body)
            if !contact.emailAddresses.isEmpty {
                Text(contact.emailAddresses[0])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !contact.phoneNumbers.isEmpty {
                Text(contact.phoneNumbers[0])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - ExportPreviewView

struct ExportPreviewView: View {
    let title: String
    @Binding var content: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: .constant(content))
                .font(Font.system(.caption, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            .navigationTitle("Export – \(title)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: content)
                }
            }
        }
    }
}

// MARK: - ExportFormatOption

enum ExportFormatOption: String, CaseIterable, Identifiable {
    case json
    case csv
    case yaml
    case toml
    case plist

    var id: String { rawValue }

    var title: String {
        switch self {
        case .json:  return "JSON"
        case .csv:   return "CSV"
        case .yaml:  return "YAML"
        case .toml:  return "TOML"
        case .plist: return "Property List"
        }
    }

    var exporter: any ContactExporter {
        switch self {
        case .json:  return JSONExporter()
        case .csv:   return CSVExporter()
        case .yaml:  return YAMLExporter()
        case .toml:  return TOMLExporter()
        case .plist: return PropertyListExporter()
        }
    }
}

#endif
