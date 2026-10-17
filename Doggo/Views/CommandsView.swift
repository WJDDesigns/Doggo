import SwiftUI

struct CommandsView: View {
    @Environment(DogStore.self) private var store
    @State private var staticLevel = 1

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.dogs) { dog in
                    Section(dog.name) {
                        HStack {
                            Button("Tone") { send(.tone, to: dog) }
                            Spacer()
                            Button("Vibrate") { send(.vibrate, to: dog) }
                        }
                        .buttonStyle(.bordered)
                        if store.safety.staticEnabled {
                            Stepper("Static level \(staticLevel)", value: $staticLevel, in: 1...store.safety.maxStaticLevel)
                            Button("Send static \(staticLevel)", role: .destructive) {
                                send(.staticCorrection(level: staticLevel), to: dog)
                            }
                        }
                    }
                }
                Section("Recent") {
                    ForEach(store.events.prefix(20)) { event in
                        HStack {
                            Image(systemName: event.succeeded ? "checkmark.circle" : "xmark.circle")
                                .foregroundStyle(event.succeeded ? .green : .red)
                            VStack(alignment: .leading) {
                                Text(event.command.label)
                                if let detail = event.detail {
                                    Text(detail).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(event.date, style: .time).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Commands")
        }
    }

    private func send(_ command: CollarCommand, to dog: Dog) {
        Task { await store.send(command, to: dog) }
    }
}
