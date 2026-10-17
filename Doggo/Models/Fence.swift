import CoreLocation
import Foundation

/// What a collar does when the dog walks out of a fence. There is deliberately no static option.
enum BoundaryFeedback: String, Codable, CaseIterable {
    case none
    case tone
    case vibrate

    var label: String {
        switch self {
        case .none: "Nothing"
        case .tone: "Tone"
        case .vibrate: "Vibrate"
        }
    }

    var command: CollarCommand? {
        switch self {
        case .none: nil
        case .tone: .tone
        case .vibrate: .vibrate
        }
    }
}

/// A circular safe zone, like PetSafe's "Backyard" fence.
struct Fence: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double = 40
    var isEnabled = true
    var boundaryFeedback = BoundaryFeedback.vibrate

    init(name: String, center: CLLocationCoordinate2D, radiusMeters: Double = 40) {
        self.name = name
        self.latitude = center.latitude
        self.longitude = center.longitude
        self.radiusMeters = radiusMeters
    }

    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }

    func contains(_ point: CLLocationCoordinate2D) -> Bool {
        let center = CLLocation(latitude: latitude, longitude: longitude)
        return center.distance(from: CLLocation(latitude: point.latitude, longitude: point.longitude)) <= radiusMeters
    }
}

enum FenceStorage {
    private static let key = "fences"

    static func load() -> [Fence] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Fence].self, from: data)) ?? []
    }

    static func save(_ fences: [Fence]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(fences), forKey: key)
    }
}
