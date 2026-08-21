internal import Type_Metadata_Shims

extension Loader {

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
