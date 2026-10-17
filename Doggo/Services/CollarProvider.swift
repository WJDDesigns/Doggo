import Foundation

enum CollarError: LocalizedError {
    case notConfigured
    case unsupported(CollarCommand)
    case blockedBySafety(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: "This collar isn't connected yet."
        case .unsupported(let command): "\(command.label) isn't supported on this collar."
        case .blockedBySafety(let reason): reason
        }
    }
}

/// One collar brand's connection. Each brand (Halo, PetSafe Guardian) gets its own implementation.
protocol CollarProvider: Sendable {
    var brand: CollarBrand { get }
    var isConfigured: Bool { get async }
    func fetchDogs() async throws -> [Dog]
    func send(_ command: CollarCommand, to dog: Dog) async throws
}
