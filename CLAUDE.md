# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Run all tests (works on Linux, no Xcode required)
swift test

# Build the package
swift build

# Open in Xcode to run the app
open Package.swift
```

## Architecture

CNContactExporter is a SwiftUI macOS/iOS app that exports system contacts to various file formats.

### Platform Separation

The codebase uses conditional compilation to separate platform-independent and Apple-only code:

- **Platform-independent** (runs on Linux): `ContactModel`, `ContactExporter` protocol, all exporters (JSON, CSV, YAML, TOML, PropertyList)
- **Apple-only** (`#if canImport(Contacts)`): `ContactStore` which wraps `CNContactStore`
- **Apple-only** (`#if canImport(SwiftUI) && canImport(Contacts)`): All SwiftUI views

This allows exporter tests to run on Linux with `swift test`.

### Key Components

- **ContactExporter protocol** (`Exporters/ContactExporter.swift`): Defines `fileExtension`, `formatName`, and `export(_:)` methods that all exporters implement
- **ContactModel** (`Models/ContactModel.swift`): Platform-independent contact representation with `Codable` conformance
- **ContactStore** (`Store/ContactStore.swift`): `@MainActor` observable object that manages CNContacts access and converts to `ContactModel`
- **ExportFormatOption** (`Views/ContentView.swift:176`): Enum that maps UI options to exporter instances

### Adding a New Export Format

1. Create `Sources/CNContactExporter/Exporters/NewExporter.swift` conforming to `ContactExporter`
2. Add a case to `ExportFormatOption` enum in `ContentView.swift`
3. Add tests in `CNContactExporterTests.swift`

## Dependencies

- [Yams](https://github.com/jpsim/Yams) for YAML export
- All other formats use Foundation encoders or built-in implementations
