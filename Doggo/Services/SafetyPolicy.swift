import Foundation

/// Limits on static correction. Tone and vibrate are never blocked.
struct SafetyPolicy: Codable, Equatable {
    var staticEnabled = false
    var maxStaticLevel = 5
    var cooldownSeconds: TimeInterval = 10

    func check(_ command: CollarCommand, lastStatic: Date?, now: Date = .now) throws {
        guard case .staticCorrection(let level) = command else { return }
        guard staticEnabled else {
            throw CollarError.blockedBySafety("Static is turned off in Settings.")
        }
        guard level <= maxStaticLevel else {
            throw CollarError.blockedBySafety("Static \(level) is above your limit of \(maxStaticLevel).")
        }
        if let lastStatic, now.timeIntervalSince(lastStatic) < cooldownSeconds {
            throw CollarError.blockedBySafety("Wait a few seconds before sending static again.")
        }
    }
}
