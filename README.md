# CNContactExporter

Your Contacts should be yours — let's export them.

## Overview

CNContactExporter is a minimal SwiftUI app for macOS and iOS that:

1. **Requests access** to the system Contacts database.
2. **Lists all contacts** in a clean, scrollable view.
3. **Exports contacts** to a variety of open formats via a single toolbar button.

### Supported Export Formats

| Format | Extension | Library |
|---|---|---|
| JSON | `.json` | Foundation (`JSONEncoder`) |
| CSV | `.csv` | Built-in |
| YAML | `.yaml` | [Yams](https://github.com/jpsim/Yams) |
| TOML | `.toml` | Built-in |
| Property List | `.plist` | Foundation (`PropertyListEncoder`) |

## Requirements

- Xcode 15+
- macOS 13+ / iOS 16+
- Swift 5.9+

## Getting Started

```bash
# Clone the repo
git clone https://github.com/zacharyc/CNContactExporter.git
cd CNContactExporter

# Run tests (no Xcode required)
swift test
```

Open `Package.swift` in Xcode to build and run the app.

## Project Structure

```
Sources/CNContactExporter/
├── Models/
│   └── ContactModel.swift          # Platform-independent contact model
├── Exporters/
│   ├── ContactExporter.swift       # Protocol defining the export interface
│   ├── JSONExporter.swift
│   ├── CSVExporter.swift
│   ├── YAMLExporter.swift          # Uses Yams
│   ├── TOMLExporter.swift
│   └── PropertyListExporter.swift
├── Store/
│   └── ContactStore.swift          # CNContacts wrapper (macOS/iOS only)
└── Views/
    ├── CNContactExporterApp.swift   # App entry point
    └── ContentView.swift           # Main list + export UI
Tests/CNContactExporterTests/
└── CNContactExporterTests.swift    # Unit tests for all exporters
```

## Architecture

The exporter logic lives in a platform-independent library layer (`ContactModel` + `ContactExporter` protocol + concrete exporters). This means:

- All exporter tests run on **Linux** with `swift test` — no macOS required.
- The SwiftUI views and `ContactStore` are compiled only on Apple platforms (`#if canImport(SwiftUI)` / `#if canImport(Contacts)`).

## Adding a New Export Format

1. Create `Sources/CNContactExporter/Exporters/MyExporter.swift`.
2. Conform to `ContactExporter` (implement `fileExtension`, `formatName`, and `export(_:)`).
3. Add a case to `ExportFormatOption` in `ContentView.swift`.
4. Add tests in `CNContactExporterTests.swift`.

## License

MIT — see [LICENSE](LICENSE).

