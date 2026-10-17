import Foundation

/// Halo One collar. Halo has no public API, so this will talk to the same cloud service the Halo app uses,
/// signed in with the owner's Halo account. Not implemented yet: endpoints still need to be worked out.
struct HaloCollarProvider: CollarProvider {
    let brand = CollarBrand.halo
    var isConfigured: Bool { get async { false } }

    func fetchDogs() async throws -> [Dog] {
        throw CollarError.notConfigured
    }

    func send(_ command: CollarCommand, to dog: Dog) async throws {
        throw CollarError.notConfigured
    }
}
