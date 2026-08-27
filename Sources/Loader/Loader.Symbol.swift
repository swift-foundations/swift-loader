#if os(Windows)

    import Loader_Vocabulary
    extension Loader.Symbol {

        @inlinable
        public static func lookup(
            name: UnsafePointer<CChar>,
            in scope: Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {
            fatalError("Windows Loader.Symbol.lookup not yet implemented")
        }
    }
#endif
