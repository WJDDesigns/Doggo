import Foundation
import Observation

@MainActor
@Observable
final class DogStore {
    private(set) var dogs: [Dog] = []
    private(set) var events: [CommandEvent] = []
    private(set) var lastError: String?
    var safety = SafetyPolicy()

    private let providers: [CollarProvider]
    private var lastStatic: [String: Date] = [:]

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
    }

    func send(_ command: CollarCommand, to dog: Dog) async {
        let provider = providers.first { $0.brand == dog.brand }
        do {
            try safety.check(command, lastStatic: lastStatic[dog.id])
            guard let provider else { throw CollarError.notConfigured }
            try await provider.send(command, to: dog)
            if case .staticCorrection = command { lastStatic[dog.id] = .now }
            events.insert(CommandEvent(dogID: dog.id, command: command, date: .now, succeeded: true, detail: nil), at: 0)
        } catch {
            events.insert(CommandEvent(dogID: dog.id, command: command, date: .now, succeeded: false,
                                       detail: error.localizedDescription), at: 0)
        }
    }
}
