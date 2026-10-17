import Foundation

/// PetSafe Guardian GPS 2.0 (model RFA-669). Controlled through PetSafe's cloud over LTE; it also has a
/// Bluetooth module that may allow local commands (to be investigated for the ESP32 beacons).
/// Not implemented yet.
struct GuardianCollarProvider: CollarProvider {
    let brand = CollarBrand.petSafeGuardian
    var isConfigured: Bool { get async { false } }

    func fetchDogs() async throws -> [Dog] {
        throw CollarError.notConfigured
    }

    func send(_ command: CollarCommand, to dog: Dog) async throws {
        throw CollarError.notConfigured
    }
}
