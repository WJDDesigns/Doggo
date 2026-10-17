import CoreLocation
import Foundation

/// Demo dogs that wander around so the UI can be built before the real collars are wired up.
actor MockCollarProvider: CollarProvider {
    nonisolated let brand = CollarBrand.mock
    var isConfigured: Bool { true }

    private var dogs: [Dog] = [
        Dog(id: "demo-1", name: "Demo Halo Dog", brand: .mock,
            location: CLLocationCoordinate2D(latitude: 27.9506, longitude: -82.4572), batteryPercent: 82),
        Dog(id: "demo-2", name: "Demo Guardian Dog", brand: .mock,
            location: CLLocationCoordinate2D(latitude: 27.9509, longitude: -82.4566), batteryPercent: 64),
    ]

    func fetchDogs() async throws -> [Dog] {
        for index in dogs.indices {
            guard let location = dogs[index].location else { continue }
            dogs[index].location = CLLocationCoordinate2D(
                latitude: location.latitude + .random(in: -0.00005...0.00005),
                longitude: location.longitude + .random(in: -0.00005...0.00005))
            dogs[index].lastUpdated = .now
        }
        return dogs
    }

    func send(_ command: CollarCommand, to dog: Dog) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}
