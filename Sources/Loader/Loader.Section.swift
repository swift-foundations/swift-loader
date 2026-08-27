public import Loader

#if canImport(Darwin)
    public import Darwin_Loader
#elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
    public import Linux_Loader
#endif

extension Loader.Section {

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
