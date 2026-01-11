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

@_exported public import Loader_Primitives

#if canImport(Darwin)
@_exported public import Darwin_Loader
#elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
@_exported public import POSIX_Loader
@_exported public import Linux_Loader
#elseif os(Windows)
// @_exported public import Windows_Loader  // Future
#endif
