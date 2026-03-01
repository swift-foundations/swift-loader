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

#ifndef C_TYPE_METADATA_H
#define C_TYPE_METADATA_H

#include <stddef.h>

#if defined(__cplusplus)
#define CTM_EXTERN extern "C"
#else
#define CTM_EXTERN extern
#endif

#define CTM_SWIFT_NAME(name) __attribute__((swift_name(#name)))

/// Size in bytes of a Swift type metadata record.
CTM_EXTERN const size_t SWTTypeMetadataRecordByteCount;

/// Get the type from a type metadata record if its name contains the given
/// substring.
///
/// - Parameters:
///   - recordAddress: Pointer to a Swift type metadata record in the
///     __swift5_types section.
///   - nameSubstring: String to match against the type's context descriptor
///     name.
/// - Returns: Swift metatype pointer, or NULL if no match.
CTM_EXTERN const void * _Nullable swt_getTypeFromTypeMetadataRecord(
    const void * _Nonnull recordAddress,
    const char * _Nonnull nameSubstring
) CTM_SWIFT_NAME(swt_getType(fromTypeMetadataRecord:ifNameContains:));

#endif
