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

internal import CTypeMetadata

extension Loader {
    /// Enumerates all Swift types whose name contains the given substring.
    ///
    /// Walks the `__swift5_types` section across all loaded images and filters
    /// types by name. Used for legacy test discovery on Swift < 6.3.
    ///
    /// - Parameter substring: The name pattern to match (e.g., `"__🟡$"`).
    /// - Returns: An array of matching Swift metatypes.
    public static func types(
        named substring: some StringProtocol
    ) -> [Any.Type] {
        var result: [Any.Type] = []

        for bounds in Self.Section.all(.swiftTypeMetadata) {
            let buffer = unsafe bounds.buffer
            let stride = SWTTypeMetadataRecordByteCount
            guard stride > 0 else { continue }

            for offset in Swift.stride(from: 0, to: buffer.count, by: stride) {
                guard let baseAddress = buffer.baseAddress else { continue }
                let recordAddress = unsafe baseAddress + offset

                let metatype = unsafe substring.withCString { cString in
                    unsafe swt_getType(
                        fromTypeMetadataRecord: recordAddress,
                        ifNameContains: cString
                    )
                }

                if let metatype = unsafe metatype {
                    result.append(unsafe unsafeBitCast(metatype, to: Any.Type.self))
                }
            }
        }

        return result
    }
}
