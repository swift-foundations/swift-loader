# swift-loader

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Runtime discovery of Swift types, binary metadata sections, and dynamic-library symbols across every image loaded into a process.

---

## Key Features

- **Process-wide type discovery** — `Loader.types(named:)` walks the compiler-emitted `__swift5_types` metadata records of every loaded image; no registration protocol and no source access to the images required
- **Cross-platform section enumeration** — one `Loader.Section.all(_:)` call resolves to dyld's `getsectiondata` on Darwin and `swift_enumerateAllMetadataSections` on Linux
- **Typed throws end-to-end** — every throwing operation throws `Loader.Error`; no `any Error` escapes the API surface
- **Dynamic-library vocabulary in one import** — `dlopen`/`dlclose`/`dlsym` wrappers for the current platform are re-exported through `import Loader`

---

## Quick Start

Swift has no standard API for asking "which types exist in this process?". `Loader.types(named:)` answers it by scanning the type metadata of the main executable, loaded frameworks, and `dlopen`ed plugins alike:

```swift
import Loader

// Find every non-generic Swift type whose name contains a marker,
// across all images loaded into the process.
let plugins = Loader.types(named: "PluginEntryPoint")

for plugin in plugins {
    print("discovered:", plugin)
}
```

The section walk underneath is public too. `Loader.Section.all(_:)` enumerates a named metadata section across all loaded images behind a single platform-neutral call:

```swift
import Loader

for bounds in Loader.Section.all(.swiftTypeMetadata) {
    // Bounds are valid only during this iteration step — do not store them.
    print("image contributes \(bounds.span.byteCount) bytes of type metadata")
}
```

---

## Installation

Add swift-loader to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-loader.git", branch: "main")
]
```

Add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Loader", package: "swift-loader")
    ]
)
```

### Requirements

- Swift 6.3.1+
- macOS 26.0+, iOS 26.0+, tvOS 26.0+, watchOS 26.0+, visionOS 26.0+, or Linux

---

## Architecture

| Product | When to import |
|---------|----------------|
| `Loader` | The package surface: type discovery, section enumeration, and the dynamic-library vocabulary for the current platform |
| `Loader Test Support` | Test targets; currently a re-export of `Loader` with no additional API |

`Loader` is an umbrella over platform loader stacks: it re-exports the shared `Loader` namespace vocabulary (`Loader.Error`, `Loader.Section.Name`, `Loader.Section.Bounds`, `Loader.Library.Handle`) plus the Darwin stack on Apple platforms and the POSIX + Linux stacks on Linux-family platforms, and adds the process-wide `types(named:)` and `Section.all(_:)` entry points on top.

---

## Platform Support

| Capability | Darwin (macOS, iOS, tvOS, watchOS, visionOS) | Linux, FreeBSD, OpenBSD, Android | Windows |
|------------|----------------------------------------------|----------------------------------|---------|
| `Loader.types(named:)` / `Loader.Section.all(_:)` | dyld `getsectiondata` | `swift_enumerateAllMetadataSections` | Returns empty |
| Symbol lookup (`Loader.Symbol.lookup(name:in:)`) | `dlsym` | `dlsym` via the POSIX loader stack | Traps — not yet implemented |
| Library open/close (`POSIX.Loader.Library`) | `dlopen` / `dlclose` | `dlopen` / `dlclose` | Not available |

Verified by build and test on macOS. The Linux path is implemented but not yet CI-verified; Windows support is stubbed only.

---

## Error Handling

All throwing operations throw `Loader.Error`, a four-case enum whose cases each carry a diagnostic message (typically the `dlerror` text):

```
Loader.Error
├── .open(Message)     // library load failed
├── .close(Message)    // library unload failed
├── .symbol(Message)   // symbol lookup failed
└── .section(Message)  // section enumeration failed
```

```swift
import Loader

do {
    let address = try Loader.Symbol.lookup(name: "swift_demangle", in: .default)
    print("resolved at", address)
} catch .symbol(let message) {
    // Symbol not found — message carries the dlerror text.
    print("lookup failed:", message)
} catch {
    // .open / .close / .section arise from library and section operations.
}
```

The discovery entry points (`Loader.types(named:)`, `Loader.Section.all(_:)`) do not throw; images that contribute no matching section are skipped.

---

## Test Support

The `Loader Test Support` product gives test targets a stable import for loader-backed testing helpers. It currently re-exports `Loader` and adds no API of its own.

---

## Related Packages

### Dependencies

- [swift-loader-primitives](https://github.com/swift-primitives/swift-loader-primitives) — The shared `Loader` namespace vocabulary: `Loader.Error`, `Loader.Section.Name`, `Loader.Section.Bounds`, `Loader.Library.Handle`. Pre-release; no tags yet.
- [swift-posix](https://github.com/swift-foundations/swift-posix) — POSIX loader stack: `dlopen`/`dlclose` wrappers.
- [swift-darwin](https://github.com/swift-foundations/swift-darwin) — Darwin loader stack: dyld section access and `dlsym` symbol lookup.
- [swift-linux](https://github.com/swift-foundations/swift-linux) — Linux loader stack: Swift metadata-section enumeration.

---

## Acknowledgments

The internal `CTypeMetadata` target's type-metadata record walker is ported from [swift-testing](https://github.com/swiftlang/swift-testing)'s `Discovery.cpp` (copyright Apple Inc., Apache License 2.0 with Runtime Library Exception).

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md).
