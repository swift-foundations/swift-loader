#ifndef C_TYPE_METADATA_H
#define C_TYPE_METADATA_H

#include <stddef.h>

#if defined(__cplusplus)
#define CTM_EXTERN extern "C"
#else
#define CTM_EXTERN extern
#endif

#define CTM_SWIFT_NAME(name) __attribute__((swift_name(#name)))

CTM_EXTERN const size_t SWTTypeMetadataRecordByteCount;

CTM_EXTERN const void * _Nullable swt_getTypeFromTypeMetadataRecord(
    const void * _Nonnull recordAddress,
    const char * _Nonnull nameSubstring
) CTM_SWIFT_NAME(swt_getType(fromTypeMetadataRecord:ifNameContains:));

#endif
