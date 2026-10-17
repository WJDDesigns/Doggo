import Foundation

/// Halo One collar. Halo has no public API, so Doggo can't send its tone or vibrate itself.
/// Instead it offers a hand-off: a button that opens the Halo app, where you press Instant Feedback.
/// The collar's status still lives in the Halo app, so this provider only carries the hand-off for now.
struct HaloCollarProvider: CollarProvider {
    let brand = CollarBrand.halo
    var isConfigured: Bool { get async { true } }

    func fetchDogs() async throws -> [Dog] {
        var cooper = Dog(id: "halo-cooper", name: "Cooper", brand: .halo)
        cooper.appHandoff = .halo
        return [cooper]
    }

    func send(_ command: CollarCommand, to dog: Dog) async throws {
        // Doggo never sends to Halo directly; the UI hands off to the Halo app instead.
        throw CollarError.unsupported(command)
    }
}
