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

#if os(Windows)

    import Loader_Primitives
    extension Loader.Symbol {
        /// Looks up a symbol by name in the specified scope.
        ///
        /// - Parameters:
        ///   - name: The symbol name (C string).
        ///   - scope: Where to search — `.default` for all loaded images, or a specific handle.
        /// - Returns: Pointer to the symbol.
        /// - Throws: `Loader.Error.symbol` if not found.
        ///
        /// ## Platform Implementation
        ///
        /// - **POSIX (Darwin, Linux):** Uses `dlsym` (via ISO_9945.Loader.Symbol.lookup)
        /// - **Windows:** Uses `GetProcAddress` (future)
        ///
        /// ## Example
        ///
        /// ```swift
        /// let sym = try Loader.Symbol.lookup(name: "myFunction", in: .default)
        /// typealias MyFunc = @convention(c) () -> Int32
        /// let fn = unsafeBitCast(sym, to: MyFunc.self)
        /// ```
        @inlinable
        public static func lookup(
            name: UnsafePointer<CChar>,
            in scope: Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {
            fatalError("Windows Loader.Symbol.lookup not yet implemented")
        }
    }
#endif
