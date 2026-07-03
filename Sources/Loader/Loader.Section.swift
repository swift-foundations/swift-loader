// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Loader_Primitives

#if canImport(Darwin)
    public import Darwin_Loader
#elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
    public import Linux_Loader
#endif

extension Loader.Section {
    /// All section bounds of the given name across all loaded images.
    ///
    /// ## Lifetime Contract
    ///
    /// The returned bounds are valid only during iteration.
    /// Do not store bounds or capture buffer pointers beyond
    /// the scope of the iteration.
    ///
    /// ## Platform Implementation
    ///
    /// - **Darwin**: Uses dyld `getsectiondata` API
    /// - **Linux**: Uses `swift_enumerateAllMetadataSections`
    /// - **Windows**: Not yet implemented (returns empty)
    ///
    /// ## Example
    ///
    /// ```swift
    /// for bounds in Loader.Section.all(.swiftTestContent) {
    ///     // Process section data - do NOT store bounds
    ///     processSection(bounds.buffer)
    /// }
    /// ```
    @inlinable
    public static func all(_ name: Name) -> some Swift.Sequence<Bounds> {
        #if canImport(Darwin)
            return unsafe Array(Darwin.Loader.Section.all(name))
        #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
            return Linux.Loader.Section.all(name)
        #else
            return EmptyCollection<Bounds>()
        #endif
    }
}
