// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

import Loader
import Loader_Test_Support

extension Loader.Section {
    @Suite struct Tests {
        @Suite struct Unit {
            @Test func `type metadata sections are discoverable in the loaded image`() {
                let bounds = Array(Loader.Section.all(.swiftTypeMetadata))

                #if canImport(Darwin) || os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
                    #expect(
                        bounds.isEmpty == false,
                        "A Swift test binary always carries a type metadata section"
                    )
                #else
                    #expect(bounds.isEmpty)
                #endif
            }

            @Test func `every discovered section bound spans a non-empty buffer`() {
                for bound in Loader.Section.all(.swiftTypeMetadata) {
                    let buffer = unsafe bound.buffer
                    #expect(buffer.count > 0)
                    #expect(unsafe buffer.baseAddress != nil)
                }
            }

            @Test func `test content sections enumerate without fault`() {
                var count = 0
                for bound in Loader.Section.all(.swiftTestContent) {
                    #expect(unsafe bound.buffer.count >= 0)
                    count += 1
                }
                #expect(count >= 0)
            }

            @Test func `enumeration is repeatable`() {
                let first = Array(Loader.Section.all(.swiftTypeMetadata)).count
                let second = Array(Loader.Section.all(.swiftTypeMetadata)).count
                #expect(first == second)
            }
        }
    }
}
