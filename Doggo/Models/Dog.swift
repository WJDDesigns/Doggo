import CoreLocation
import Foundation

enum CollarBrand: String, Codable, CaseIterable {
    case halo = "Halo"
    case petSafeGuardian = "PetSafe Guardian"
    case mock = "Demo"
}

enum GPSSignal: String, Codable {
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
}

struct Dog: Identifiable, Hashable {
    let id: String
    var name: String
    var brand: CollarBrand
    var location: CLLocationCoordinate2D?
    var batteryPercent: Int?
    var lastUpdated: Date?
    var gpsSignal: GPSSignal?
    var isCharging = false
    /// Set when Doggo can't command this collar directly and hands off to the maker's app (e.g. Halo).
    var appHandoff: AppHandoff? = nil

    static func == (lhs: Dog, rhs: Dog) -> Bool {
        lhs.id == rhs.id && lhs.lastUpdated == rhs.lastUpdated
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Feedback a collar can give. Static carries a level (1...15 on Guardian collars).
enum CollarCommand: Hashable {
    case tone
    case vibrate
    case staticCorrection(level: Int)

    var label: String {
        switch self {
        case .tone: "Tone"
        case .vibrate: "Vibrate"
        case .staticCorrection(let level): "Static \(level)"
        }
    }
}

struct CommandEvent: Identifiable {
    let id = UUID()
    let dogID: String
    let command: CollarCommand
    let date: Date
    let succeeded: Bool
    let detail: String?
    /// Why it was sent when Doggo sent it on its own, e.g. "Left Backyard".
    var reason: String? = nil
}
