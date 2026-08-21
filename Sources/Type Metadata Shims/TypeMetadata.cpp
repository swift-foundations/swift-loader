#include "CTypeMetadata.h"

#include <cstdint>
#include <cstring>
#include <type_traits>

#pragma mark - Swift ABI

#if defined(__PTRAUTH_INTRINSICS__)
#include <ptrauth.h>
#define SWT_PTRAUTH_SWIFT_TYPE_DESCRIPTOR \
    __ptrauth(ptrauth_key_process_independent_data, 1, 0xae86)
#else
#define SWT_PTRAUTH_SWIFT_TYPE_DESCRIPTOR
#endif

template <typename T, int32_t maskValue = 0>
struct SWTRelativePointer {
private:
    int32_t _offset;

public:
    SWTRelativePointer(const SWTRelativePointer &) = delete;
    SWTRelativePointer(const SWTRelativePointer &&) = delete;
    SWTRelativePointer &operator=(const SWTRelativePointer &) = delete;
    SWTRelativePointer &operator=(const SWTRelativePointer &&) = delete;

    int32_t getRawValue(void) const {
        return _offset;
    }

    const T *_Nullable get(void) const & {
        int32_t maskedOffset = getRawValue() & ~maskValue;
        if (maskedOffset == 0) {
            return nullptr;
        }

        auto offset =
            static_cast<uintptr_t>(static_cast<intptr_t>(maskedOffset));
        auto result = reinterpret_cast<void *>(
            reinterpret_cast<uintptr_t>(this) + offset);
#if defined(__PTRAUTH_INTRINSICS__)
        if (std::is_function_v<T> && result) {
            result =
                ptrauth_strip(result, ptrauth_key_function_pointer);
            result = ptrauth_sign_unauthenticated(
                result, ptrauth_key_function_pointer, 0);
        }
#endif
        return reinterpret_cast<const T *>(result);
    }
};

template <typename T>
struct SWTAbsoluteFunctionPointer {
private:
    T *_pointer;
    static_assert(sizeof(T *) == sizeof(int32_t),
        "Function pointer must be 32-bit when using compact absolute pointer");

public:
    const T *_Nullable get(void) const & {
        return _pointer;
    }
};

template <typename T, typename I,
    int32_t maskValue = (alignof(int32_t) - 1)>
struct SWTRelativePointerIntPair
    : public SWTRelativePointer<T, maskValue> {
    I getInt() const & {
        return I(this->getRawValue() & maskValue);
    }
};

template <typename T>
#if defined(__wasm32__)
using SWTCompactFunctionPointer = SWTAbsoluteFunctionPointer<T>;
#else
using SWTCompactFunctionPointer = SWTRelativePointer<T>;
#endif

struct SWTTypeContextDescriptor {
private:
    uint32_t _flags;
    SWTRelativePointer<void> _parent;
    SWTRelativePointer<char> _name;

    struct MetadataAccessResponse {
        void *value;
        size_t state;
    };
    using MetadataAccessFunction =
        __attribute__((swiftcall)) MetadataAccessResponse(size_t);
    SWTCompactFunctionPointer<MetadataAccessFunction>
        _metadataAccessFunction;

public:
    const char *_Nullable getName(void) const & {
        return _name.get();
    }

    void *_Nullable getMetadata(void) const & {
        if (auto fp = _metadataAccessFunction.get()) {
            return (*fp)(0xFF).value;
        }
        return nullptr;
    }

    bool isGeneric(void) const & {
        return (_flags & 0x80u) != 0;
    }
};

struct SWTTypeMetadataRecord {
private:
    SWTRelativePointerIntPair<void, unsigned int> _pointer;

public:
    const SWTTypeContextDescriptor *_Nullable
    getContextDescriptor(void) const {
        switch (_pointer.getInt()) {
        case 0:
            return reinterpret_cast<
                const SWTTypeContextDescriptor *>(_pointer.get());
        case 1:
            if (auto contextDescriptor = reinterpret_cast<
                    SWTTypeContextDescriptor *const
                        SWT_PTRAUTH_SWIFT_TYPE_DESCRIPTOR *>(
                    _pointer.get())) {
                return *contextDescriptor;
            }
            [[fallthrough]];
        default:
            return nullptr;
        }
    }
};

#pragma mark - Legacy test discovery

const size_t SWTTypeMetadataRecordByteCount = sizeof(SWTTypeMetadataRecord);

const void *swt_getTypeFromTypeMetadataRecord(
    const void *recordAddress, const char *nameSubstring) {
    auto record =
        reinterpret_cast<const SWTTypeMetadataRecord *>(recordAddress);
    auto contextDescriptor = record->getContextDescriptor();
    if (!contextDescriptor) {
        return nullptr;
    } else if (contextDescriptor->isGeneric()) {
        return nullptr;
    }

    const char *typeName = contextDescriptor->getName();
    bool nameOK = typeName && nullptr != std::strstr(typeName, nameSubstring);
    if (!nameOK) {
        return nullptr;
    }

    if (void *typeMetadata = contextDescriptor->getMetadata()) {
        return typeMetadata;
    }

    return nullptr;
}
