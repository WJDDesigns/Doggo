import Foundation
import Observation

@MainActor
@Observable
final class DogStore {
    private(set) var dogs: [Dog] = []
    private(set) var events: [CommandEvent] = []
    private(set) var lastError: String?
    var safety = SafetyPolicy()
    var fences: [Fence] = FenceStorage.load() {
        didSet { FenceStorage.save(fences) }
    }
    /// Minimum gap between automatic fence cues to the same dog.
    var boundaryCooldownSeconds: TimeInterval = 30

    private let providers: [CollarProvider]
    private var lastStatic: [String: Date] = [:]
    /// The fence each dog was inside at the last refresh. Missing means outside or unknown.
    private var insideFence: [String: Fence.ID] = [:]
    private var lastBoundaryCue: [String: Date] = [:]

    init(providers: [CollarProvider]) {
        self.providers = providers
    }

    func startPolling(every interval: Duration = .seconds(15)) async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: interval)
        }
    }

    func refresh() async {
        var all: [Dog] = []
        for provider in providers where await provider.isConfigured {
            do {
                all += try await provider.fetchDogs()
            } catch {
                lastError = "\(provider.brand.rawValue): \(error.localizedDescription)"
            }
        }
        dogs = all
        await checkBoundaries()
    }

    func send(_ command: CollarCommand, to dog: Dog, reason: String? = nil) async {
        let provider = providers.first { $0.brand == dog.brand }
        do {
            try safety.check(command, lastStatic: lastStatic[dog.id])
            guard let provider else { throw CollarError.notConfigured }
            try await provider.send(command, to: dog)
            if case .staticCorrection = command { lastStatic[dog.id] = .now }
            events.insert(CommandEvent(dogID: dog.id, command: command, date: .now, succeeded: true, detail: nil,
                                       reason: reason), at: 0)
        } catch {
            events.insert(CommandEvent(dogID: dog.id, command: command, date: .now, succeeded: false,
                                       detail: error.localizedDescription, reason: reason), at: 0)
        }
    }

    // MARK: Fences

    func save(_ fence: Fence) {
        if let index = fences.firstIndex(where: { $0.id == fence.id }) {
            fences[index] = fence
        } else {
            fences.append(fence)
        }
    }

    func fence(containing dog: Dog) -> Fence? {
        guard let location = dog.location else { return nil }
        return fences.first { $0.isEnabled && $0.contains(location) }
    }

    /// One line like PetSafe's "Backyard • 5 hrs ago".
    func zoneLine(for dog: Dog) -> String {
        let place: String
        if dog.location == nil {
            place = "Location unknown"
        } else if let fence = fence(containing: dog) {
            place = fence.name
        } else {
            place = fences.contains(where: \.isEnabled) ? "Outside fences" : "No fence"
        }
        guard let updated = dog.lastUpdated else { return place }
        let age = RelativeDateTimeFormatter().localizedString(for: updated, relativeTo: .now)
        return "\(place) • \(age)"
    }

    /// Cues a dog once when it walks out of a fence it was inside. Only tone or vibrate, never static.
    private func checkBoundaries() async {
        for dog in dogs where dog.location != nil {
            let current = fence(containing: dog)
            defer { insideFence[dog.id] = current?.id }
            guard current == nil,
                  let previousID = insideFence[dog.id],
                  let previous = fences.first(where: { $0.id == previousID && $0.isEnabled }),
                  let command = previous.boundaryFeedback.command
            else { continue }
            if let last = lastBoundaryCue[dog.id], Date.now.timeIntervalSince(last) < boundaryCooldownSeconds {
                continue
            }
            lastBoundaryCue[dog.id] = .now
            await send(command, to: dog, reason: "Left \(previous.name)")
        }
    }
}
